part of 'connectivity_bloc.dart';

/// Enum representing the connectivity status
enum ConnectivityFirstStatus {
  /// Device is connected to the internet
  online,

  /// Device is not connected to the internet
  offline,
}

/// Base class for all connectivity states
sealed class ConnectivityFirstState extends Equatable {
  final ConnectivityFirstStatus status;
  final bool isLocalMode;

  const ConnectivityFirstState({
    required this.status,
    required this.isLocalMode,
  });

  @override
  List<Object?> get props => [status, isLocalMode];

  /// Returns true if the device is currently online
  bool get isOnline => status == ConnectivityFirstStatus.online;

  /// Returns true if the device is currently offline
  bool get isOffline => status == ConnectivityFirstStatus.offline;
}

/// Initial state when the connectivity bloc is first created
class ConnectivityInitial extends ConnectivityFirstState {
  const ConnectivityInitial({
    required super.status,
    required super.isLocalMode,
  });

  ConnectivityInitial copyWith({
    ConnectivityFirstStatus? status,
    bool? isLocalMode,
  }) {
    return ConnectivityInitial(
      status: status ?? this.status,
      isLocalMode: isLocalMode ?? this.isLocalMode,
    );
  }

  @override
  String toString() =>
      'ConnectivityInitial(status: $status, isLocalMode: $isLocalMode)';
}

/// State emitted when connectivity status has been updated
class ConnectivityUpdated extends ConnectivityFirstState {
  const ConnectivityUpdated({
    required super.status,
    required super.isLocalMode,
  });

  ConnectivityUpdated copyWith({
    ConnectivityFirstStatus? status,
    bool? isLocalMode,
  }) {
    return ConnectivityUpdated(
      status: status ?? this.status,
      isLocalMode: isLocalMode ?? this.isLocalMode,
    );
  }

  @override
  String toString() =>
      'ConnectivityUpdated(status: $status, isLocalMode: $isLocalMode)';
}

/// State emitted when a full UI reload is requested
class ConnectivityUIReloadRequested extends ConnectivityFirstState {
  final DateTime timestamp;

  const ConnectivityUIReloadRequested({
    required super.status,
    required super.isLocalMode,
    required this.timestamp,
  });

  ConnectivityUIReloadRequested copyWith({
    ConnectivityFirstStatus? status,
    bool? isLocalMode,
    DateTime? timestamp,
  }) {
    return ConnectivityUIReloadRequested(
      status: status ?? this.status,
      isLocalMode: isLocalMode ?? this.isLocalMode,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [status, isLocalMode, timestamp];

  @override
  String toString() =>
      'ConnectivityUIReloadRequested(status: $status, isLocalMode: $isLocalMode, timestamp: $timestamp)';
}
