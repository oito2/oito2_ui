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

import 'dart:async';
import 'dart:ui' show Color;

import 'package:oito2_ui_settings/oito2_ui_settings.dart';

/// GSettings values held in memory, keyed by `schema/key`.
class FakeGSettings implements Oito2GSettingsSource {
  /// Creates a fake store with [values].
  FakeGSettings([Map<String, Object?>? values]) : values = values ?? {};

  /// The stored values, keyed by `schema/key`.
  final Map<String, Object?> values;

  final Map<String, StreamController<void>> _controllers = {};

  /// When true, every read throws.
  bool broken = false;

  /// Whether [close] was called.
  bool closed = false;

  @override
  Future<Object?> read(String schema, String key) async {
    if (broken) throw StateError('broken');
    return values['$schema/$key'];
  }

  @override
  Future<void> close() async => closed = true;

  @override
  Stream<void> changes(String schema) =>
      _controllers.putIfAbsent(schema, StreamController<void>.broadcast).stream;

  /// Sets a value and notifies listeners of its schema.
  void set(String schema, String key, Object? value) {
    values['$schema/$key'] = value;
    _controllers[schema]?.add(null);
  }
}

/// Configuration files held in memory, keyed by relative path.
class FakeConfigFiles implements Oito2ConfigFileSource {
  /// Creates fake files with [files].
  FakeConfigFiles([Map<String, String>? files]) : files = files ?? {};

  /// The file contents, keyed by relative path.
  final Map<String, String> files;

  final Map<String, StreamController<void>> _controllers = {};

  @override
  Future<String?> read(String relativePath) async => files[relativePath];

  @override
  Stream<void> changes(String relativePath) => _controllers
      .putIfAbsent(relativePath, StreamController<void>.broadcast)
      .stream;

  /// Writes a file and notifies its listeners.
  void write(String relativePath, String content) {
    files[relativePath] = content;
    _controllers[relativePath]?.add(null);
  }

  /// Whether anyone listens to changes of [relativePath].
  bool isWatched(String relativePath) =>
      _controllers[relativePath]?.hasListener ?? false;
}

/// An accent color held in memory.
class FakeAccent implements Oito2AccentSource {
  /// Creates a fake accent source starting with [color].
  FakeAccent([this.color]);

  /// The current accent color.
  Color? color;

  final StreamController<void> _controller = StreamController.broadcast();

  @override
  Future<Color?> read() async => color;

  @override
  Stream<void> changes() => _controller.stream;

  /// Changes the color and notifies listeners.
  void change(Color? value) {
    color = value;
    _controller.add(null);
  }
}
