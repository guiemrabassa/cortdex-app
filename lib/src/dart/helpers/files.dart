import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> getMainDirectory() async {
  // https://stackoverflow.com/questions/59501445/flutter-how-to-save-a-file-on-ios

  Directory dir;

  if (Platform.isAndroid) {
    // dir = await getApplicationDocumentsDirectory();
    dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();

    // Maybe getExternalStorageDirectory?
  } else if (Platform.isIOS) {
    // dir = await getLibraryDirectory();
    dir = await getApplicationDocumentsDirectory();
    debugPrint("isIOS: $dir");
  } else {
    dir = await getApplicationDocumentsDirectory();
  }
  
  return dir;
}



extension StringCasingExtension on String {
  String get toCapitalized => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String get toTitleCase => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized).join(' ');
}