import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'daily_reminder_provider.dart';
import 'daily_reminder_settings.dart';

/// Opens the shared Daily Reminder bottom sheet (You + Settings).
Future<void> showDailyReminderSheet({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final settings =
      ref.read(dailyReminderSettingsProvider).valueOrNull ??
          DailyReminderSettings.defaults;

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return _DailyReminderSheet(
        initial: settings,
        onChangedEnabled: (enabled) async {
          final ok = await ref
              .read(dailyReminderSettingsProvider.notifier)
              .setEnabled(enabled);
          if (!context.mounted) return;
          if (enabled && !ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Notification permission is needed for daily reminders.',
                ),
              ),
            );
          }
        },
        onPickTime: () async {
          final current =
              ref.read(dailyReminderSettingsProvider).valueOrNull ??
                  DailyReminderSettings.defaults;
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: current.hour,
              minute: current.minute,
            ),
            helpText: 'Daily reminder (UK time)',
            useRootNavigator: true,
            builder: (pickerContext, child) {
              return MediaQuery(
                data: MediaQuery.of(pickerContext).copyWith(
                  alwaysUse24HourFormat: true,
                ),
                child: Theme(
                  data: Theme.of(pickerContext).copyWith(
                    colorScheme: Theme.of(pickerContext).colorScheme.copyWith(
                          primary: AppColors.primary,
                        ),
                  ),
                  child: child!,
                ),
              );
            },
          );
          if (picked == null) return;

          final ok = await ref.read(dailyReminderSettingsProvider.notifier).setTime(
                hour: picked.hour,
                minute: picked.minute,
              );
          if (!context.mounted) return;

          final saved =
              ref.read(dailyReminderSettingsProvider).valueOrNull ??
                  DailyReminderSettings(
                    enabled: true,
                    hour: picked.hour,
                    minute: picked.minute,
                  );

          if (!ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Notification permission is needed for daily reminders.',
                ),
              ),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Reminder set for ${saved.formattedTime} UK every day.',
              ),
            ),
          );
        },
      );
    },
  );
}

class _DailyReminderSheet extends ConsumerWidget {
  const _DailyReminderSheet({
    required this.initial,
    required this.onChangedEnabled,
    required this.onPickTime,
  });

  final DailyReminderSettings initial;
  final ValueChanged<bool> onChangedEnabled;
  final Future<void> Function() onPickTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(dailyReminderSettingsProvider).valueOrNull ?? initial;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Daily reminder',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick a UK time. We will nudge you every day to keep your streak.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.mutedFg,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Remind me daily',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: settings.enabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: onChangedEnabled,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  onPickTime();
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reminder time (UK)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.foreground,
                              ),
                            ),
                            Text(
                              'Tap to change',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.mutedFg,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        settings.formattedTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.mutedFg,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => onPickTime(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Set time',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
