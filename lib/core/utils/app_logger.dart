import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void debug(String message, [dynamic error]) =>
      _logger.d(message, error: error);

  static void info(String message, [dynamic error]) =>
      _logger.i(message, error: error);

  static void warning(String message, [dynamic error]) =>
      _logger.w(message, error: error);

  static void error(String message, [dynamic error, StackTrace? stack]) =>
      _logger.e(message, error: error, stackTrace: stack);
}
