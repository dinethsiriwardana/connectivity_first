import 'package:connectivity_first/src/bloc/connectivity/connectivity_bloc.dart';
import 'package:connectivity_first/src/bloc/connectivity_quality/connectivity_quality_bloc.dart';
import 'package:connectivity_first/src/services/global_connectivity_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityFirstProvider extends StatelessWidget {
  final Widget builder;
  final Function()? onConnectivityRestored;
  final Function()? onConnectivityLost;

  /// Whether to automatically enable connectivity monitoring (default: true)
  final bool autoEnableConnectivity;

  /// Whether to automatically enable connectivity quality monitoring (default: true)
  final bool autoEnableQualityMonitoring;

  /// Duration for periodic connection quality checks (default: 10 seconds)
  final Duration qualityCheckInterval;

  /// Whether to enable connectivity logging (default: true)
  final bool loggerConnectivity;

  /// Whether to enable quality monitoring logging (default: true)
  final bool loggerQualityMonitoring;

  /// Duration to wait before confirming a connectivity state change (default: 3 seconds)
  /// This prevents flickering when connection briefly drops and recovers
  final Duration connectionStabilityDelay;

  const ConnectivityFirstProvider({
    super.key,
    required this.builder,
    this.onConnectivityRestored,
    this.onConnectivityLost,
    this.autoEnableConnectivity = true,
    this.autoEnableQualityMonitoring = true,
    this.loggerConnectivity = true,
    this.loggerQualityMonitoring = true,
    this.qualityCheckInterval = const Duration(seconds: 10),
    this.connectionStabilityDelay = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ConnectivityFirstBloc(
            loggerConnectivity: loggerConnectivity,
            connectionStabilityDelay: connectionStabilityDelay,
          ),
        ),
        BlocProvider(
          create: (context) => ConnectivityQualityBloc(
            qualityCheckInterval: qualityCheckInterval,
            loggerQualityMonitoring: loggerQualityMonitoring,
          ),
        ),
      ],
      child: ConnectivityFirstGlobalManager(
        onConnectivityRestored: onConnectivityRestored,
        onConnectivityLost: onConnectivityLost,
        autoEnableConnectivity: autoEnableConnectivity,
        autoEnableQualityMonitoring: autoEnableQualityMonitoring,
        loggerConnectivity: loggerConnectivity,
        loggerQualityMonitoring: loggerQualityMonitoring,
        child: builder,
      ),
    );
  }
}
