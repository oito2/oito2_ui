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

import 'drop_target.dart';

/// The files that stand for dropped directories.
final Expando<bool> _directories = Expando('directories');

/// Records that [file] stands for a directory and returns [file].
///
/// [oito2PlatformDropTarget] marks the directories it receives; a custom
/// `Oito2FileDropTargetBuilder` can mark its own the same way.
XFile oito2MarkAsDirectory(XFile file) {
  _directories[file] = true;
  return file;
}

/// Whether [file] stands for a directory rather than a file, as marked by
/// [oito2MarkAsDirectory].
///
/// On Linux, Windows and macOS, the `path` of a dropped directory is its
/// path in the file system. On the web the browser gives only its `name`,
/// and its `path` is not a file system path.
bool oito2IsDirectory(XFile file) => _directories[file] ?? false;
