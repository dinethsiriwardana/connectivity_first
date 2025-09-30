import 'package:connectivity_first/src/bloc/connectivity/connectivity_bloc.dart';
import 'package:connectivity_first/src/bloc/connectivity_quality/connectivity_quality_bloc.dart';
import 'package:connectivity_first/src/utils/connectivity_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Global connectivity manager that wraps the entire app
/// and provides connectivity-based UI management
class ConnectivityFirstGlobalManager extends StatefulWidget {
  final Widget child;
  final Function()? onConnectivityRestored;
  final Function()? onConnectivityLost;
  final bool autoEnableConnectivity;
  final bool autoEnableQualityMonitoring;

  const ConnectivityFirstGlobalManager({
    super.key,
    required this.child,
    this.onConnectivityRestored,
    this.onConnectivityLost,
    this.autoEnableConnectivity = true,
    this.autoEnableQualityMonitoring = true,
  });

  @override
  State<ConnectivityFirstGlobalManager> createState() =>
      _ConnectivityFirstGlobalManagerState();
}

class _ConnectivityFirstGlobalManagerState
    extends State<ConnectivityFirstGlobalManager> {
  bool? _previousConnectivityStatus;

  final ConnectivityLogger logger = ConnectivityLogger();

  @override
  void initState() {
    super.initState();

    // Auto-enable services after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _autoEnableServices();
      }
    });
  }

  /// Automatically enable connectivity and quality monitoring services based on configuration
  void _autoEnableServices() {
    if (widget.autoEnableConnectivity) {
      try {
        context.read<ConnectivityFirstBloc>().startPeriodicCheck();
        logger.i('Auto-enabled connectivity monitoring');
      } catch (e) {
        logger.w('Failed to auto-enable connectivity monitoring: $e');
      }
    }

    if (widget.autoEnableQualityMonitoring) {
      try {
        context.read<ConnectivityQualityBloc>().startPeriodicCheck();
        logger.i('Auto-enabled quality monitoring');
      } catch (e) {
        logger.w('Failed to auto-enable quality monitoring: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityFirstBloc, ConnectivityFirstState>(
      listener: (context, state) {
        _handleConnectivityChange(context, state);
      },
      child: BlocBuilder<ConnectivityFirstBloc, ConnectivityFirstState>(
        builder: (context, state) {
          return widget.child;
        },
      ),
    );
  }

  void _handleConnectivityChange(
    BuildContext context,
    ConnectivityFirstState state,
  ) {
    final currentStatus = state.isOnline;

    if (_previousConnectivityStatus != null &&
        _previousConnectivityStatus != currentStatus) {
      if (currentStatus) {
        widget.onConnectivityRestored?.call();
        _showConnectivityMessage(context, 'Connected', Colors.green);
      } else {
        widget.onConnectivityLost?.call();
        _showConnectivityMessage(context, 'No Internet Connection', Colors.red);
      }
    }

    _previousConnectivityStatus = currentStatus;
  }

  void _showConnectivityMessage(
    BuildContext context,
    String message,
    Color color, {
    Duration duration = const Duration(seconds: 2),
  }) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                color == Colors.green ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: color,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      logger.w('Connectivity: $message');
    }
  }
}

/// Sample connectivity commands that you can use throughout your app
class ConnectivityFirstCommand {
  /// Trigger a manual connectivity check
  static void checkConnectivity(BuildContext context) {
    context.read<ConnectivityFirstBloc>().checkConnectivity();
  }

  /// Trigger a full UI reload
  static void reloadAllUIs(BuildContext context) {
    context.read<ConnectivityFirstBloc>().reloadAllUIs();
  }

  /// Start periodic connectivity monitoring
  static void startPeriodicCheck(BuildContext context) {
    context.read<ConnectivityFirstBloc>().startPeriodicCheck();
  }

  /// Stop periodic connectivity monitoring
  static void stopPeriodicCheck(BuildContext context) {
    context.read<ConnectivityFirstBloc>().stopPeriodicCheck();
  }

  /// Restart connectivity monitoring (useful for troubleshooting)
  static void restartConnectivity(BuildContext context) {
    context.read<ConnectivityFirstBloc>().restartConnectivity();
  }
}

/// Sample connectivity quality commands that you can use throughout your app
class ConnectivityQualityCommand {
  /// Trigger a manual quality check
  static void checkQuality(BuildContext context) {
    context.read<ConnectivityQualityBloc>().checkQuality();
  }

  /// Start periodic quality monitoring
  static void startPeriodicQualityCheck(BuildContext context) {
    context.read<ConnectivityQualityBloc>().startPeriodicCheck();
  }

  /// Stop periodic quality monitoring
  static void stopPeriodicQualityCheck(BuildContext context) {
    context.read<ConnectivityQualityBloc>().stopPeriodicCheck();
  }

  /// Restart quality monitoring (useful for troubleshooting)
  static void restartQualityMonitoring(BuildContext context) {
    context.read<ConnectivityQualityBloc>().restartMonitoring();
  }
}
