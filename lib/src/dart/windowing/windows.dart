import 'dart:collection';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// This is the page that holds inner note editors, allowing for multiple at the same time

class AppWindow {
  final WindowController windowController;

  AppWindow({required this.windowController});
}

final Map<int, AppWindow> planets = HashMap(); // Is a HashMap

class NoteView extends HookConsumerWidget {
  const NoteView({super.key});

  void createWindow() async {

    var window = await DesktopMultiWindow.createWindow(jsonEncode({
      'args1': 'multi_window',
      'args2': 100,
      'args3': true,
      'bussiness': 'bussiness_test',
    }));

    debugPrint('Created window: $window');

    window
      ..setFrame(const Offset(0, 0) & const Size(1280, 720))
      ..center()
      ..setTitle('Another window')
      ..show();

    planets.putIfAbsent(
        window.windowId, () => AppWindow(windowController: window));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text('Create window!'),
      onTap: () async {
        createWindow();
      },
    );
  }
}
