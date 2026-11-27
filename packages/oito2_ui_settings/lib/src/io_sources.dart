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
import 'dart:ui' show Brightness, Color;

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
///
/// A path that leaves the configuration directory, such as an absolute
/// path or one that climbs out with `..`, reads as null and never emits.
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

  /// Returns the file at [relativePath] under [configHome], or null when
  /// the path leaves [configHome].
  File? _file(String relativePath) {
    final root = p.normalize(configHome);
    final path = p.normalize(p.join(root, relativePath));
    return p.isWithin(root, path) ? File(path) : null;
  }

  @override
  Future<String?> read(String relativePath) async {
    if (configHome.isEmpty) return null;
    final file = _file(relativePath);
    if (file == null) return null;
    try {
      return await file.exists() ? await file.readAsString() : null;
    } on FileSystemException {
      return null;
    }
  }

  /// Emits whenever the file at [relativePath] changes.
  ///
  /// When the file's folder doesn't exist yet, as on a fresh account where
  /// the desktop writes its settings only after the first change, the
  /// nearest existing ancestor is watched until the folder appears; the
  /// stream emits once the folder exists, since the file may have been
  /// written along with it.
  ///
  /// When the file is a symbolic link, as with dotfiles managed by a tool
  /// such as GNU Stow or home-manager, the folder of the file it points to
  /// is watched too, so changes to that file also emit; the link is
  /// followed again whenever it changes.
  @override
  Stream<void> changes(String relativePath) {
    if (configHome.isEmpty) return const Stream.empty();
    final file = _file(relativePath);
    if (file == null) return const Stream.empty();
    final folder = file.parent;
    late final StreamController<void> controller;
    StreamSubscription<FileSystemEvent>? subscription;
    StreamSubscription<FileSystemEvent>? targetSubscription;

    // Matches writes in place and atomic replacements, where a temporary
    // file is renamed onto [path].
    bool touchesPath(FileSystemEvent event, String path) =>
        p.equals(event.path, path) ||
        (event is FileSystemMoveEvent &&
            event.destination != null &&
            p.equals(event.destination!, path));
    bool touches(FileSystemEvent event) => touchesPath(event, file.path);

    // Watches the folder of the file the link at [file] points to, when it
    // is a link to an existing file; stops watching otherwise.
    void watchTarget() {
      final previous = targetSubscription;
      if (previous != null) unawaited(previous.cancel());
      targetSubscription = null;
      final String target;
      try {
        if (!FileSystemEntity.isLinkSync(file.path)) return;
        target = file.resolveSymbolicLinksSync();
      } on FileSystemException {
        return;
      }
      targetSubscription = File(target).parent.watch().listen((event) {
        if (touchesPath(event, target)) controller.add(null);
      }, onError: (Object _) {});
    }

    // Watches the file's folder, or its nearest existing ancestor until
    // the folder appears. Returns whether the folder itself is watched.
    bool watch() {
      final previous = subscription;
      if (previous != null) unawaited(previous.cancel());
      subscription = null;
      var directory = folder;
      while (!directory.existsSync()) {
        final parent = directory.parent;
        if (p.equals(parent.path, directory.path)) return false;
        directory = parent;
      }
      if (p.equals(directory.path, folder.path)) {
        watchTarget();
        subscription = directory.watch().listen(
          (event) {
            if (!touches(event)) return;
            // The link may point elsewhere now.
            watchTarget();
            controller.add(null);
          },
          onError: (Object _) {},
          // The folder was removed: wait for it to come back.
          onDone: () {
            if (!controller.isClosed) watch();
          },
        );
        return true;
      }
      subscription = directory.watch().listen((_) {
        if (_nextLevelExists(directory, folder)) {
          if (watch()) controller.add(null);
        }
      }, onError: (Object _) {});
      return false;
    }

    controller = StreamController<void>(
      onListen: watch,
      onCancel: () async {
        await subscription?.cancel();
        await targetSubscription?.cancel();
        subscription = null;
        targetSubscription = null;
      },
    );
    return controller.stream;
  }

  /// Whether the child of [ancestor] on the way to [folder] exists.
  static bool _nextLevelExists(Directory ancestor, Directory folder) {
    final relative = p.relative(folder.path, from: ancestor.path);
    final next = p.join(ancestor.path, p.split(relative).first);
    return Directory(next).existsSync();
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

  /// Holds no connection to release.
  @override
  Future<void> close() async {}
}

