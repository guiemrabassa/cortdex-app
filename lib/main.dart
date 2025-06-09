import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cortdex/l10n/generated/app_localizations.dart';
import 'package:cortdex/src/dart/client.dart';
import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/helpers/platform.dart';
import 'package:cortdex/src/dart/notifications/notifications.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:cortdex/src/rust/frb_generated.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cortdex/src/dart/error/error_handler.dart';

import 'package:cortdex/src/dart/routes/routes.dart';
import 'package:cortdex/src/dart/settings/localization.dart';
import 'package:cortdex/src/rust/api.dart';

import 'package:cortdex/src/dart/helpers/files.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:window_manager/window_manager.dart';

late List<CameraDescription> cameras;

Future<void> configWindow(bool isSubWindow) async {
  if (PlatformUtils.isDesktop) {
    await windowManager.ensureInitialized();

    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      debugPrint('${call.method} ${call.arguments} $fromWindowId');
      return "result";
    });

    WindowManager.instance.setMinimumSize(const Size(600, 800));

    WindowOptions windowOptions = WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    if (!isSubWindow) {
      windowManager.waitUntilReadyToShow(null, () async {
        await windowManager.setTitle("Main Window");
        await windowManager.show();
      });
    } else {
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setTitle("Child Window");
        await windowManager.show();
      });
    }
  }
}

Future<void> start(bool isSubWindow) async {
  await RustLib.init();
  await Log.setupLogging();

  

  if (!isSubWindow) {
    // Start the server only in the main window, in the future here it will read if it's client-server or what
    var mainDir = await getMainDirectory();
    await initApp(mainDir: mainDir.path);
  }

  if (PlatformUtils.isMobile) {
    cameras = await availableCameras();
  } else {
    await configWindow(isSubWindow);
  }

  tz.initializeTimeZones();

  // I need to raise to API 35 to get this working
  // final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  // debugPrint('Current timezone is $currentTimeZone');
  // tz.setLocalLocation(tz.getLocation(currentTimeZone));

  ErrorHandler.init();

  await notificationPlatform.setup();

  await Settings.init();

  try {
    // await Client().startClient();
  } catch (e) {
    Log.e(e);
  }
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final isSubWindow = (args.firstOrNull == "multi_window");

  await start(isSubWindow);

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Locale locale = ref.watch(appLanguageProvider);

    return MaterialApp.router(
      localizationsDelegates: [
        AppLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      locale: locale,
      routerConfig: mainRouter,
    );
  }
}

// TODO: https://marketplace.visualstudio.com/items?itemName=robert-brunhage.flutter-riverpod-snippets
