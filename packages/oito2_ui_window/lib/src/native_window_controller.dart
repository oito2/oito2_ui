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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'native_window_port.dart';

/// Creates an [Oito2NativeWindowController] for [port], reads the current
/// window state and starts listening to window events.
///
/// [canShowMenu] tells whether the platform supports the native window
/// menu.
Future<Oito2NativeWindowController> attachNativeWindowController(
  NativeWindowPort port, {
  required bool canShowMenu,
}) async {
  final controller = Oito2NativeWindowController._(
    port,
    canShowMenu: canShowMenu,
  );
  await controller.refresh();
  controller._removeListener = port.addListener(controller._onEvent);
  return controller;
}

/// The [Oito2WindowController] of the app's native window on Linux, Windows
/// and macOS, backed by `window_manager`.
///
/// `Oito2Window.ensureInitialized` creates it; the app keeps it, hands it
/// to an [Oito2WindowScope] and may [dispose] it. It forwards the window
/// actions to the native window and keeps [state] in sync with its
/// maximize, focus and full-screen events.
///
/// As an [Oito2WindowCloseGuard], it holds every native close request while
/// close handlers are added: the request asks the handlers and goes through
/// once every one of them allows it, or keeps the window open otherwise.
final class Oito2NativeWindowController
    implements Oito2WindowController, Oito2WindowCloseGuard {
  Oito2NativeWindowController._(this._port, {required bool canShowMenu})
    : _state = ValueNotifier(Oito2WindowState(canShowMenu: canShowMenu));

  final NativeWindowPort _port;
  final ValueNotifier<Oito2WindowState> _state;

  /// Stops the window events, once listening started.
  void Function()? _removeListener;

  @override
  ValueListenable<Oito2WindowState> get state => _state;

  bool _disposed = false;

  /// Counts state changes, so a refresh that a window event overtakes
  /// doesn't overwrite it.
  int _generation = 0;

  /// Reads the maximized, full-screen and focus state from the window.
  ///
  /// The last known state stays when the window can't be queried, when a
  /// window event arrives meanwhile, or after [dispose].
  Future<void> refresh() async {
    final generation = ++_generation;
    try {
      final isMaximized = await _port.isMaximized();
      final isFullScreen = await _port.isFullScreen();
      final isActive = await _port.isFocused();
      if (_disposed || generation != _generation) return;
      _state.value = _state.value.copyWith(
        isMaximized: isMaximized,
        isFullScreen: isFullScreen,
        isActive: isActive,
      );
    } on NativeWindowUnavailableException {
      return;
    }
  }

  /// Applies [change] to [state] and invalidates any refresh in flight,
  /// unless the controller is disposed.
  void _update(Oito2WindowState Function(Oito2WindowState state) change) {
    if (_disposed) return;
    _generation++;
    _state.value = change(_state.value);
  }

  @override
  Future<void> minimize() => _port.minimize();

  @override
  Future<void> toggleMaximize() async {
    if (await _port.isMaximized()) {
      await _port.unmaximize();
    } else {
      await _port.maximize();
    }
  }

  @override
  Future<void> close() => _port.close();

  final List<Oito2WindowCloseHandler> _closeHandlers = [];

  /// Whether the close handlers are being asked.
  bool _askingToClose = false;

  @override
  void addCloseHandler(Oito2WindowCloseHandler handler) {
    _closeHandlers.add(handler);
  }

  @override
  void removeCloseHandler(Oito2WindowCloseHandler handler) {
    _closeHandlers.remove(handler);
  }

  /// Asks the close handlers, the last added first, and lets [request]
  /// through when every one of them allows it; otherwise cancels it, which
  /// keeps the window open.
  ///
  /// A handler that throws keeps the window open: its error goes to
  /// [FlutterError.reportError] and the remaining handlers aren't asked.
  ///
  /// Lets the request through at once when there are no handlers or the
  /// controller is disposed, and cancels a request that arrives while the
  /// handlers are already being asked. The request stays pending until the
  /// returned future completes.
  Future<void> _askToClose(NativeWindowCloseRequested request) async {
    if (_disposed || _closeHandlers.isEmpty) return;
    if (_askingToClose) {
      request.cancel();
      return;
    }
    _askingToClose = true;
    try {
      for (final handler in _closeHandlers.reversed.toList()) {
        final bool allowed;
        try {
          allowed = await handler();
        } on Object catch (error, stack) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stack,
              library: 'oito2_ui_window',
              context: ErrorDescription('while asking a window close handler'),
            ),
          );
          request.cancel();
          return;
        }
        if (!allowed) {
          request.cancel();
          return;
        }
      }
      if (_disposed) request.cancel();
    } finally {
      _askingToClose = false;
    }
  }

  @override
  Future<void> startDrag() => _port.startDragging();

  @override
  Future<void> showMenu() async {
    if (_state.value.canShowMenu) await _port.showSystemMenu();
  }

  /// Stops listening to window events, which lets the native close through
  /// again when close handlers held it back, forgets the close handlers
  /// and releases [state].
  ///
  /// Calling it again does nothing.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _removeListener?.call();
    _removeListener = null;
    _closeHandlers.clear();
    _state.dispose();
  }

  /// Updates [state] from [event], or asks the close handlers when the
  /// window is asked to close; a close request stays pending until the
  /// returned future completes.
  FutureOr<void> _onEvent(NativeWindowEvent event) {
    switch (event) {
      case NativeWindowMaximized():
        _update((s) => s.copyWith(isMaximized: true));
      case NativeWindowRestored():
        unawaited(refresh());
      case NativeWindowFocused():
        _update((s) => s.copyWith(isActive: true));
      case NativeWindowBlurred():
        _update((s) => s.copyWith(isActive: false));
      case NativeWindowEnteredFullScreen():
        _update((s) => s.copyWith(isFullScreen: true));
      case NativeWindowExitedFullScreen():
        _update((s) => s.copyWith(isFullScreen: false));
      case NativeWindowCloseRequested():
        return _askToClose(event);
    }
  }
}
