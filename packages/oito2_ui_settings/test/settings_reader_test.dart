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

const _min = Oito2WindowButton.minimize;
const _max = Oito2WindowButton.maximize;
const _close = Oito2WindowButton.close;

Oito2SystemSettingsReader _reader({
  String desktop = 'GNOME',
  Oito2Platform platform = _linux,
  FakeGSettings? gsettings,
  FakeConfigFiles? files,
  FakeAccent? accent,
  bool platformHighContrast = false,
}) => Oito2SystemSettingsReader(
  platform: platform,
  environment: {'XDG_CURRENT_DESKTOP': desktop},
  gsettings: gsettings ?? FakeGSettings(),
  configFiles: files ?? FakeConfigFiles(),
  accent: accent ?? FakeAccent(),
  platformHighContrast: () => platformHighContrast,
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
  });

  test('close releases the GSettings connections', () async {
    final gsettings = FakeGSettings();
    final reader = _reader(gsettings: gsettings);
    await reader.read();
    await reader.close();
    expect(gsettings.closed, isTrue);
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
