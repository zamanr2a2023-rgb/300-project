import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/paned_status_bar.dart';
import '../../../learning/domain/learning_math.dart';
import '../../../learning/presentation/view_models/learning_view_model.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

class ProgressTabScreen extends ConsumerWidget {
  const ProgressTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningAsync = ref.watch(learningViewModelProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return learningAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('$e')),
      ),
      data: (state) {
        final summary = LearningMath.summarizeProgress(state.progress);
        final streak = state.streak;
        final profile = profileAsync.valueOrNull;
        final firstName =
            (profile?.displayName ?? 'you').split(' ').first;
        final goal = profile?.dailyGoal ?? 20;
        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        final weekActivity = state.weekActivity;
        final max = weekActivity.reduce((a, b) => a > b ? a : b);
        final safeMax = max == 0 ? 1 : max;
        final todayIdx = (DateTime.now().weekday - 1) % 7;
        final totalThisWeek = weekActivity.fold(0, (a, b) => a + b);
        final todayCount = weekActivity[todayIdx];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false,
            bottom: true,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: PanedStatusBar()),
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR JOURNEY',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.leaf,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Well done, $firstName.',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.foreground,
                          ),
                        ),
                        Text(
                          "You're brewing a great habit.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.mutedFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                // Big stat cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      children: [
                        _BigStat(
                          icon: Icons.local_fire_department_rounded,
                          value: '$streak',
                          sub: 'day streak',
                          tone: _StatTone.accent,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _BigStat(
                          icon: Icons.emoji_events_rounded,
                          value: '${summary.learned}',
                          sub: 'words learned',
                          tone: _StatTone.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                // Weekly bar chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: AppColors.ringLeaf,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'This week',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.foreground,
                                ),
                              ),
                              Text(
                                '$totalThisWeek reviews',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.mutedFg,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            height: 112,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(7, (i) {
                                final isToday = i == todayIdx;
                                final filled = weekActivity[i] / safeMax;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 3),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              // Background bar
                                              Expanded(
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  children: [
                                                    // Gray background
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary
                                                            .withValues(alpha: 0.12),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .vertical(
                                                          top: Radius.circular(6),
                                                        ),
                                                      ),
                                                    ),
                                                    // Filled portion
                                                    FractionallySizedBox(
                                                      heightFactor:
                                                          filled.clamp(0.0, 1.0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: isToday
                                                              ? AppColors.accent
                                                              : AppColors.primary,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .vertical(
                                                            top: Radius.circular(6),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          days[i],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isToday
                                                ? AppColors.accent
                                                : AppColors.mutedFg,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                // Achievements header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text(
                      'Achievements',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

                // Badge grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverGrid.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    children: [
                      _Badge(emoji: '🐉', label: 'First dragon', earned: summary.learned >= 1),
                      _Badge(emoji: '🔥', label: '7-day Sip', earned: streak >= 7),
                      _Badge(emoji: '📚', label: '50 words', earned: summary.learned >= 50),
                      _Badge(emoji: '⛰️', label: 'Mountain', earned: summary.learned >= 10),
                      _Badge(emoji: '🌊', label: 'Sea', earned: summary.learned >= 20),
                      _Badge(emoji: '💎', label: '30-day', earned: streak >= 30),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                // Daily goal card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.track_changes_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily goal',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.foreground,
                                  ),
                                ),
                                Text(
                                  '$todayCount / $goal reviews today',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.mutedFg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.calendar_today_rounded,
                              size: 16, color: AppColors.mutedFg),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────

enum _StatTone { primary, accent }

class _BigStat extends StatelessWidget {
  const _BigStat({
    required this.icon,
    required this.value,
    required this.sub,
    required this.tone,
  });

  final IconData icon;
  final String value;
  final String sub;
  final _StatTone tone;

  @override
  Widget build(BuildContext context) {
    final bg = tone == _StatTone.accent ? AppColors.accent : AppColors.primary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.shadowSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.emoji, required this.label, required this.earned});

  final String emoji;
  final String label;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: earned ? AppColors.card : AppColors.muted,
        borderRadius: BorderRadius.circular(18),
        border: earned ? AppColors.ringLeaf : null,
      ),
      child: Opacity(
        opacity: earned ? 1.0 : 0.45,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedFg,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
