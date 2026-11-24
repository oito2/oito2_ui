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

import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui_settings/src/io_sources.dart';
import 'package:system_theme/system_theme.dart';

void main() {
  late Directory home;

  setUp(() async {
    home = await Directory.systemTemp.createTemp('oito2_settings_');
  });

  tearDown(() async {
    if (home.existsSync()) await home.delete(recursive: true);
  });

  group('Oito2HomeConfigFileSource', () {
    test('reads existing files and returns null for missing ones', () async {
      await File('${home.path}/kwinrc').writeAsString('[A]\nb=c\n');
      final source = Oito2HomeConfigFileSource(home.path);
      expect(await source.read('kwinrc'), '[A]\nb=c\n');
      expect(await source.read('missing'), isNull);
    });

    test('emits when a watched file changes', () async {
      final file = File('${home.path}/kdeglobals');
      await file.writeAsString('one');
      final source = Oito2HomeConfigFileSource(home.path);
      final changed = source.changes('kdeglobals').first;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await file.writeAsString('two');
      await changed.timeout(const Duration(seconds: 5));
    });

    test('emits when a file is replaced by renaming a temporary one', () async {
      final file = File('${home.path}/kwinrc');
      await file.writeAsString('one');
      final source = Oito2HomeConfigFileSource(home.path);
      final changed = source.changes('kwinrc').first;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final temp = File('${home.path}/kwinrc.tmp');
      await temp.writeAsString('two');
      await temp.rename(file.path);
      await changed.timeout(const Duration(seconds: 5));
    });

    test('emits for a configuration path with a trailing slash', () async {
      final file = File('${home.path}/kdeglobals');
      await file.writeAsString('one');
      final source = Oito2HomeConfigFileSource('${home.path}/');
      final changed = source.changes('kdeglobals').first;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await file.writeAsString('two');
      await changed.timeout(const Duration(seconds: 5));
    });

    test('ignores changes to other files in the same folder', () async {
      final source = Oito2HomeConfigFileSource(home.path);
      var events = 0;
      final subscription = source.changes('kwinrc').listen((_) => events++);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await File('${home.path}/other').writeAsString('x');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await subscription.cancel();
      expect(events, 0);
    });

    test('emits once a missing folder appears with the file', () async {
      final source = Oito2HomeConfigFileSource(home.path);
      final events = <void>[];
      final subscription = source
          .changes('cosmic/com.system76.CosmicTk/v1/show_minimize')
          .listen(events.add);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final folder = Directory('${home.path}/cosmic/com.system76.CosmicTk/v1');
      await folder.create(recursive: true);
      await File('${folder.path}/show_minimize').writeAsString('false');
      await _until(() => events.isNotEmpty);

      // Later writes are watched in the new folder.
      final count = events.length;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await File('${folder.path}/show_minimize').writeAsString('true');
      await _until(() => events.length > count);
      await subscription.cancel();
    });

    test('ignores new folders off the path to the file', () async {
      final source = Oito2HomeConfigFileSource(home.path);
      var events = 0;
      final subscription = source
          .changes('cosmic/a/v1/show_minimize')
          .listen((_) => events++);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await Directory('${home.path}/other/v1').create(recursive: true);
      await Directory('${home.path}/cosmic/b').create(recursive: true);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await subscription.cancel();
      expect(events, 0);
    });

    test('fromEnvironment prefers XDG_CONFIG_HOME over HOME', () {
      expect(
        Oito2HomeConfigFileSource.fromEnvironment({
          'XDG_CONFIG_HOME': '/xdg',
          'HOME': '/home/me',
        }).configHome,
        '/xdg',
      );
      expect(
        Oito2HomeConfigFileSource.fromEnvironment({'HOME': '/home/me'})
            .configHome,
        '/home/me/.config',
      );
      final none = Oito2HomeConfigFileSource.fromEnvironment(const {});
      expect(none.configHome, isEmpty);
    });

    test('an empty root reads nothing', () async {
      final source = Oito2HomeConfigFileSource('');
      expect(await source.read('kwinrc'), isNull);
      expect(await source.changes('kwinrc').isEmpty, isTrue);
    });
  });

  group('Oito2SystemThemeAccentSource', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('system_theme');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('keeps the global fallback and counts every real accent', () async {
      final fallback = SystemTheme.fallbackColor;
      // The package's default fallback is also a real accent color.
      messenger.setMockMethodCallHandler(channel, (_) async {
        return {
          'accent': {'R': 0x00, 'G': 0xb7, 'B': 0xc3},
        };
      });
      final source = Oito2SystemThemeAccentSource();
      expect(SystemTheme.fallbackColor, fallback);
      expect(await source.read(), const Color(0xff00b7c3));
    });

    test('a missing accent reads as none', () async {
      messenger.setMockMethodCallHandler(channel, (_) async => null);
      expect(await Oito2SystemThemeAccentSource().read(), isNull);
    });
  });

  group('Oito2DconfGSettingsSource', () {
    late DBusServer server;
    late DBusClient session;
    late DBusClient system;
    late Directory socketDir;

    setUp(() async {
      socketDir = await Directory.systemTemp.createTemp('oito2_dbus');
      server = DBusServer();
      final address = await server.listenAddress(
        DBusAddress.unix(dir: socketDir),
      );
      session = DBusClient(address);
      system = DBusClient(address);
    });

    tearDown(() async {
      await session.close();
      await system.close();
      await server.close();
      await socketDir.delete(recursive: true);
    });

    test(
      'an unknown schema reads as null and its changes stay quiet',
      () async {
        final source = Oito2DconfGSettingsSource(
          sessionBus: session,
          systemBus: system,
        );
        expect(await source.read('org.example.missing', 'key'), isNull);
        final subscription = source
            .changes('org.example.missing')
            .listen((_) => fail('No change was made.'));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await subscription.cancel();
        await source.close();
      },
    );

    test('closing leaves buses it was given open', () async {
      final source = Oito2DconfGSettingsSource(
        sessionBus: session,
        systemBus: system,
      );
      await source.read('org.example.missing', 'key');
      await source.close();
      await expectLater(session.ping(), completes);
      await expectLater(system.ping(), completes);
    });
  });

  group('Oito2PortalColorSchemeSource', () {
    late DBusServer server;
    late DBusClient session;
    late DBusClient portalBus;
    late Directory socketDir;

    setUp(() async {
      socketDir = await Directory.systemTemp.createTemp('oito2_portal');
      server = DBusServer();
      final address = await server.listenAddress(
        DBusAddress.unix(dir: socketDir),
      );
      session = DBusClient(address);
      portalBus = DBusClient(address);
    });

    tearDown(() async {
      await session.close();
      await portalBus.close();
      await server.close();
      await socketDir.delete(recursive: true);
    });

    Future<_FakePortal> servePortal(int value, {bool readOne = true}) async {
      final portal = _FakePortal(value, readOne: readOne);
      await portalBus.registerObject(portal);
      await portalBus.requestName('org.freedesktop.portal.Desktop');
      return portal;
    }

    test('maps the portal values to a brightness', () async {
      for (final (value, expected) in [
        (0, null),
        (1, Brightness.dark),
        (2, Brightness.light),
        (7, null),
      ]) {
        final portal = await servePortal(value);
        final source = Oito2PortalColorSchemeSource(sessionBus: session);
        expect(await source.read(), expected, reason: '$value');
        await source.close();
        await portalBus.unregisterObject(portal);
      }
    });

    test('falls back to Read on a portal without ReadOne', () async {
      final portal = await servePortal(1, readOne: false);
      final source = Oito2PortalColorSchemeSource(sessionBus: session);
      expect(await source.read(), Brightness.dark);
      expect(portal.calls, ['ReadOne', 'Read']);
      await source.close();
    });

    test('reads null without a portal', () async {
      final source = Oito2PortalColorSchemeSource(sessionBus: session);
      expect(await source.read(), isNull);
      await source.close();
    });

    test('emits only for the color scheme setting', () async {
      final portal = await servePortal(1);
      final source = Oito2PortalColorSchemeSource(sessionBus: session);
      final events = <void>[];
      final subscription = source.changes().listen(events.add);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await portal.change('org.freedesktop.appearance', 'accent-color');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(events, isEmpty);

      await portal.change('org.freedesktop.appearance', 'color-scheme');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(events, hasLength(1));

      await subscription.cancel();
      await source.close();
    });

    test('closing leaves a bus it was given open', () async {
      final source = Oito2PortalColorSchemeSource(sessionBus: session);
      await source.read();
      await source.close();
      await expectLater(session.ping(), completes);
    });

    test('brightnessOf unwraps nested variants', () {
      expect(
        Oito2PortalColorSchemeSource.brightnessOf(
          DBusVariant(DBusVariant(DBusUint32(2))),
        ),
        Brightness.light,
      );
      expect(
        Oito2PortalColorSchemeSource.brightnessOf(DBusString('dark')),
        isNull,
      );
    });
  });

  group('Oito2PortalAccentSource', () {
    late DBusServer server;
    late DBusClient session;
    late DBusClient portalBus;
    late Directory socketDir;

    setUp(() async {
      socketDir = await Directory.systemTemp.createTemp('oito2_portal');
      server = DBusServer();
      final address = await server.listenAddress(
        DBusAddress.unix(dir: socketDir),
      );
      session = DBusClient(address);
      portalBus = DBusClient(address);
    });

    tearDown(() async {
      await session.close();
      await portalBus.close();
      await server.close();
      await socketDir.delete(recursive: true);
    });

    Future<_FakePortal> servePortal(
      DBusValue? accent, {
      bool readOne = true,
    }) async {
      final portal = _FakePortal(0, readOne: readOne, accent: accent);
      await portalBus.registerObject(portal);
      await portalBus.requestName('org.freedesktop.portal.Desktop');
      return portal;
    }

    DBusStruct rgb(double red, double green, double blue) =>
        DBusStruct([DBusDouble(red), DBusDouble(green), DBusDouble(blue)]);

    test('reads the accent as an opaque color', () async {
      await servePortal(rgb(0.2, 0.4, 1));
      final source = Oito2PortalAccentSource(sessionBus: session);
      expect(
        await source.read(),
        Color.from(alpha: 1, red: 0.2, green: 0.4, blue: 1),
      );
      await source.close();
    });

    test('falls back to Read on a portal without ReadOne', () async {
      final portal = await servePortal(rgb(1, 0, 0), readOne: false);
      final source = Oito2PortalAccentSource(sessionBus: session);
      expect(
        await source.read(),
        Color.from(alpha: 1, red: 1, green: 0, blue: 0),
      );
      expect(portal.calls, ['ReadOne', 'Read']);
      await source.close();
    });

    test('reads null for no accent, an unknown setting or no portal', () async {
      final source = Oito2PortalAccentSource(sessionBus: session);
      expect(await source.read(), isNull, reason: 'no portal');

      final unknown = await servePortal(null);
      expect(await source.read(), isNull, reason: 'unknown setting');
      await portalBus.unregisterObject(unknown);

      await servePortal(rgb(-1, -1, -1));
      expect(await source.read(), isNull, reason: 'out of range');
      await source.close();
    });

    test('emits only for the accent setting', () async {
      final portal = await servePortal(rgb(0, 0, 1));
      final source = Oito2PortalAccentSource(sessionBus: session);
      final events = <void>[];
      final subscription = source.changes().listen(events.add);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await portal.change('org.freedesktop.appearance', 'color-scheme');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(events, isEmpty);

      await portal.change('org.freedesktop.appearance', 'accent-color');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(events, hasLength(1));

      await subscription.cancel();
      await source.close();
    });

    test('colorOf unwraps variants and rejects other shapes', () {
      expect(
        Oito2PortalAccentSource.colorOf(DBusVariant(rgb(0, 1, 0))),
        Color.from(alpha: 1, red: 0, green: 1, blue: 0),
      );
      expect(Oito2PortalAccentSource.colorOf(rgb(0, 1.5, 0)), isNull);
      expect(Oito2PortalAccentSource.colorOf(DBusString('blue')), isNull);
      expect(
        Oito2PortalAccentSource.colorOf(
          DBusStruct([DBusDouble(0), DBusDouble(1)]),
        ),
        isNull,
      );
    });
  });

  group('Oito2PortalReducedMotionSource', () {
    late DBusServer server;
    late DBusClient session;
    late DBusClient portalBus;
    late Directory socketDir;

    setUp(() async {
      socketDir = await Directory.systemTemp.createTemp('oito2_portal');
      server = DBusServer();
      final address = await server.listenAddress(
        DBusAddress.unix(dir: socketDir),
      );
      session = DBusClient(address);
      portalBus = DBusClient(address);
    });

    tearDown(() async {
      await session.close();
      await portalBus.close();
      await server.close();
      await socketDir.delete(recursive: true);
    });

    Future<_FakePortal> servePortal(
      DBusValue? reducedMotion, {
      bool readOne = true,
    }) async {
      final portal = _FakePortal(
        0,
        readOne: readOne,
        reducedMotion: reducedMotion,
      );
      await portalBus.registerObject(portal);
      await portalBus.requestName('org.freedesktop.portal.Desktop');
      return portal;
    }

    test('maps the portal values to a preference', () async {
      for (final (value, expected) in [(0, false), (1, true), (7, false)]) {
        final portal = await servePortal(DBusUint32(value));
        final source = Oito2PortalReducedMotionSource(sessionBus: session);
        expect(await source.read(), expected, reason: '$value');
        await source.close();
        await portalBus.unregisterObject(portal);
      }
    });

    test('falls back to Read on a portal without ReadOne', () async {
      final portal = await servePortal(DBusUint32(1), readOne: false);
      final source = Oito2PortalReducedMotionSource(sessionBus: session);
      expect(await source.read(), isTrue);
      expect(portal.calls, ['ReadOne', 'Read']);
      await source.close();
    });

    test('reads null for an unknown setting or no portal', () async {
      var source = Oito2PortalReducedMotionSource(sessionBus: session);
      expect(await source.read(), isNull);
      await source.close();

      // A portal older than the reduced-motion key.
      await servePortal(null);
      source = Oito2PortalReducedMotionSource(sessionBus: session);
      expect(await source.read(), isNull);
      await source.close();
    });

    test('emits only for the reduced motion setting', () async {
      final portal = await servePortal(DBusUint32(1));
      final source = Oito2PortalReducedMotionSource(sessionBus: session);
      final events = <void>[];
      final subscription = source.changes().listen(events.add);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await portal.change('org.freedesktop.appearance', 'color-scheme');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(events, isEmpty);

      await portal.change('org.freedesktop.appearance', 'reduced-motion');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(events, hasLength(1));

      await subscription.cancel();
      await source.close();
    });

    test('reducedMotionOf unwraps variants and rejects other types', () {
      expect(
        Oito2PortalReducedMotionSource.reducedMotionOf(
          DBusVariant(DBusVariant(DBusUint32(1))),
        ),
        isTrue,
      );
      expect(
        Oito2PortalReducedMotionSource.reducedMotionOf(DBusBoolean(true)),
        isNull,
      );
    });
  });
}

