/// Persisted daily reminder preferences (UK / Europe/London clock).
class DailyReminderSettings {
  const DailyReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  static const defaults = DailyReminderSettings(
    enabled: true,
    hour: 8,
    minute: 30,
  );

  final bool enabled;
  final int hour;
  final int minute;

  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// e.g. "8:30 AM" for Notification Center display.
  String get formattedTimeAmPm {
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$hour12:$m $period';
  }

  DailyReminderSettings copyWith({bool? enabled, int? hour, int? minute}) {
    return DailyReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}
