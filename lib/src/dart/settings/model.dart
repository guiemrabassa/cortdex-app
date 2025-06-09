import 'dart:io';

import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:flutter/services.dart';

Future<void> copyAssetModels() async {
  try {
    // 1. Get the application's documents directory

    Log.d('Starting model copy!');

    final directory = Settings().mainDir;
    final destinationPath =
        '$directory/models/sentence-transformers---all-MiniLM-L6-v2/';

    Directory modelDir = await Directory(destinationPath).create(recursive: true);

    if (!await modelDir.list().isEmpty) return;

    // 2. Load the binary data from the asset bundle
    String sourcePath =
        'assets/models/sentence-transformers---all-MiniLM-L6-v2/';
    final files = ['config.json', 'model.safetensors', 'tokenizer.json'];

    for (var filePath in files) {
      final file = File(destinationPath + filePath);
      file.create(recursive: true);
      final ByteData data = await rootBundle.load(sourcePath + filePath);
      final List<int> bytes = data.buffer.asUint8List();

      await file.writeAsBytes(bytes, flush: true);
    }
  } catch (e) {
    Log.e('Error copying asset to file: $e');
    rethrow;
  }
}
