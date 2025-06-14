import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cortdex/src/rust/api.dart';
import 'package:logger/logger.dart';

class CustomOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    event.lines.forEach(stdout.writeln);
  }
}

class Log {
  static bool _toggled = false;

  static StreamSubscription<LogEntry>? _rustStream;

  static final _flutterLogger = Logger(
    output: CustomOutput(),
    printer: CustomPrinter('${AnsiColor.fg(270)}[F]'),
  );

  static final _rustLogger = Logger(
    output: CustomOutput(),
    printer: CustomPrinter('${AnsiColor.fg(257)}[R]'),
  );

  static void set(bool toggled) {
    _toggled = toggled;
  }

  static _colorTest() {
    _flutterLogger.t("This is a TRACE message.");
    _flutterLogger.i("This is an INFO message.");
    _flutterLogger.w("This is a WARNING message.");
    _flutterLogger.e("This is an ERROR message.");
    _flutterLogger.f("This is a FATAL message.");
    _flutterLogger.d("This is a DEBUG message.");
  }

  static t(Object? message) {
    _flutterLogger.t(message);
  }

  static i(Object? message) {
    _flutterLogger.i(message);
  }

  static w(Object? message) {
    _flutterLogger.w(message);
  }

  static e(Object? message) {
    _flutterLogger.e(message);
  }

  static f(Object? message) {
    _flutterLogger.f(message);
  }

  static d(Object? message) {
    _flutterLogger.d(message);
  }

  static Future<void> setupLogging() async {
    _rustStream = createLogStream().listen((event) {
      String message = "RUST: ${event.msg}";
      switch (event.level) {
        case 5000:
          _rustLogger.t(message);
        case 10000:
          _rustLogger.d(message);
        case 20000:
          _rustLogger.i(message);
        case 30000:
          _rustLogger.w(message);
        case 40000:
          _rustLogger.e(message);
      }
      /* debugPrint(
          'log from rust: ${event.level} ${event.tag} ${event.msg} ${event.timeMillis}'); */
    });
  }
}

class CustomPrinter extends LogPrinter {
  CustomPrinter(this.prefix);

  static final levelPrefixes = {
    Level.trace: '[TRACE]',
    Level.debug: '[DEBUG]',
    Level.info: '[INFO]',
    Level.warning: '[WARN]',
    Level.error: '[ERROR]',
    Level.fatal: '[FATAL]',
  };

  static final levelColors = {
    Level.trace: AnsiColor.fg(129),
    Level.debug: AnsiColor.fg(270), // OK
    Level.info: AnsiColor.fg(12), // OK
    Level.warning: AnsiColor.fg(259), // OK
    Level.error: AnsiColor.fg(257),
    Level.fatal: AnsiColor.fg(199),
  };

  final bool printTime = true;
  final bool colors = true;

  final String prefix;

  final List<String> excludePaths = [];
  final int stackTraceBeginIndex = 0;

  @override
  List<String> log(LogEvent event) {
    var messageStr = _stringifyMessage(event.message);
    var errorStr = event.error != null ? '  ERROR: ${event.error}' : '';

    if (event.level == Level.error || event.level == Level.fatal) {
      formatStackTrace(StackTrace.current, 3);
    }

    var timeStr = printTime ? 'TIME: ${event.time.toIso8601String()}' : '';
    return [
      '$prefix${_labelFor(event.level)} $timeStr $messageStr$errorStr ${_stk(event)}',
    ];
  }

  String _stk(LogEvent event) {
    if (event.level == Level.error || event.level == Level.fatal) {
      return formatStackTrace(StackTrace.current, 3) ?? '';
    } else {
      return '';
    }
  }

  String _labelFor(Level level) {
    var prefix = levelPrefixes[level]!;
    var color = levelColors[level]!;

    return colors ? color(prefix) : prefix;
  }

  String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      var encoder = const JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }

  /// Matches a stacktrace line as generated on Android/iOS devices.
  ///
  /// For example:
  /// * #1      Logger.log (package:logger/src/logger.dart:115:29)
  static final _deviceStackTraceRegex = RegExp(r'#[0-9]+\s+(.+) \((\S+)\)');

  /// Matches a stacktrace line as generated by Flutter web.
  ///
  /// For example:
  /// * packages/logger/src/printers/pretty_printer.dart 91:37
  static final _webStackTraceRegex = RegExp(r'^((packages|dart-sdk)/\S+/)');

  /// Matches a stacktrace line as generated by browser Dart.
  ///
  /// For example:
  /// * dart:sdk_internal
  /// * package:logger/src/logger.dart
  static final _browserStackTraceRegex = RegExp(
    r'^(?:package:)?(dart:\S+|\S+)',
  );

  bool _isInExcludePaths(String segment) {
    for (var element in excludePaths) {
      if (segment.startsWith(element)) {
        return true;
      }
    }
    return false;
  }

  bool _discardDeviceStacktraceLine(String line) {
    var match = _deviceStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    final segment = match.group(2)!;
    if (segment.startsWith('package:logger')) {
      return true;
    }
    return _isInExcludePaths(segment);
  }

  bool _discardWebStacktraceLine(String line) {
    var match = _webStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    final segment = match.group(1)!;
    if (segment.startsWith('packages/logger') ||
        segment.startsWith('dart-sdk/lib')) {
      return true;
    }
    return _isInExcludePaths(segment);
  }

  bool _discardBrowserStacktraceLine(String line) {
    var match = _browserStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    final segment = match.group(1)!;
    if (segment.startsWith('package:logger') || segment.startsWith('dart:')) {
      return true;
    }
    return _isInExcludePaths(segment);
  }

  String? formatStackTrace(StackTrace? stackTrace, int? methodCount) {
    List<String> lines = stackTrace
        .toString()
        .split('\n')
        .where(
          (line) =>
              !_discardDeviceStacktraceLine(line) &&
              !_discardWebStacktraceLine(line) &&
              !_discardBrowserStacktraceLine(line) &&
              line.isNotEmpty,
        )
        .toList();
    List<String> formatted = [];

    int longestLine = 0;

    int stackTraceLength = (methodCount != null
        ? min(lines.length, methodCount + 3)
        : lines.length);
    for (int count = 3; count < stackTraceLength; count++) {
      var line = lines[count];
      if (count < stackTraceBeginIndex) {
        continue;
      }

      longestLine = max(longestLine, line.length);

      formatted.add('#${count - 3}   ${line.replaceFirst(RegExp(r'#\d+\s+'), '')}');
    }

    if (formatted.isEmpty) {
      return null;
    } else {
      String dashes = _createDashes(longestLine);
      formatted.insert(0, '\n$dashes');
      formatted.add(dashes);
      return formatted.join('\n');
    }
  }

  String _createDashes(int count) {
    if (count < 0) {
      return "";
    }
    return '-' * count;
  }
}
