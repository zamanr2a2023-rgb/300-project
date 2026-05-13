import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../domain/user_profile.dart';
import 'profile_repository_provider.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final session = ref.watch(authSessionProvider).valueOrNull;
  final uid = session?.id;
  if (uid == null) {
    return Stream<UserProfile?>.value(null);
  }
  return ref.read(profileRepositoryProvider).watchProfile(uid);
});
