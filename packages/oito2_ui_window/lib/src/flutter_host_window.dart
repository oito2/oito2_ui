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

import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

/// The top-level windows of the desktop, as the Flutter host window search
/// sees them.
abstract interface class TopLevelWindows {
  /// The id of the current process.
  int get currentProcessId;

  /// The handles of every top-level window, hidden ones included.
  Iterable<int> get handles;

  /// Returns the id of the process that owns the window [handle].
  int processIdOf(int handle);

  /// Returns whether the window [handle] has an owner window.
  bool hasOwner(int handle);

  /// Returns whether the window [handle] has a Flutter view as a child.
  bool hostsFlutterView(int handle);
}

/// Returns the handle of the only top-level window of the current process
/// that has no owner and hosts a Flutter view, among [windows].
///
/// Returns 0 when there is no such window or more than one.
int soleFlutterHostWindow(TopLevelWindows windows) {
  final self = windows.currentProcessId;
  var found = 0;
  for (final handle in windows.handles) {
    if (windows.processIdOf(handle) != self) continue;
    if (windows.hasOwner(handle)) continue;
    if (!windows.hostsFlutterView(handle)) continue;
    if (found != 0) return 0;
    found = handle;
  }
  return found;
}

/// Returns the `HWND` of the only top-level window of this process that
/// hosts a Flutter view, visible or hidden, or 0 when there is none, more
/// than one, or the platform isn't Windows.
int findSoleFlutterHostWindow() {
  if (!Platform.isWindows) return 0;
  return soleFlutterHostWindow(_Win32TopLevelWindows());
}

typedef _EnumWindowsProcNative = Int32 Function(IntPtr hwnd, IntPtr lParam);

/// The `GW_OWNER` command of `GetWindow`.
const _gwOwner = 4;

/// The window handles collected by [_collectWindow] during one
/// `EnumWindows` call.
List<int>? _collected;

/// Adds [hwnd] to [_collected] and asks `EnumWindows` to go on.
int _collectWindow(int hwnd, int lParam) {
  _collected?.add(hwnd);
  return 1;
}

/// [TopLevelWindows] read through the Win32 API.
final class _Win32TopLevelWindows implements TopLevelWindows {
  _Win32TopLevelWindows() {
    final user32 = DynamicLibrary.open('user32.dll');
    final kernel32 = DynamicLibrary.open('kernel32.dll');
    _enumWindows = user32
        .lookupFunction<
          Int32 Function(
            Pointer<NativeFunction<_EnumWindowsProcNative>>,
            IntPtr,
          ),
          int Function(Pointer<NativeFunction<_EnumWindowsProcNative>>, int)
        >('EnumWindows');
    _findWindowEx = user32
        .lookupFunction<
          IntPtr Function(IntPtr, IntPtr, Pointer<Utf16>, Pointer<Utf16>),
          int Function(int, int, Pointer<Utf16>, Pointer<Utf16>)
        >('FindWindowExW');
    _getWindowThreadProcessId = user32
        .lookupFunction<
          Uint32 Function(IntPtr, Pointer<Uint32>),
          int Function(int, Pointer<Uint32>)
        >('GetWindowThreadProcessId');
    _getWindow = user32
        .lookupFunction<
          IntPtr Function(IntPtr, Uint32),
          int Function(int, int)
        >('GetWindow');
    _getCurrentProcessId = kernel32
        .lookupFunction<Uint32 Function(), int Function()>(
          'GetCurrentProcessId',
        );
  }

  late final int Function(Pointer<NativeFunction<_EnumWindowsProcNative>>, int)
  _enumWindows;
  late final int Function(int, int, Pointer<Utf16>, Pointer<Utf16>)
  _findWindowEx;
  late final int Function(int, Pointer<Uint32>) _getWindowThreadProcessId;
  late final int Function(int, int) _getWindow;
  late final int Function() _getCurrentProcessId;

  @override
  int get currentProcessId => _getCurrentProcessId();

  /// Takes a snapshot of the top-level windows with `EnumWindows`.
  @override
  Iterable<int> get handles {
    final windows = _collected = <int>[];
    try {
      _enumWindows(
        Pointer.fromFunction<_EnumWindowsProcNative>(_collectWindow, 0),
        0,
      );
      return windows;
    } finally {
      _collected = null;
    }
  }

  @override
  int processIdOf(int handle) => using((arena) {
    final processId = arena<Uint32>();
    _getWindowThreadProcessId(handle, processId);
    return processId.value;
  });

  @override
  bool hasOwner(int handle) => _getWindow(handle, _gwOwner) != 0;

  /// Looks for a child window of the `FLUTTERVIEW` class, the class of the
  /// Flutter engine's view.
  @override
  bool hostsFlutterView(int handle) => using((arena) {
    final viewClass = 'FLUTTERVIEW'.toNativeUtf16(allocator: arena);
    return _findWindowEx(handle, 0, viewClass, nullptr) != 0;
  });
}
