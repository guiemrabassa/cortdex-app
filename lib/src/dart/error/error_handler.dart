import 'dart:isolate';
import 'dart:ui';

import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:flutter/material.dart';
import 'package:cortdex/src/rust/frb_generated.dart';

class ErrorHandler {

  static present(Object error) {
    ErrorDescription? message;

      if (error is CortdexErrorImpl) {
        message = ErrorDescription(error.getMessage());
        // Log.e('Is cortdex: $message');
      }

      FlutterErrorDetails details =
          FlutterErrorDetails(exception: error, context: message);

      Log.e(error);

      // FlutterError.presentError(details);
  }
  
  @pragma('vm:entry-point')
  static void init() {
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      final FlutterErrorDetails details =
          FlutterErrorDetails(exception: errorAndStacktrace.first)
              .copyWith(stack: errorAndStacktrace.last);

      Log.e(details);

      // FlutterError.presentError(details);
    }).sendPort);

    FlutterError.onError = (details) {
      final excep = details.exception;

      if (excep is CortdexErrorImpl) {
        details =
            details.copyWith(context: ErrorDescription(excep.getMessage()));
      }

      Log.e(details);

      // FlutterError.presentError(details);
      // if (kReleaseMode) exit(1);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      ErrorDescription? message;

      if (error is CortdexErrorImpl) {
        message = ErrorDescription(error.getMessage());
      }

      Log.e(error);

      /* FlutterErrorDetails details =
          FlutterErrorDetails(exception: error, stack: stack, context: message);
      FlutterError.presentError(details); */

      return true;
    };
  }
}
