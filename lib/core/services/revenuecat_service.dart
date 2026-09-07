import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../config/revenuecat_config.dart';

/// RevenueCat SDK wrapper for initialization and user identity sync.
class RevenueCatService {
  Future<void>? _initializeFuture;
  String? _linkedUserId;
  bool _configured = false;

  bool get isConfigured => _configured;

  Future<void> initialize() {
    return _initializeFuture ??= _initializeImpl();
  }

  Future<void> _initializeImpl() async {
    if (!RevenueCatConfig.isSupportedPlatform) {
      if (kDebugMode) {
        debugPrint('RevenueCat skipped: unsupported platform.');
      }
      return;
    }

    if (_configured) return;

    try {
      if (await Purchases.isConfigured) {
        _configured = true;
        return;
      }

      final apiKey = RevenueCatConfig.apiKeyForCurrentPlatform();
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;

      if (kDebugMode) {
        debugPrint('RevenueCat configured.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RevenueCat initialization failed: $e');
      }
    }
  }

  Future<void> identifyUser(String firebaseUid) async {
    if (!_configured) return;

    final uid = firebaseUid.trim();
    if (uid.isEmpty) return;
    if (_linkedUserId == uid) return;

    try {
      final currentUserId = await Purchases.appUserID;
      if (currentUserId == uid) {
        _linkedUserId = uid;
        return;
      }

      await Purchases.logIn(uid);
      _linkedUserId = uid;

      if (kDebugMode) {
        debugPrint('RevenueCat user identified.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RevenueCat identifyUser failed: $e');
      }
    }
  }

  Future<void> logOutUser() async {
    if (!_configured) return;

    try {
      if (await Purchases.isAnonymous) {
        _linkedUserId = null;
        return;
      }

      await Purchases.logOut();
      _linkedUserId = null;

      if (kDebugMode) {
        debugPrint('RevenueCat user logged out.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RevenueCat logOutUser failed: $e');
      }
    }
  }

  /// Opens RevenueCat Customer Center for subscription management.
  /// Returns `false` when unavailable (not configured / platform / error).
  Future<bool> presentCustomerCenter() async {
    await initialize();
    if (!_configured || !RevenueCatConfig.isSupportedPlatform) {
      return false;
    }

    try {
      await RevenueCatUI.presentCustomerCenter();
      return true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('RevenueCat Customer Center failed: $e\n$st');
      }
      return false;
    }
  }
}

/// Shared service instance initialized during app startup.
final revenueCatService = RevenueCatService();

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return revenueCatService;
});
