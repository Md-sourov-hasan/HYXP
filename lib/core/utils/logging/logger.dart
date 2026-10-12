import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLoggerHelper {
  AppLoggerHelper._();
  static final Logger _logger = Logger(
    printer: PrettyPrinter(), // Customize the log levels based on your needs
    level: Level.debug, // Set the default log level
  );

  static void debug(String message) {
    debugPrint(message);
    _logger.d(message);
  }

  static void debugLong(String message, {int chunkSize = 700}) {
    if (message.length <= chunkSize) {
      debug(message);
      return;
    }

    for (var start = 0; start < message.length; start += chunkSize) {
      final end = start + chunkSize > message.length
          ? message.length
          : start + chunkSize;
      _logger.d(message.substring(start, end));
    }
  }

  static void info(String message) {
    debugPrint(message);
    _logger.i(message);
  }

  static void warning(String message) {
    debugPrint(message);
    _logger.w(message);
  }

  static void error(String message, [dynamic error]) {
    debugPrint('$message${error == null ? '' : ' | error=$error'}');
    _logger.e(message, error: error, stackTrace: StackTrace.current);
  }
}
