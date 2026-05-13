import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/paned_status_bar.dart';
import '../../../../router/routes.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    await ref.read(onboardingServiceProvider).markCompleted();
    ref.invalidate(onboardingCompletedProvider);
    if (!context.mounted) return;
    context.go(AppRoute.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            const PanedStatusBar(),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedFg,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _continue(context, ref),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mutedFg,
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            // Progress bar (static 2/3 done)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 2 / 3,
                  minHeight: 6,
                  backgroundColor: AppColors.muted,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Headline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Swipe your way\nto fluency.',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.foreground,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Three gestures. Twenty seconds. One round.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.mutedFg,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stacked card preview
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Back card 2 — cream, rotated left
                  Transform.rotate(
                    angle: -0.10,
                    child: Transform.translate(
                      offset: const Offset(-24, 0),
                      child: _PreviewCard(
                        color: AppColors.cream,
                        showBorder: true,
                      ),
                    ),
                  ),
                  // Back card 1 — white, rotated right
                  Transform.rotate(
                    angle: 0.055,
                    child: Transform.translate(
                      offset: const Offset(16, 0),
                      child: _PreviewCard(
                        color: AppColors.card,
                        elevated: true,
                      ),
                    ),
                  ),
                  // Front card — fully detailed
                  _FrontCard(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Gesture legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  _GestureChip(
                    label: "Don't know",
                    sublabel: 'Practice soon',
                    color: AppColors.muted,
                    textColor: AppColors.foreground,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _GestureChip(
                    label: 'Know it ↑',
                    sublabel: 'Mastered',
                    color: AppColors.primary.withValues(alpha: 0.1),
                    textColor: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _GestureChip(
                    label: 'Sort of →',
                    sublabel: 'Review later',
                    color: AppColors.accent.withValues(alpha: 0.1),
                    textColor: AppColors.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // CTA button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _continue(context, ref),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Get started',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.color,
    this.showBorder = false,
    this.elevated = false,
  });

  final Color color;
  final bool showBorder;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 290,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        border: showBorder ? AppColors.ringLeaf : null,
        boxShadow: elevated ? AppColors.shadowSoft : null,
      ),
    );
  }
}

class _FrontCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 290,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.shadowCard,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GREETINGS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.leaf,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('👋', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  'Hello',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welsh: Helo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.mutedFg,
                  ),
                ),
              ],
            ),
          ),
          // Left arrow
          Positioned(
            left: -14,
            top: 0,
            bottom: 0,
            child: Center(child: _ArrowCircle(icon: Icons.arrow_back_rounded, color: AppColors.mutedFg)),
          ),
          // Up arrow (know it)
          Positioned(
            top: -14,
            left: 0,
            right: 0,
            child: Center(child: _ArrowCircle(icon: Icons.arrow_upward_rounded, color: AppColors.primary)),
          ),
          // Right arrow
          Positioned(
            right: -14,
            top: 0,
            bottom: 0,
            child: Center(child: _ArrowCircle(icon: Icons.arrow_forward_rounded, color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _ArrowCircle extends StatelessWidget {
  const _ArrowCircle({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        boxShadow: AppColors.shadowSoft,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _GestureChip extends StatelessWidget {
  const _GestureChip({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.textColor,
  });

  final String label;
  final String sublabel;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                color: AppColors.mutedFg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
