import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_repository_provider.dart';

/// UI state for the auth form — decoupled from LoginScreen widget.
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._ref) : super(const AuthState());

  final Ref _ref;

  Future<void> signInWithEmail(String email, String password) async {
    _loading();
    try {
      await _ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          );
      state = const AuthState();
    } catch (e) {
      _error(e.toString());
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    _loading();
    try {
      await _ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
            displayName: displayName,
          );
      state = const AuthState();
    } catch (e) {
      _error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    _loading();
    try {
      await _ref.read(authRepositoryProvider).signInWithGoogle();
      state = const AuthState();
    } catch (e) {
      _error(e.toString());
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);

  void _loading() => state = const AuthState(isLoading: true);

  void _error(String msg) => state = AuthState(errorMessage: msg);
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref);
});
