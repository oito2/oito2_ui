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

import 'dart:ui' show Size;

import 'package:oito2_ui/oito2_ui.dart';

/// Returns null: platforms without `dart:io`, such as the web, have no
/// native window to control.
Future<Oito2WindowController?> ensureInitialized({
  String? title,
  Size? size,
  Size? minimumSize,
  bool center = true,
}) async => null;
