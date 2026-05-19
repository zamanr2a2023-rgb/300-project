import '../domain/user_session.dart';

abstract class AuthRepository {
  /// Emits whenever sign-in state changes (Firebase `authStateChanges`).
  Stream<UserSession?> authStateChanges();

  Future<UserSession?> restoreSession();

  Future<UserSession> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserSession> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<UserSession> signInWithGoogle();

  Future<void> signOut();
}
