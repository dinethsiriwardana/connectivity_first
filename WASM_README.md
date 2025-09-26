# WebAssembly (Wasm) Support for connectivity_first

This document explains how to build and run the `connectivity_first` Flutter package with WebAssembly (Wasm) compilation support.

## Overview

WebAssembly (Wasm) provides near-native performance for Flutter web applications by compiling Dart code to WebAssembly bytecode. This is particularly beneficial for performance-critical applications like connectivity monitoring and real-time data synchronization.

## Prerequisites

- Flutter SDK 3.8.1 or higher
- A modern web browser that supports WebAssembly
- Node.js (optional, for advanced serving options)

## Quick Start

### 1. Build with WebAssembly

```bash
# Build the example with WebAssembly support
./build_wasm.sh
```

### 2. Serve the Application

```bash
# Start the development server
./serve_wasm.sh
```

The application will be available at `http://localhost:8080`

## Manual Build Commands

If you prefer to run commands manually:

### Development Build

```bash
cd example
flutter run -d web-server --web-port 8080 --web-renderer canvaskit
```

### Production Build

```bash
cd example
flutter build web \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/ \
  --release \
  --source-maps \
  --web-resources-cdn \
  --tree-shake-icons
```

## WebAssembly Benefits for connectivity_first

1. **Performance**: Near-native performance for connectivity checks and network monitoring
2. **Real-time Processing**: Faster BLoC state updates and UI rebuilds
3. **Offline Capabilities**: Improved performance for local data processing
4. **Memory Efficiency**: Better memory management for long-running connectivity monitoring

## Configuration Options

The build uses the following optimizations:

- **CanvasKit Renderer**: Hardware-accelerated rendering with WebAssembly
- **Tree Shaking**: Removes unused code for smaller bundle sizes
- **Source Maps**: Enables debugging in production builds
- **CDN Resources**: Loads Flutter resources from CDN for better caching

## Browser Compatibility

WebAssembly is supported in:
- Chrome 57+
- Firefox 52+
- Safari 11+
- Edge 16+

## Performance Considerations

1. **Initial Load**: WebAssembly builds may have a slightly larger initial bundle
2. **Runtime Performance**: Significantly faster execution, especially for:
   - Network connectivity checks
   - BLoC state management
   - Real-time data processing
   - UI animations and updates

## Troubleshooting

### Build Issues

If you encounter build issues:

```bash
cd example
flutter clean
flutter pub get
flutter doctor
```

### Browser Issues

Ensure your browser supports WebAssembly:

```javascript
// Check WebAssembly support in browser console
console.log('WebAssembly supported:', typeof WebAssembly === 'object');
```

### Performance Debugging

Enable Flutter's performance overlay:

```dart
MaterialApp(
  showPerformanceOverlay: true,
  // ... your app
)
```

## Advanced Configuration

### Custom WebAssembly Settings

Edit `wasm.config` to customize WebAssembly compilation:

```bash
# Enable SIMD for better performance
WASM_SIMD_ENABLED=true

# Enable threads for parallel processing
WASM_THREADS_ENABLED=true
```

### HTTP Headers

For production deployment, ensure your server sends proper headers:

```
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
```

## Integration with connectivity_first Features

The WebAssembly build enhances all connectivity_first features:

- **ConnectivityFirstService**: Faster network state detection
- **ConnectivityBloc**: More responsive state management
- **Global Connectivity Manager**: Improved real-time updates
- **Offline-First Widgets**: Better performance during connectivity transitions

## File Structure

```
connectivity_first/
├── build_wasm.sh              # WebAssembly build script
├── serve_wasm.sh              # Development server script
├── wasm.config                # WebAssembly configuration
├── example/
│   ├── web/
│   │   ├── index.html         # WebAssembly-enabled HTML
│   │   └── manifest.json      # PWA manifest
│   ├── main.dart              # Example application
│   └── pubspec.yaml           # Example dependencies
└── WASM_README.md             # This documentation
```

## Next Steps

1. Run `./build_wasm.sh` to create your first WebAssembly build
2. Test performance improvements with your connectivity monitoring
3. Deploy to your preferred hosting platform
4. Monitor performance metrics and optimize as needed

For more information, visit the [Flutter WebAssembly documentation](https://flutter.dev/docs/development/platform-integration/web/building).