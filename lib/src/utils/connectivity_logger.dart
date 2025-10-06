import 'package:flutter/foundation.dart';

/// A simple logger that works with WebAssembly by using Flutter's built-in
/// debugPrint function instead of dart:io dependencies.
class ConnectivityLogger {
  bool _enabled = kDebugMode;

  /// Enable or disable logging
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Log info message
  void i(String message) {
    if (_enabled) {
      debugPrint('[INFO] $message');
    }
  }

  /// Log warning message
  void w(String message) {
    if (_enabled) {
      debugPrint('[WARN] $message');
    }
  }

  /// Log error message
  void e(String message) {
    if (_enabled) {
      debugPrint('[ERROR] $message');
    }
  }
}
