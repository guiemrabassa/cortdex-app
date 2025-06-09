import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cortdex/src/dart/notifications/notifications.dart';



class AndroidNotifications extends NotificationPlatform {
  @override
  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? grantedNotificationPermission =
        await androidImplementation?.requestNotificationsPermission();

        await androidImplementation?.requestExactAlarmsPermission();

    arePermissionsGranted = grantedNotificationPermission ?? false;

    /* await SharedPreferencesAsync()
        .setBool("notification_permission_granted", grantedNotificationPermission ?? false); */
  }

  @override
  InitializationSettings initialization() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    return InitializationSettings(android: initializationSettingsAndroid);
  }

  @override
  void setNotificationDetails() {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
  }
}


/* Future<void> isAndroidPermissionGranted() async {
  if (Platform.isAndroid) {
    final bool granted = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;

    await SharedPreferencesAsync()
        .setBool("android_notification_permission_granted", granted);
  }
} */