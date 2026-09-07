import 'daily_reminder_service.dart';

/// Initializes local daily reminders once during application startup.
Future<void> initializeDailyReminder() {
  return dailyReminderService.initialize();
}
