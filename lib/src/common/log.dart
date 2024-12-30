import 'dart:developer' as dev;

/// Log utility
class Log implements ILogger {
  final _Logger _logger;

  /// Log is enable
  bool _enable;

  /// Constructor
  Log({
    required bool enable,
    required LogLevel level,
  })  : _enable = enable,
        _logger = _Logger(
          logLevel: level,
        );

  /// Enable log
  @override
  void enable() {
    _enable = true;
  }

  /// Disable log
  @override
  void disable() {
    _enable = false;
  }

  @override
  void debug(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enable) return;
    _logger.debug(message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enable) return;
    _logger.error(message, error: error, stackTrace: stackTrace);
  }

  @override
  void info(dynamic message) {
    if (!_enable) return;
    _logger.info(
      message,
    );
  }

  @override
  void verbose(dynamic message) {
    if (!_enable) return;
    _logger.verbose(
      message,
    );
  }

  @override
  void warning(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enable) return;
    _logger.warning(message, error: error, stackTrace: stackTrace);
  }
}

/// Logger interface
abstract class ILogger extends ToggableLog {
  /// Log verbose
  void verbose(dynamic message);

  /// Log debug
  void debug(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log info
  void info(dynamic message);

  /// Log warning
  void warning(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log error
  void error(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  });
}

/// Log that can be toggable
abstract class ToggableLog {
  /// Enable log
  void enable();

  /// Disable log
  void disable();
}

class _Logger {
  /// The current log level. Messages at or above this level will be logged.
  final LogLevel logLevel;

  /// Constructor for the logger, taking in a [logLevel].
  _Logger({this.logLevel = LogLevel.debug});

  /// Logs the message at the provided [level].
  /// Only logs if [level] is >= the configured [logLevel].
  void log(
    dynamic message, {
    required LogLevel level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_shouldLog(level)) {
      // You can customize the formatting of the log output here.
      // ignore: avoid_print
      print('[Messaging][${level.name.toUpperCase()}] $message');
      if (error != null) {
        // ignore: avoid_print
        print(error);
      }
      if (stackTrace != null) {
        dev.log(stackTrace.toString());
      }
    }
  }

  /// Logs a debug message.
  void debug(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        message,
        level: LogLevel.debug,
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs an info message.
  void info(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        message,
        level: LogLevel.info,
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs a warning message.
  void warning(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        message,
        level: LogLevel.warning,
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs an error message.
  void error(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        message,
        level: LogLevel.error,
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs a verbose message.
  void verbose(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        message,
        level: LogLevel.verbose,
        error: error,
        stackTrace: stackTrace,
      );

  /// A helper function to decide whether to print a message or not.
  bool _shouldLog(LogLevel level) {
    return level.index >= logLevel.index;
  }
}

/// Level of log to show
enum LogLevel {
  /// Will show all log
  verbose,

  /// Will not show verbose log
  debug,

  /// Will not show debug log
  info,

  /// Will not show info, debug and verbose
  warning,

  /// Will show only error log
  error,
}
