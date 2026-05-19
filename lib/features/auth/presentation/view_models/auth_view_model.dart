import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_service.dart';
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
      _error(_messageFor(e));
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
      _error(_messageFor(e));
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);

  String _messageFor(Object e) {
    if (e is AuthServiceException) return e.message;
    return e.toString();
  }

  void _loading() => state = const AuthState(isLoading: true);

  void _error(String msg) => state = AuthState(errorMessage: msg);
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref);
});
