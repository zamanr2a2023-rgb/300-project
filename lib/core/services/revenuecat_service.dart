import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../config/revenuecat_config.dart';

/// Thrown when RevenueCat is unavailable (unsupported platform / failed configure).
class RevenueCatUnavailableException implements Exception {
  RevenueCatUnavailableException([
    this.message = 'RevenueCat is not available on this device.',
  ]);

  final String message;

  @override
  String toString() => 'RevenueCatUnavailableException: $message';
}

/// Thrown when the expected offering/package is missing from the dashboard catalog.
class RevenueCatCatalogException implements Exception {
  RevenueCatCatalogException(this.message);

  final String message;

  @override
  String toString() => 'RevenueCatCatalogException: $message';
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

  Future<void> _ensureConfigured() async {
    await initialize();
    if (!_configured || !RevenueCatConfig.isSupportedPlatform) {
      throw RevenueCatUnavailableException();
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

  /// Loads all offerings from RevenueCat.
  Future<Offerings> getOfferings() async {
    await _ensureConfigured();
    return Purchases.getOfferings();
  }

  /// Resolves the `default` offering, falling back to the dashboard current offering.
  Future<Offering> getDefaultOffering() async {
    final offerings = await getOfferings();
    final offering = offerings.getOffering(RevenueCatConfig.offeringId) ??
        offerings.current;
    if (offering == null) {
      throw RevenueCatCatalogException(
        'Offering "${RevenueCatConfig.offeringId}" was not found, '
        'and no current offering is configured.',
      );
    }
    return offering;
  }

  /// Resolves the monthly package (`$rc_monthly` / monthly product).
  Future<Package> getMonthlyPackage() async {
    final offering = await getDefaultOffering();

    final byPackageId = offering.getPackage(RevenueCatConfig.monthlyPackageId);
    if (byPackageId != null) return byPackageId;

    final monthly = offering.monthly;
    if (monthly != null) return monthly;

    for (final package in offering.availablePackages) {
      if (package.storeProduct.identifier == RevenueCatConfig.monthlyProductId) {
        return package;
      }
    }

    throw RevenueCatCatalogException(
      'Monthly package "${RevenueCatConfig.monthlyPackageId}" '
      '(product "${RevenueCatConfig.monthlyProductId}") was not found '
      'in offering "${offering.identifier}".',
    );
  }

  /// Latest [CustomerInfo] for the current App User ID.
  Future<CustomerInfo> getCustomerInfo() async {
    await _ensureConfigured();
    return Purchases.getCustomerInfo();
  }

  /// Whether [info] currently unlocks [RevenueCatConfig.entitlementId].
  bool hasProEntitlement(CustomerInfo info) {
    return info.entitlements.active.containsKey(RevenueCatConfig.entitlementId);
  }

  /// Convenience: fetch CustomerInfo and check `paned_ap_pro`.
  Future<bool> isProActive() async {
    final info = await getCustomerInfo();
    return hasProEntitlement(info);
  }

  /// Purchases the monthly package from the default offering.
  ///
  /// Store cancellation surfaces as a [PurchasesError] — treat cancel as non-fatal.
  Future<CustomerInfo> purchaseMonthly() async {
    final package = await getMonthlyPackage();
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  /// Restores previous purchases for the current App User ID.
  Future<CustomerInfo> restorePurchases() async {
    await _ensureConfigured();
    return Purchases.restorePurchases();
  }
}

/// Shared service instance initialized during application startup.
final revenueCatService = RevenueCatService();

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return revenueCatService;
});
