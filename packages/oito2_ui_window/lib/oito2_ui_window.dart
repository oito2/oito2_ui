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

/// Window chrome integration for `oito2_ui`.
///
/// Connects the `oito2_ui` title bar and window controls to the native
/// window on Linux, Windows and macOS.
library;

export 'src/native_window_controller.dart' show Oito2NativeWindowController;
export 'src/oito2_window.dart';
