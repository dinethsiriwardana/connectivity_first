import 'dart:async';
import 'package:connectivity_first/src/utils/connectivity_logger.dart';
import 'package:http/http.dart' as http;

/// Enum to represent different connection quality levels
enum ConnectionQuality {
  none,
  poor,
  fair,
  good,
  excellent,
}

/// Service for measuring and monitoring connection quality
/// Provides latency-based quality assessment and periodic monitoring
class ConnectivityQualityService {
  static final ConnectivityQualityService _instance =
      ConnectivityQualityService._internal();
  factory ConnectivityQualityService() => _instance;
  ConnectivityQualityService._internal();

  final ConnectivityLogger _logger = ConnectivityLogger();
  Timer? _periodicTimer;

  // Stream controller for broadcasting connectivity quality status
  final StreamController<ConnectionQuality> _qualityController =
      StreamController<ConnectionQuality>.broadcast();

  // Current connection quality
  ConnectionQuality _currentQuality = ConnectionQuality.none;

  /// Stream of connection quality changes
  Stream<ConnectionQuality> get qualityStream => _qualityController.stream;

  /// Current connection quality
  ConnectionQuality get currentQuality => _currentQuality;

  /// Initialize the connectivity quality service and start monitoring
  Future<void> initialize() async {
    // _logger.i('Initializing ConnectivityQualityService');

    // Check initial connection quality
    await _checkInitialQuality();

    // Start periodic quality check
    _startPeriodicCheck();
  }

  /// Check the initial connection quality
  Future<void> _checkInitialQuality() async {
    try {
      _currentQuality = await measureConnectionQuality();
      _qualityController.add(_currentQuality);
    } catch (e) {
      _logger.e('Error checking initial connection quality: $e');
      _currentQuality = ConnectionQuality.none;
      _qualityController.add(_currentQuality);
    }
  }

  /// Start periodic connection quality check every 10 seconds
  void _startPeriodicCheck() {
    _periodicTimer?.cancel(); // Cancel any existing timer

    _periodicTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final quality = await measureConnectionQuality();
        _logger.i('Periodic quality check (${DateTime.now()}): $quality');

        // Update quality if it changed
        if (_currentQuality != quality) {
          _logger.i(
            'Connection quality changed: $_currentQuality -> $quality',
          );
          _currentQuality = quality;
          _qualityController.add(_currentQuality);
        }
      } catch (e) {
        _logger.e('Error during periodic quality check: $e');
      }
    });

    // _logger.i('Started periodic connection quality check (every 10 seconds)');
  }

  /// Measure connection quality based on latency
  Future<ConnectionQuality> measureConnectionQuality() async {
    try {

      final stopwatch = Stopwatch()..start();

      final response = await http.get(
        Uri.parse('https://www.google.com/generate_204'),
      ).timeout(const Duration(seconds: 10));

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
}