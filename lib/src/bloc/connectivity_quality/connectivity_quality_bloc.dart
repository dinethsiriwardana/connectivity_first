import 'dart:async';
import 'package:connectivity_first/src/bloc/connectivity_quality/connectivity_quality_event.dart';
import 'package:connectivity_first/src/bloc/connectivity_quality/connectivity_quality_state.dart';
import 'package:connectivity_first/src/services/connectivity_quality_service.dart';
import 'package:connectivity_first/src/utils/connectivity_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc for managing connection quality state
class ConnectivityQualityBloc
    extends Bloc<ConnectivityQualityEvent, ConnectivityQualityState> {
  final ConnectivityQualityService _qualityService;
  final ConnectivityLogger _logger = ConnectivityLogger();
  StreamSubscription<ConnectionQuality>? _qualitySubscription;
  final Duration qualityCheckInterval;
  final bool loggerQualityMonitoring;

  ConnectivityQualityBloc({
    ConnectivityQualityService? qualityService,
    this.qualityCheckInterval = const Duration(seconds: 10),
    this.loggerQualityMonitoring = true,
  }) : _qualityService = qualityService ?? ConnectivityQualityService(),
       super(const ConnectivityQualityState.initial()) {
    on<CheckConnectionQualityEvent>(_onCheckConnectionQuality);
    on<StartPeriodicQualityCheckEvent>(_onStartPeriodicQualityCheck);
    on<StopPeriodicQualityCheckEvent>(_onStopPeriodicQualityCheck);
    on<RestartQualityMonitoringEvent>(_onRestartQualityMonitoring);
    on<UpdateConnectionQualityEvent>(_onUpdateConnectionQuality);

    _initializeService();
  }

  /// Initialize the quality service and start listening to quality changes
  Future<void> _initializeService() async {
    try {
      await _qualityService.initialize(
        checkInterval: qualityCheckInterval,
        loggerQualityMonitoring: loggerQualityMonitoring,
      );
      _startListeningToQualityChanges();
    } catch (e) {
      _logger.e('Error initializing ConnectivityQualityService: $e');
    }
  }

  /// Start listening to quality changes from the service
  void _startListeningToQualityChanges() {
    _qualitySubscription?.cancel();
    _qualitySubscription = _qualityService.qualityStream.listen(
      (quality) {
        add(UpdateConnectionQualityEvent(quality));
      },
      onError: (error) {
        _logger.e('Quality stream error: $error');
      },
    );
  }

  /// Handle manual quality check
  Future<void> _onCheckConnectionQuality(
    CheckConnectionQualityEvent event,
    Emitter<ConnectivityQualityState> emit,
  ) async {
    try {
      emit(state.copyWithLoading());
      final quality = await _qualityService.checkQuality();
      emit(state.copyWithQuality(quality));
    } catch (e) {
      _logger.e('Error checking connection quality: $e');
      emit(state.copyWithError('Failed to check connection quality'));
    }
  }

  /// Handle starting periodic quality check
  void _onStartPeriodicQualityCheck(
    StartPeriodicQualityCheckEvent event,
    Emitter<ConnectivityQualityState> emit,
  ) {
    try {
      _qualityService.startPeriodicCheck();
      _logger.i('Started periodic quality check');
    } catch (e) {
      _logger.e('Error starting periodic quality check: $e');
      emit(state.copyWithError('Failed to start periodic quality check'));
    }
  }

  /// Handle stopping periodic quality check
  void _onStopPeriodicQualityCheck(
    StopPeriodicQualityCheckEvent event,
    Emitter<ConnectivityQualityState> emit,
  ) {
    try {
      _qualityService.stopPeriodicCheck();
      _logger.i('Stopped periodic quality check');
    } catch (e) {
      _logger.e('Error stopping periodic quality check: $e');
      emit(state.copyWithError('Failed to stop periodic quality check'));
    }
  }

  /// Handle restarting quality monitoring
  void _onRestartQualityMonitoring(
    RestartQualityMonitoringEvent event,
    Emitter<ConnectivityQualityState> emit,
  ) {
    try {
      _qualityService.restartMonitoring();
      _logger.i('Restarted quality monitoring');
    } catch (e) {
      _logger.e('Error restarting quality monitoring: $e');
      emit(state.copyWithError('Failed to restart quality monitoring'));
    }
  }

  /// Handle quality updates from the service
  void _onUpdateConnectionQuality(
    UpdateConnectionQualityEvent event,
    Emitter<ConnectivityQualityState> emit,
  ) {
    emit(state.copyWithQuality(event.quality));
  }

  /// Public methods for external access
  void checkQuality() => add(CheckConnectionQualityEvent());
  void startPeriodicCheck() => add(StartPeriodicQualityCheckEvent());
  void stopPeriodicCheck() => add(StopPeriodicQualityCheckEvent());
  void restartMonitoring() => add(RestartQualityMonitoringEvent());

  @override
  Future<void> close() {
    _qualitySubscription?.cancel();
    _qualityService.dispose();
    return super.close();
  }
}
