import 'package:firebase_auth/firebase_auth.dart';

import '../domain/user_session.dart';
import 'auth_exception_mapper.dart';

/// Email/password authentication via Firebase Auth.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<UserSession?> get authStateChanges {
    return _auth.authStateChanges().map(_mapUser);
  }

  UserSession? get currentUser => _mapUser(_auth.currentUser);

  Future<UserSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final session = _mapUser(cred.user);
      if (session == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }
      return session;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(mapFirebaseAuthError(e));
    }
  }

  Future<UserSession> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'unknown');
      }
      final name = displayName.trim();
      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
        await user.reload();
      }
      final session = _mapUser(_auth.currentUser);
      if (session == null) {
        throw FirebaseAuthException(code: 'unknown');
      }
      return session;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(mapFirebaseAuthError(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  UserSession? _mapUser(User? user) {
    if (user == null) return null;
    return UserSession(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName?.trim().isNotEmpty == true
          ? user.displayName
          : user.email?.split('@').first,
    );
  }
}

class AuthServiceException implements Exception {
  AuthServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
