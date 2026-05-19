import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_week.dart';
import '../domain/word_progress.dart';
import '../domain/word_status.dart';

/// Firestore persistence for per-user vocabulary progress.
class ProgressService {
  ProgressService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _progressRef(String uid) =>
      _userRef(uid).collection('progress');

  Future<ProgressMap> fetchProgress(String userId) async {
    final snap = await _progressRef(userId).get();
    final map = <String, WordProgressEntry>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      map[doc.id] = WordProgressEntry(
        status: WordStatus.fromStorage(data['status']),
        reviews: (data['reviewCount'] as num?)?.toInt() ?? 0,
      );
    }
    return map;
  }

  Future<List<int>> fetchWeekActivity(String userId) async {
    final snap = await _userRef(userId).get();
    final raw = snap.data()?['weekActivity'];
    if (raw is List) {
      return raw.map((e) => (e as num).toInt()).toList();
    }
    return List.filled(7, 0);
  }

  Future<void> recordReview({
    required String userId,
    required String wordId,
    required String deckId,
    required WordStatus status,
    required int reviewCount,
  }) async {
    final batch = _firestore.batch();
    final progressDoc = _progressRef(userId).doc(wordId);
    final userDoc = _userRef(userId);

    batch.set(
      progressDoc,
      {
        'wordId': wordId,
        'deckId': deckId,
        'status': status.storageValue,
        'reviewCount': reviewCount,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final userSnap = await userDoc.get();
    var week = List<int>.from(
      (userSnap.data()?['weekActivity'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt()) ??
          List.filled(7, 0),
    );
    if (week.length != 7) {
      week = List.filled(7, 0);
    }
    final todayIdx = DateWeek.todayMondayFirstIndex();
    week[todayIdx] = week[todayIdx] + 1;

    batch.set(
      userDoc,
      {
        'weekActivity': week,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
    await _syncStatusCounts(userId);
  }

  Future<void> _syncStatusCounts(String userId) async {
    final snap = await _progressRef(userId).get();
    var known = 0;
    var sortOf = 0;
    var dontKnow = 0;

    for (final doc in snap.docs) {
      switch (WordStatus.fromStorage(doc.data()['status'])) {
        case WordStatus.known:
          known++;
        case WordStatus.sortOfKnow:
          sortOf++;
        case WordStatus.dontKnow:
          dontKnow++;
        case WordStatus.unseen:
          break;
      }
    }

    await _userRef(userId).set({
      'knownCount': known,
      'sortOfKnowCount': sortOf,
      'dontKnowCount': dontKnow,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
