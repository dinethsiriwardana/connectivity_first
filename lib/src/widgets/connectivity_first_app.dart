import 'package:connectivity_first/src/bloc/connectivity/connectivity_bloc.dart';
import 'package:connectivity_first/src/bloc/connectivity_quality/connectivity_quality_bloc.dart';
import 'package:connectivity_first/src/bloc/connectivity_quality/connectivity_quality_state.dart';
import 'package:connectivity_first/src/services/connectivity_quality_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Enum representing the app's connectivity state
enum ConnectivityAppState {
  /// Initial state when checking connectivity
  initiating,

  /// Listening for connectivity changes
  listening,

  /// Error occurred during connectivity check
  error,
}

class ConnectivityFirstApp extends StatelessWidget {
  final Widget Function(
    ConnectivityAppState state,
    bool isOnline,
    ConnectionQuality quality,
    String? error,
  )
  builder;

  const ConnectivityFirstApp({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityFirstBloc, ConnectivityFirstState>(
      builder: (context, connectivityState) {
        return BlocBuilder<ConnectivityQualityBloc, ConnectivityQualityState>(
          builder: (context, qualityState) {
            final appState = _determineAppState(
              connectivityState,
              qualityState,
            );
            final isOnline = connectivityState.isOnline;
            final quality = qualityState.quality;
            final error = qualityState.error;

            switch (appState) {
              case ConnectivityAppState.initiating:
              case ConnectivityAppState.listening:
              case ConnectivityAppState.error:
                return builder(appState, isOnline, quality, error);
            }
          },
        );
      },
    );
  }

  ConnectivityAppState _determineAppState(
    ConnectivityFirstState connectivityState,
    ConnectivityQualityState qualityState,
  ) {
    if (qualityState.error != null) {
      return ConnectivityAppState.error;
    }
    if (connectivityState is ConnectivityInitial ||
        qualityState.quality == ConnectionQuality.loading ||
        qualityState.isLoading) {
      return ConnectivityAppState.initiating;
    }
    return ConnectivityAppState.listening;
  }
}
