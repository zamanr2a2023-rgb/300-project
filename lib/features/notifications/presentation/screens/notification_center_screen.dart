import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/notifications/app_notification.dart';
import '../../../../core/notifications/notification_history_service.dart';
import '../../../../core/reminders/daily_reminder_provider.dart';
import '../../../../core/reminders/daily_reminder_service.dart';
import '../../../../core/reminders/daily_reminder_settings.dart';
import '../../../../core/theme/app_colors.dart';

String _formatAmPm(DateTime when) {
  final hour12 = when.hour % 12 == 0 ? 12 : when.hour % 12;
  final m = when.minute.toString().padLeft(2, '0');
  final period = when.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$m $period';
}

const _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _friendlyDayTime(tz.TZDateTime when, {required tz.TZDateTime now}) {
  final time = _formatAmPm(when);
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(when.year, when.month, when.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today, $time';
  if (diff == 1) return 'Yesterday, $time';
  if (diff == -1) return 'Tomorrow, $time';
  return '${when.day} ${_months[when.month - 1]}, $time';
}

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderAsync = ref.watch(dailyReminderSettingsProvider);
    final historyAsync = ref.watch(notificationHistoryProvider);
    final reminder =
        reminderAsync.valueOrNull ?? DailyReminderSettings.defaults;
    final history = historyAsync.valueOrNull ?? const <AppNotification>[];

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
                          'Notifications',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.foreground,
                          ),
                        ),
                        Text(
                          'Your reminders and recent updates',
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
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await ref
                      .read(notificationHistoryProvider.notifier)
                      .refresh();
                  ref.invalidate(dailyReminderSettingsProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  children: [
                    _ReminderStatusCard(settings: reminder),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Earlier',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                        if (history.isNotEmpty)
                          TextButton(
                            onPressed: () => _confirmClear(context, ref),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.mutedFg,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Clear history',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (historyAsync.isLoading && history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (history.isEmpty)
                      const _EmptyHistoryCard()
                    else
                      ...history.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _NotificationHistoryTile(
                            notification: item,
                            onTap: () => ref
                                .read(notificationHistoryProvider.notifier)
                                .markRead(item.id),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Clear history?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
          ),
        ),
        content: Text(
          'This removes earlier notifications from Paned. Your daily reminder stays unchanged.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.mutedFg,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Clear',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(notificationHistoryProvider.notifier).clearHistory();
    }
  }
}

class _ReminderStatusCard extends StatelessWidget {
  const _ReminderStatusCard({required this.settings});

  final DailyReminderSettings settings;

  @override
  Widget build(BuildContext context) {
    final active = settings.enabled;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.muted.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border,
          width: active ? 1.5 : 1,
        ),
        boxShadow: active ? AppColors.shadowSoft : null,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              active
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              color: active ? AppColors.primary : AppColors.mutedFg,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Reminder',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  active
                      ? '${settings.formattedTimeAmPm} UK time · On'
                      : '${settings.formattedTimeAmPm} UK time · Turned off',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.mutedFg,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(active: active),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColors.primary : AppColors.muted;
    final fg = active ? AppColors.onPrimary : AppColors.mutedFg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'Active' : 'Off',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 36,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 36,
            color: AppColors.mutedFg,
          ),
          const SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your Paned reminders will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.mutedFg,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationHistoryTile extends StatelessWidget {
  const _NotificationHistoryTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unread
                  ? AppColors.leaf.withValues(alpha: 0.28)
                  : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.mutedFg,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _friendlyWhen(notification.createdAt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _friendlyWhen(DateTime utcOrLocal) {
    final london = tz.getLocation(DailyReminderService.ukLocationName);
    final when = tz.TZDateTime.from(utcOrLocal.toUtc(), london);
    final now = tz.TZDateTime.now(london);
    return _friendlyDayTime(when, now: now);
  }
}
