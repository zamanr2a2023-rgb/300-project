import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/user_session.dart';
import '../../features/auth/presentation/providers/auth_session_provider.dart';
import '../services/revenuecat_service.dart';

/// Keeps RevenueCat App User ID in sync with Firebase Auth.
final revenueCatIdentitySyncProvider = Provider<void>((ref) {
  final service = ref.watch(revenueCatServiceProvider);

  ref.listen<AsyncValue<UserSession?>>(
    authSessionProvider,
    (previous, next) {
      next.whenData((session) {
        unawaited(_syncRevenueCatIdentity(service, session));
      });
    },
    fireImmediately: true,
  );
});

Future<void> _syncRevenueCatIdentity(
  RevenueCatService service,
  UserSession? session,
) async {
  try {
    await service.initialize();

    if (session != null) {
      await service.identifyUser(session.id);
      return;
    }

    await service.logOutUser();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('RevenueCat identity sync failed: $e');
    }
  }
}
