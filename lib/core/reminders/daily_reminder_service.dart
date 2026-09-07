import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../notifications/notification_copy.dart';
import 'daily_reminder_settings.dart';

/// Local daily reminder scheduled for Europe/London (buyer default 08:30 UK).
class DailyReminderService {
  DailyReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _notificationId = 1001;
  static const _channelId = 'paned_daily_reminder';
  static const _channelName = 'Daily reminder';
  static const _prefsEnabled = 'paned:reminder_enabled';
  static const _prefsHour = 'paned:reminder_hour';
  static const _prefsMinute = 'paned:reminder_minute';
  static const ukLocationName = 'Europe/London';

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initializeFuture;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() {
    return _initializeFuture ??= _initializeImpl();
  }

  Future<void> _initializeImpl() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation(ukLocationName));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings: settings);
    await _ensureAndroidChannel();
    _initialized = true;

    final saved = await loadSettings();
    if (saved.enabled) {
      await scheduleFromSettings(saved, requestPermissionIfNeeded: false);
    }
  }

  Future<void> _ensureAndroidChannel() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Daily Welsh learning reminder',
        importance: Importance.high,
      ),
    );
  }

  Future<DailyReminderSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return DailyReminderSettings(
      enabled:
          prefs.getBool(_prefsEnabled) ??
          DailyReminderSettings.defaults.enabled,
      hour: prefs.getInt(_prefsHour) ?? DailyReminderSettings.defaults.hour,
      minute:
          prefs.getInt(_prefsMinute) ?? DailyReminderSettings.defaults.minute,
    );
  }

  Future<void> saveSettings(DailyReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsEnabled, settings.enabled);
    await prefs.setInt(_prefsHour, settings.hour);
    await prefs.setInt(_prefsMinute, settings.minute);
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestExactAlarmsPermission();
      return status.isGranted || status.isLimited;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final macos = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      final granted =
          await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          await macos?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return granted;
    }

    return true;
  }

  Future<bool> hasPermission() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Permission.notification.isGranted;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final status = await Permission.notification.status;
      return status.isGranted || status.isLimited;
    }
    return true;
  }

  /// Returns `true` when a reminder is scheduled (or successfully cancelled).
  Future<bool> applySettings(
    DailyReminderSettings settings, {
    bool requestPermissionIfNeeded = true,
  }) async {
    await initialize();
    await saveSettings(settings);
    if (!settings.enabled) {
      await cancel();
      return true;
    }
    return scheduleFromSettings(
      settings,
      requestPermissionIfNeeded: requestPermissionIfNeeded,
    );
  }

  /// Returns `true` when the daily notification was scheduled.
  Future<bool> scheduleFromSettings(
    DailyReminderSettings settings, {
    required bool requestPermissionIfNeeded,
  }) async {
    await initialize();
    if (!settings.enabled) {
      await cancel();
      return true;
    }

    var allowed = await hasPermission();
    if (!allowed && requestPermissionIfNeeded) {
      allowed = await requestPermission();
    }
    if (!allowed) return false;

    final scheduled = _nextInstanceUk(settings.hour, settings.minute);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Daily Welsh learning reminder',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: _notificationId,
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      title: NotificationCopy.dailyReminderTitle,
      body: NotificationCopy.dailyReminderBody,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }

  Future<void> cancel() async {
    await initialize();
    await _plugin.cancel(id: _notificationId);
  }

  /// Next Europe/London occurrence for the saved hour/minute.
  tz.TZDateTime nextInstanceUk(int hour, int minute) =>
      _nextInstanceUk(hour, minute);

  tz.TZDateTime _nextInstanceUk(int hour, int minute) {
    final london = tz.getLocation(ukLocationName);
    final now = tz.TZDateTime.now(london);
    var scheduled = tz.TZDateTime(
      london,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// Shared instance initialized during app startup.
final dailyReminderService = DailyReminderService();
