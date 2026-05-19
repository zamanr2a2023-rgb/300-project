import '../domain/user_session.dart';
import 'auth_repository.dart';
import 'auth_service.dart';
import 'user_profile_service.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    AuthService? authService,
    UserProfileService? userProfileService,
  })  : _auth = authService ?? AuthService(),
        _profiles = userProfileService ?? UserProfileService();

  final AuthService _auth;
  final UserProfileService _profiles;

  @override
  Stream<UserSession?> authStateChanges() => _auth.authStateChanges;

  @override
  Future<UserSession?> restoreSession() async => _auth.currentUser;

  @override
  Future<UserSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final session = await _auth.signInWithEmail(
      email: email,
      password: password,
    );
    await _profiles.ensureUserDocument(session);
    return session;
  }

  @override
  Future<UserSession> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final session = await _auth.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
    await _profiles.ensureUserDocument(session);
    return session;
  }

  @override
  Future<UserSession> signInWithGoogle() {
    throw UnsupportedError('Google sign-in is not enabled in this build.');
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
