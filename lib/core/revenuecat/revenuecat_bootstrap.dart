import '../services/revenuecat_service.dart';

/// Initializes RevenueCat once during application startup.
Future<void> initializeRevenueCat() {
  return revenueCatService.initialize();
}
