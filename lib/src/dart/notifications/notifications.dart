import 'dart:async';
import 'dart:io';

import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/notifications/windows.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cortdex/src/dart/notifications/android.dart';
import 'package:cortdex/src/dart/notifications/ios.dart';
import 'package:cortdex/src/dart/notifications/linux.dart';
import 'package:cortdex/src/dart/notifications/macos.dart';

import 'package:timezone/timezone.dart' as tz;

final NotificationPlatform notificationPlatform =
    switch (Platform.operatingSystem) {
      "android" => AndroidNotifications(),
      "ios" => IOSNotifications(),
      "linux" => LinuxNotifications(),
      "macos" => MacOSNotifications(),
      "windows" => WindowsNotifications(),
      // "fuchsia" => AndroidNotifications(),
      String() => throw UnimplementedError(),
    };

abstract class NotificationPlatform {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late bool arePermissionsGranted;

  int notificationId = 0;

  final StreamController<NotificationResponse> selectNotificationStream =
      StreamController<NotificationResponse>.broadcast();

  late NotificationDetails notificationDetails;

  InitializationSettings initialization();

  void setNotificationDetails();

  Future<void> requestPermissions();

  Future<void> setup() async {
    Log.i("Setting up notifications!");

    await requestPermissions();

    setNotificationDetails();

    await flutterLocalNotificationsPlugin.initialize(
      initialization(),
      onDidReceiveNotificationResponse: selectNotificationStream.add,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    Log.i("Notifications are all set up!");
  }

  NotificationPlatform platform() {
    return switch (Platform.operatingSystem) {
      "android" => AndroidNotifications(),
      "ios" => IOSNotifications(),
      "linux" => LinuxNotifications(),
      "macos" => MacOSNotifications(),
      // "windows" => AndroidNotifications(),
      // "fuchsia" => AndroidNotifications(),
      String() => throw UnimplementedError(),
    };
  }

  Future<void> showNotification() async {
    await flutterLocalNotificationsPlugin.show(
      notificationId++,
      'plain title $notificationId',
      'plain body',
      notificationDetails,
      payload: 'item x',
    );
  }

  Future<void> showNotificationIn() async {
    if (!Platform.isLinux) {
      // Configure scheduling
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId++,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 20)),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> showNotificationPeriodically() async {
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'repeating title',
      'repeating body',
      RepeatInterval.everyMinute,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<List<PendingNotificationRequest>> showActive() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}
