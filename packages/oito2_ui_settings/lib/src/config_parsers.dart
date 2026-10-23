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

import 'dart:ui' show Color;

/// Parsers for the configuration file formats of Linux desktops.
abstract final class Oito2ConfigParsers {
  /// Returns the value of [key] in [group] of the INI-style [content], such
  /// as KDE's `kwinrc` and `kdeglobals`, or null when it is missing.
  ///
  /// Group headers are `[name]`; nested KDE groups like `[a][b]` match the
  /// name `a][b`. Lines starting with `#` or `;` are comments. Keys with
  /// a locale or KDE flag suffix (`key[$e]`) are ignored.
  static String? iniValue(String content, String group, String key) {
    String? current;
    for (final raw in content.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#') || line.startsWith(';')) {
        continue;
      }
      if (line.startsWith('[') && line.endsWith(']')) {
        current = line.substring(1, line.length - 1);
        continue;
      }
      if (current != group) continue;
      final separator = line.indexOf('=');
      if (separator <= 0) continue;
      if (line.substring(0, separator).trim() == key) {
        return line.substring(separator + 1).trim();
      }
    }
    return null;
  }

  /// Returns the `value` attribute of the `<property name="[name]">`
  /// element in the xfconf channel file [content], such as `xfwm4.xml`, or
  /// null when it is missing. XML entities in the value are decoded.
  static String? xfconfProperty(String content, String name) {
    final pattern = RegExp(
      '<property\\s+name="${RegExp.escape(name)}"[^>]*?\\svalue="([^"]*)"',
    );
    final value = pattern.firstMatch(content)?.group(1);
    return value == null ? null : _unescapeXml(value);
  }

  /// Parses [content] as a `true`/`false` file, as COSMIC stores its
  /// boolean settings.
  ///
  /// Returns null for any other content.
  static bool? cosmicBool(String content) => switch (content.trim()) {
    'true' => true,
    'false' => false,
    _ => null,
  };

  /// Parses [value] as a KDE `r,g,b` color, such as the value of
  /// `AccentColor=61,174,233`, or returns null when it isn't one with
  /// three components from 0 to 255.
  static Color? kdeColor(String value) {
    final parts = value.split(',').map((p) => int.tryParse(p.trim())).toList();
    if (parts.length != 3 || parts.any((p) => p == null || p < 0 || p > 255)) {
      return null;
    }
    return Color.fromARGB(255, parts[0]!, parts[1]!, parts[2]!);
  }

  /// Decodes the predefined XML entities in [value].
  static String _unescapeXml(String value) => value
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&');
}
