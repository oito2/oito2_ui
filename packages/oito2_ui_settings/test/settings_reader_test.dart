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

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_settings/oito2_ui_settings.dart';

import 'fakes.dart';

const _linux = Oito2Platform(
  targetPlatform: TargetPlatform.linux,
  isWeb: false,
);
const _windows = Oito2Platform(
  targetPlatform: TargetPlatform.windows,
  isWeb: false,
);

const _gnomeWm = 'org.gnome.desktop.wm.preferences';
const _interface = 'org.gnome.desktop.interface';
const _a11y = 'org.gnome.desktop.a11y.interface';
const _kwinrc = 'kwinrc';
const _kdeglobals = 'kdeglobals';
const _xfwm = 'xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml';
const _cosmic = 'cosmic/com.system76.CosmicTk/v1';
const _cosmicDark = 'cosmic/com.system76.CosmicTheme.Mode/v1/is_dark';

const _min = Oito2WindowButton.minimize;
const _max = Oito2WindowButton.maximize;
const _close = Oito2WindowButton.close;

Oito2SystemSettingsReader _reader({
  String desktop = 'GNOME',
  Oito2Platform platform = _linux,
  FakeGSettings? gsettings,
  FakeConfigFiles? files,
  FakeAccent? accent,
  FakeAccent? portalAccent,
  FakeColorScheme? colorScheme,
  FakeReducedMotion? reducedMotion,
  bool platformHighContrast = false,
  Brightness? platformBrightness,
  bool? platformReduceMotion,
  double? platformTextScaleFactor,
}) => Oito2SystemSettingsReader(
  platform: platform,
  environment: {'XDG_CURRENT_DESKTOP': desktop},
  gsettings: gsettings ?? FakeGSettings(),
  configFiles: files ?? FakeConfigFiles(),
  accent: accent ?? FakeAccent(),
  portalAccent: portalAccent ?? FakeAccent(),
  colorScheme: colorScheme ?? FakeColorScheme(),
  reducedMotion: reducedMotion ?? FakeReducedMotion(),
  platformHighContrast: () => platformHighContrast,
  platformBrightness: () => platformBrightness,
  platformReduceMotion: () => platformReduceMotion,
  platformTextScaleFactor: () => platformTextScaleFactor,
  debounce: const Duration(milliseconds: 10),
);

