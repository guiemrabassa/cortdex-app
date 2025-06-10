import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cortdex/src/dart/notifications/apple.dart';
import 'package:cortdex/src/dart/notifications/notifications.dart';

class WindowsNotifications extends NotificationPlatform {
  @override
  Future<void> requestPermissions() async {
    
  }

  @override
  InitializationSettings initialization() {
    // TODO

    /* return InitializationSettings(windows: WindowsInitializationSettings(
      appName: appName,
      appUserModelId: appUserModelId,
      guid: guid
    )); */

    return appleCommonInitialization();
  }

  @override
  void setNotificationDetails() {
    notificationDetails = NotificationDetails();
  }
}
