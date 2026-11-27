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

// The window_manager 0.5.x API lives on, deprecated, in its legacy library.
// ignore_for_file: deprecated_member_use

import 'dart:io' show Platform;
import 'dart:ui' show Size;

import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:oito2_ui/oito2_ui.dart';
import 'package:window_manager/legacy.dart';

import 'native_window_controller.dart';

/// Prepares the native desktop window for client-side decorations and
/// returns its controller.
///
/// Returns null on non-desktop platforms and when there is no native window
/// to control. [title], [size], [minimumSize] and [center] become the
/// initial window options.
Future<Oito2WindowController?> ensureInitialized({
  String? title,
  Size? size,
  Size? minimumSize,
  bool center = true,
}) async {
  if (!(Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    return null;
  }
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  // An id of 0 means no native window was found, such as in tests or an
  // embedder without one: the app runs without window control.
  if (await windowManager.getId() == 0) return null;
  final options = WindowOptions(
    title: title,
    size: size,
    minimumSize: minimumSize,
    center: center,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: Platform.isMacOS,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  return Oito2NativeWindowController.attach(
    windowManager,
    canShowMenu: Platform.isLinux || Platform.isWindows,
  );
}
