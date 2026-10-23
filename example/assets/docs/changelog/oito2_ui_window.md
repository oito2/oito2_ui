# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial package skeleton.
- `Oito2Window.ensureInitialized`: hides the native title bar for client-side decorations on Linux, Windows and macOS (keeping the macOS traffic lights) and returns an `Oito2WindowController` backed by `window_manager`; returns null on the web, Android and iOS.

### Changed

- `Oito2NativeWindowController` is exported, so the app can dispose it, and `Oito2Window.ensureInitialized` returns null when the window plugin isn't available.

### Fixed

- `Oito2NativeWindowController.refresh` keeps the last state when the window can't be queried, when a window event arrives meanwhile, or after `dispose`.
