import 'package:flutter/foundation.dart';

/// RevenueCat Public SDK keys and catalog identifiers.
///
/// Replace [androidApiKey] / [iosApiKey] with store keys (`goog_` / `appl_`)
/// once Google Play / App Store apps are connected in the RevenueCat dashboard.
abstract final class RevenueCatConfig {
  /// Test Store key until Play/App Store SDK keys are available.
  static const String androidApiKey = 'test_nVYBPMhxbCQplYeyVHugjqLJMWe';
  static const String iosApiKey = 'test_nVYBPMhxbCQplYeyVHugjqLJMWe';

  /// Dashboard entitlement that unlocks Paned Pro.
  static const String entitlementId = 'paned_ap_pro';

  /// Dashboard offering identifier.
  static const String offeringId = 'default';

  /// Dashboard package identifier for the monthly plan.
  static const String monthlyPackageId = r'$rc_monthly';

  /// Store product identifier for the monthly subscription.
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
}
