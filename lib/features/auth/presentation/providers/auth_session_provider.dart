import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/fake_auth_repository.dart';
import '../../domain/user_session.dart';

/// Reactive session stream (demo auth only).
final authSessionProvider = StreamProvider<UserSession?>((ref) {
  return FakeAuthRepository.sessionStream;
});
