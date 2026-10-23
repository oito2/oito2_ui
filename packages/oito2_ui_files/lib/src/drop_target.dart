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

import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';

import 'drop_target_stub.dart'
    if (dart.library.js_interop) 'drop_target_web.dart'
    as platform;

/// Builds a widget that receives files dropped on [child]: [onHover]
/// reports whether files are dragged over it, and [onDrop] receives the
/// dropped files while [enabled].
///
/// Pass one to [Oito2FileDropZone.dropTargetBuilder] to receive drops from
/// another source, such as a desktop drag-and-drop plugin.
typedef Oito2FileDropTargetBuilder = Widget Function({
  required Widget child,
  required bool enabled,
  required ValueChanged<bool> onHover,
  required ValueChanged<List<XFile>> onDrop,
});

/// Whether [oito2PlatformDropTarget] receives dropped files on this
/// platform: true on the web only.
bool get oito2CanDropFiles => platform.canDropFiles;

/// The drop target of the platform: on the web, files dragged from the
/// desktop onto [child]; elsewhere, [child] alone, without drops.
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
