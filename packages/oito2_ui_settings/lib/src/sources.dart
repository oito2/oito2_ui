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

import 'dart:ui' show Color;

/// Reads values from GSettings, the settings store of GNOME and the
/// desktops derived from it.
abstract interface class Oito2GSettingsSource {
  /// Returns the value of [key] in [schema] as a Dart value (`String`,
  /// `bool`, `int`, ...), or null when the schema or key doesn't exist.
  Future<Object?> read(String schema, String key);

  /// Emits whenever a key in [schema] changes.
  Stream<void> changes(String schema);

  /// Releases the connections the source holds.
  Future<void> close();
}

/// Reads text files from the user's configuration directory
/// (`$XDG_CONFIG_HOME`, by default `~/.config`).
abstract interface class Oito2ConfigFileSource {
  /// Returns the content of the file at [relativePath], or null when it
  /// doesn't exist or can't be read.
  Future<String?> read(String relativePath);

  /// Emits whenever the file at [relativePath] changes.
  Stream<void> changes(String relativePath);
}

/// Reads the accent color the operating system or the toolkit theme
/// exposes.
abstract interface class Oito2AccentSource {
  /// Returns the accent color, or null when none is available.
  Future<Color?> read();

  /// Emits whenever the accent color changes.
  Stream<void> changes();
}

/// A source with no values and no changes, used where a platform has no
/// such store.
class Oito2EmptySource
    implements Oito2GSettingsSource, Oito2ConfigFileSource, Oito2AccentSource {
  /// Creates an empty source.
  const Oito2EmptySource();

  /// Returns null for every read.
  @override
  Future<Null> read([String? first, String? second]) async => null;

  /// Never emits.
  @override
  Stream<void> changes([String? target]) => const Stream.empty();

  /// Holds nothing to release.
  @override
  Future<void> close() async {}
}
