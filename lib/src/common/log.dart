import 'package:logger/logger.dart';

/// Log utility
class Log implements ILogger {
  final Logger _logger;

  /// Log is enable
  bool _enable;

  /// Constructor
  Log({
    required bool enable,
    required LogLevel level,
  })  : _enable = enable,
        _logger = Logger(
          level: _logLevelToLevel(level),
          output: _ConsoleOutput(),
          printer: PrefixPrinter(
            PrettyPrinter(
              printEmojis: false,
              errorMethodCount: 10,
              lineLength: 80,
              methodCount: 20,
            ),
          ),
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
    _logger.d(message, error, stackTrace);
  }

  @override
  void error(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enable) return;
    _logger.e(message, error, stackTrace);
  }

  @override
  void info(dynamic message) {
    if (!_enable) return;
    _logger.i(
      message,
      null,
      StackTrace.empty,
    );
  }

  @override
  void verbose(dynamic message) {
    if (!_enable) return;
    _logger.v(
      message,
      null,
      StackTrace.empty,
    );
  }

  @override
  void warning(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enable) return;
    _logger.w(message, error, stackTrace);
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

class _ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      // ignore: avoid_print
      print("[Messaging]: $line");
    }
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

Level _logLevelToLevel(LogLevel logLevel) {
  switch (logLevel) {
    case LogLevel.debug:
      return Level.debug;
    case LogLevel.info:
      return Level.info;
    case LogLevel.warning:
      return Level.warning;
    case LogLevel.error:
      return Level.error;
    default:
      return Level.verbose;
  }
}