/// The settings object of the XDG desktop portal
/// (`org.freedesktop.portal.Settings`), shared by the sources that read one
/// of its settings.
///
/// The connection stays open until [close]; a process with an open
/// connection may not exit.
abstract class _Oito2PortalSetting {
  _Oito2PortalSetting({DBusClient? sessionBus})
    : _ownsBus = sessionBus == null,
      _bus = sessionBus ?? DBusClient.session();

  static const _interface = 'org.freedesktop.portal.Settings';

  /// The namespace of the setting.
  static const _namespace = 'org.freedesktop.appearance';

  /// The key of the setting within [_namespace].
  String get _key;

  final bool _ownsBus;
  final DBusClient _bus;

  /// The portal's settings object.
  late final DBusRemoteObject _portal = DBusRemoteObject(
    _bus,
    name: 'org.freedesktop.portal.Desktop',
    path: DBusObjectPath('/org/freedesktop/portal/desktop'),
  );

  /// Reads the setting with `ReadOne`, or with `Read` on a portal that
  /// predates it.
  ///
  /// Throws a [DBusMethodResponseException] when the portal is missing or
  /// doesn't know the setting.
  Future<DBusValue> _readSetting() async {
    try {
      return await _call('ReadOne');
    } on DBusUnknownMethodException {
      return _call('Read');
    }
  }

  /// Calls [method] for the setting and returns its value.
  Future<DBusValue> _call(String method) async {
    final response = await _portal.callMethod(_interface, method, [
      const DBusString(_namespace),
      DBusString(_key),
    ], replySignature: DBusSignature('v'));
    return response.values.single;
  }

  /// Emits on the portal's `SettingChanged` signal for the setting; never
  /// emits without a portal.
  Stream<void> _settingChanges() {
    try {
      return DBusRemoteObjectSignalStream(
            object: _portal,
            interface: _interface,
            name: 'SettingChanged',
            signature: DBusSignature('ssv'),
          )
          .where(
            (signal) =>
                signal.values[0].asString() == _namespace &&
                signal.values[1].asString() == _key,
          )
          .map((_) {})
          .handleError((Object _) {});
    } on Object {
      return const Stream.empty();
    }
  }

  /// Closes the bus connection when the source opened it.
  Future<void> close() async {
    if (_ownsBus) await _bus.close();
  }

  /// Returns [value] without the variants that wrap it, as `Read` and
  /// `ReadOne` return it.
  static DBusValue _unwrap(DBusValue value) {
    var inner = value;
    while (inner is DBusVariant) {
      inner = inner.value;
    }
    return inner;
  }
}

/// Reads the color scheme preference through the XDG desktop portal
/// (`org.freedesktop.appearance color-scheme`), which every Linux desktop
/// with a settings portal exposes.
///
/// The connection stays open until [close]; a process with an open
/// connection may not exit.
class Oito2PortalColorSchemeSource extends _Oito2PortalSetting
    implements Oito2ColorSchemeSource {
  /// Creates a source on [sessionBus], or on a connection of its own when
  /// it is null.
  ///
  /// [close] closes the connection the source opened itself and leaves
  /// the one it was given open.
  Oito2PortalColorSchemeSource({super.sessionBus});

  @override
  String get _key => 'color-scheme';

  /// Reads the preference. Returns null without a portal or when it
  /// reports no preference.
  @override
  Future<Brightness?> read() async {
    try {
      return brightnessOf(await _readSetting());
    } on Object {
      return null;
    }
  }

  /// Maps a portal `color-scheme` value to a brightness: 1 asks for dark,
  /// 2 for light and any other value states no preference.
  ///
  /// The value may be wrapped in one or more variants, as `Read` and
  /// `ReadOne` return it.
  static Brightness? brightnessOf(DBusValue value) {
    return switch (_Oito2PortalSetting._unwrap(value)) {
      DBusUint32(value: 1) => Brightness.dark,
      DBusUint32(value: 2) => Brightness.light,
      _ => null,
    };
  }

  /// Emits on the portal's `SettingChanged` signal for the color scheme
  /// key; never emits without a portal.
  @override
  Stream<void> changes() => _settingChanges();
}

