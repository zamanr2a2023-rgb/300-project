import 'package:flutter/foundation.dart';

/// RevenueCat Public SDK keys (test keys for development).
abstract final class RevenueCatConfig {
  static const String androidApiKey = 'test_nVYBPMhxbCQplYeyVHugjqLJMWe';
  static const String iosApiKey = 'test_nVYBPMhxbCQplYeyVHugjqLJMWe';

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
