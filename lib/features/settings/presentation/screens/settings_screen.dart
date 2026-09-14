import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/config/app_links_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/reminders/daily_reminder_provider.dart';
import '../../../../core/reminders/daily_reminder_settings.dart';
import '../../../../core/reminders/daily_reminder_sheet.dart';
import '../../../../core/services/invite_share_service.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../../core/services/url_launch_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../../profile/presentation/widgets/daily_goal_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder =
        ref.watch(dailyReminderSettingsProvider).valueOrNull ??
            DailyReminderSettings.defaults;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final dailyGoal = profile?.dailyGoal ?? ProfileRepository.defaultDailyGoal;
    final versionAsync = ref.watch(_appVersionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: AppColors.ringLeaf,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.foreground,
                          ),
                        ),
                        Text(
                          'Manage your Paned preferences',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.mutedFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                children: [
                  const _SectionHeading('Learning'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.track_changes_rounded,
                        title: 'Daily Goal',
                        subtitle: 'Learning target',
                        trailing: '$dailyGoal words',
                        onTap: () => showDailyGoalSheet(
                          context: context,
                          ref: ref,
                          currentGoal: dailyGoal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _SectionHeading('Notifications'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Daily Reminder',
                        subtitle: 'Welsh learning reminder',
                        trailing: reminder.enabled ? 'Active' : 'Off',
                        statusActive: reminder.enabled,
                        onTap: () => showDailyReminderSheet(
                          context: context,
                          ref: ref,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.schedule_rounded,
                        title: 'Reminder Time',
                        subtitle: 'Europe/London',
                        trailing: '${reminder.formattedTimeAmPm} UK',
                        onTap: () => showDailyReminderSheet(
                          context: context,
                          ref: ref,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _SectionHeading('Subscription'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.workspace_premium_outlined,
                        title: 'Manage Subscription',
                        subtitle: 'Plans and billing',
                        onTap: () => _openManageSubscription(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _SectionHeading('Support'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.favorite_outline_rounded,
                        title: 'Invite a Friend',
                        subtitle: 'Share Paned with friends',
                        onTap: () => _shareInvite(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _SectionHeading('Legal'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.shield_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'How we handle your data',
                        onTap: () => _openConfiguredUrl(
                          context,
                          ref,
                          url: AppLinksConfig.privacyPolicyUrl,
                          missingMessage:
                              'Privacy Policy link is not configured yet.',
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        subtitle: 'Rules for using Paned',
                        onTap: () => _openConfiguredUrl(
                          context,
                          ref,
                          url: AppLinksConfig.termsAndConditionsUrl,
                          missingMessage:
                              'Terms & Conditions link is not configured yet.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _SectionHeading('About'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        subtitle: 'Installed app version',
                        trailing: versionAsync.when(
                          data: (v) => v,
                          loading: () => '…',
                          error: (_, _) => '—',
                        ),
                        showChevron: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareInvite(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(inviteShareServiceProvider).shareInvite();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the share sheet.')),
      );
    }
  }

  Future<void> _openManageSubscription(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ok =
        await ref.read(revenueCatServiceProvider).presentCustomerCenter();
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Subscription management is unavailable right now. Please try again later.',
          ),
        ),
      );
    }
  }

  Future<void> _openConfiguredUrl(
    BuildContext context,
    WidgetRef ref, {
    required String url,
    required String missingMessage,
  }) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(missingMessage)),
      );
      return;
    }

    final ok = await ref.read(urlLaunchServiceProvider).openHttpUrl(url);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }
}

final _appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.mutedFg,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: AppColors.ringLeaf,
        boxShadow: AppColors.shadowSoft,
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, color: AppColors.border, indent: 60),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.statusActive,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool? statusActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.mutedFg,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                if (statusActive != null)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusActive!
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.muted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trailing!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusActive!
                            ? AppColors.primary
                            : AppColors.mutedFg,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      trailing!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedFg,
                      ),
                    ),
                  ),
              ],
              if (showChevron && onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.mutedFg,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
