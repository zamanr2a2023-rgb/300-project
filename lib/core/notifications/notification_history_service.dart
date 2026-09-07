import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../reminders/daily_reminder_service.dart';
import '../reminders/daily_reminder_settings.dart';
import 'app_notification.dart';
import 'notification_copy.dart';

/// Persists Paned notification history in SharedPreferences.
class NotificationHistoryService {
  static const _prefsKey = 'paned:notification_history_v1';
  static const _maxItems = 60;

  Future<List<AppNotification>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final items = AppNotification.decodeList(prefs.getString(_prefsKey));
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> _save(List<AppNotification> items) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = items.take(_maxItems).toList();
    await prefs.setString(_prefsKey, AppNotification.encodeList(trimmed));
  }

  /// Inserts [item] if [id] is not already present (dedupe).
  Future<bool> addIfAbsent(AppNotification item) async {
    final items = await loadAll();
    if (items.any((e) => e.id == item.id)) return false;
    items.insert(0, item);
    await _save(items);
    return true;
  }

  Future<void> markRead(String id) async {
    final items = await loadAll();
    final next = items
        .map((e) => e.id == id ? e.copyWith(isRead: true) : e)
        .toList();
    await _save(next);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  int unreadCount(List<AppNotification> items) =>
      items.where((e) => !e.isRead).length;

  /// Records recent past daily-reminder days into history (deduped by date id).
  Future<void> syncPastDailyReminders(DailyReminderSettings settings) async {
    if (!settings.enabled) return;

    tzdata.initializeTimeZones();
    final london = tz.getLocation(DailyReminderService.ukLocationName);
    final now = tz.TZDateTime.now(london);

    // Keep several recent reminder days so Earlier shows a real list.
    for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
      final day = now.subtract(Duration(days: dayOffset));
      final occurrence = tz.TZDateTime(
        london,
        day.year,
        day.month,
        day.day,
        settings.hour,
        settings.minute,
      );
      if (!occurrence.isBefore(now)) continue;

      await addIfAbsent(
        AppNotification(
          id: dailyReminderIdFor(occurrence),
          title: NotificationCopy.dailyReminderTitle,
          body: NotificationCopy.dailyReminderBody,
          createdAt: occurrence.toUtc(),
          type: AppNotification.typeDailyReminder,
          isRead: dayOffset > 0,
        ),
      );
    }
  }

  static String dailyReminderIdFor(tz.TZDateTime occurrence) {
    final y = occurrence.year.toString().padLeft(4, '0');
    final m = occurrence.month.toString().padLeft(2, '0');
    final d = occurrence.day.toString().padLeft(2, '0');
    return '${AppNotification.typeDailyReminder}_$y-$m-$d';
  }
}

final notificationHistoryServiceProvider =
    Provider<NotificationHistoryService>((ref) {
  return NotificationHistoryService();
});

final notificationHistoryProvider =
    AsyncNotifierProvider<NotificationHistoryNotifier, List<AppNotification>>(
  NotificationHistoryNotifier.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  final history = ref.watch(notificationHistoryProvider).valueOrNull ?? const [];
  return history.where((e) => !e.isRead).length;
});

class NotificationHistoryNotifier
    extends AsyncNotifier<List<AppNotification>> {
  NotificationHistoryService get _service =>
      ref.read(notificationHistoryServiceProvider);

  @override
  Future<List<AppNotification>> build() async {
    final reminder = await dailyReminderService.loadSettings();
    await _service.syncPastDailyReminders(reminder);
    return _service.loadAll();
  }

  Future<void> refresh() async {
    final reminder = await dailyReminderService.loadSettings();
    await _service.syncPastDailyReminders(reminder);
    state = AsyncData(await _service.loadAll());
  }

  Future<void> markRead(String id) async {
    await _service.markRead(id);
    state = AsyncData(await _service.loadAll());
  }

  Future<void> clearHistory() async {
    await _service.clearHistory();
    state = const AsyncData([]);
  }
}
