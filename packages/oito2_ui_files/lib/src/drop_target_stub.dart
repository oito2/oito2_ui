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

/// Files can't be dropped without a platform drop target.
const bool canDropFiles = false;

/// Returns [child]: this platform has no built-in drop target.
Widget buildDropTarget({
  required Widget child,
  required bool enabled,
  required ValueChanged<bool> onHover,
  required ValueChanged<List<XFile>> onDrop,
}) => child;
