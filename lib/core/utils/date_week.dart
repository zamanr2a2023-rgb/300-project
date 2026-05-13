/// Date helpers matching the original web app (local Monday-week + UTC `YYYY-MM-DD` keys).
abstract final class DateWeek {
  /// `new Date().toISOString().slice(0, 10)` in JavaScript — **UTC** calendar day of "now".
  static String todayKeyUtc() {
    final n = DateTime.now().toUtc();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  /// Monday-first list of 7 keys, matching `fetchWeekActivity` in `learning.ts`.
  static List<String> currentWeekDayKeys() {
    final now = DateTime.now();
    final daysFromMonday = (now.weekday + 6) % 7;
    final mondayLocal = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysFromMonday));
    return List.generate(7, (i) {
      final d = mondayLocal.add(Duration(days: i));
      final localMidnight = DateTime(d.year, d.month, d.day);
      final utc = localMidnight.toUtc();
      return '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
    });
  }

  /// Index of "today" within the Monday-first week array (`0` = Monday).
  static int todayMondayFirstIndex() {
    final now = DateTime.now();
    return (now.weekday + 6) % 7;
  }
}