/// Completes once [condition] holds, polling for up to five seconds.
Future<void> _until(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('condition not met within five seconds');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

/// A settings portal that answers `ReadOne` (unless [readOne] is false)
/// and `Read` with [value] for the color scheme, with [accent] for the
/// accent color and with [reducedMotion] for reduced motion; a missing
/// [accent] or [reducedMotion] answers as an unknown setting.
class _FakePortal extends DBusObject {
  _FakePortal(
    this.value, {
    this.readOne = true,
    this.accent,
    this.reducedMotion,
  }) : super(DBusObjectPath('/org/freedesktop/portal/desktop'));

  static const _interface = 'org.freedesktop.portal.Settings';

  final int value;
  final bool readOne;
  final DBusValue? accent;
  final DBusValue? reducedMotion;
  final List<String> calls = [];

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != _interface) {
      return DBusMethodErrorResponse.unknownInterface();
    }
    calls.add(methodCall.name);
    final DBusValue? setting = switch (methodCall.values[1].asString()) {
      'color-scheme' => DBusUint32(value),
      'accent-color' => accent,
      'reduced-motion' => reducedMotion,
      _ => null,
    };
    if (setting == null && (methodCall.name == 'Read' || readOne)) {
      return DBusMethodErrorResponse('org.freedesktop.portal.Error.NotFound', [
        const DBusString('Requested setting not found'),
      ]);
    }
    return switch (methodCall.name) {
      'ReadOne' when readOne => DBusMethodSuccessResponse([
        DBusVariant(setting!),
      ]),
      'Read' => DBusMethodSuccessResponse([DBusVariant(DBusVariant(setting!))]),
      _ => DBusMethodErrorResponse.unknownMethod(),
    };
  }

  /// Emits `SettingChanged` for [namespace] and [key].
  Future<void> change(String namespace, String key) => emitSignal(
    _interface,
    'SettingChanged',
    [DBusString(namespace), DBusString(key), DBusVariant(DBusUint32(value))],
  );
}
