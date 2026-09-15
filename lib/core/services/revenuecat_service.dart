import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../config/revenuecat_config.dart';

/// Result of a purchase attempt (includes user-cancel as a non-error outcome).
enum SubscriptionPurchaseStatus {
  success,
  cancelled,
  unavailable,
  failed,
}

class SubscriptionPurchaseOutcome {
  const SubscriptionPurchaseOutcome({
    required this.status,
    this.customerInfo,
    this.message,
  });

  final SubscriptionPurchaseStatus status;
  final CustomerInfo? customerInfo;
  final String? message;

  bool get isSuccess => status == SubscriptionPurchaseStatus.success;
}

/// RevenueCat SDK wrapper: identity, offerings, purchase, restore, entitlements.
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

  /// Latest [CustomerInfo], or `null` when SDK is unavailable.
  Future<CustomerInfo?> getCustomerInfo() async {
    await initialize();
    if (!_configured) return null;

    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RevenueCat getCustomerInfo failed: $e');
      }
      return null;
    }
  }

  /// Whether the current user has [RevenueCatConfig.entitlementId] active.
  Future<bool> hasProEntitlement() async {
    final info = await getCustomerInfo();
    return RevenueCatConfig.hasProEntitlement(info);
  }

  /// Loads all offerings from RevenueCat.
  Future<Offerings?> getOfferings() async {
    await initialize();
    if (!_configured) return null;

    try {
      return await Purchases.getOfferings();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RevenueCat getOfferings failed: $e');
      }
      return null;
    }
  }

  /// Resolves the configured `default` offering (falls back to current).
  Future<Offering?> getDefaultOffering() async {
    final offerings = await getOfferings();
    if (offerings == null) return null;

    return offerings.getOffering(RevenueCatConfig.offeringId) ??
        offerings.current;
  }

  /// Resolves the monthly package (`$rc_monthly`) from the default offering.
  Future<Package?> getMonthlyPackage() async {
    final offering = await getDefaultOffering();
    if (offering == null) return null;

    final byId = offering.getPackage(RevenueCatConfig.monthlyPackageId);
    if (byId != null) return byId;

    if (offering.monthly != null) return offering.monthly;

    for (final package in offering.availablePackages) {
      if (package.storeProduct.identifier ==
              RevenueCatConfig.monthlyProductId ||
          package.identifier == RevenueCatConfig.monthlyPackageId) {
        return package;
      }
    }
    return null;
  }

  /// Purchases the monthly package. User cancel is a normal [cancelled] outcome.
  Future<SubscriptionPurchaseOutcome> purchaseMonthlyPackage() async {
    await initialize();
    if (!_configured || !RevenueCatConfig.isSupportedPlatform) {
      return const SubscriptionPurchaseOutcome(
        status: SubscriptionPurchaseStatus.unavailable,
        message: 'Subscriptions are unavailable on this device.',
      );
    }

    final package = await getMonthlyPackage();
    if (package == null) {
      return const SubscriptionPurchaseOutcome(
        status: SubscriptionPurchaseStatus.unavailable,
        message:
            'Monthly plan is not available yet. Check RevenueCat offerings.',
      );
    }

    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      return SubscriptionPurchaseOutcome(
        status: SubscriptionPurchaseStatus.success,
        customerInfo: result.customerInfo,
      );
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return const SubscriptionPurchaseOutcome(
          status: SubscriptionPurchaseStatus.cancelled,
        );
      }
      if (kDebugMode) {
        debugPrint('RevenueCat purchaseMonthlyPackage failed: $e');
      }
      return SubscriptionPurchaseOutcome(
        status: SubscriptionPurchaseStatus.failed,
        message: e.message ?? 'Purchase failed.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RevenueCat purchaseMonthlyPackage failed: $e');
      }
      return SubscriptionPurchaseOutcome(
        status: SubscriptionPurchaseStatus.failed,
        message: e.toString(),
      );
    }
  }

  /// Restores previous purchases and returns updated [CustomerInfo].
  Future<CustomerInfo?> restorePurchases() async {
    await initialize();
    if (!_configured) return null;

    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RevenueCat restorePurchases failed: $e');
      }
      rethrow;
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
