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

// Helpers shared by the parity exporters.

import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Color;

/// Returns [color] as `#RRGGBB`, with `AA` appended when it isn't opaque.
String hex(Color color) {
  final argb = color.toARGB32();
  final rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  final alpha = (argb >>> 24) & 0xFF;
  final suffix = alpha == 0xFF ? '' : alpha.toRadixString(16).padLeft(2, '0');
  return '#$rgb$suffix'.toUpperCase();
}

/// Returns the opaque color written as `#RRGGBB` in [value].
Color color(String value) =>
    Color(0xFF000000 | int.parse(value.substring(1), radix: 16));

/// The directory the fixtures are written to: `PARITY_OUT` when set,
/// otherwise `fixtures/` in this package.
Directory fixturesDirectory() =>
    Directory(Platform.environment['PARITY_OUT'] ?? 'fixtures');

/// Writes [data] as tab-indented JSON with a final newline to [name] in
/// [fixturesDirectory], creating the directory when needed, and returns
/// the file.
File writeFixture(String name, Object data) {
  final out = fixturesDirectory()..createSync(recursive: true);
  return File(
    '${out.path}/$name',
  )..writeAsStringSync('${const JsonEncoder.withIndent('\t').convert(data)}\n');
}
