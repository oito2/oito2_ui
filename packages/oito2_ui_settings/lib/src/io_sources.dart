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

import 'dart:async';
import 'dart:io';
import 'dart:ui' show Color;

import 'package:gsettings/gsettings.dart';
import 'package:system_theme/system_theme.dart';

import 'sources.dart';

/// Reads GSettings through dconf over D-Bus, keeping one connection per
/// schema.
class Oito2DconfGSettingsSource implements Oito2GSettingsSource {
  final Map<String, GSettings> _schemas = {};

  GSettings _schema(String name) => _schemas.putIfAbsent(name, () {
    return GSettings(name);
  });

  @override
  Future<Object?> read(String schema, String key) async {
    try {
      final value = await _schema(schema).get(key);
      return value.toNative();
    } on Object {
      return null;
    }
  }

  @override
  Stream<void> changes(String schema) =>
      _schema(schema).keysChanged.handleError((Object _) {});

  /// Closes every D-Bus connection.
  Future<void> close() async {
    for (final schema in _schemas.values) {
      await schema.close();
    }
    _schemas.clear();
  }
}

/// Reads files under the user's configuration directory and watches their
/// parent directories for changes, since editors often replace a file
/// instead of writing it in place.
class Oito2HomeConfigFileSource implements Oito2ConfigFileSource {
  /// Creates a source rooted at [configHome].
  Oito2HomeConfigFileSource(this.configHome);

  /// Creates a source rooted at `$XDG_CONFIG_HOME`, falling back to
  /// `$HOME/.config`. Returns a source rooted at a non-existent directory
  /// when neither variable is set.
  factory Oito2HomeConfigFileSource.fromEnvironment(
    Map<String, String> environment,
  ) {
    final xdg = environment['XDG_CONFIG_HOME'];
    if (xdg != null && xdg.isNotEmpty) return Oito2HomeConfigFileSource(xdg);
    final home = environment['HOME'] ?? '';
    return Oito2HomeConfigFileSource(home.isEmpty ? '' : '$home/.config');
  }

  /// The configuration directory.
  final String configHome;

  File _file(String relativePath) => File('$configHome/$relativePath');

  @override
  Future<String?> read(String relativePath) async {
    if (configHome.isEmpty) return null;
    try {
      final file = _file(relativePath);
      return await file.exists() ? await file.readAsString() : null;
    } on FileSystemException {
      return null;
    }
  }

  @override
  Stream<void> changes(String relativePath) {
    if (configHome.isEmpty) return const Stream.empty();
    final file = _file(relativePath);
    final directory = file.parent;
    if (!directory.existsSync()) return const Stream.empty();
    return directory
        .watch()
        .where((event) => event.path == file.path)
        .map((_) {})
        .handleError((Object _) {});
  }
}

/// Reads the accent color through `system_theme`: the Windows, macOS and
/// Android system accent, or the GTK theme's selection color on Linux.
///
/// `system_theme` reports its fallback color when the platform has no
/// accent; this source sets a fully transparent fallback before the shared
/// [SystemTheme.accentColor] is first used, and also treats the package's
/// default fallback as missing, so neither is mistaken for a real accent.
class Oito2SystemThemeAccentSource implements Oito2AccentSource {
  /// Creates the source and configures the `system_theme` fallback.
  Oito2SystemThemeAccentSource() {
    SystemTheme.fallbackColor = _missing;
  }

  static const _missing = Color(0x00000000);

  @override
  Future<Color?> read() async {
    try {
      final accent = SystemTheme.accentColor;
      await accent.load();
      final color = accent.accent;
      final isFallback =
          color.a == 0 ||
          color.toARGB32() == SystemTheme.kDefaultFallbackColor.toARGB32();
      return isFallback ? null : color;
    } on Object {
      return null;
    }
  }

  @override
  Stream<void> changes() {
    try {
      return SystemTheme.onChange.map((_) {}).handleError((Object _) {});
    } on Object {
      return const Stream.empty();
    }
  }
}
