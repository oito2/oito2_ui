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
import 'package:flutter/services.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:window_manager/window_manager.dart';

/// An [Oito2WindowController] backed by `window_manager`.
///
/// Forwards the window actions to a [WindowManager] and keeps [state] in
/// sync with its maximize, focus and full-screen events.
class Oito2NativeWindowController
    with WindowListener
    implements Oito2WindowController {
  Oito2NativeWindowController._(this._manager, {required bool canShowMenu})
    : _state = ValueNotifier(Oito2WindowState(canShowMenu: canShowMenu));

  /// Creates a controller for [manager], reads the current window state and
  /// starts listening to window events.
  ///
  /// [canShowMenu] tells whether the platform supports the native window
  /// menu.
  static Future<Oito2NativeWindowController> attach(
    WindowManager manager, {
    required bool canShowMenu,
  }) async {
    final controller = Oito2NativeWindowController._(
      manager,
      canShowMenu: canShowMenu,
    );
    await controller.refresh();
    manager.addListener(controller);
    return controller;
  }

  final WindowManager _manager;
  final ValueNotifier<Oito2WindowState> _state;

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
      final isMaximized = await _manager.isMaximized();
      final isFullScreen = await _manager.isFullScreen();
      final isActive = await _manager.isFocused();
      if (_disposed || generation != _generation) return;
      _state.value = _state.value.copyWith(
        isMaximized: isMaximized,
        isFullScreen: isFullScreen,
        isActive: isActive,
      );
    } on PlatformException {
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
  Future<void> minimize() => _manager.minimize();

  @override
  Future<void> toggleMaximize() async {
    if (await _manager.isMaximized()) {
      await _manager.unmaximize();
    } else {
      await _manager.maximize();
    }
  }

  @override
  Future<void> close() => _manager.close();

  @override
  Future<void> startDrag() => _manager.startDragging();

  @override
  Future<void> showMenu() async {
    if (_state.value.canShowMenu) await _manager.popUpWindowMenu();
  }

  /// Stops listening to window events and releases [state].
  void dispose() {
    _disposed = true;
    _manager.removeListener(this);
    _state.dispose();
  }

  @override
  void onWindowMaximize() => _update((s) => s.copyWith(isMaximized: true));

  @override
  void onWindowUnmaximize() => _update((s) => s.copyWith(isMaximized: false));

  @override
  void onWindowFocus() => _update((s) => s.copyWith(isActive: true));

  @override
  void onWindowBlur() => _update((s) => s.copyWith(isActive: false));

  @override
  void onWindowEnterFullScreen() =>
      _update((s) => s.copyWith(isFullScreen: true));

  @override
  void onWindowLeaveFullScreen() =>
      _update((s) => s.copyWith(isFullScreen: false));

  @override
  void onWindowRestore() => unawaited(refresh());
}
