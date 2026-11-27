// Copyright (C) 2026  OITO2
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:nativeapi/nativeapi.dart' show DisplayManager;
import 'package:window_manager/window_manager.dart';

import 'native_window_port.dart';

/// Runs [body] and returns its result, or null when the native library
/// isn't loaded, as in a test that runs without the desktop runner.
T? tryNative<T>(T Function() body) {
  try {
    return body();
  } on ArgumentError {
    return null;
  }
}

/// A [NativeWindowPort] over a `window_manager` [Window].
final class WindowManagerPort implements NativeWindowPort {
  /// Creates a port that drives [window].
  WindowManagerPort(this._window);

  final Window _window;

  /// Returns the result of [query], or throws a
  /// [NativeWindowUnavailableException] when the native library isn't
  /// loaded.
  bool _query(bool Function() query) {
    try {
      return query();
    } on ArgumentError {
      throw const NativeWindowUnavailableException();
    }
  }

  @override
  Future<bool> isMaximized() async => _query(() => _window.isMaximized);

  @override
  Future<bool> isFullScreen() async => _query(() => _window.isFullScreen);

  @override
  Future<bool> isFocused() async => _query(() => _window.isFocused);

  @override
  Future<void> minimize() async => _window.minimize();

  @override
  Future<void> maximize() async => _window.maximize();

  @override
  Future<void> unmaximize() async {
    if (_window.isMaximizedVertically) _window.setMaximizedVertically(false);
    _window.unmaximize();
  }

  @override
  Future<void> close() async => _window.close();

  @override
  Future<void> startDragging() async => _window.startDragging();

  /// Opens the system menu at the cursor position, given relative to the
  /// window content; does nothing where the platform has no system menu.
  @override
  Future<void> showSystemMenu() async {
    tryNative(() {
      if (!Window.isSystemMenuSupported()) return;
      final cursor = DisplayManager.instance.getCursorPosition().toOffset();
      final content = _window.contentBounds.toRect();
      _window.showSystemMenu((cursor - content.topLeft).toNative());
    });
  }

  /// Forwards the maximize, restore, focus, full-screen and close request
  /// events of the window to [listener]; a close request stays pending
  /// until the future [listener] returns completes.
  @override
  void Function() addListener(NativeWindowListener listener) {
    final id = _window.addListener((event) {
      switch (event) {
        case WindowMaximizedEvent():
          return listener(const NativeWindowMaximized());
        case WindowRestoredEvent():
          return listener(const NativeWindowRestored());
        case WindowFocusedEvent():
          return listener(const NativeWindowFocused());
        case WindowBlurredEvent():
          return listener(const NativeWindowBlurred());
        case WindowEnteredFullScreenEvent():
          return listener(const NativeWindowEnteredFullScreen());
        case WindowExitedFullScreenEvent():
          return listener(const NativeWindowExitedFullScreen());
        case WindowCloseRequestedEvent(:final request):
          return listener(NativeWindowCloseRequested(request.cancel));
        default:
          return null;
      }
    });
    return () => _window.removeListener(id);
  }
}