void main() {
  group('GNOME family', () {
    test('reads the button layout from GSettings', () async {
      final settings = await _reader(
        gsettings: FakeGSettings({'$_gnomeWm/button-layout': 'close:'}),
      ).read();
      expect(settings.desktopEnvironment, Oito2DesktopEnvironment.gnome);
      expect(settings.windowControlStyle, Oito2WindowControlStyle.gnome);
      expect(
        settings.windowButtonLayout,
        const Oito2WindowButtonLayout(leading: [_close]),
      );
    });

    test('falls back to the default layout without GSettings', () async {
      final settings = await _reader().read();
      expect(
        settings.windowButtonLayout,
        Oito2WindowButtonLayout.defaultFor(Oito2WindowControlStyle.gnome),
      );
    });

    test('Budgie, Pantheon and Unity read the GNOME schema', () async {
      for (final desktop in ['Budgie:GNOME', 'Pantheon', 'Unity']) {
        final settings = await _reader(
          desktop: desktop,
          gsettings: FakeGSettings({'$_gnomeWm/button-layout': 'close:'}),
        ).read();
        expect(settings.windowButtonLayout.leading, [_close], reason: desktop);
      }
    });

    test('Cinnamon and MATE read their own schemas', () async {
      final cinnamon = await _reader(
        desktop: 'X-Cinnamon',
        gsettings: FakeGSettings({
          'org.cinnamon.desktop.wm.preferences/button-layout':
              ':minimize,close',
        }),
      ).read();
      expect(cinnamon.windowButtonLayout.trailing, [_min, _close]);

      final mate = await _reader(
        desktop: 'MATE',
        gsettings: FakeGSettings({
          'org.mate.Marco.general/button-layout': 'close,maximize:',
        }),
      ).read();
      expect(mate.windowButtonLayout.leading, [_close, _max]);
    });

    test('maps the GNOME 47 accent-color to the GNOME palette', () async {
      final settings = await _reader(
        gsettings: FakeGSettings({'$_interface/accent-color': 'purple'}),
        accent: FakeAccent(const Color(0xFF123456)),
      ).read();
      expect(settings.accentColor, Oito2AccentColor.purple.color);
    });

    test('other desktops ignore the GNOME accent-color key', () async {
      // Their systems may install the GNOME schema, whose default accent
      // is blue, without using it.
      for (final desktop in ['MATE', 'X-Cinnamon', 'Budgie:GNOME', 'XFCE']) {
        final settings = await _reader(
          desktop: desktop,
          gsettings: FakeGSettings({'$_interface/accent-color': 'blue'}),
          accent: FakeAccent(const Color(0xFF123456)),
        ).read();
        expect(settings.accentColor, const Color(0xFF123456), reason: desktop);
      }
    });

    test('uses the toolkit accent without accent-color', () async {
      final settings = await _reader(
        accent: FakeAccent(const Color(0xFF123456)),
      ).read();
      expect(settings.accentColor, const Color(0xFF123456));
    });

    test('reads high contrast from the a11y key or the GTK theme', () async {
      expect(
        (await _reader(
          gsettings: FakeGSettings({'$_a11y/high-contrast': true}),
        ).read()).highContrast,
        isTrue,
      );
      expect(
        (await _reader(
          gsettings: FakeGSettings({'$_interface/gtk-theme': 'HighContrast'}),
        ).read()).highContrast,
        isTrue,
      );
      expect(
        (await _reader(
          gsettings: FakeGSettings({'$_interface/gtk-theme': 'Adwaita'}),
        ).read()).highContrast,
        isFalse,
      );
    });
  });

  group('KDE Plasma', () {
    test('reads the button layout from kwinrc', () async {
      final settings = await _reader(
        desktop: 'KDE',
        files: FakeConfigFiles({
          _kwinrc:
              '[org.kde.kdecoration2]\nButtonsOnLeft=X\nButtonsOnRight=IA\n',
        }),
      ).read();
      expect(settings.windowControlStyle, Oito2WindowControlStyle.breeze);
      expect(
        settings.windowButtonLayout,
        const Oito2WindowButtonLayout(
          leading: [_close],
          trailing: [_min, _max],
        ),
      );
    });

    test('uses the Breeze defaults without kwinrc', () async {
      final settings = await _reader(desktop: 'KDE').read();
      expect(
        settings.windowButtonLayout,
        const Oito2WindowButtonLayout(trailing: [_min, _max, _close]),
      );
    });

    test('reads the accent and contrast from kdeglobals', () async {
      final settings = await _reader(
        desktop: 'KDE',
        files: FakeConfigFiles({
          _kdeglobals: '[General]\nAccentColor=61,174,233\nColorScheme=BreezeHighContrast\n',
        }),
        accent: FakeAccent(const Color(0xFF123456)),
      ).read();
      expect(settings.accentColor, const Color(0xFF3DAEE9));
      expect(settings.highContrast, isTrue);
    });

    test('falls back to the toolkit accent without AccentColor', () async {
      final settings = await _reader(
        desktop: 'KDE',
        files: FakeConfigFiles({
          _kdeglobals: '[General]\nColorScheme=Breeze\n',
        }),
        accent: FakeAccent(const Color(0xFF123456)),
      ).read();
      expect(settings.accentColor, const Color(0xFF123456));
      expect(settings.highContrast, isFalse);
    });
  });

  group('Xfce', () {
    test('reads the button layout from xfwm4.xml', () async {
      final settings = await _reader(
        desktop: 'XFCE',
        files: FakeConfigFiles({
          _xfwm:
              '<channel name="xfwm4"><property name="general" type="empty">'
              '<property name="button_layout" type="string" value="CMH|"/>'
              '</property></channel>',
        }),
      ).read();
      expect(settings.windowControlStyle, Oito2WindowControlStyle.xfwm);
      expect(settings.windowButtonLayout.leading, [_close, _max, _min]);
      expect(settings.windowButtonLayout.trailing, isEmpty);
    });

    test('uses the Xfce default without the file', () async {
      final settings = await _reader(desktop: 'XFCE').read();
      expect(settings.windowButtonLayout.trailing, [_min, _max, _close]);
    });
  });

  group('COSMIC', () {
    test('hides the buttons turned off in its settings', () async {
      final settings = await _reader(
        desktop: 'COSMIC',
        files: FakeConfigFiles({
          '$_cosmic/show_minimize': 'false',
          '$_cosmic/show_maximize': 'true',
        }),
      ).read();
      expect(settings.windowControlStyle, Oito2WindowControlStyle.cosmic);
      expect(settings.windowButtonLayout.trailing, [_max, _close]);
    });

    test('shows every button by default', () async {
      final settings = await _reader(desktop: 'COSMIC').read();
      expect(settings.windowButtonLayout.trailing, [_min, _max, _close]);
    });
  });

  group('other platforms', () {
    test('use the platform defaults and the system accent', () async {
      final settings = await _reader(
        platform: _windows,
        accent: FakeAccent(const Color(0xFF0078D4)),
        gsettings: FakeGSettings({'$_gnomeWm/button-layout': 'close:'}),
      ).read();
      expect(settings.desktopEnvironment, isNull);
      expect(settings.windowControlStyle, Oito2WindowControlStyle.windows);
      expect(
        settings.windowButtonLayout,
        Oito2WindowButtonLayout.defaultFor(Oito2WindowControlStyle.windows),
      );
      expect(settings.accentColor, const Color(0xFF0078D4));
    });

    test('honor the platform high-contrast preference', () async {
      final settings = await _reader(
        platform: _windows,
        platformHighContrast: true,
      ).read();
      expect(settings.highContrast, isTrue);
    });

    test('the web has no desktop environment', () async {
      final settings = await _reader(
        platform: const Oito2Platform(
          targetPlatform: TargetPlatform.linux,
          isWeb: true,
        ),
      ).read();
      expect(settings.desktopEnvironment, isNull);
      expect(settings.windowControlStyle, Oito2WindowControlStyle.none);
    });
  });

  group('portal accent', () {
    test('wins over the desktop stores and the toolkit', () async {
      const portal = Color(0xFF3399FF);
      for (final (desktop, gsettings, files) in [
        (
          'GNOME',
          FakeGSettings({'$_interface/accent-color': 'purple'}),
          FakeConfigFiles(),
        ),
        (
          'KDE',
          FakeGSettings(),
          FakeConfigFiles({_kdeglobals: '[General]\nAccentColor=255,0,0\n'}),
        ),
        ('COSMIC', FakeGSettings(), FakeConfigFiles()),
      ]) {
        final settings = await _reader(
          desktop: desktop,
          gsettings: gsettings,
          files: files,
          accent: FakeAccent(const Color(0xFF123456)),
          portalAccent: FakeAccent(portal),
        ).read();
        expect(settings.accentColor, portal, reason: desktop);
      }
    });

    test('is not read outside native Linux', () async {
      final settings = await _reader(
        platform: _windows,
        accent: FakeAccent(const Color(0xFF123456)),
        portalAccent: FakeAccent(const Color(0xFF3399FF)),
      ).read();
      expect(settings.accentColor, const Color(0xFF123456));
    });
  });

  group('color scheme', () {
    test('the desktop portal wins over the desktop store', () async {
      final settings = await _reader(
        colorScheme: FakeColorScheme(Brightness.dark),
        gsettings: FakeGSettings({'$_interface/color-scheme': 'prefer-light'}),
      ).read();
      expect(settings.colorScheme, Brightness.dark);
    });

    test('the GNOME family falls back to color-scheme', () async {
      for (final (value, expected) in [
        ('prefer-dark', Brightness.dark),
        ('prefer-light', Brightness.light),
        ('default', null),
        (null, null),
      ]) {
        for (final desktop in ['GNOME', 'Budgie:GNOME', 'X-Cinnamon', 'MATE']) {
          final settings = await _reader(
            desktop: desktop,
            gsettings: FakeGSettings({'$_interface/color-scheme': value}),
          ).read();
          expect(settings.colorScheme, expected, reason: '$desktop $value');
        }
      }
    });

    test('KDE falls back to a dark color scheme or look-and-feel', () async {
      Future<Brightness?> read(String globals) async => (await _reader(
        desktop: 'KDE',
        files: FakeConfigFiles({_kdeglobals: globals}),
      ).read()).colorScheme;
      expect(
        await read('[General]\nColorScheme=BreezeDark\n'),
        Brightness.dark,
      );
      expect(await read('[General]\nColorScheme=BreezeLight\n'), isNull);
      expect(
        await read('[KDE]\nLookAndFeelPackage=org.kde.breezedark.desktop\n'),
        Brightness.dark,
      );
      expect(await read(''), isNull);
    });

    test('COSMIC falls back to its theme mode', () async {
      Future<Brightness?> read(Map<String, String> files) async =>
          (await _reader(
            desktop: 'COSMIC',
            files: FakeConfigFiles(files),
          ).read()).colorScheme;
      expect(await read({_cosmicDark: 'true'}), Brightness.dark);
      expect(await read({_cosmicDark: 'false'}), Brightness.light);
      expect(await read({}), isNull);
    });

    test('Xfce and LXQt rely on the portal alone', () async {
      for (final desktop in ['XFCE', 'LXQt']) {
        final settings = await _reader(
          desktop: desktop,
          gsettings: FakeGSettings({'$_interface/color-scheme': 'prefer-dark'}),
        ).read();
        expect(settings.colorScheme, isNull, reason: desktop);
      }
    });

    test('other platforms report the platform brightness', () async {
      final settings = await _reader(
        platform: _windows,
        colorScheme: FakeColorScheme(Brightness.light),
        platformBrightness: Brightness.dark,
      ).read();
      expect(settings.colorScheme, Brightness.dark);
      final none = await _reader(platform: _windows).read();
      expect(none.colorScheme, isNull);
    });
  });

  group('motion, text scale and cursor size', () {
    const cinnamonInterface = 'org.cinnamon.desktop.interface';
    const mateInterface = 'org.mate.interface';
    const xsettings = 'xfce4/xfconf/xfce-perchannel-xml/xsettings.xml';
    String xfconf({String? dpi, String? cursor}) =>
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<channel name="xsettings" version="1.0">\n'
        '  <property name="Xft" type="empty">\n'
        '${dpi == null ? '' : '    <property name="DPI" type="int" value="$dpi"/>\n'}'
        '  </property>\n'
        '  <property name="Gtk" type="empty">\n'
        '${cursor == null ? '' : '    <property name="CursorThemeSize" type="int" value="$cursor"/>\n'}'
        '  </property>\n'
        '</channel>\n';

    test('are unknown on GNOME without values', () async {
      final settings = await _reader().read();
      expect(settings.reduceMotion, isNull);
      expect(settings.textScaleFactor, isNull);
      expect(settings.cursorSize, isNull);
    });

    test('the GNOME family reads the interface and a11y keys', () async {
      for (final desktop in ['GNOME', 'Budgie:GNOME', 'Pantheon', 'Unity']) {
        final gsettings = FakeGSettings({
          '$_interface/enable-animations': true,
          '$_interface/text-scaling-factor': 1.25,
          '$_interface/cursor-size': 48,
        });
        final reader = _reader(desktop: desktop, gsettings: gsettings);
        var settings = await reader.read();
        expect(settings.reduceMotion, isFalse, reason: desktop);
        expect(settings.textScaleFactor, 1.25, reason: desktop);
        expect(settings.cursorSize, 48, reason: desktop);

        gsettings.set(_interface, 'enable-animations', false);
        settings = await reader.read();
        expect(settings.reduceMotion, isTrue, reason: desktop);

        // GNOME 50 adds a separate reduced motion preference.
        gsettings
          ..set(_interface, 'enable-animations', true)
          ..set(_a11y, 'reduced-motion', 'reduce');
        settings = await reader.read();
        expect(settings.reduceMotion, isTrue, reason: desktop);
      }
    });

    test('a cursor size of 0 is the theme default', () async {
      final settings = await _reader(
        gsettings: FakeGSettings({'$_interface/cursor-size': 0}),
      ).read();
      expect(settings.cursorSize, isNull);
    });

    test('Cinnamon reads its own schemas', () async {
      final gsettings = FakeGSettings({
        '$_interface/text-scaling-factor': 2.0,
        '$_interface/cursor-size': 96,
        '$cinnamonInterface/enable-animations': true,
        'org.cinnamon/desktop-effects-workspace': true,
        '$cinnamonInterface/text-scaling-factor': 1.5,
        '$cinnamonInterface/cursor-size': 32,
      });
      final reader = _reader(desktop: 'X-Cinnamon', gsettings: gsettings);
      var settings = await reader.read();
      expect(settings.reduceMotion, isFalse);
      expect(settings.textScaleFactor, 1.5);
      expect(settings.cursorSize, 32);

      gsettings.set('org.cinnamon', 'desktop-effects-workspace', false);
      settings = await reader.read();
      expect(settings.reduceMotion, isTrue);

      gsettings
        ..set('org.cinnamon', 'desktop-effects-workspace', true)
        ..set(cinnamonInterface, 'enable-animations', false);
      settings = await reader.read();
      expect(settings.reduceMotion, isTrue);
    });

    test('MATE reads its animation, font DPI and mouse keys', () async {
      final gsettings = FakeGSettings({
        '$mateInterface/enable-animations': true,
        '$mateInterface/gtk-enable-animations': true,
        'org.mate.font-rendering/dpi': 0.0,
        'org.mate.peripherals-mouse/cursor-size': 36,
      });
      final reader = _reader(desktop: 'MATE', gsettings: gsettings);
      var settings = await reader.read();
      expect(settings.reduceMotion, isFalse);
      // A DPI of 0 is the automatic DPI.
      expect(settings.textScaleFactor, isNull);
      expect(settings.cursorSize, 36);

      gsettings
        ..set('org.mate.font-rendering', 'dpi', 120.0)
        ..set(mateInterface, 'gtk-enable-animations', false);
      settings = await reader.read();
      expect(settings.textScaleFactor, 1.25);
      expect(settings.reduceMotion, isTrue);
    });

    test('KDE reads kdeglobals, kcmfonts and kcminputrc', () async {
      final files = FakeConfigFiles();
      final reader = _reader(desktop: 'KDE', files: files);
      var settings = await reader.read();
      expect(settings.reduceMotion, isFalse);
      expect(settings.textScaleFactor, 1.0);
      expect(settings.cursorSize, 24);

      files
        ..write(_kdeglobals, '[KDE]\nAnimationDurationFactor=0\n')
        ..write('kcmfonts', '[General]\nforceFontDPI=144\n')
        ..write('kcminputrc', '[Mouse]\ncursorSize=48\ncursorTheme=breeze\n');
      settings = await reader.read();
      expect(settings.reduceMotion, isTrue);
      expect(settings.textScaleFactor, 1.5);
      expect(settings.cursorSize, 48);

      files
        ..write(_kdeglobals, '[KDE]\nAnimationDurationFactor=0.5\n')
        ..write('kcmfonts', '[General]\nforceFontDPI=0\n');
      settings = await reader.read();
      expect(settings.reduceMotion, isFalse);
      expect(settings.textScaleFactor, 1.0);
    });

    test('KDE ignores the forced font DPI in a Wayland session', () async {
      final settings = await Oito2SystemSettingsReader(
        platform: _linux,
        environment: const {
          'XDG_CURRENT_DESKTOP': 'KDE',
          'XDG_SESSION_TYPE': 'wayland',
        },
        configFiles: FakeConfigFiles({
          'kcmfonts': '[General]\nforceFontDPI=144\n',
        }),
      ).read();
      expect(settings.textScaleFactor, 1.0);
    });

    test('Xfce reads xsettings.xml', () async {
      final files = FakeConfigFiles();
      final reader = _reader(desktop: 'XFCE', files: files);
      var settings = await reader.read();
      // No animation setting, default DPI, theme cursor size.
      expect(settings.reduceMotion, isNull);
      expect(settings.textScaleFactor, 1.0);
      expect(settings.cursorSize, isNull);

      files.write(xsettings, xfconf(dpi: '120', cursor: '48'));
      settings = await reader.read();
      expect(settings.textScaleFactor, 1.25);
      expect(settings.cursorSize, 48);

      // -1 asks xfsettingsd for the automatic DPI.
      files.write(xsettings, xfconf(dpi: '-1', cursor: '0'));
      settings = await reader.read();
      expect(settings.textScaleFactor, isNull);
      expect(settings.cursorSize, isNull);
    });

    test('COSMIC and LXQt read only the cursor size', () async {
      final files = FakeConfigFiles({
        'cosmic/com.system76.CosmicComp/v1/cursor_size': 'Some(48)',
        'lxqt/session.conf': '[Mouse]\ncursor_size=32\n',
      });
      final gsettings = FakeGSettings({
        '$_interface/enable-animations': false,
        '$_interface/text-scaling-factor': 2.0,
      });
      for (final (desktop, size) in [('COSMIC', 48), ('LXQt', 32)]) {
        final settings = await _reader(
          desktop: desktop,
          files: files,
          gsettings: gsettings,
        ).read();
        expect(settings.reduceMotion, isNull, reason: desktop);
        expect(settings.textScaleFactor, isNull, reason: desktop);
        expect(settings.cursorSize, size, reason: desktop);
      }
      files.write('cosmic/com.system76.CosmicComp/v1/cursor_size', 'None');
      final settings = await _reader(desktop: 'COSMIC', files: files).read();
      expect(settings.cursorSize, isNull);
    });

    test('the portal and the platform add reduced motion', () async {
      for (final desktop in ['XFCE', 'COSMIC', 'GNOME']) {
        final reducedMotion = FakeReducedMotion(false);
        final reader = _reader(desktop: desktop, reducedMotion: reducedMotion);
        expect((await reader.read()).reduceMotion, isFalse, reason: desktop);
        reducedMotion.reduce = true;
        expect((await reader.read()).reduceMotion, isTrue, reason: desktop);
      }
      final settings = await _reader(
        desktop: 'XFCE',
        platformReduceMotion: true,
      ).read();
      expect(settings.reduceMotion, isTrue);
    });

    test('a portal without a preference leaves the desktop key', () async {
      final settings = await _reader(
        desktop: 'KDE',
        files: FakeConfigFiles({
          _kdeglobals: '[KDE]\nAnimationDurationFactor=0\n',
        }),
        reducedMotion: FakeReducedMotion(false),
      ).read();
      expect(settings.reduceMotion, isTrue);
    });

    test('other platforms report the platform values', () async {
      final settings = await _reader(
        platform: _windows,
        gsettings: FakeGSettings({
          '$_interface/text-scaling-factor': 2.0,
          '$_interface/cursor-size': 48,
        }),
        reducedMotion: FakeReducedMotion(true),
        platformReduceMotion: false,
        platformTextScaleFactor: 1.5,
      ).read();
      expect(settings.reduceMotion, isFalse);
      expect(settings.textScaleFactor, 1.5);
      expect(settings.cursorSize, isNull);
    });

    test('watch follows the desktop stores and the portal', () async {
      Future<Oito2SystemSettings> next(List<Oito2SystemSettings> events) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return events.last;
      }

      // KDE: config files.
      final files = FakeConfigFiles();
      final kde = _reader(desktop: 'KDE', files: files);
      final kdeEvents = <Oito2SystemSettings>[];
      var subscription = kde.watch().listen(kdeEvents.add);
      await next(kdeEvents);
      files.write('kcmfonts', '[General]\nforceFontDPI=120\n');
      expect((await next(kdeEvents)).textScaleFactor, 1.25);
      files.write('kcminputrc', '[Mouse]\ncursorSize=36\n');
      expect((await next(kdeEvents)).cursorSize, 36);
      files.write(_kdeglobals, '[KDE]\nAnimationDurationFactor=0\n');
      expect((await next(kdeEvents)).reduceMotion, isTrue);
      await subscription.cancel();

      // Xfce, COSMIC and LXQt: their files.
      for (final (desktop, path, content) in [
        ('XFCE', xsettings, xfconf(cursor: '40')),
        ('COSMIC', 'cosmic/com.system76.CosmicComp/v1/cursor_size', '40'),
        ('LXQt', 'lxqt/session.conf', '[Mouse]\ncursor_size=40\n'),
      ]) {
        final files = FakeConfigFiles();
        final events = <Oito2SystemSettings>[];
        subscription = _reader(
          desktop: desktop,
          files: files,
        ).watch().listen(events.add);
        await next(events);
        files.write(path, content);
        expect((await next(events)).cursorSize, 40, reason: desktop);
        await subscription.cancel();
      }

      // GSettings desktops: their schemas.
      for (final (desktop, schema, key, value) in [
        ('GNOME', _interface, 'text-scaling-factor', 1.5 as Object),
        ('GNOME', _a11y, 'reduced-motion', 'reduce'),
        ('X-Cinnamon', 'org.cinnamon', 'desktop-effects-workspace', false),
        ('X-Cinnamon', cinnamonInterface, 'text-scaling-factor', 1.5),
        ('MATE', 'org.mate.font-rendering', 'dpi', 144.0),
        ('MATE', 'org.mate.peripherals-mouse', 'cursor-size', 40),
      ]) {
        final gsettings = FakeGSettings();
        final events = <Oito2SystemSettings>[];
        subscription = _reader(
          desktop: desktop,
          gsettings: gsettings,
        ).watch().listen(events.add);
        final before = await next(events);
        gsettings.set(schema, key, value);
        expect(await next(events), isNot(before), reason: '$schema $key');
        await subscription.cancel();
      }

      // The portal.
      final reducedMotion = FakeReducedMotion();
      final events = <Oito2SystemSettings>[];
      subscription = _reader(
        desktop: 'XFCE',
        reducedMotion: reducedMotion,
      ).watch().listen(events.add);
      expect((await next(events)).reduceMotion, isNull);
      reducedMotion.change(true);
      expect((await next(events)).reduceMotion, isTrue);
      await subscription.cancel();
    });
  });

  test('a failing store never breaks the others', () async {
    final gsettings = FakeGSettings()..broken = true;
    final settings = await _reader(
      gsettings: gsettings,
      accent: FakeAccent(const Color(0xFF123456)),
    ).read();
    expect(
      settings.windowButtonLayout,
      Oito2WindowButtonLayout.defaultFor(Oito2WindowControlStyle.gnome),
    );
    expect(settings.accentColor, const Color(0xFF123456));
  });

  group('watch', () {
    test('emits the current settings first', () async {
      final reader = _reader(
        gsettings: FakeGSettings({'$_gnomeWm/button-layout': 'close:'}),
      );
      final first = await reader.watch().first;
      expect(first.windowButtonLayout.leading, [_close]);
    });

    test('drops a read that a newer one overtakes', () async {
      final gate = Completer<void>();
      final accent = _GatedAccent(gate.future, const Color(0xFF111111));
      final reader = _reader(accent: accent);
      final events = <Oito2SystemSettings>[];
      final subscription = reader.watch().listen(events.add);
      addTearDown(subscription.cancel);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      accent.change(const Color(0xFF222222));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      gate.complete();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(events.last.accentColor, const Color(0xFF222222));
    });

    test('emits again only when a change alters the settings', () async {
      final gsettings = FakeGSettings({'$_gnomeWm/button-layout': 'close:'});
      final reader = _reader(gsettings: gsettings);
      final events = <Oito2SystemSettings>[];
      final subscription = reader.watch().listen(events.add);
      addTearDown(subscription.cancel);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(events, hasLength(1));

      gsettings.set(_gnomeWm, 'button-layout', 'close:');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(events, hasLength(1));

      gsettings
        ..set(_gnomeWm, 'button-layout', ':minimize')
        ..set(_gnomeWm, 'button-layout', ':close');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(events, hasLength(2));
      expect(events.last.windowButtonLayout.trailing, [_close]);
    });

    test('follows accent and config file changes', () async {
      final accent = FakeAccent(const Color(0xFF111111));
      final files = FakeConfigFiles();
      final reader = _reader(desktop: 'KDE', files: files, accent: accent);
      final events = <Oito2SystemSettings>[];
      final subscription = reader.watch().listen(events.add);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      accent.change(const Color(0xFF222222));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(events.last.accentColor, const Color(0xFF222222));

      files.write(
        _kwinrc,
        '[org.kde.kdecoration2]\nButtonsOnLeft=X\nButtonsOnRight=\n',
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(events.last.windowButtonLayout.leading, [_close]);

      expect(files.isWatched(_kwinrc), isTrue);
      await subscription.cancel();
      expect(files.isWatched(_kwinrc), isFalse);
    });

    test('follows the portal accent', () async {
      final portalAccent = FakeAccent();
      final reader = _reader(desktop: 'COSMIC', portalAccent: portalAccent);
      final events = <Oito2SystemSettings>[];
      final subscription = reader.watch().listen(events.add);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(events.last.accentColor, isNull);

      portalAccent.change(const Color(0xFF3399FF));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(events.last.accentColor, const Color(0xFF3399FF));
      await subscription.cancel();
    });

    test('Cinnamon and MATE follow their interface schema', () async {
      for (final (desktop, schema) in [
        ('X-Cinnamon', 'org.cinnamon.desktop.interface'),
        ('MATE', 'org.mate.interface'),
      ]) {
        final gsettings = FakeGSettings();
        final accent = FakeAccent(const Color(0xFF111111));
        final reader = _reader(
          desktop: desktop,
          gsettings: gsettings,
          accent: accent,
        );
        final events = <Oito2SystemSettings>[];
        final subscription = reader.watch().listen(events.add);
        await Future<void>.delayed(const Duration(milliseconds: 30));

        // A new GTK theme changes the toolkit accent without notifying it.
        accent.color = const Color(0xFF222222);
        gsettings.set(schema, 'gtk-theme', 'Other');
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(
          events.last.accentColor,
          const Color(0xFF222222),
          reason: desktop,
        );
        await subscription.cancel();
      }
    });

    test('follows the portal color scheme', () async {
      final colorScheme = FakeColorScheme();
      final reader = _reader(colorScheme: colorScheme);
      final events = <Oito2SystemSettings>[];
      final subscription = reader.watch().listen(events.add);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(events.last.colorScheme, isNull);

      colorScheme.change(Brightness.dark);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(events.last.colorScheme, Brightness.dark);
      await subscription.cancel();
    });
  });

  test('close releases the GSettings, accent and portal connections', () async {
    final gsettings = FakeGSettings();
    final accent = FakeAccent();
    final portalAccent = FakeAccent();
    final colorScheme = FakeColorScheme();
    final reducedMotion = FakeReducedMotion();
    final reader = _reader(
      gsettings: gsettings,
      accent: accent,
      portalAccent: portalAccent,
      colorScheme: colorScheme,
      reducedMotion: reducedMotion,
    );
    await reader.read();
    await reader.close();
    expect(reducedMotion.closed, isTrue);
    expect(gsettings.closed, isTrue);
    expect(accent.closed, isTrue);
    expect(portalAccent.closed, isTrue);
    expect(colorScheme.closed, isTrue);
  });
}

/// An accent source whose first read waits for [gate] and returns the
/// color it had when the read started.
class _GatedAccent extends FakeAccent {
  _GatedAccent(this.gate, super.color);

  final Future<void> gate;
  bool _first = true;

  @override
  Future<Color?> read() async {
    final value = color;
    if (_first) {
      _first = false;
      await gate;
    }
    return value;
  }
}
