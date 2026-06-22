import 'dart:developer' as developer;

/// Log levels for the t1yOS SDK logger.
enum T1YLogLevel {
  /// Detailed debug information.
  debug,

  /// General informational messages.
  info,

  /// Warnings that don't prevent the SDK from working.
  warning,

  /// Errors that may affect functionality.
  error,
}

/// Custom log handler signature.
///
/// Receives the [level], [message], and optional [error] object.
typedef T1YLogHandler = void Function(
  T1YLogLevel level,
  String message, [
  Object? error,
]);

/// Lightweight static logger for the t1yOS SDK.
///
/// By default, log messages at [T1YLogLevel.warning] and above are printed
/// via `dart:developer`'s `log()` function. Users can customize the minimum
/// level with [setLevel] or provide a custom handler with [setHandler].
///
/// Example — enable debug logs:
/// ```dart
/// T1YLogger.setLevel(T1YLogLevel.debug);
/// ```
///
/// Example — route logs to your own system:
/// ```dart
/// T1YLogger.setHandler((level, message, [error]) {
///   myLogger.log(level.name, message, error);
/// });
/// ```
class T1YLogger {
  static T1YLogHandler? _handler;
  static T1YLogLevel _minLevel = T1YLogLevel.warning;

  // Private constructor — no instances needed
  T1YLogger._();

  /// Set a custom log handler to receive all SDK log messages.
  ///
  /// Pass `null` to restore the default behaviour (dart:developer `log`).
  static void setHandler(T1YLogHandler? handler) => _handler = handler;

  /// Set the minimum log level. Messages below this level are dropped.
  static void setLevel(T1YLogLevel level) => _minLevel = level;

  /// Log a debug message.
  static void debug(String message, [Object? error]) =>
      _log(T1YLogLevel.debug, message, error);

  /// Log an informational message.
  static void info(String message, [Object? error]) =>
      _log(T1YLogLevel.info, message, error);

  /// Log a warning.
  static void warning(String message, [Object? error]) =>
      _log(T1YLogLevel.warning, message, error);

  /// Log an error.
  static void error(String message, [Object? error]) =>
      _log(T1YLogLevel.error, message, error);

  static void _log(T1YLogLevel level, String message, [Object? error]) {
    if (level.index < _minLevel.index) return;

    if (_handler != null) {
      _handler!(level, message, error);
      return;
    }

    final fullMessage = error != null ? '$message Error: $error' : message;
    developer.log(
      fullMessage,
      name: 't1y_sdk',
      level: level.index,
      time: DateTime.now(),
    );
  }
}
