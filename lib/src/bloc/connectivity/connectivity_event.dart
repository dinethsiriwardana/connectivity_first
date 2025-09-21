part of 'connectivity_bloc.dart';

/// Base class for all connectivity events
sealed class ConnectivityFirstEvent extends Equatable {
  const ConnectivityFirstEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when connectivity status changes
class ConnectivityChanged extends ConnectivityFirstEvent {
  final bool isConnected;

  const ConnectivityChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];

  @override
  String toString() => 'ConnectivityChanged(isConnected: $isConnected)';
}

/// Event to manually check connectivity status
class ConnectivityCheckRequested extends ConnectivityFirstEvent {
  const ConnectivityCheckRequested();

  @override
  String toString() => 'ConnectivityCheckRequested';
}

/// Event to initialize connectivity monitoring
class ConnectivityInitializeRequested extends ConnectivityFirstEvent {
  const ConnectivityInitializeRequested();

  @override
  String toString() => 'ConnectivityInitializeRequested';
}

/// Event to trigger a full UI reload when connectivity is restored
class ConnectivityReloadUIRequested extends ConnectivityFirstEvent {
  const ConnectivityReloadUIRequested();

  @override
  String toString() => 'ConnectivityReloadUIRequested';
}
