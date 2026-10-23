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

import 'dart:ui' show Size;

import 'package:oito2_ui/oito2_ui.dart';

import 'window_stub.dart' if (dart.library.io) 'window_io.dart' as platform;

/// Entry point for native window integration.
abstract final class Oito2Window {
  /// Hides the native title bar, applies the initial window options, shows
  /// the window and returns an [Oito2WindowController] for it.
  ///
  /// [title] sets the window title, [size] the initial size and
  /// [minimumSize] the smallest size the user can resize it to; when
  /// [center] is true the window opens centered on the screen.
  ///
  /// Call it in `main` before `runApp`, and provide the result through an
  /// [Oito2WindowScope]. Returns null on the web, Android and iOS, where
  /// the app doesn't own a desktop window, and when the window plugin
  /// isn't available; `Oito2WindowTitleBar` then adapts on its own. On
  /// desktop the controller is an [Oito2NativeWindowController], which the
  /// app can dispose when it no longer needs it.
  ///
  /// On macOS the native traffic lights stay visible over the hidden
  /// title bar.
  static Future<Oito2WindowController?> ensureInitialized({
    String? title,
    Size? size,
    Size? minimumSize,
    bool center = true,
  }) {
    return platform.ensureInitialized(
      title: title,
      size: size,
      minimumSize: minimumSize,
      center: center,
    );
  }
}
