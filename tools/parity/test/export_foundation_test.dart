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

// Writes the expected results of the oito2_ui foundation helpers (contrast,
// desktop environment, window button layouts, platform and system
// settings) as a JSON fixture for the sibling implementations.

import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'support.dart';

/// The operating system name the fixtures use for [platform].
String os(TargetPlatform platform) => platform.name.toLowerCase();

List<String> buttons(List<Oito2WindowButton> list) => [
  for (final button in list) button.name,
];

Map<String, Object> layout(Oito2WindowButtonLayout value) => {
  'leading': buttons(value.leading),
  'trailing': buttons(value.trailing),
};

Map<String, Object> contrast() {
  final samples = [
    for (final accent in Oito2AccentColor.values) accent.color,
    ...Oito2StatusPalette.light.colors,
    ...Oito2StatusPalette.dark.colors,
    ...Oito2NeutralPalette.light.surfaces,
    ...Oito2NeutralPalette.dark.surfaces,
    color('#000000'),
    color('#FFFFFF'),
    color('#808080'),
  ];
  final ensure = <Object>[];
  for (final palette in [Oito2NeutralPalette.light, Oito2NeutralPalette.dark]) {
    final backgrounds = palette.surfaces;
    final colors = [
      for (final accent in Oito2AccentColor.values) accent.color,
      ...Oito2StatusPalette.light.colors,
      ...Oito2StatusPalette.dark.colors,
      palette.outline,
      palette.onSurfaceVariant,
    ];
    for (final value in colors) {
      for (final target in [
        Oito2Contrast.nonTextAA,
        Oito2Contrast.textAA,
        Oito2Contrast.textAAA,
      ]) {
        ensure.add({
          'color': hex(value),
          'backgrounds': [for (final b in backgrounds) hex(b)],
          'target': target,
          'result': hex(Oito2Contrast.ensure(value, backgrounds, target)),
        });
      }
    }
  }
  return {
    'ratio': [
      for (final a in samples)
        for (final b in samples.take(12))
          {'a': hex(a), 'b': hex(b), 'ratio': Oito2Contrast.ratio(a, b)},
    ],
    'foregroundFor': [
      for (final value in samples)
        {
          'background': hex(value),
          'foreground': hex(Oito2Contrast.foregroundFor(value)),
        },
    ],
    'ensure': ensure,
  };
}

List<Object> desktopEnvironments() {
  const cases = [
    (null, null),
    ('', ''),
    ('GNOME', null),
    ('ubuntu:GNOME', null),
    ('Budgie:GNOME', null),
    ('Pop:GNOME', null),
    ('KDE', null),
    ('XFCE', null),
    ('COSMIC', null),
    ('X-Cinnamon', null),
    ('MATE', null),
    ('LXQt', null),
    ('Pantheon', null),
    ('Unity', null),
    ('Unity:Unity7:ubuntu', null),
    (' gnome ', null),
    ('Hyprland', null),
    ('Hyprland', 'plasmawayland'),
    (null, 'budgie-desktop'),
    (null, 'xubuntu'),
    (null, 'lubuntu'),
    (null, 'cinnamon2d'),
    (null, 'gnome-xorg'),
    (null, 'sway'),
  ];
  return [
    for (final (xdg, session) in cases)
      {
        'xdgCurrentDesktop': xdg,
        'desktopSession': session,
        'result': Oito2DesktopEnvironment.detect(
          xdgCurrentDesktop: xdg,
          desktopSession: session,
        ).name,
      },
  ];
}

Map<String, Object> windowButtonLayouts() {
  const gnome = [
    'appmenu:minimize,maximize,close',
    'close,minimize,maximize:',
    'icon, close:spacer,close,menu',
    'appmenu:close',
    'close',
    '',
    ':',
    'minimize:maximize:close',
    'close,close,close:minimize',
    'menu:minimize,maximize,close,spacer',
  ];
  const kde = [
    ('MS', 'HIAX'),
    ('XIA', ''),
    ('', ''),
    ('XX', 'XIA'),
    ('M', 'IAXFB'),
  ];
  const xfwm = ['O|HMC', 'CHMS|T', 'O|SHMC', '|', '', 'HMC', 'C|C'];
  final platforms = TargetPlatform.values;
  return {
    'gnome': [
      for (final value in gnome)
        {'value': value, ...layout(Oito2WindowButtonLayout.parseGnome(value))},
    ],
    'kde': [
      for (final (left, right) in kde)
        {
          'buttonsOnLeft': left,
          'buttonsOnRight': right,
          ...layout(
            Oito2WindowButtonLayout.parseKde(
              buttonsOnLeft: left,
              buttonsOnRight: right,
            ),
          ),
        },
    ],
    'xfwm': [
      for (final value in xfwm)
        {'value': value, ...layout(Oito2WindowButtonLayout.parseXfwm(value))},
    ],
    'defaultFor': {
      for (final style in Oito2WindowControlStyle.values)
        style.name: layout(Oito2WindowButtonLayout.defaultFor(style)),
    },
    'resolve': [
      for (final platform in platforms)
        for (final isWeb in [false, true])
          for (final environment in [null, ...Oito2DesktopEnvironment.values])
            {
              'os': os(platform),
              'isWeb': isWeb,
              'desktopEnvironment': environment?.name,
              'result': Oito2WindowControlStyle.resolve(
                Oito2Platform(targetPlatform: platform, isWeb: isWeb),
                desktopEnvironment: environment,
              ).name,
            },
    ],
  };
}

List<Object> platforms() => [
  for (final platform in TargetPlatform.values)
    for (final isWeb in [false, true])
      () {
        final value = Oito2Platform(targetPlatform: platform, isWeb: isWeb);
        return {
          'os': os(platform),
          'isWeb': isWeb,
          'isDesktopNative': value.isDesktopNative,
          'isTouch': value.isTouch,
          'isWebTouch': value.isWebTouch,
          'usesTouchInput': value.usesTouchInput,
          'isLinux': value.isLinux,
          'isWindows': value.isWindows,
          'isMacOS': value.isMacOS,
          'isAndroid': value.isAndroid,
          'isIOS': value.isIOS,
        };
      }(),
];

List<Object> systemSettings() => [
  for (final platform in TargetPlatform.values)
    for (final isWeb in [false, true])
      for (final environment in [null, Oito2DesktopEnvironment.kde])
        () {
          final settings = Oito2SystemSettings.fallback(
            Oito2Platform(targetPlatform: platform, isWeb: isWeb),
            desktopEnvironment: environment,
          );
          return {
            'os': os(platform),
            'isWeb': isWeb,
            'desktopEnvironment': environment?.name,
            'result': {
              'desktopEnvironment': settings.desktopEnvironment?.name,
              'windowControlStyle': settings.windowControlStyle.name,
              'windowButtonLayout': layout(settings.windowButtonLayout),
              'accentColor': settings.accentColor,
              'colorScheme': settings.colorScheme?.name,
              'highContrast': settings.highContrast,
            },
          };
        }(),
];

void main() {
  test('exports the foundation helpers', () {
    final file = writeFixture('foundation.json', {
      'contrast': contrast(),
      'desktopEnvironments': desktopEnvironments(),
      'windowButtonLayouts': windowButtonLayouts(),
      'platforms': platforms(),
      'systemSettings': systemSettings(),
    });
    expect(file.existsSync(), isTrue);
  });
}
