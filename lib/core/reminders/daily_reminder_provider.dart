import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_reminder_service.dart';
import 'daily_reminder_settings.dart';

final dailyReminderServiceProvider = Provider<DailyReminderService>((ref) {
  return dailyReminderService;
});

final dailyReminderSettingsProvider =
    AsyncNotifierProvider<DailyReminderSettingsNotifier, DailyReminderSettings>(
  DailyReminderSettingsNotifier.new,
);

class DailyReminderSettingsNotifier
    extends AsyncNotifier<DailyReminderSettings> {
  DailyReminderService get _service => ref.read(dailyReminderServiceProvider);

  @override
  Future<DailyReminderSettings> build() {
    return _service.loadSettings();
  }

  Future<bool> setEnabled(bool enabled) async {
    final current = state.valueOrNull ?? DailyReminderSettings.defaults;
    final next = current.copyWith(enabled: enabled);
    state = AsyncData(next);
    final ok = await _service.applySettings(next);
    state = AsyncData(await _service.loadSettings());
    return ok;
  }

  Future<bool> setTime({required int hour, required int minute}) async {
    final current = state.valueOrNull ?? DailyReminderSettings.defaults;
    final next = current.copyWith(hour: hour, minute: minute, enabled: true);
    state = AsyncData(next);
    final ok = await _service.applySettings(next);
    state = AsyncData(await _service.loadSettings());
    return ok;
  }
}
