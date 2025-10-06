import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_first/src/utils/connectivity_logger.dart';

/// Service for managing connectivity status and providing a centralized
/// way to monitor network connectivity across the application
class ConnectivityFirstService {
  static final ConnectivityFirstService _instance =
      ConnectivityFirstService._internal();
  factory ConnectivityFirstService() => _instance;
  ConnectivityFirstService._internal();

  final Connectivity _connectivity = Connectivity();
  final ConnectivityLogger _logger = ConnectivityLogger();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _periodicTimer;

  bool _loggerConnectivity = true;

  // Stream controller for broadcasting connectivity status
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  // Current connectivity status
  bool _isConnected = true;

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool get isConnected => _isConnected;

  /// Initialize the connectivity service and start listening
  Future<void> initialize(bool? loggerConnectivity) async {
    if (loggerConnectivity != null) {
      _loggerConnectivity = loggerConnectivity;
    }

    _logger.setEnabled(_loggerConnectivity);

    _logger.i('Initializing ConnectivityService');

    // Check initial connectivity status
    await _checkInitialConnectivity();

    // Start listening to connectivity changes
    _startListening();

    // Start periodic connectivity check
    _startPeriodicCheck();
  }

  /// Check the initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isConnected = _isConnectedFromResults(results);

      // Emit initial status
      _connectivityController.add(_isConnected);
    } catch (e) {
      _logger.e('Error checking initial connectivity: $e');
      _isConnected = false;
      _connectivityController.add(_isConnected);
    }
  }

  /// Start listening to connectivity changes
  void _startListening() {
    _subscription?.cancel(); // Cancel any existing subscription

    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        // _logger.i('Connectivity changed: $results');
        _handleConnectivityChange(results);
      },
      onError: (error) {
        _logger.e('Connectivity stream error: $error');
        _isConnected = false;
        _connectivityController.add(_isConnected);
      },
    );
  }

  /// Start periodic connectivity check every 5 seconds
  void _startPeriodicCheck() {
    _periodicTimer?.cancel(); // Cancel any existing timer

    _periodicTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final results = await _connectivity.checkConnectivity();
        _logger.i(
          'Periodic connectivity check : (${DateTime.now()}): $results',
        );

        // Also check if the status changed
        final connected = _isConnectedFromResults(results);
        if (_isConnected != connected) {
          _logger.w(
            'Connectivity status changed during periodic check: $_isConnected -> $connected',
          );
          _handleConnectivityChange(results);
        }
      } catch (e) {
        _logger.e('Error during periodic connectivity check: $e');
      }
    });

    // _logger.i('Started periodic connectivity check (every 5 seconds)');
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = _isConnectedFromResults(results);

    if (wasConnected != _isConnected) {
      // _logger.i('Connectivity status changed: $wasConnected -> $_isConnected');
      _connectivityController.add(_isConnected);
    }
  }

  /// Determine if device is connected based on connectivity results
  bool _isConnectedFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;

    // Device is connected if any result is not 'none'
    return !results.every((result) => result == ConnectivityResult.none);
  }

  /// Manually check connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final connected = _isConnectedFromResults(results);

      _logger.i('Manual connectivity check: $connected, Results: $results');

      // Update current status if different
      if (_isConnected != connected) {
        _isConnected = connected;
        _connectivityController.add(_isConnected);
      }

      return connected;
    } catch (e) {
      _logger.e('Error during manual connectivity check: $e');
      return false;
    }
  }

  /// Dispose the service and clean up resources
  void dispose() {
    _logger.i('Disposing ConnectivityService');
    _subscription?.cancel();
    _periodicTimer?.cancel();
    _connectivityController.close();
  }

  /// Restart the connectivity listening (useful for troubleshooting)
  void restartListening() {
    _logger.i('Restarting connectivity listening');
    _startListening();
  }

  /// Stop periodic connectivity check
  void stopPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _logger.i('Stopped periodic connectivity check');
  }

  /// Start periodic connectivity check (if not already running)
  void startPeriodicCheck() {
    if (_periodicTimer?.isActive != true) {
      _startPeriodicCheck();
    }
  }
}
