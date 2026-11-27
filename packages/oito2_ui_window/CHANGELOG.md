# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial package skeleton.
- `Oito2Window.ensureInitialized`: hides the native title bar for client-side decorations on Linux, Windows and macOS (keeping the macOS traffic lights) and returns an `Oito2WindowController` backed by `window_manager`; returns null on the web, Android and iOS.
- `Oito2NativeWindowController` implements `Oito2WindowCloseGuard`: while close handlers are added, such as an `Oito2UnsavedChangesGuard` with unsaved changes, it holds back the native close with `setPreventClose`, asks the handlers when the window is asked to close and destroys it once they all allow it.

### Changed

- `Oito2NativeWindowController` is exported, so the app can dispose it, and `Oito2Window.ensureInitialized` returns null when the window plugin isn't available.

### Fixed

- `Oito2NativeWindowController`: a close handler that throws keeps the window open and reports its error through `FlutterError.reportError`, instead of leaving an uncaught error; the next close request asks the handlers again.
- `Oito2NativeWindowController.dispose` lets the native close through again when close handlers held it back, so the window can still be closed, and forgets the handlers; calling it again does nothing.
- `Oito2NativeWindowController.refresh` keeps the last state when the window can't be queried, when a window event arrives meanwhile, or after `dispose`.
