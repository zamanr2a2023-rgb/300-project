import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../features/auth/presentation/providers/auth_session_provider.dart';
import '../config/revenuecat_config.dart';
import '../services/revenuecat_service.dart';

/// Reactive CustomerInfo for the signed-in RevenueCat user.
///
/// Reloads when Firebase auth session changes. Use [SubscriptionController]
/// for purchase / restore actions.
final subscriptionControllerProvider =
    AsyncNotifierProvider<SubscriptionController, CustomerInfo?>(
  SubscriptionController.new,
);

/// Convenience: whether `paned_ap_pro` is currently active.
final isPanedProProvider = Provider<bool>((ref) {
  final info = ref.watch(subscriptionControllerProvider).valueOrNull;
  return RevenueCatConfig.hasProEntitlement(info);
});

/// Default offering (`default`), when available.
final defaultOfferingProvider = FutureProvider<Offering?>((ref) async {
  // Keep offering fetch after identity is aligned with auth.
  ref.watch(authSessionProvider);
  return ref.read(revenueCatServiceProvider).getDefaultOffering();
});

/// Monthly package (`$rc_monthly`) from the default offering.
final monthlyPackageProvider = FutureProvider<Package?>((ref) async {
  ref.watch(authSessionProvider);
  return ref.read(revenueCatServiceProvider).getMonthlyPackage();
});

class SubscriptionController extends AsyncNotifier<CustomerInfo?> {
  @override
  Future<CustomerInfo?> build() async {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final service = ref.read(revenueCatServiceProvider);

    await service.initialize();

    if (session != null) {
      await service.identifyUser(session.id);
    } else {
      await service.logOutUser();
    }

    return service.getCustomerInfo();
  }

  /// Reloads CustomerInfo from RevenueCat.
  Future<CustomerInfo?> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(revenueCatServiceProvider).getCustomerInfo(),
    );
    return state.valueOrNull;
  }

  /// Purchases the monthly package (`$rc_monthly` / product `monthly`).
  Future<SubscriptionPurchaseOutcome> purchaseMonthly() async {
    final service = ref.read(revenueCatServiceProvider);
    final outcome = await service.purchaseMonthlyPackage();
    if (outcome.customerInfo != null) {
      state = AsyncData(outcome.customerInfo);
    } else if (outcome.isSuccess) {
      await refresh();
    }
    return outcome;
  }

  /// Restores purchases and updates subscription state.
  Future<CustomerInfo?> restorePurchases() async {
    final service = ref.read(revenueCatServiceProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(service.restorePurchases);
    return state.valueOrNull;
  }

  /// Whether the current [state] has Pro entitlement.
  bool get hasPro => RevenueCatConfig.hasProEntitlement(state.valueOrNull);
}
