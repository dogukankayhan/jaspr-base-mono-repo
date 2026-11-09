import 'dart:developer' as developer;

import 'package:kit_network/core/utils/kit_print.dart';

/// Logger configuration for network operations
///
/// Usage:
/// ```dart
/// final logger = NetworkLogger(
///   level: LogLevel.debug,
///   enableColors: true,
/// );
///
/// logger.debug('Request started');
/// logger.error('Request failed', error);
/// ```
class NetworkLogger {
  final LogLevel level;
  final bool enableColors;
  final bool enableTimestamp;
  final bool enableStackTrace;
  final LogWriter? customWriter;

  NetworkLogger({
    this.level = LogLevel.info,
    this.enableColors = true,
    this.enableTimestamp = true,
    this.enableStackTrace = false,
    this.customWriter,
  });

  /// Log debug message
  void debug(String message, [dynamic data]) {
    _log(LogLevel.debug, message, data);
  }

  /// Log info message
  void info(String message, [dynamic data]) {
    _log(LogLevel.info, message, data);
  }

  /// Log warning message
  void warning(String message, [dynamic data]) {
    _log(LogLevel.warning, message, data);
  }

  /// Log error message
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void _log(
    LogLevel messageLevel,
    String message,
    dynamic data, [
    StackTrace? stackTrace,
  ]) {
    // Check if message should be logged
    if (messageLevel.value < level.value) return;

    final buffer = StringBuffer();

    // Add timestamp
    if (enableTimestamp) {
      buffer.write('[${DateTime.now().toIso8601String()}] ');
    }

    // Add level
    final levelStr = enableColors
        ? _colorize(messageLevel.name.toUpperCase(), messageLevel)
        : messageLevel.name.toUpperCase();
    buffer.write('[$levelStr] ');

    // Add message
    buffer.write(message);

    // Add data
    if (data != null) {
      buffer.write('\n  Data: $data');
    }

    // Add stack trace
    if (enableStackTrace && stackTrace != null) {
      buffer.write('\n  StackTrace: $stackTrace');
    }

    final logMessage = buffer.toString();

    // Write log
    if (customWriter != null) {
      customWriter!.write(messageLevel, logMessage);
    } else {
      _defaultWrite(messageLevel, logMessage);
    }
  }

  void _defaultWrite(LogLevel level, String message) {
    // Use developer.log for better debugging in DevTools
    developer.log(message, level: level.value, name: 'NetworkLogger');
  }

  String _colorize(String text, LogLevel level) {
    const reset = '\x1B[0m';

    final color = switch (level) {
      LogLevel.debug => '\x1B[36m', // Cyan
      LogLevel.info => '\x1B[32m', // Green
      LogLevel.warning => '\x1B[33m', // Yellow
      LogLevel.error => '\x1B[31m', // Red
    };

    return '$color$text$reset';
  }
}

/// Log levels
enum LogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3);

  final int value;
  const LogLevel(this.value);
}

/// Custom log writer interface
abstract class LogWriter {
  void write(LogLevel level, String message);
}

/// File log writer (example)
class FileLogWriter implements LogWriter {
  final String filePath;

  FileLogWriter(this.filePath);

  @override
  void write(LogLevel level, String message) {
    // Implementation would write to file
    // This is a placeholder
    kitPrint('Writing to $filePath: $message');
  }
}

/// Remote log writer (example for crash reporting)
class RemoteLogWriter implements LogWriter {
  final String endpoint;

  RemoteLogWriter(this.endpoint);

  @override
  void write(LogLevel level, String message) {
    // Implementation would send to remote service
    // This is a placeholder
    kitPrint('Sending to $endpoint: $message');
  }
}

/// Multi log writer (write to multiple destinations)
class MultiLogWriter implements LogWriter {
  final List<LogWriter> writers;

  MultiLogWriter(this.writers);

  @override
  void write(LogLevel level, String message) {
    for (final writer in writers) {
      writer.write(level, message);
    }
  }
}

/// Logger extensions for common network operations
extension NetworkLoggerExtensions on NetworkLogger {
  void logRequest(String method, String url, {Map<String, dynamic>? data}) {
    debug('→ $method $url', data);
  }

  void logResponse(
    String method,
    String url,
    int statusCode,
    Duration duration,
  ) {
    info('← $method $url [$statusCode] (${duration.inMilliseconds}ms)');
  }

  void logError(String method, String url, dynamic error) {
    this.error('✗ $method $url', error);
  }

  void logCacheHit(String url) {
    debug('💾 Cache HIT: $url');
  }

  void logCacheMiss(String url) {
    debug('💥 Cache MISS: $url');
  }

  void logRetry(String url, int attempt, int maxAttempts) {
    warning('🔄 Retry $attempt/$maxAttempts: $url');
  }

  void logRateLimit(String url, Duration retryAfter) {
    warning('⏱️ Rate limited: $url (retry after ${retryAfter.inSeconds}s)');
  }
}
