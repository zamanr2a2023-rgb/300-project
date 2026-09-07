import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/user_profile.dart';

/// Local profile stream for UI (no Firestore).
class ProfileRepository {
  ProfileRepository();

  static const _dailyGoalKey = 'paned:daily_goal';
  static const defaultDailyGoal = 20;

  final StreamController<void> _goalChanged = StreamController<void>.broadcast();

  Stream<UserProfile?> watchProfile(String uid) async* {
    yield await _loadProfile(uid);
    await for (final _ in _goalChanged.stream) {
      yield await _loadProfile(uid);
    }
  }

  Future<UserProfile> _loadProfile(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getInt(_dailyGoalKey) ?? defaultDailyGoal;
    return UserProfile(
      id: uid,
      displayName: 'Learner',
      avatarEmoji: '🐉',
      dialect: 'North Wales',
      dailyGoal: goal,
    );
  }

  Future<void> updateDailyGoal(String uid, int dailyGoal) async {
    final prefs = await SharedPreferences.getInstance();
    final clamped = dailyGoal.clamp(5, 100);
    await prefs.setInt(_dailyGoalKey, clamped);
    if (!_goalChanged.isClosed) {
      _goalChanged.add(null);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    await updateDailyGoal(profile.id, profile.dailyGoal);
  }
}
