import 'package:connectivity_first/src/services/connectivity_quality_service.dart';
import 'package:equatable/equatable.dart';

/// State for the ConnectivityQuality Bloc
class ConnectivityQualityState extends Equatable {
  final ConnectionQuality quality;
  final bool isLoading;
  final String? error;

  const ConnectivityQualityState({
    required this.quality,
    this.isLoading = false,
    this.error,
  });

  /// Initial state
  const ConnectivityQualityState.initial()
    : quality = ConnectionQuality.none,
      isLoading = false,
      error = null;

  /// Loading state
  ConnectivityQualityState copyWithLoading() {
    return ConnectivityQualityState(
      quality: quality,
      isLoading: true,
      error: null,
    );
  }

  /// Success state with new quality
  ConnectivityQualityState copyWithQuality(ConnectionQuality newQuality) {
    return ConnectivityQualityState(
      quality: newQuality,
      isLoading: false,
      error: null,
    );
  }

  /// Error state
  ConnectivityQualityState copyWithError(String errorMessage) {
    return ConnectivityQualityState(
      quality: quality,
      isLoading: false,
      error: errorMessage,
    );
  }

  @override
  List<Object?> get props => [quality, isLoading, error];
}
