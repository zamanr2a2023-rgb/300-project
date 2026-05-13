import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/user_session.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/providers/auth_session_provider.dart';
import '../features/dashboard/presentation/screens/dashboard_shell.dart';
import '../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// GoRouter with auth + onboarding redirects.
/// Refresh fires whenever [authSessionProvider] or [onboardingCompletedProvider] emit.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);

  ref.listen<AsyncValue<UserSession?>>(
    authSessionProvider,
    (prev, next) => refresh.value++,
  );
  ref.listen<AsyncValue<bool>>(
    onboardingCompletedProvider,
    (prev, next) => refresh.value++,
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);

      final auth = container.read(authSessionProvider);
      final onboardingAsync = container.read(onboardingCompletedProvider);

      final loc = state.matchedLocation;
      final onSplash = loc == AppRoute.splash;
      final onAuth = loc.startsWith('/auth');
      final onOnboarding = loc == AppRoute.onboarding;
      final onDashboard = loc.startsWith('/tab');

      // Wait for both auth and onboarding to resolve before redirecting away from splash.
      if (auth.isLoading || auth.isRefreshing || onboardingAsync.isLoading) {
        if (onSplash) return null;
        return AppRoute.splash;
      }

      final isAuthed = auth.valueOrNull != null;
      final hasOnboarded = onboardingAsync.valueOrNull ?? false;

      // Authenticated users always go to the dashboard.
      if (isAuthed) {
        if (onDashboard) return null;
        return AppRoute.tabHome;
      }

      // Unauthenticated — show onboarding first.
      if (!hasOnboarded) {
        if (onOnboarding) return null;
        return AppRoute.onboarding;
      }

      // Onboarded but not authed — show login.
      if (onAuth) return null;
      return AppRoute.login;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoute.onboarding,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoute.login,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoute.tabHome,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: DashboardShell(),
        ),
      ),
    ],
  );
});
