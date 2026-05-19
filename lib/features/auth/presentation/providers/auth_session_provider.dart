import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/user_session.dart';
import 'auth_repository_provider.dart';

/// Reactive session from Firebase Auth `authStateChanges`.
final authSessionProvider = StreamProvider<UserSession?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
