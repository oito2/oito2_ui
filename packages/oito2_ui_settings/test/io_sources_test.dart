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

    test('a missing folder has no changes', () async {
      final source = Oito2HomeConfigFileSource('${home.path}/missing');
      expect(await source.changes('cosmic/x').isEmpty, isTrue);
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
}

/// A settings portal that answers `ReadOne` (unless [readOne] is false)
/// and `Read` with [value] for every setting.
class _FakePortal extends DBusObject {
  _FakePortal(this.value, {this.readOne = true})
    : super(DBusObjectPath('/org/freedesktop/portal/desktop'));

  static const _interface = 'org.freedesktop.portal.Settings';

  final int value;
  final bool readOne;
  final List<String> calls = [];

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != _interface) {
      return DBusMethodErrorResponse.unknownInterface();
    }
    calls.add(methodCall.name);
    return switch (methodCall.name) {
      'ReadOne' when readOne => DBusMethodSuccessResponse([
        DBusVariant(DBusUint32(value)),
      ]),
      'Read' => DBusMethodSuccessResponse([
        DBusVariant(DBusVariant(DBusUint32(value))),
      ]),
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
