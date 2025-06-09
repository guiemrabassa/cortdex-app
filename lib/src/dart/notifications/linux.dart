import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cortdex/src/dart/notifications/notifications.dart';

class LinuxNotifications extends NotificationPlatform {
  @override
  Future<void> requestPermissions() async {}

  @override
  InitializationSettings initialization() {
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );

    return InitializationSettings(linux: initializationSettingsLinux);
  }

  @override
  void setNotificationDetails() {
    notificationDetails = NotificationDetails();
  }
}
