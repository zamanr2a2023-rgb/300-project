import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat Public SDK keys and catalog identifiers.
///
/// Store keys: replace `test_...` with real `goog_...` / `appl_...` when Play/App
/// Store apps are connected in the RevenueCat dashboard.
abstract final class RevenueCatConfig {
  static const String androidApiKey = 'test_nVYBPMhxbCQplYeyVHugjqLJMWe';
  static const String iosApiKey = 'test_nVYBPMhxbCQplYeyVHugjqLJMWe';

  /// Dashboard entitlement that unlocks paid access.
  static const String entitlementId = 'paned_ap_pro';

  /// Dashboard offering identifier.
  static const String offeringId = 'default';

  /// Dashboard package identifier for the monthly plan.
  static const String monthlyPackageId = r'$rc_monthly';

  /// Store product identifier (Play / App Store).
  static const String monthlyProductId = 'monthly';

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  static String apiKeyForCurrentPlatform() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => iosApiKey,
      TargetPlatform.android => androidApiKey,
      _ => androidApiKey,
    };
  }

  /// Whether [info] currently has the Paned Pro entitlement.
  static bool hasProEntitlement(CustomerInfo? info) {
    if (info == null) return false;
    return info.entitlements.active.containsKey(entitlementId);
  }
}
