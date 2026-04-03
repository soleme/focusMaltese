import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    try {
      await _plugin.initialize(initializationSettings);
      _initialized = true;
    } on MissingPluginException {
      _initialized = false;
    } on ArgumentError {
      _initialized = false;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<bool> requestPermissions() async {
    await initialize();
    try {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkPermissions() async {
    await initialize();
    try {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final settings = await ios?.checkPermissions();
      return settings?.isEnabled ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleFocusReminder({
    required int id,
    required Duration delay,
  }) async {
    await initialize();

    try {
      await _plugin.zonedSchedule(
        id,
        '집중해 말티즈',
        '집중 시간이 끝났멍! 돌아와서 보상을 받아보멍.',
        tz.TZDateTime.now(tz.local).add(delay),
        const NotificationDetails(iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on MissingPluginException {
      return;
    } catch (_) {
      return;
    }
  }

  Future<void> cancelFocusReminder(int id) async {
    try {
      await _plugin.cancel(id);
    } on MissingPluginException {
      return;
    } catch (_) {
      return;
    }
  }
}
