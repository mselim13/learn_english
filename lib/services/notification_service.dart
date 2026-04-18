import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'daily_reminders';
  static const _channelName = 'Daily reminders';
  static const _channelDesc = 'Reminders to practice English';

  static bool _inited = false;

  static Future<void> ensureInitialized() async {
    if (_inited) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const init = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(
      settings: init,
      onDidReceiveNotificationResponse: (_) {},
    );

    _inited = true;
  }

  static Future<bool> requestPermissionIfNeeded() async {
    await ensureInitialized();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final mac = _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();

    final a = await android?.requestNotificationsPermission();
    final i = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    final m = await mac?.requestPermissions(alert: true, badge: true, sound: true);

    return (a ?? true) && (i ?? true) && (m ?? true);
  }

  static NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  static Future<void> showNow({
    required String title,
    required String body,
  }) async {
    await ensureInitialized();
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: _details(),
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = 'Practice English',
    String body = 'A few minutes today will make a difference.',
  }) async {
    await ensureInitialized();
    // stable id
    const id = 1001;
    final when = _nextInstanceOfTime(hour, minute);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDailyReminder() async {
    await ensureInitialized();
    const id = 1001;
    await _plugin.cancel(id: id);
  }

  @visibleForTesting
  static FlutterLocalNotificationsPlugin debugPlugin() => _plugin;
}

