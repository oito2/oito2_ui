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
import 'dart:io';
import 'dart:ui' show Color;

import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:gsettings/gsettings.dart';
import 'package:path/path.dart' as p;
import 'package:system_theme/system_theme.dart';

import 'sources.dart';

/// Reads GSettings through dconf over D-Bus, sharing one session and one
/// system bus connection between every schema it reads.
///
/// The connections stay open until [close]; a process with an open
/// connection may not exit.
class Oito2DconfGSettingsSource implements Oito2GSettingsSource {
  /// Creates a source on [sessionBus] and [systemBus], or on connections of
  /// its own when they are null.
  ///
  /// [close] closes the connections the source opened itself and leaves
  /// the ones it was given open.
  Oito2DconfGSettingsSource({DBusClient? sessionBus, DBusClient? systemBus})
    : _ownsSessionBus = sessionBus == null,
      _ownsSystemBus = systemBus == null,
      _sessionBus = sessionBus ?? DBusClient.session(),
      _systemBus = systemBus ?? DBusClient.system();

  final bool _ownsSessionBus;
  final bool _ownsSystemBus;
  final DBusClient _sessionBus;
  final DBusClient _systemBus;
  final Map<String, GSettings> _schemas = {};

  /// The cached [GSettings] client for the schema [name].
  GSettings _schema(String name) => _schemas.putIfAbsent(
    name,
    () => GSettings(name, sessionBus: _sessionBus, systemBus: _systemBus),
  );

  @override
  Future<Object?> read(String schema, String key) async {
    try {
      final value = await _schema(schema).get(key);
      return value.toNative();
    } on Object {
      return null;
    }
  }

  /// Emits whenever a key in [schema] changes; never emits when the schema
  /// isn't installed.
  ///
  /// `GSettings` loads the schema when its stream gets a listener, and a
  /// missing schema fails outside the stream, so the subscription runs in
  /// a zone that keeps that failure from escaping.
  @override
  Stream<void> changes(String schema) {
    late final StreamController<void> controller;
    StreamSubscription<Object?>? subscription;
    controller = StreamController<void>(
      onListen: () => runZonedGuarded(() {
        subscription = _schema(schema).keysChanged
            .listen((_) => controller.add(null), onError: (Object _) {});
      }, (_, _) {}),
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  /// Closes every schema and, when the source opened them, both bus
  /// connections.
  @override
  Future<void> close() async {
    for (final schema in _schemas.values) {
      await schema.close();
    }
    _schemas.clear();
    if (_ownsSessionBus) await _sessionBus.close();
    if (_ownsSystemBus) await _systemBus.close();
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
    return Oito2HomeConfigFileSource(
      home.isEmpty ? '' : p.join(home, '.config'),
    );
  }

  /// The configuration directory.
  final String configHome;

  /// The file at [relativePath] under [configHome].
  File _file(String relativePath) =>
      File(p.normalize(p.join(configHome, relativePath)));

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
    // Matches writes in place and atomic replacements, where a temporary
    // file is renamed onto the watched path.
    bool touches(FileSystemEvent event) =>
        p.equals(event.path, file.path) ||
        (event is FileSystemMoveEvent &&
            event.destination != null &&
            p.equals(event.destination!, file.path));
    return directory
        .watch()
        .where(touches)
        .map((_) {})
        .handleError((Object _) {});
  }
}

/// Reads the accent color through `system_theme`: the Windows, macOS and
/// Android system accent, or the GTK theme's selection color on Linux.
///
/// It reads through its own `system_theme` color with a fully transparent
/// default, which stands for a missing accent, so the package's global
/// fallback stays untouched and every real accent color counts.
class Oito2SystemThemeAccentSource implements Oito2AccentSource {
  /// Creates the source.
  Oito2SystemThemeAccentSource();

  /// The fully transparent default that marks a missing accent.
  static const _missing = Color(0x00000000);

  /// The accent read on demand; its default marks a missing accent.
  final SystemAccentColor _accent = SystemAccentColor(_missing);

  @override
  Future<Color?> read() async {
    try {
      await _accent.load();
      final color = _accent.accent;
      return color.a == 0 ? null : color;
    } on Object {
      return null;
    }
  }

  /// Changes arrive only where `system_theme` streams them (Windows and
  /// macOS); elsewhere the stream is empty.
  @override
  Stream<void> changes() {
    if (!defaultTargetPlatform.supportsListeningToAccentColorChanges) {
      return const Stream.empty();
    }
    try {
      return SystemTheme.onChange.map((_) {}).handleError((Object _) {});
    } on Object {
      return const Stream.empty();
    }
  }
}
