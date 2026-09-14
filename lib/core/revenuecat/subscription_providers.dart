import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../features/auth/domain/user_session.dart';
import '../../features/auth/presentation/providers/auth_session_provider.dart';
import '../config/revenuecat_config.dart';
import '../services/revenuecat_service.dart';

/// Live [CustomerInfo] for the current RevenueCat App User ID.
///
/// Emits `null` when RevenueCat is unavailable (e.g. web / failed configure).
/// Re-fetches when Firebase auth session changes after identity sync.
final customerInfoProvider = StreamProvider<CustomerInfo?>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  final controller = StreamController<CustomerInfo?>.broadcast();

  Future<void> emitLatest() async {
    try {
      await service.initialize();
      if (!service.isConfigured) {
        if (!controller.isClosed) controller.add(null);
        return;
      }
      final info = await service.getCustomerInfo();
      if (!controller.isClosed) controller.add(info);
    } catch (e, st) {
      if (!controller.isClosed) controller.addError(e, st);
    }
  }

  void onCustomerInfo(CustomerInfo info) {
    if (!controller.isClosed) controller.add(info);
  }

  var listenerAttached = false;

  Future<void> attach() async {
    await service.initialize();
    if (!service.isConfigured) {
      if (!controller.isClosed) controller.add(null);
      return;
    }
    if (!listenerAttached) {
      Purchases.addCustomerInfoUpdateListener(onCustomerInfo);
      listenerAttached = true;
    }
    await emitLatest();
  }

  unawaited(attach());

  ref.listen<AsyncValue<UserSession?>>(
    authSessionProvider,
    (previous, next) {
      next.whenData((_) => unawaited(emitLatest()));
    },
  );

  ref.onDispose(() {
    if (listenerAttached) {
      Purchases.removeCustomerInfoUpdateListener(onCustomerInfo);
    }
    unawaited(controller.close());
  });

  return controller.stream;
});

/// True when entitlement [RevenueCatConfig.entitlementId] (`paned_ap_pro`) is active.
final isPanedProProvider = Provider<AsyncValue<bool>>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return ref.watch(customerInfoProvider).whenData(
        (info) => info != null && service.hasProEntitlement(info),
      );
});

/// Default offering (`default`), or null when unavailable / misconfigured.
final defaultOfferingProvider = FutureProvider<Offering?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  try {
    return await service.getDefaultOffering();
  } on RevenueCatUnavailableException {
    return null;
  } on RevenueCatCatalogException {
    return null;
  }
});

/// Monthly package (`$rc_monthly`), or null when unavailable / misconfigured.
final monthlyPackageProvider = FutureProvider<Package?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  try {
    return await service.getMonthlyPackage();
  } on RevenueCatUnavailableException {
    return null;
  } on RevenueCatCatalogException {
    return null;
  }
});

/// Imperative purchase / restore actions (no UI wiring yet).
final subscriptionActionsProvider = Provider<SubscriptionActions>((ref) {
  return SubscriptionActions(ref);
});

class SubscriptionActions {
  SubscriptionActions(this._ref);

  final Ref _ref;

  RevenueCatService get _service => _ref.read(revenueCatServiceProvider);

  /// Purchases the monthly package. Returns updated [CustomerInfo].
  Future<CustomerInfo> purchaseMonthly() {
    return _service.purchaseMonthly();
  }

  /// Restores purchases. Returns updated [CustomerInfo].
  Future<CustomerInfo> restorePurchases() {
    return _service.restorePurchases();
  }

  /// Refreshes [customerInfoProvider] from the network.
  Future<CustomerInfo?> refreshCustomerInfo() async {
    _ref.invalidate(customerInfoProvider);
    return _ref.read(customerInfoProvider.future);
  }
}
