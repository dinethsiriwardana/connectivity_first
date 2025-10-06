# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2025-10-06

### Added
- **Connectivity Logging Control**: New logging configuration options for better control over debug output
  - `loggerConnectivity` parameter in `ConnectivityFirstProvider` to enable/disable connectivity logging (default: `true`)
  - `loggerQualityMonitoring` parameter in `ConnectivityFirstProvider` to enable/disable quality monitoring logging (default: `true`)
  - Updated `ConnectivityFirstBloc`, `ConnectivityQualityBloc`, and related services to respect logging settings
  - Enhanced `ConnectivityLogger` utility with configurable logging levels
  - Improved example app with logging configuration examples

## [2.0.0] - 2025-09-30

### Added
- **Connection Quality Monitoring**: New feature for real-time latency-based quality assessment
  - `ConnectivityQualityService` for measuring connection quality using HTTP requests to Google's generate_204 endpoint
  - `ConnectivityQualityBloc` for state management of quality monitoring
  - Five quality levels: `none`, `poor`, `fair`, `good`, `excellent` based on latency thresholds
  - `ConnectivityQualityCommand` utility class for easy quality management throughout the app
  - Periodic quality monitoring with automatic quality updates
  - Quality-aware `ConnectivityFirstApp` widget that now provides both connectivity status and quality to builder function
- **Auto-Enable Configuration**: New automatic service initialization options
  - `autoEnableConnectivity` parameter in `ConnectivityFirstProvider` (default: `true`)
  - `autoEnableQualityMonitoring` parameter in `ConnectivityFirstProvider` (default: `true`)
  - Both connectivity and quality monitoring now start automatically by default
- **Configurable Quality Check Interval**: 
  - `qualityCheckInterval` parameter in `ConnectivityFirstProvider` (default: 10 seconds)
  - `updateCheckInterval()` method in `ConnectivityQualityService` for dynamic interval changes
  - Support for custom intervals from seconds to minutes

### Changed
- **Breaking Change**: `ConnectivityFirstApp` builder function signature changed from `(bool isOnline)` to `(bool isOnline, ConnectionQuality quality)`
- `ConnectivityFirstProvider` now uses `MultiBlocProvider` to provide both connectivity and quality blocs
- `ConnectivityFirstGlobalManager` enhanced with auto-enable functionality and service initialization
- `ConnectivityQualityService` now accepts configurable check intervals
- Updated example app to demonstrate new configuration options and quality monitoring features
- Enhanced README with comprehensive configuration documentation and examples

### Dependencies
- Added `http: ^2.0.0` dependency for quality measurement HTTP requests

## [1.0.2] - 2025-09-28

### Fixed
- **Documentation**: Fixed incorrect import statement in README (`connectivity_first` instead of `flutter_connectivity_first`)
- **Documentation**: Updated acknowledgments section to reflect removal of logger dependency
- **Documentation**: Corrected contributing workflow formatting and numbering

### Changed
- **Documentation**: Enhanced contribution guidelines with proper workflow steps

## [1.0.1] - 2025-09-26

### Fixed
- **WASM Compatibility**: Removed dependency on `logger` package that imported `dart:io`, which was incompatible with WebAssembly runtime
- Replaced `logger` package with custom `ConnectivityLogger` utility that uses Flutter's `debugPrint` for WASM compatibility

### Added
- **ConnectivityLogger**: New WASM-compatible logging utility exported from the main library
- Full WebAssembly (WASM) runtime support for all connectivity monitoring features

## [1.0.0] - 2025-09-21

### Added

- Initial stable release of `connectivity_first`.
- Core connectivity_first synchronization utilities and BLoC connectivity wrappers.
- Example app demonstrating integration and platform support.

### Fixed

- N/A — initial stable release.

### Changed

- N/A — initial release.

### Contributors

- Maintainer: dinethsiriwardana
