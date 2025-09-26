# Connectivity First

A Flutter package for building offline-first applications with automatic connectivity management, realtime status monitoring, and simple UI helpers built on the BLoC pattern.

---

## Quick summary

This package helps Flutter apps detect online/offline state, react to connectivity changes, and expose a few small APIs and widgets to make UI updates and programmatic checks simple. It is intended to be lightweight and easy to integrate into existing apps.

Key features:

- **WebAssembly (WASM) compatible** - Full support for Flutter web WASM builds
- Global connectivity monitoring using a provider widget
- A simple `ConnectivityFirstApp` widget that rebuilds based on connectivity
- Programmatic commands to check status, restart monitoring, and start/stop periodic checks
- Small set of utilities designed to integrate with BLoC or other state management approaches

---

## Installation

Add the package to your app's `pubspec.yaml` or use the convenience command:

```bash
flutter pub add connectivity_first
```

Then run:

```bash
flutter pub get
```

Minimum supported Flutter SDK: see `pubspec.yaml` in this repo for exact constraints.

---

## Basic usage

1. Import the package in your Dart files:

```dart
import 'package:connectivity_first/flutter_connectivity_first.dart';
```

2. Wrap your app with `ConnectivityFirstProvider` (usually above `MaterialApp`) to enable global monitoring and callbacks:

```dart
import 'package:flutter/material.dart';
import 'package:connectivity_first/flutter_connectivity_first.dart';

 return MaterialApp(
      home:
      ConnectivityFirstProvider(
        onConnectivityRestored: () {
          print('Internet restored!');
        },
        onConnectivityLost: () {
          print('Internet lost!');
        },
        builder: const MyHomePage(),
      ),
    );

```

3. Use `ConnectivityFirstApp` somewhere in your widget tree to rebuild UI based on the current connectivity state:

```dart

  @override
  Widget build(BuildContext context) {
    return ConnectivityFirstApp(
      builder: (isOnline) => Scaffold(
        appBar: AppBar(title: const Text('Offline First Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isOnline ? 'You are online' : 'You are offline',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (isOnline) {
                    // refresh UIs or data
                    ConnectivityFirstCommand.reloadAllUIs(context);
                  } else {
                    // try a manual connectivity check
                    ConnectivityFirstCommand.checkConnectivity(context);
                  }
                },
                child: Text(isOnline ? 'Refresh' : 'Check Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }

```

---

## Programmatic API (examples)

Use the connectivity command helpers to trigger checks or control monitoring from code.

```dart
// Check current connectivity status (triggers an immediate check)
await ConnectivityFirstCommand.checkConnectivity(context);

// Reload UI components or notify listeners
ConnectivityFirstCommand.reloadAllUIs(context);

// Restart listening for connectivity changes
ConnectivityFirstCommand.restartConnectivity(context);

// Start/stop periodic checks
ConnectivityFirstCommand.startPeriodicCheck(context);
ConnectivityFirstCommand.stopPeriodicCheck(context);
```

Direct access to the connectivity service (if you need programmatic state):

```dart
final service = ConnectivityFirstService();
final isConnected = service.isConnected; // bool

service.startPeriodicCheck();
service.stopPeriodicCheck();
service.checkConnectivity();
service.restartListening();
```

---

## Platform & permissions notes

This package depends on native connectivity capabilities (via `connectivity_plus`). Some platforms require app-level permissions/configuration:

- Android: ensure you have the appropriate network permissions in `android/app/src/main/AndroidManifest.xml` (usually no special permission is needed for connectivity detection, but if you perform network requests you may need `INTERNET`).
- iOS: if you perform additional network probes (not just interface state), you may need to add keys to `Info.plist` for networking usage descriptions.

For details, consult the `connectivity_plus` package documentation.

---

## Contributing

Contributions welcome! Please open issues for feature requests or bugs. Basic workflow:

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-feature`
3. Make changes and add tests
4. Run `flutter test` and verify the example
5. Open a pull request

---

## Changelog

See `CHANGELOG.md` for recent releases and notes.

---

## License

MIT — see the `LICENSE` file for details.

---

## Acknowledgments

- Built with `flutter_bloc`
- Connectivity detection powered by `connectivity_plus`
- Logging by `logger`
