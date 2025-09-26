# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
