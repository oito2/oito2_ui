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

import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';

import 'drop_target_stub.dart'
    if (dart.library.js_interop) 'drop_target_web.dart'
    if (dart.library.io) 'drop_target_io.dart'
    as platform;

/// Builds a widget that receives files dropped on [child]: [onHover]
/// reports whether files are dragged over it, and [onDrop] receives the
/// dropped files while [enabled].
///
/// Pass one to [Oito2FileDropZone.dropTargetBuilder] to receive drops from
/// another source than [oito2PlatformDropTarget].
typedef Oito2FileDropTargetBuilder = Widget Function({
  required Widget child,
  required bool enabled,
  required ValueChanged<bool> onHover,
  required ValueChanged<List<XFile>> onDrop,
});

/// Whether [oito2PlatformDropTarget] receives dropped files on this
/// platform: true on the web, Linux, Windows and macOS.
bool get oito2CanDropFiles => platform.canDropFiles;

/// The drop target of the platform: files dragged from the desktop onto
/// [child], received through the browser on the web and through the
/// desktop_drop plugin on Linux, Windows and macOS; elsewhere, [child]
/// alone, without drops.
///
/// Dropped directories are handed over with the files, marked so that an
/// `Oito2FileUploadController` refuses them.
Widget oito2PlatformDropTarget({
  required Widget child,
  required bool enabled,
  required ValueChanged<bool> onHover,
  required ValueChanged<List<XFile>> onDrop,
}) => platform.buildDropTarget(
  child: child,
  enabled: enabled,
  onHover: onHover,
  onDrop: onDrop,
);
