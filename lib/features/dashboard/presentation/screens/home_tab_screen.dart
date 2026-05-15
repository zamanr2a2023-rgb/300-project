import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/paned_logo.dart';
import '../../../../core/widgets/paned_status_bar.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../../content/presentation/providers/words_catalog_provider.dart';
import '../../../learning/domain/learning_math.dart';
import '../../../learning/presentation/view_models/learning_view_model.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../providers/dashboard_tab_provider.dart';
import '../providers/selected_deck_provider.dart';
import '../widgets/deck_card.dart';
import 'all_decks_screen.dart';

class HomeTabScreen extends ConsumerWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningAsync = ref.watch(learningViewModelProvider);
    final catalogAsync = ref.watch(wordsCatalogProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final session = ref.watch(authSessionProvider).valueOrNull;

    final displayName = profileAsync.valueOrNull?.displayName
        ?? session?.displayName
        ?? 'Learner';

    if (catalogAsync.isLoading || learningAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (catalogAsync.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: ${catalogAsync.error}')),
      );
    }
    if (learningAsync.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: ${learningAsync.error}')),
      );
    }

    final catalog = catalogAsync.value!;
    final state = learningAsync.value!;

    final summary = LearningMath.summarizeProgress(
      state.progress,
      vocabularyTotal: catalog.all.length,
    );
    final streak = state.streak;
    final accuracy = (summary.learned + summary.learning) > 0
        ? ((summary.learned / (summary.learned + summary.learning)) * 100)
            .round()
        : 0;

    final decks = buildDeckCards(state.progress, catalog);

    void openDeck(String deckId) {
      ref.read(selectedDeckIdProvider.notifier).state = deckId;
      ref.read(panedDashboardTabIndexProvider.notifier).state = 1;
    }

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
                    child: Row(
                      children: [
                        // Logo + name
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: AppColors.ringLeaf,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const PanedLogo(size: 36),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good morning,',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.mutedFg,
                                ),
                              ),
                              Text(
                                displayName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.foreground,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Streak badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_fire_department_rounded,
                                  size: 14, color: AppColors.accent),
                              const SizedBox(width: 3),
                              Text(
                                '$streak',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                            border: AppColors.ringLeaf,
                          ),
                          child: Icon(Icons.notifications_none_rounded,
                              size: 18, color: AppColors.foreground),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                // Hero card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _HeroCard(
                      learned: summary.learned,
                      streak: streak,
                      onStart: () => openDeck(ref.read(selectedDeckIdProvider)),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                // Stat grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      children: [
                        _StatCard(
                          icon: Icons.emoji_events_rounded,
                          value: '${summary.learned}',
                          label: 'Words',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatCard(
                          icon: Icons.auto_awesome_rounded,
                          value: '$accuracy%',
                          label: 'Accuracy',
                          tone: _Tone.accent,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatCard(
                          icon: Icons.local_fire_department_rounded,
                          value: '${streak}d',
                          label: 'Streak',
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

                // Deck list header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your decks',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.foreground,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const AllDecksScreen(),
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            'See all',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

                // Deck items
                SliverList.separated(
                  itemCount: decks.length,
                  separatorBuilder: (_, index) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, i) {
                    final d = decks[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: DeckCardTile(
                        deck: d,
                        onTap: () => openDeck(d.id),
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
  }

}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.learned,
    required this.streak,
    required this.onStart,
  });
  final int learned;
  final int streak;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final pct = (learned / 3000).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S LESSON",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.onPrimary.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.onPrimary,
              ),
              children: [
                const TextSpan(text: "You've marked "),
                TextSpan(
                  text: '$learned',
                  style: TextStyle(color: AppColors.cream),
                ),
                const TextSpan(text: ' words as known'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Goal: 3,000 words to fluency',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor:
                            AppColors.onPrimary.withValues(alpha: 0.2),
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.cream),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$learned / 3,000 · ${(pct * 100).round()}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onStart,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.shadowSoft,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        learned > 0 ? 'Continue' : 'Start',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _Tone { primary, accent }

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.tone = _Tone.primary,
  });

  final IconData icon;
  final String value;
  final String label;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final color = tone == _Tone.accent ? AppColors.accent : AppColors.primary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: AppColors.ringLeaf,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.foreground,
              ),
            ),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedFg,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
