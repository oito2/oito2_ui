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

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// The state of the native window, as shown by the title bar.
@immutable
class Oito2WindowState {
  /// Creates a window state.
  const Oito2WindowState({
    this.isMaximized = false,
    this.isFullScreen = false,
    this.isActive = true,
    this.canShowMenu = false,
  });

  /// Whether the window fills the work area.
  final bool isMaximized;

  /// Whether the window is in full-screen mode.
  final bool isFullScreen;

  /// Whether the window has the input focus.
  final bool isActive;

  /// Whether the platform can show the native window menu.
  final bool canShowMenu;

  /// Returns a copy with the given fields replaced.
  Oito2WindowState copyWith({
    bool? isMaximized,
    bool? isFullScreen,
    bool? isActive,
    bool? canShowMenu,
  }) {
    return Oito2WindowState(
      isMaximized: isMaximized ?? this.isMaximized,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      isActive: isActive ?? this.isActive,
      canShowMenu: canShowMenu ?? this.canShowMenu,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2WindowState &&
      other.isMaximized == isMaximized &&
      other.isFullScreen == isFullScreen &&
      other.isActive == isActive &&
      other.canShowMenu == canShowMenu;

  @override
  int get hashCode =>
      Object.hash(isMaximized, isFullScreen, isActive, canShowMenu);

  @override
  String toString() =>
      'Oito2WindowState(isMaximized: $isMaximized, '
      'isFullScreen: $isFullScreen, isActive: $isActive, '
      'canShowMenu: $canShowMenu)';
}

/// Controls the native window that hosts the app.
///
/// `oito2_ui` only defines this contract; the `oito2_ui_window` package
/// implements it on Linux, Windows and macOS.
abstract interface class Oito2WindowController {
  /// The current window state, updated as the window changes.
  ValueListenable<Oito2WindowState> get state;

  /// Minimizes the window.
  Future<void> minimize();

  /// Maximizes the window, or restores it when it is maximized.
  Future<void> toggleMaximize();

  /// Asks the window to close.
  Future<void> close();

  /// Starts moving the window with the pointer that is currently pressed.
  Future<void> startDrag();

  /// Shows the native window menu, when [Oito2WindowState.canShowMenu] is
  /// true.
  Future<void> showMenu();
}

/// Exposes an [Oito2WindowController] to the widgets below it.
class Oito2WindowScope extends InheritedWidget {
  /// Creates a scope that provides [controller] to [child].
  const Oito2WindowScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The controller provided to descendant widgets, or null when the app
  /// doesn't control its window (for example on the web).
  final Oito2WindowController? controller;

  /// Returns the controller of the closest enclosing [Oito2WindowScope], or
  /// null when there is none.
  static Oito2WindowController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Oito2WindowScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(Oito2WindowScope oldWidget) =>
      controller != oldWidget.controller;
}
