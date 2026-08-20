import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../../../../core/widgets/paned_logo.dart';
import '../../../../router/routes.dart';
import '../../../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/auth_session_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dots;

  @override
  void initState() {
    super.initState();
    _dots = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true),
    );
    for (var i = 0; i < _dots.length; i++) {
      Future.delayed(Duration(milliseconds: i * 120), () {
        if (mounted) _dots[i].repeat(reverse: true);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    for (final c in _dots) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final watch = Stopwatch()..start();
    try {
      await Future.wait([
        ref.read(authSessionProvider.future),
        ref.read(onboardingCompletedProvider.future),
      ]);
    } catch (_) {}

    final minDelay = 1400 - watch.elapsedMilliseconds;
    if (minDelay > 0) {
      await Future<void>.delayed(Duration(milliseconds: minDelay));
    }
    if (!mounted) return;

    final isAuthed = ref.read(authSessionProvider).valueOrNull != null;
    final hasOnboarded = ref.read(onboardingCompletedProvider).valueOrNull ?? false;

    if (!mounted) return;
    if (isAuthed) {
      context.go(AppRoute.tabHome);
    } else if (!hasOnboarded) {
      context.go(AppRoute.onboarding);
    } else {
      context.go(AppRoute.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshBackground(
        child: SafeArea(
          child: Column(
                children: [
                  const Spacer(flex: 2),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 350),
                    curve: const Cubic(0.2, 0.9, 0.3, 1.2),
                    builder: (context, t, child) {
                      return Transform.scale(
                        scale: 0.92 + 0.08 * t,
                        child: Opacity(opacity: t, child: child),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.leaf.withValues(alpha: 0.3),
                          ),
                        ),
                        const PanedLogo(size: 200),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Paned',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Learn Welsh · Sip by sip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedFg,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(flex: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return AnimatedBuilder(
                        animation: _dots[i < _dots.length ? i : 0],
                        builder: (_, child) {
                          final opacity = 0.3 +
                              (_dots[i < _dots.length ? i : 0].value) * 0.7;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: opacity),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Brewing your lessons…',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.mutedFg,
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
          ),
        ),
      ),
    );
  }
}
