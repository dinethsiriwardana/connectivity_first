import 'package:connectivity_first/src/services/connectivity_quality_service.dart';

/// Events for the ConnectivityQuality Bloc
abstract class ConnectivityQualityEvent {}

/// Event to check connection quality
class CheckConnectionQualityEvent extends ConnectivityQualityEvent {}

/// Event to start periodic quality monitoring
class StartPeriodicQualityCheckEvent extends ConnectivityQualityEvent {}

/// Event to stop periodic quality monitoring
class StopPeriodicQualityCheckEvent extends ConnectivityQualityEvent {}

/// Event to restart quality monitoring
class RestartQualityMonitoringEvent extends ConnectivityQualityEvent {}

/// Event to update quality when service emits new value
class UpdateConnectionQualityEvent extends ConnectivityQualityEvent {
  final ConnectionQuality quality;

  UpdateConnectionQualityEvent(this.quality);
}