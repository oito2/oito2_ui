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

import 'dart:io' show Platform;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

/// Desktop platforms have a "Save as" dialog.
bool get canSaveFiles =>
    Platform.isLinux || Platform.isWindows || Platform.isMacOS;

/// Asks where to save [bytes] with the platform's "Save as" dialog and
/// writes them there; false when the dialog is canceled.
Future<bool> saveFile({
  required String fileName,
  required Uint8List bytes,
  String? mimeType,
}) async {
  if (!canSaveFiles) {
    throw UnsupportedError('Saving files is not supported on this platform.');
  }
  final location = await getSaveLocation(suggestedName: fileName);
  if (location == null) return false;
  await XFile.fromData(
    bytes,
    name: fileName,
    mimeType: mimeType,
  ).saveTo(location.path);
  return true;
}
