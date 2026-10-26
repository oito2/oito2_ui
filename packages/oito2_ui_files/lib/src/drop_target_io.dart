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

import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';

import 'directories.dart';

/// Files dragged from the desktop can be dropped on Linux, Windows and
/// macOS.
bool get canDropFiles =>
    Platform.isLinux || Platform.isWindows || Platform.isMacOS;

/// Receives files dropped on [child] from the desktop through the
/// desktop_drop plugin on Linux, Windows and macOS; elsewhere returns
/// [child], without drops.
Widget buildDropTarget({
  required Widget child,
  required bool enabled,
  required ValueChanged<bool> onHover,
  required ValueChanged<List<XFile>> onDrop,
}) {
  if (!canDropFiles) return child;
  return DropTarget(
    enable: enabled,
    onDragEntered: (_) => onHover(true),
    onDragExited: (_) => onHover(false),
    onDragDone: (details) => _drop(details.files, onDrop),
    child: child,
  );
}

/// Hands the dropped [items] that exist in the file system to [onDrop],
/// with directories marked as such; dragged items that aren't local paths,
/// such as web links, are skipped.
Future<void> _drop(List<XFile> items, ValueChanged<List<XFile>> onDrop) async {
  final existing = <XFile>[];
  for (final item in items) {
    if (item.path.isEmpty) continue;
    switch (await FileSystemEntity.type(item.path)) {
      case FileSystemEntityType.notFound:
        break;
      case FileSystemEntityType.directory:
        existing.add(markAsDirectory(item));
      default:
        existing.add(item);
    }
  }
  if (existing.isNotEmpty) onDrop(existing);
}
