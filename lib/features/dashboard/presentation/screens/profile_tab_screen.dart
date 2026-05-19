import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/paned_status_bar.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../../content/presentation/providers/words_catalog_provider.dart';
import '../../../learning/domain/learning_math.dart';
import '../../../learning/presentation/view_models/learning_view_model.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningAsync = ref.watch(learningViewModelProvider);
    final catalogAsync = ref.watch(wordsCatalogProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final session = ref.watch(authSessionProvider).valueOrNull;

    final profile = profileAsync.valueOrNull;
    final displayName = profile?.displayName ?? session?.displayName ?? 'Learner';
    final email = session?.email ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    final vocabularyTotal = catalogAsync.valueOrNull?.all.length ?? 0;
    final summary = learningAsync.valueOrNull != null
        ? LearningMath.summarizeProgress(
            learningAsync.valueOrNull!.progress,
            vocabularyTotal: vocabularyTotal,
          )
        : (learned: 0, learning: 0, total: 0, pct: 0);
    final streak = learningAsync.valueOrNull?.streak ?? 0;
    final level = (summary.learned ~/ 10 + 1).clamp(1, 999);

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.foreground,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: AppColors.ringLeaf,
                      ),
                      child: Icon(Icons.settings_outlined,
                          size: 18, color: AppColors.foreground),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // Avatar
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.leaf],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: AppColors.shadowCard,
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              boxShadow: AppColors.shadowSoft,
                            ),
                            child: Center(
                              child: Text(
                                profile?.avatarEmoji ?? '🐉',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.mutedFg,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              size: 13, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            'Level $level',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // Mini stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    _MiniStat(value: '${summary.learned}', label: 'Words'),
                    const SizedBox(width: AppSpacing.sm),
                    _MiniStat(value: '$streak', label: 'Streak'),
                    const SizedBox(width: AppSpacing.sm),
                    _MiniStat(value: 'Lv $level', label: 'Level'),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // Settings list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: AppColors.ringLeaf,
                  ),
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.notifications_outlined,
                        label: 'Daily reminder',
                        value: '08:30',
                      ),
                      _SettingsRow(
                        icon: Icons.language_rounded,
                        label: 'Dialect',
                        value: profile?.dialect ?? 'North Wales',
                      ),
                      _SettingsRow(
                        icon: Icons.favorite_outline_rounded,
                        label: 'Invite a friend',
                      ),
                      _SettingsRow(
                        icon: Icons.logout_rounded,
                        label: 'Log out',
                        danger: true,
                        onTap: () async {
                          final repo = ref.read(authRepositoryProvider);
                          await repo.signOut();
                          ref.invalidate(learningViewModelProvider);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // Support card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.shadowSoft,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.cream.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('☕', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buy us a cuppa',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Support Welsh language learning',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Tip',
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
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: AppColors.ringLeaf,
        ),
        child: Column(
          children: [
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
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLast = label == 'Log out';
    final color = danger ? const Color(0xFFC94A1E) : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? const Radius.circular(24) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: danger
                    ? const Color(0xFFC94A1E).withValues(alpha: 0.1)
                    : AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: danger ? const Color(0xFFC94A1E) : AppColors.foreground,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.mutedFg,
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.mutedFg),
          ],
        ),
      ),
    );
  }
}
