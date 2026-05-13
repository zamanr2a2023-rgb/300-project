import 'dart:async';

import 'auth_repository.dart';
import '../domain/user_session.dart';

/// In-memory auth for demo / widget tests — no Firebase required.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository._();

  static final FakeAuthRepository instance = FakeAuthRepository._();

  /// Broadcast stream that [authSessionProvider] listens to in demo mode.
  static final _controller = StreamController<UserSession?>.broadcast();

  /// Emits the current session immediately (like Firebase `authStateChanges`).
  static Stream<UserSession?> get sessionStream async* {
    yield instance.currentSession;
    yield* _controller.stream;
  }

  UserSession? _session;

  /// Latest session (also the first value on [sessionStream]).
  UserSession? get currentSession => _session;

  void _emit(UserSession? s) {
    _session = s;
    _controller.add(s);
  }

  @override
  Future<UserSession?> restoreSession() async => _session;

  @override
  Future<UserSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final s = UserSession(
      id: 'demo-user',
      email: email,
      displayName: email.split('@').first,
    );
    _emit(s);
    return s;
  }

  @override
  Future<UserSession> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final s = UserSession(
      id: 'demo-user',
      email: email,
      displayName: displayName.trim().isNotEmpty ? displayName.trim() : email.split('@').first,
    );
    _emit(s);
    return s;
  }

  @override
  Future<UserSession> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    const s = UserSession(
      id: 'demo-google',
      email: 'demo@paned.app',
      displayName: 'Demo User',
    );
    _emit(s);
    return s;
  }

  @override
  Future<void> signOut() async {
    _emit(null);
  }
}
