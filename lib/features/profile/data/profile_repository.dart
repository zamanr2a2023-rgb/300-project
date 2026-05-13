import '../domain/user_profile.dart';

/// Local profile stream for UI (no Firestore).
class ProfileRepository {
  ProfileRepository();

  Stream<UserProfile?> watchProfile(String uid) {
    return Stream<UserProfile>.value(
      UserProfile(
        id: uid,
        displayName: 'Learner',
        avatarEmoji: '🐉',
        dialect: 'Gogledd',
        dailyGoal: 20,
      ),
    );
  }

  Future<void> updateProfile(UserProfile profile) async {}
}
