// Copyright (C) 2026  oito2
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

import 'dart:io' show Platform;
import 'dart:ui' show Size;

import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:oito2_ui/oito2_ui.dart';
import 'package:window_manager/window_manager.dart';

import 'native_window_controller.dart';

/// Prepares the native desktop window for client-side decorations and
/// returns its controller, or null on non-desktop platforms.
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
  try {
    await windowManager.ensureInitialized();
  } on MissingPluginException {
    // The window plugin isn't registered, such as in tests or an embedder
    // without it: the app runs without window control.
    return null;
  }
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
