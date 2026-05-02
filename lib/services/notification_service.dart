import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/reminder.dart';

/// Wraps flutter_local_notifications and exposes a small API for the rest
/// of the app: init, schedule a periodic reminder, cancel one, cancel all.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidInit);

    await _plugin.initialize(settings);

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // POST_NOTIFICATIONS prompt (Android 13+)
      await android?.requestNotificationsPermission();
      // SCHEDULE_EXACT_ALARM prompt (Android 12+)
      await android?.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Periodic reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
      );

  /// Schedule (or reschedule) a periodic notification for [reminder].
  /// If the reminder is disabled it is simply cancelled.
  Future<void> schedule(Reminder reminder) async {
    await cancel(reminder.id);
    if (!reminder.enabled) return;

    await _plugin.periodicallyShowWithDuration(
      reminder.id,
      reminder.title,
      (reminder.note?.isNotEmpty ?? false)
          ? reminder.note
          : 'Tap to open Reminders',
      reminder.duration,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
