// ignore_for_file: avoid_print

import 'package:connectivity_first/connectivity_first.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ConnectivityFirstProvider(
        // Automatically enable connectivity monitoring (default: true)
        autoEnableConnectivity: true,

        // Automatically enable quality monitoring (default: true)
        autoEnableQualityMonitoring: true,

        // Custom interval for quality checks (default: 10 seconds)
        qualityCheckInterval: const Duration(seconds: 5),

        // Delay before confirming offline state (default: 3 seconds)
        connectionStabilityDelay: const Duration(seconds: 5),

        // Disable connectivity logging (default: true)
        loggerConnectivity: true,

        // Disable quality monitoring logging (default: true)
        loggerQualityMonitoring: true,

        onConnectivityRestored: () {
          print('Internet restored!');
        },
        onConnectivityLost: () {
          print('Internet lost!');
        },
        builder: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  void buttonAction() {
    if (ConnectivityFirstService().isConnected) {
      ConnectivityFirstService().stopPeriodicCheck();
    } else {
      ConnectivityFirstService().startPeriodicCheck();
      ConnectivityFirstService().checkConnectivity();
    }
    ConnectivityFirstService().restartListening();
  }

  String _getQualityText(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.loading:
        return 'Checking...';
      case ConnectionQuality.none:
        return 'No Connection';
      case ConnectionQuality.poor:
        return 'Poor';
      case ConnectionQuality.fair:
        return 'Fair';
      case ConnectionQuality.good:
        return 'Good';
      case ConnectionQuality.excellent:
        return 'Excellent';
    }
  }

  Color _getQualityColor(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.loading:
        return Colors.grey;
      case ConnectionQuality.none:
        return Colors.red;
      case ConnectionQuality.poor:
        return Colors.orange;
      case ConnectionQuality.fair:
        return Colors.yellow;
      case ConnectionQuality.good:
        return Colors.lightGreen;
      case ConnectionQuality.excellent:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline First Example')),
      body: ConnectivityFirstApp(
        builder: (state, isOnline, quality, error) {
          switch (state) {
            case ConnectivityAppState.initiating:
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Checking connectivity...'),
                  ],
                ),
              );
            case ConnectivityAppState.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text('Connectivity Error'),
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(error, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ConnectivityFirstCommand.checkConnectivity(context);
                        ConnectivityQualityCommand.checkQuality(context);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case ConnectivityAppState.listening:
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isOnline ? 'You are online' : 'You are offline',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Connection Quality: ${_getQualityText(quality)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _getQualityColor(quality),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (isOnline) {
                          // Perform online action - maybe reload UI to get fresh data
                          ConnectivityFirstCommand.reloadAllUIs(context);
                        } else {
                          // Check connectivity when offline
                          ConnectivityFirstCommand.checkConnectivity(context);
                        }
                      },
                      child: Text(isOnline ? 'Refresh' : 'Check Connection'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          ConnectivityQualityCommand.checkQuality(context),
                      child: const Text('Check Quality'),
                    ),
                    if (!isOnline) ...[
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () =>
                            ConnectivityFirstCommand.restartConnectivity(
                              context,
                            ),
                        child: const Text('Restart Connectivity'),
                      ),
                    ],
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
