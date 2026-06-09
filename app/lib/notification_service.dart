import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'daily_readings.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  tz.Location? _localLocation;

  Future<void> init({required GlobalKey<NavigatorState> navigatorKey}) async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null && response.payload == 'daily_reflection') {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const DailyReadings()),
          );
        }
        // TODO: Handle 'gratitude_journal' payload — navigate to JournalMenu once available.
      },
    );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    _localLocation = tz.getLocation(timeZoneName);
  }

  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reflexión Diaria',
      '✨ Tu pensamiento para el día de hoy está listo. ¡Tócalo para leerlo!',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel_id',
          'Reflexiones Diarias',
          channelDescription: 'Canal para recordatorios diarios de reflexiones.',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reflection',
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(_localLocation!);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        _localLocation!, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleGratitudeNotification(TimeOfDay time) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1, // ID 1 (0 is already used for daily reflection)
      'Diario de Gratitud',
      '🌟 ¿Por qué estás agradecido hoy? Tómate un momento para escribirlo.',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'gratitude_channel_id',
          'Recordatorio de Gratitud',
          channelDescription: 'Recordatorio diario para el diario de gratitud.',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'gratitude_journal',
    );
  }

  Future<void> cancelGratitudeNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(1);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Detecta si la app fue abierta desde una notificación (app cerrada)
  Future<NotificationAppLaunchDetails?> getAppLaunchDetails() async {
    return await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }
}