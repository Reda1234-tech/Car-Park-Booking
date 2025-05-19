import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationConfig {
  static const String channelId = 'car_park_booking';
  static const String channelName = 'Car Park Notifications';
  static const String channelDescription =
      'Notifications for car park booking app';

  static const AndroidNotificationChannel androidNotificationChannel =
      AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.max,
  );

  static const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  static const DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails();

  static const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: iosNotificationDetails,
  );
}
