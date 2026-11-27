# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial package skeleton.
- `Oito2Window.ensureInitialized`: hides the native title bar for client-side decorations on Linux, Windows and macOS (keeping the macOS traffic lights) and returns an `Oito2WindowController` backed by `window_manager`; returns null on the web, Android and iOS.
- `Oito2NativeWindowController` implements `Oito2WindowCloseGuard`: while close handlers are added, such as an `Oito2UnsavedChangesGuard` with unsaved changes, it holds every native close request pending, asks the handlers and lets the request through once they all allow it, or cancels it and keeps the window open.

### Changed

- `Oito2NativeWindowController` is exported, so the app can dispose it, and `Oito2Window.ensureInitialized` returns null when no native window can be found.
- Requires `window_manager` 0.7.1 and with it Flutter 3.50 / Dart 3.14 and macOS 10.15. `window_manager` no longer ships platform plugin code: its native library is built from source, which on Linux needs the GTK 3, X11 and Xi development files (`libgtk-3-dev libx11-dev libxi-dev` on Debian and Ubuntu).
- Uses the native `Window` API of `window_manager` 0.7 (from nativeapi) instead of its deprecated 0.5.x-compatible `legacy.dart` bridge. The window options, state, actions, window menu and close guard behave as before; on Windows the window is still found while it is hidden at startup.
- `Oito2NativeWindowController` is created only by `Oito2Window.ensureInitialized`: apps use it through `Oito2WindowController` and `Oito2WindowCloseGuard`, and may still dispose it. It is a `final` class, also exported on the web.

### Removed

- `Oito2NativeWindowController.attach`, which took the legacy `WindowManager`; `Oito2Window.ensureInitialized` creates the controller.
- The web stub of `Oito2NativeWindowController`: the same class compiles on every platform.

### Fixed

- `Oito2NativeWindowController`: a close handler that throws keeps the window open and reports its error through `FlutterError.reportError`, instead of leaving an uncaught error; the next close request asks the handlers again.
- `Oito2NativeWindowController.dispose` lets the native close through again when close handlers held it back, so the window can still be closed, and forgets the handlers; calling it again does nothing.
- `Oito2NativeWindowController.refresh` keeps the last state when the window can't be queried, when a window event arrives meanwhile, or after `dispose`.
