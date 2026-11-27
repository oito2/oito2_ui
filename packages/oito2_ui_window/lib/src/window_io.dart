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

import 'dart:ffi' show Pointer, Void;
import 'dart:io' show Platform;
import 'dart:ui' show Offset, Size;

import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:nativeapi/nativeapi.dart'
    show Application, Display, DisplayManager;
import 'package:oito2_ui/oito2_ui.dart';
import 'package:window_manager/window_manager.dart';

import 'flutter_host_window.dart';
import 'native_window_controller.dart';
import 'native_window_port_io.dart';

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
  // No window is found in tests or an embedder without one: the app then
  // runs without window control.
  final window = _findAppWindow();
  if (window == null) return null;
  _applyInitialOptions(
    window,
    title: title,
    size: size,
    minimumSize: minimumSize,
    center: center,
  );
  if (window.isMinimized) window.restore();
  window
    ..show()
    ..focus();
  return attachNativeWindowController(
    WindowManagerPort(window),
    canShowMenu: tryNative(Window.isSystemMenuSupported) ?? false,
  );
}

/// Returns the app's window: the window the platform considers current or,
/// on Windows, where that can miss a window still hidden at startup, the
/// application's primary window or the only window hosting a Flutter view.
///
/// Returns null when there is none or the native library isn't loaded.
Window? _findAppWindow() {
  return tryNative<Window?>(
    () => WindowManager.instance.getCurrent() ?? _findHiddenWindowOnWindows(),
  );
}

/// Returns the application's primary window, or the only top-level window
/// of this process that hosts a Flutter view, on Windows; null elsewhere or
/// when there is none.
Window? _findHiddenWindowOnWindows() {
  if (!Platform.isWindows) return null;
  final primary = Application.instance.getPrimaryWindow();
  if (primary != null) return primary;
  final hwnd = findSoleFlutterHostWindow();
  if (hwnd == 0) return null;
  return Window.createWithNativeWindow(Pointer<Void>.fromAddress(hwnd));
}

/// Hides the title bar of [window], keeping the native window buttons only
/// on macOS, brings it back to its normal state and applies [size], the
/// centered position when [center] is true, [minimumSize] and [title].
void _applyInitialOptions(
  Window window, {
  required String? title,
  required Size? size,
  required Size? minimumSize,
  required bool center,
}) {
  final wasFrameless = window.isFrameless;
  window
    ..titleBarStyle = TitleBarStyle.hidden
    ..isWindowControlButtonsVisible = Platform.isMacOS;
  if (Platform.isMacOS && wasFrameless) window.hasShadow = true;

  if (window.isFullScreen) window.isFullScreen = false;
  if (window.isMaximized) {
    if (window.isMaximizedVertically) window.setMaximizedVertically(false);
    window.unmaximize();
  }
  if (window.isMinimized) window.restore();

  if (size != null) window.setSize(size.toNative(), false);
  if (center) {
    final position = _centeredWindowPosition(size ?? window.size.toSize());
    window.position = position.toNative();
  }
  if (minimumSize != null) window.minimumSize = minimumSize.toNative();
  if (title != null) window.title = title;
}

/// Returns where a window of [windowSize] sits centered in the work area of
/// the display under the cursor, or of the primary display when no display
/// is under it.
///
/// Returns [Offset.zero] when there is no display.
Offset _centeredWindowPosition(Size windowSize) {
  final displays = DisplayManager.instance;
  final cursor = displays.getCursorPosition().toOffset();
  Display? current;
  for (final display in displays.getAll()) {
    final bounds = display.position.toOffset() & display.size.toSize();
    if (bounds.contains(cursor)) {
      current = display;
      break;
    }
  }
  current ??= displays.getPrimary();
  if (current == null) return Offset.zero;
  final workArea = current.workArea.toRect();
  return Offset(
    workArea.left + (workArea.width - windowSize.width) / 2,
    workArea.top + (workArea.height - windowSize.height) / 2,
  );
}
