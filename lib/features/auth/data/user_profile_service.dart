import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/user_session.dart';

/// Creates and maintains `users/{uid}` profile documents.
class UserProfileService {
  UserProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> ensureUserDocument(UserSession session) async {
    final ref = _firestore.collection('users').doc(session.id);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.set({
        'email': session.email,
        'displayName': session.displayName ?? session.email.split('@').first,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await ref.set({
      'uid': session.id,
      'email': session.email,
      'displayName': session.displayName ?? session.email.split('@').first,
      'knownCount': 0,
      'sortOfKnowCount': 0,
      'dontKnowCount': 0,
      'weekActivity': List.filled(7, 0),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
