import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cortdex/src/dart/notifications/apple.dart';
import 'package:cortdex/src/dart/notifications/notifications.dart';

class IOSNotifications extends NotificationPlatform {
  @override
  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  @override
  InitializationSettings initialization() {
    return appleCommonInitialization();
  }

  @override
  void setNotificationDetails() {
    notificationDetails = NotificationDetails();
  }
}
