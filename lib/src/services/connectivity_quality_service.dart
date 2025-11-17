import 'dart:async';
import 'package:connectivity_first/src/utils/connectivity_logger.dart';
import 'package:http/http.dart' as http;

/// Enum to represent different connection quality levels
enum ConnectionQuality { loading, none, poor, fair, good, excellent }

/// Service for measuring and monitoring connection quality
/// Provides latency-based quality assessment and periodic monitoring
class ConnectivityQualityService {
  static final ConnectivityQualityService _instance =
      ConnectivityQualityService._internal();
  factory ConnectivityQualityService({Duration? checkInterval}) => _instance;
  ConnectivityQualityService._internal();

  final ConnectivityLogger _logger = ConnectivityLogger();
  Timer? _periodicTimer;
  Duration _checkInterval = const Duration(seconds: 10);

  bool _loggerQualityMonitoring = true;

  // Stream controller for broadcasting connectivity quality status
  final StreamController<ConnectionQuality> _qualityController =
      StreamController<ConnectionQuality>.broadcast();

  // Current connection quality
  ConnectionQuality _currentQuality = ConnectionQuality.loading;

  /// Stream of connection quality changes
  Stream<ConnectionQuality> get qualityStream => _qualityController.stream;

  /// Current connection quality
  ConnectionQuality get currentQuality => _currentQuality;

  /// Initialize the connectivity quality service and start monitoring
  /// [checkInterval] allows customizing the periodic check interval
  Future<void> initialize({
    Duration? checkInterval,
    bool? loggerQualityMonitoring,
  }) async {
    if (checkInterval != null) {
      _checkInterval = checkInterval;
    }
    if (loggerQualityMonitoring != null) {
      _loggerQualityMonitoring = loggerQualityMonitoring;
    }

    _logger.setEnabled(_loggerQualityMonitoring);

    // Check initial connection quality
    await _checkInitialQuality();

    // Start periodic quality check
    _startPeriodicCheck();
  }

  /// Check the initial connection quality
  Future<void> _checkInitialQuality() async {
    try {
      // Emit loading state before first check
      _currentQuality = ConnectionQuality.loading;
      _qualityController.add(_currentQuality);

      _currentQuality = await measureConnectionQuality();
      _qualityController.add(_currentQuality);
    } catch (e) {
      _logger.e('Error checking initial connection quality: $e');
      _currentQuality = ConnectionQuality.none;
      _qualityController.add(_currentQuality);
    }
  }

  /// Start periodic connection quality check with configurable interval
  void _startPeriodicCheck() {
    _periodicTimer?.cancel(); // Cancel any existing timer

    _periodicTimer = Timer.periodic(_checkInterval, (timer) async {
      try {
        final quality = await measureConnectionQuality();
        _logger.i('Periodic quality check (${DateTime.now()}): $quality');

        // Update quality if it changed
        if (_currentQuality != quality) {
          _logger.i('Connection quality changed: $_currentQuality -> $quality');
          _currentQuality = quality;
          _qualityController.add(_currentQuality);
        }
      } catch (e) {
        _logger.e('Error during periodic quality check: $e');
      }
    });
  }

  /// Measure connection quality based on latency
  Future<ConnectionQuality> measureConnectionQuality() async {
    try {
      final stopwatch = Stopwatch()..start();

      final response = await http
          .get(Uri.parse('https://www.google.com/generate_204'))
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      if (response.statusCode == 204) {
        if (latency < 100) return ConnectionQuality.excellent;
        if (latency < 300) return ConnectionQuality.good;
        if (latency < 600) return ConnectionQuality.fair;
        return ConnectionQuality.poor;
      }

      return ConnectionQuality.poor;
    } catch (e) {
      _logger.e('Error measuring connection quality: $e');
      return ConnectionQuality.none;
    }
  }

  /// Manually check connection quality
  Future<ConnectionQuality> checkQuality() async {
    try {
      final quality = await measureConnectionQuality();
      _logger.i('Manual quality check: $quality');

      // Update current quality if different
      if (_currentQuality != quality) {
        _currentQuality = quality;
        _qualityController.add(_currentQuality);
      }

      return quality;
    } catch (e) {
      _logger.e('Error during manual quality check: $e');
      return ConnectionQuality.none;
    }
  }

  /// Dispose the service and clean up resources
  void dispose() {
    _logger.i('Disposing ConnectivityQualityService');
    _periodicTimer?.cancel();
    _qualityController.close();
  }

  /// Stop periodic quality check
  void stopPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _logger.i('Stopped periodic quality check');
  }

  /// Start periodic quality check (if not already running)
  void startPeriodicCheck() {
    if (_periodicTimer?.isActive != true) {
      _startPeriodicCheck();
    }
  }

  /// Restart the quality monitoring (useful for troubleshooting)
  void restartMonitoring() {
    _logger.i('Restarting quality monitoring');
    _startPeriodicCheck();
  }

  /// Update the check interval and restart monitoring if active
  void updateCheckInterval(Duration newInterval) {
    _checkInterval = newInterval;
    if (_periodicTimer?.isActive == true) {
      _logger.i('Updating check interval to ${newInterval.inSeconds} seconds');
      _startPeriodicCheck(); // Restart with new interval
    }
  }

  /// Get the current check interval
  Duration get checkInterval => _checkInterval;
}
