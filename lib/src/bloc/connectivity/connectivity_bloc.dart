import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_first/src/services/connectivity_service.dart';
import 'package:connectivity_first/src/utils/connectivity_logger.dart';
import 'package:equatable/equatable.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityFirstBloc
    extends Bloc<ConnectivityFirstEvent, ConnectivityFirstState> {
  final ConnectivityFirstService _connectivityService;
  final ConnectivityLogger _logger = ConnectivityLogger();
  StreamSubscription<bool>? _connectivitySubscription;
  final bool loggerConnectivity;

  ConnectivityFirstBloc({
    ConnectivityFirstService? connectivityService,
    this.loggerConnectivity = true,
  }) : _connectivityService = connectivityService ?? ConnectivityFirstService(),
       super(
         const ConnectivityInitial(
           status: ConnectivityFirstStatus.online,
           isLocalMode: false,
         ),
       ) {
    // Register event handlers
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<ConnectivityCheckRequested>(_onConnectivityCheckRequested);
    on<ConnectivityInitializeRequested>(_onConnectivityInitializeRequested);
    on<ConnectivityReloadUIRequested>(_onConnectivityReloadUIRequested);

    // Initialize the connectivity service and start listening
    _initializeConnectivity();
  }

  /// Initialize connectivity service and start listening to changes
  Future<void> _initializeConnectivity() async {
    try {
      // Initialize the connectivity service
      await _connectivityService.initialize(loggerConnectivity);

      // Start listening to connectivity changes
      _startListening();

      // Emit initial connectivity state
      add(ConnectivityChanged(_connectivityService.isConnected));
    } catch (e) {
      _logger.e('Error initializing connectivity: $e');
      // Emit offline state in case of error
      add(const ConnectivityChanged(false));
    }
  }

  /// Start listening to connectivity changes from the service
  void _startListening() {
    _connectivitySubscription?.cancel();

    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (bool isConnected) {
        add(ConnectivityChanged(isConnected));
      },
      onError: (error) {
        _logger.e('Connectivity stream error: $error');
        add(const ConnectivityChanged(false));
      },
    );
  }

  /// Handle connectivity change events
  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityFirstState> emit,
  ) async {
    final status = event.isConnected
        ? ConnectivityFirstStatus.online
        : ConnectivityFirstStatus.offline;

    final isLocalMode = !event.isConnected;

    if (state is ConnectivityInitial) {
      emit(ConnectivityUpdated(status: status, isLocalMode: isLocalMode));
    } else if (state is ConnectivityUpdated) {
      final currentState = state as ConnectivityUpdated;

      // Only emit if the state actually changed
      if (currentState.status != status ||
          currentState.isLocalMode != isLocalMode) {
        emit(currentState.copyWith(status: status, isLocalMode: isLocalMode));
      }
    }
  }

  /// Handle manual connectivity check requests
  Future<void> _onConnectivityCheckRequested(
    ConnectivityCheckRequested event,
    Emitter<ConnectivityFirstState> emit,
  ) async {
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      add(ConnectivityChanged(isConnected));
    } catch (e) {
      _logger.e('Error during manual connectivity check: $e');
      add(const ConnectivityChanged(false));
    }
  }

  /// Handle connectivity initialization requests
  Future<void> _onConnectivityInitializeRequested(
    ConnectivityInitializeRequested event,
    Emitter<ConnectivityFirstState> emit,
  ) async {
    await _initializeConnectivity();
  }

  /// Handle UI reload requests
  Future<void> _onConnectivityReloadUIRequested(
    ConnectivityReloadUIRequested event,
    Emitter<ConnectivityFirstState> emit,
  ) async {
    _logger.i('UI reload requested');

    final currentStatus = _connectivityService.isConnected
        ? ConnectivityFirstStatus.online
        : ConnectivityFirstStatus.offline;

    emit(
      ConnectivityUIReloadRequested(
        status: currentStatus,
        isLocalMode: !_connectivityService.isConnected,
        timestamp: DateTime.now(),
      ),
    );

    // After emitting reload state, go back to updated state
    await Future.delayed(const Duration(milliseconds: 100));
    emit(
      ConnectivityUpdated(
        status: currentStatus,
        isLocalMode: !_connectivityService.isConnected,
      ),
    );
  }

  /// Get current connectivity status
  bool get isConnected => _connectivityService.isConnected;

  /// Manually trigger a connectivity check
  void checkConnectivity() {
    add(const ConnectivityCheckRequested());
  }

  /// Restart connectivity listening (useful for troubleshooting)
  void restartConnectivity() {
    _connectivityService.restartListening();
    _startListening();
  }

  /// Start periodic connectivity check (every 5 seconds)
  void startPeriodicCheck() {
    ('Starting periodic connectivity check');
    _connectivityService.startPeriodicCheck();
  }

  /// Stop periodic connectivity check
  void stopPeriodicCheck() {
    _connectivityService.stopPeriodicCheck();
  }

  /// Trigger a full UI reload
  void reloadAllUIs() {
    _logger.i('Triggering UI reload command');
    add(const ConnectivityReloadUIRequested());
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
