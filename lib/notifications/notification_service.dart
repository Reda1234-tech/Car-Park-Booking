import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notifications_config.dart';
import '../utils/timezone_helper.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await TimezoneHelper.initializeTimezones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: (details) {
      // TODO: handle notification tap if needed
      print('Notification tapped with payload: ${details.payload}');
    });
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationConfig.notificationDetails,
      payload: payload,
    );
  }

  // Future<void> scheduleNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required DateTime scheduledDate,
  //   String? payload,
  // }) async {
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     id,
  //     title,
  //     body,
  //     tz.TZDateTime.from(scheduledDate, tz.local),
  //     NotificationConfig.notificationDetails,
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     payload: payload,
  //   );
  // }
}
