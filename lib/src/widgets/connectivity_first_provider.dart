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

  const ConnectivityFirstProvider({
    super.key,
    required this.builder,
    this.onConnectivityRestored,
    this.onConnectivityLost,
    this.autoEnableConnectivity = true,
    this.autoEnableQualityMonitoring = true,
    this.qualityCheckInterval = const Duration(seconds: 10),
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ConnectivityFirstBloc()),
        BlocProvider(
          create: (context) => ConnectivityQualityBloc(
            qualityCheckInterval: qualityCheckInterval,
          ),
        ),
      ],
      child: ConnectivityFirstGlobalManager(
        onConnectivityRestored: onConnectivityRestored,
        onConnectivityLost: onConnectivityLost,
        autoEnableConnectivity: autoEnableConnectivity,
        autoEnableQualityMonitoring: autoEnableQualityMonitoring,
        child: builder,
      ),
    );
  }
}
