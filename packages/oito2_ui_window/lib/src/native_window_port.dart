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

/// A native window event that the window controller follows.
sealed class NativeWindowEvent {
  /// Creates a window event.
  const NativeWindowEvent();
}

/// The window was maximized.
final class NativeWindowMaximized extends NativeWindowEvent {
  /// Creates the event.
  const NativeWindowMaximized();
}

/// The window left the maximized or the minimized state.
final class NativeWindowRestored extends NativeWindowEvent {
  /// Creates the event.
  const NativeWindowRestored();
}

/// The window got the input focus.
final class NativeWindowFocused extends NativeWindowEvent {
  /// Creates the event.
  const NativeWindowFocused();
}

/// The window lost the input focus.
final class NativeWindowBlurred extends NativeWindowEvent {
  /// Creates the event.
  const NativeWindowBlurred();
}

/// The window entered full-screen mode.
final class NativeWindowEnteredFullScreen extends NativeWindowEvent {
  /// Creates the event.
  const NativeWindowEnteredFullScreen();
}

/// The window left full-screen mode.
final class NativeWindowExitedFullScreen extends NativeWindowEvent {
  /// Creates the event.
  const NativeWindowExitedFullScreen();
}

/// The window was asked to close.
///
/// The window closes once every listener has finished with the event, unless
/// one of them calls [cancel]. A listener that returns a [Future] keeps the
/// request pending until the future completes, so [cancel] still works after
/// an `await`.
final class NativeWindowCloseRequested extends NativeWindowEvent {
  /// Creates the event; [onCancel] vetoes the close request.
  const NativeWindowCloseRequested(this.onCancel);

  /// Vetoes the close request.
  final void Function() onCancel;

  /// Keeps the window open.
  void cancel() => onCancel();
}

/// Receives the events of a [NativeWindowPort].
///
/// Returns a [Future] to keep a [NativeWindowCloseRequested] pending until
/// it completes.
typedef NativeWindowListener = FutureOr<void> Function(NativeWindowEvent event);

/// Thrown by a [NativeWindowPort] query when the native window can't be
/// reached.
final class NativeWindowUnavailableException implements Exception {
  /// Creates the exception.
  const NativeWindowUnavailableException();

  @override
  String toString() => 'NativeWindowUnavailableException';
}

/// The native window operations that the window controller uses.
///
/// An internal seam between the controller and the native window library,
/// replaced by a fake in tests.
abstract interface class NativeWindowPort {
  /// Returns whether the window is maximized.
  ///
  /// Throws a [NativeWindowUnavailableException] when the window can't be
  /// reached.
  Future<bool> isMaximized();

  /// Returns whether the window is in full-screen mode.
  ///
  /// Throws a [NativeWindowUnavailableException] when the window can't be
  /// reached.
  Future<bool> isFullScreen();

  /// Returns whether the window has the input focus.
  ///
  /// Throws a [NativeWindowUnavailableException] when the window can't be
  /// reached.
  Future<bool> isFocused();

  /// Minimizes the window.
  Future<void> minimize();

  /// Maximizes the window.
  Future<void> maximize();

  /// Restores the window from the maximized state.
  Future<void> unmaximize();

  /// Asks the window to close, which sends a [NativeWindowCloseRequested]
  /// to the listeners first.
  Future<void> close();

  /// Starts moving the window with the pointer that is currently pressed.
  Future<void> startDragging();

  /// Shows the native window menu at the pointer, where the platform has
  /// one.
  Future<void> showSystemMenu();

  /// Sends the window events to [listener] until the returned function is
  /// called.
  void Function() addListener(NativeWindowListener listener);
}
