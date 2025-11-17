# Connectivity First

A Flutter package for building offline-first applications with automatic connectivity management, realtime status monitoring, and simple UI helpers built on the BLoC pattern.

---

## Quick summary

This package helps Flutter apps detect online/offline state, react to connectivity changes, and expose a few small APIs and widgets to make UI updates and programmatic checks simple. It is intended to be lightweight and easy to integrate into existing apps.

Key features:

- **WebAssembly (WASM) compatible** - Full support for Flutter web WASM builds
- **Auto-enabled by default** - Both connectivity and quality monitoring start automatically
- **State-based UI** - Different screens for initiating, listening, and error states
- **Connection stability delay** - Prevents flickering from brief network interruptions
- Global connectivity monitoring using a provider widget
- **Connection quality assessment** - Real-time latency-based quality monitoring with configurable intervals
- A simple `ConnectivityFirstApp` widget that rebuilds based on connectivity and quality
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
import 'package:connectivity_first/connectivity_first.dart';
```

2. Wrap your app with `ConnectivityFirstProvider` (usually above `MaterialApp`) to enable global monitoring and callbacks:

```dart
import 'package:flutter/material.dart';
import 'package:connectivity_first/connectivity_first.dart';

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

### State-Based UI

The `ConnectivityFirstApp` widget now supports state-based UI rendering with different screens for different connectivity phases:

- **`ConnectivityAppState.initiating`** - Initial loading/checking state
- **`ConnectivityAppState.listening`** - Active monitoring state (normal operation)
- **`ConnectivityAppState.error`** - Error state when connectivity checks fail

The builder function receives: `(ConnectivityAppState state, bool isOnline, ConnectionQuality quality, String? error)`

### Connection Stability Delay

To prevent UI flickering from brief network interruptions, you can configure a stability delay that waits before confirming offline state changes:

```dart
ConnectivityFirstProvider(
  connectionStabilityDelay: const Duration(seconds: 3), // Wait 3 seconds before going offline
  builder: MyApp(),
)
```

- When connection drops, it waits the specified delay before switching to offline
- If connection recovers within the delay, it stays online
- Coming back online happens immediately (no delay)

---

## Configuration Options

The `ConnectivityFirstProvider` offers several configuration options to customize behavior:

### Auto-Enable Services

By default, both connectivity monitoring and connection quality monitoring are automatically enabled. You can control this:

```dart
ConnectivityFirstProvider(
  // Automatically enable connectivity monitoring (default: true)
  autoEnableConnectivity: true,
  
  // Automatically enable quality monitoring (default: true)
  autoEnableQualityMonitoring: true,
  
  // Custom interval for quality checks (default: 10 seconds)
  qualityCheckInterval: const Duration(seconds: 5),
  
  // Delay before confirming offline state (default: 3 seconds)
  connectionStabilityDelay: const Duration(seconds: 3),
  
  onConnectivityRestored: () => print('Internet restored!'),
  onConnectivityLost: () => print('Internet lost!'),
  builder: const MyHomePage(),
)
```

### Configuration Examples

**Minimal setup (everything auto-enabled):**
```dart
ConnectivityFirstProvider(
  builder: MyApp(), // Both services start automatically
)
```

**Custom quality check interval:**
```dart
ConnectivityFirstProvider(
  qualityCheckInterval: const Duration(seconds: 30), // Check every 30 seconds
  builder: MyApp(),
)
```

**Selective auto-enabling:**
```dart
ConnectivityFirstProvider(
  autoEnableConnectivity: false,          // Manual connectivity control
  autoEnableQualityMonitoring: true,      // Auto-start quality monitoring
  qualityCheckInterval: const Duration(minutes: 1), // Check every minute
  builder: MyApp(),
)
```

---



3. Use `ConnectivityFirstApp` somewhere in your widget tree to rebuild UI based on the current connectivity state and quality:

```dart
  @override
  Widget build(BuildContext context) {
    return ConnectivityFirstApp(
      builder: (state, isOnline, quality, error) {
        switch (state) {
          case ConnectivityAppState.initiating:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectivityAppState.error:
            return Center(
              child: Text('Error: $error'),
            );
          case ConnectivityAppState.listening:
            return Scaffold(
              appBar: AppBar(title: const Text('Offline First Example')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isOnline ? 'You are online' : 'You are offline',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Connection Quality: ${quality.name}',
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
            );
        }
      },
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

## Connection Quality Monitoring

The package now includes connection quality assessment based on latency measurements. This feature provides real-time quality monitoring to help you build adaptive UI experiences.

### Connection Quality Levels

- **`ConnectionQuality.none`** - No connection available
- **`ConnectionQuality.poor`** - High latency (>600ms)
- **`ConnectionQuality.fair`** - Moderate latency (300-600ms)
- **`ConnectionQuality.good`** - Low latency (100-300ms)
- **`ConnectionQuality.excellent`** - Very low latency (<100ms)

### Quality Commands

Use the connectivity quality command helpers to control quality monitoring:

```dart
// Check current connection quality (triggers an immediate check)
ConnectivityQualityCommand.checkQuality(context);

// Start/stop periodic quality checks
ConnectivityQualityCommand.startPeriodicQualityCheck(context);
ConnectivityQualityCommand.stopPeriodicQualityCheck(context);

// Restart quality monitoring
ConnectivityQualityCommand.restartQualityMonitoring(context);
```

Direct access to the quality service:

```dart
final service = ConnectivityQualityService();
final quality = await service.measureConnectionQuality();
final currentQuality = service.currentQuality;

service.startPeriodicCheck();
service.stopPeriodicCheck();
service.restartMonitoring();
```

### Example: Adaptive UI Based on Quality

```dart
Widget build(BuildContext context) {
  return ConnectivityFirstApp(
    builder: (isOnline, quality) {
      return Scaffold(
        body: Column(
          children: [
            Text('Status: ${isOnline ? 'Online' : 'Offline'}'),
            Text('Quality: ${quality.name}'),
            if (quality == ConnectionQuality.poor)
              const Text('Slow connection detected. Some features may be limited.')
            else if (quality == ConnectionQuality.excellent)
              const Text('Excellent connection! All features available.')
            else if (quality == ConnectionQuality.none)
              const Text('No connection. Working in offline mode.'),
          ],
        ),
      );
    },
  );
}
```

---

## Migration Guide

### Upgrading from 1.0.x to 2.0.0

**Breaking Change**: The `ConnectivityFirstApp` builder function signature has changed to include connection quality and state.

**Before (1.0.x):**
```dart
ConnectivityFirstApp(
  builder: (isOnline) => YourWidget(isOnline: isOnline),
)
```

**After (2.0.0):**
```dart
ConnectivityFirstApp(
  builder: (state, isOnline, quality, error) {
    switch (state) {
      case ConnectivityAppState.initiating:
        return LoadingWidget();
      case ConnectivityAppState.error:
        return ErrorWidget(error: error);
      case ConnectivityAppState.listening:
        return YourWidget(isOnline: isOnline, quality: quality);
    }
  },
)
```

If you don't need the advanced state handling, you can ignore the extra parameters:
```dart
ConnectivityFirstApp(
  builder: (_, isOnline, quality, _) => YourWidget(
    isOnline: isOnline,
    quality: quality,
  ),
)
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
3. Make changes
4. Update the CHANGELOG.md
5. Run `dart format .`
6. Open a pull request

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
- WASM-compatible logging using Flutter's `debugPrint`
