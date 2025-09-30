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
        builder: (isOnline, quality) => Container(
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
                onPressed: () => ConnectivityQualityCommand.checkQuality(context),
                child: const Text('Check Quality'),
              ),
              if (!isOnline) ...[
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () =>
                      ConnectivityFirstCommand.restartConnectivity(context),
                  child: const Text('Restart Connectivity'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
