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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline First Example')),
      body: ConnectivityFirstApp(
        builder: (isOnline) => Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isOnline ? 'You are online' : 'You are offline',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
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