/// Reads the accent color through the XDG desktop portal
/// (`org.freedesktop.appearance accent-color`), which the GNOME, KDE,
/// COSMIC and XApp portals expose.
///
/// The connection stays open until [close]; a process with an open
/// connection may not exit.
class Oito2PortalAccentSource extends _Oito2PortalSetting
    implements Oito2AccentSource {
  /// Creates a source on [sessionBus], or on a connection of its own when
  /// it is null.
  ///
  /// [close] closes the connection the source opened itself and leaves
  /// the one it was given open.
  Oito2PortalAccentSource({super.sessionBus});

  @override
  String get _key => 'accent-color';

  /// Reads the accent. Returns null without a portal, when the portal
  /// doesn't know the setting or when it reports no accent.
  @override
  Future<Color?> read() async {
    try {
      return colorOf(await _readSetting());
    } on Object {
      return null;
    }
  }

  /// Maps a portal `accent-color` value, a `(ddd)` structure of red, green
  /// and blue between 0 and 1, to an opaque color.
  ///
  /// Returns null when the value has another shape or a channel outside
  /// 0 to 1, which the portal uses for no accent. The value may be wrapped
  /// in one or more variants, as `Read` and `ReadOne` return it.
  static Color? colorOf(DBusValue value) {
    final inner = _Oito2PortalSetting._unwrap(value);
    if (inner is! DBusStruct || inner.children.length != 3) return null;
    final channels = <double>[];
    for (final child in inner.children) {
      if (child is! DBusDouble || child.value < 0 || child.value > 1) {
        return null;
      }
      channels.add(child.value);
    }
    return Color.from(
      alpha: 1,
      red: channels[0],
      green: channels[1],
      blue: channels[2],
    );
  }

  /// Emits on the portal's `SettingChanged` signal for the accent key;
  /// never emits without a portal.
  @override
  Stream<void> changes() => _settingChanges();
}

/// Reads the reduced motion preference from the XDG desktop portal's
/// `org.freedesktop.appearance reduced-motion` setting, which portal
/// backends of GNOME 50 and later and KDE Plasma 6.6 and later report.
///
/// The connection stays open until [close]; a process with an open
/// connection may not exit.
class Oito2PortalReducedMotionSource extends _Oito2PortalSetting
    implements Oito2ReducedMotionSource {
  /// Creates a source on [sessionBus], or on a connection of its own when
  /// it is null.
  ///
  /// [close] closes the connection the source opened itself and leaves
  /// the one it was given open.
  Oito2PortalReducedMotionSource({super.sessionBus});

  @override
  String get _key => 'reduced-motion';

  /// Reads the preference. Returns null without a portal or when the
  /// portal doesn't know the setting.
  @override
  Future<bool?> read() async {
    try {
      return reducedMotionOf(await _readSetting());
    } on Object {
      return null;
    }
  }

  /// Maps a portal `reduced-motion` value to a preference: 1 asks for
  /// reduced motion and any other number states no preference. Returns
  /// null when the value isn't a number.
  ///
  /// The value may be wrapped in one or more variants, as `Read` and
  /// `ReadOne` return it.
  static bool? reducedMotionOf(DBusValue value) {
    return switch (_Oito2PortalSetting._unwrap(value)) {
      DBusUint32(value: 1) => true,
      DBusUint32() => false,
      _ => null,
    };
  }

  /// Emits on the portal's `SettingChanged` signal for the reduced motion
  /// key; never emits without a portal.
  @override
  Stream<void> changes() => _settingChanges();
}
