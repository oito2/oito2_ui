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

// Writes the palettes of the theme families and every resolved color of the
// oito2 base schemes and the 13 presets as a JSON fixture.

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_themes/oito2_ui_themes.dart';

import 'support.dart';

Map<String, String> colorScheme(ColorScheme s) => {
  'primary': hex(s.primary),
  'onPrimary': hex(s.onPrimary),
  'primaryContainer': hex(s.primaryContainer),
  'onPrimaryContainer': hex(s.onPrimaryContainer),
  'primaryFixed': hex(s.primaryFixed),
  'primaryFixedDim': hex(s.primaryFixedDim),
  'onPrimaryFixed': hex(s.onPrimaryFixed),
  'onPrimaryFixedVariant': hex(s.onPrimaryFixedVariant),
  'secondary': hex(s.secondary),
  'onSecondary': hex(s.onSecondary),
  'secondaryContainer': hex(s.secondaryContainer),
  'onSecondaryContainer': hex(s.onSecondaryContainer),
  'secondaryFixed': hex(s.secondaryFixed),
  'secondaryFixedDim': hex(s.secondaryFixedDim),
  'onSecondaryFixed': hex(s.onSecondaryFixed),
  'onSecondaryFixedVariant': hex(s.onSecondaryFixedVariant),
  'tertiary': hex(s.tertiary),
  'onTertiary': hex(s.onTertiary),
  'tertiaryContainer': hex(s.tertiaryContainer),
  'onTertiaryContainer': hex(s.onTertiaryContainer),
  'tertiaryFixed': hex(s.tertiaryFixed),
  'tertiaryFixedDim': hex(s.tertiaryFixedDim),
  'onTertiaryFixed': hex(s.onTertiaryFixed),
  'onTertiaryFixedVariant': hex(s.onTertiaryFixedVariant),
  'error': hex(s.error),
  'onError': hex(s.onError),
  'errorContainer': hex(s.errorContainer),
  'onErrorContainer': hex(s.onErrorContainer),
  'surface': hex(s.surface),
  'onSurface': hex(s.onSurface),
  'surfaceDim': hex(s.surfaceDim),
  'surfaceBright': hex(s.surfaceBright),
  'surfaceContainerLowest': hex(s.surfaceContainerLowest),
  'surfaceContainerLow': hex(s.surfaceContainerLow),
  'surfaceContainer': hex(s.surfaceContainer),
  'surfaceContainerHigh': hex(s.surfaceContainerHigh),
  'surfaceContainerHighest': hex(s.surfaceContainerHighest),
  'onSurfaceVariant': hex(s.onSurfaceVariant),
  'outline': hex(s.outline),
  'outlineVariant': hex(s.outlineVariant),
  'shadow': hex(s.shadow),
  'scrim': hex(s.scrim),
  'inverseSurface': hex(s.inverseSurface),
  'onInverseSurface': hex(s.onInverseSurface),
  'inversePrimary': hex(s.inversePrimary),
  'surfaceTint': hex(s.surfaceTint),
};

Map<String, String> syntax(Oito2SyntaxPalette p) => {
  'foreground': hex(p.foreground),
  'comment': hex(p.comment),
  'keyword': hex(p.keyword),
  'string': hex(p.string),
  'number': hex(p.number),
  'function': hex(p.function),
  'type': hex(p.type),
  'tag': hex(p.tag),
  'attribute': hex(p.attribute),
  'constant': hex(p.constant),
  'invalid': hex(p.invalid),
};

Map<String, Object> theme(Oito2ColorTheme t) => {
  'brightness': t.brightness.name,
  'highContrast': t.highContrast,
  'background': hex(t.background),
  'colorScheme': colorScheme(t.colorScheme),
  'semantic': {
    'primaryText': hex(t.semantic.primaryText),
    'errorText': hex(t.semantic.errorText),
    'success': hex(t.semantic.success),
    'warning': hex(t.semantic.warning),
    'info': hex(t.semantic.info),
    'link': hex(t.semantic.link),
  },
  'chrome': {
    'background': hex(t.chrome.background),
    'sidebar': hex(t.chrome.sidebar),
    'mainbar': hex(t.chrome.mainbar),
    'titleBar': hex(t.chrome.titleBar),
    'dialog': hex(t.chrome.dialog),
  },
  'syntax': syntax(t.syntax),
};

Map<String, String> everforest(Oito2EverforestPalette p) => {
  'bgDim': hex(p.bgDim),
  'bg0': hex(p.bg0),
  'bg1': hex(p.bg1),
  'bg2': hex(p.bg2),
  'bg3': hex(p.bg3),
  'bg4': hex(p.bg4),
  'fg': hex(p.fg),
  'red': hex(p.red),
  'orange': hex(p.orange),
  'yellow': hex(p.yellow),
  'green': hex(p.green),
  'aqua': hex(p.aqua),
  'blue': hex(p.blue),
  'purple': hex(p.purple),
  'grey0': hex(p.grey0),
  'grey1': hex(p.grey1),
  'grey2': hex(p.grey2),
};

Map<String, String> rosePine(Oito2RosePinePalette p) => {
  'base': hex(p.base),
  'surface': hex(p.surface),
  'overlay': hex(p.overlay),
  'muted': hex(p.muted),
  'subtle': hex(p.subtle),
  'text': hex(p.text),
  'love': hex(p.love),
  'gold': hex(p.gold),
  'rose': hex(p.rose),
  'pine': hex(p.pine),
  'foam': hex(p.foam),
  'iris': hex(p.iris),
};

Map<String, String> dracula(Oito2DraculaPalette p) => {
  'background': hex(p.background),
  'currentLine': hex(p.currentLine),
  'foreground': hex(p.foreground),
  'comment': hex(p.comment),
  'cyan': hex(p.cyan),
  'green': hex(p.green),
  'orange': hex(p.orange),
  'pink': hex(p.pink),
  'purple': hex(p.purple),
  'red': hex(p.red),
  'yellow': hex(p.yellow),
};

Map<String, String> flavor(Flavor f) => {
  'rosewater': hex(f.rosewater),
  'flamingo': hex(f.flamingo),
  'pink': hex(f.pink),
  'mauve': hex(f.mauve),
  'red': hex(f.red),
  'maroon': hex(f.maroon),
  'peach': hex(f.peach),
  'yellow': hex(f.yellow),
  'green': hex(f.green),
  'teal': hex(f.teal),
  'sky': hex(f.sky),
  'sapphire': hex(f.sapphire),
  'blue': hex(f.blue),
  'lavender': hex(f.lavender),
  'text': hex(f.text),
  'subtext1': hex(f.subtext1),
  'subtext0': hex(f.subtext0),
  'overlay2': hex(f.overlay2),
  'overlay1': hex(f.overlay1),
  'overlay0': hex(f.overlay0),
  'surface2': hex(f.surface2),
  'surface1': hex(f.surface1),
  'surface0': hex(f.surface0),
  'base': hex(f.base),
  'mantle': hex(f.mantle),
  'crust': hex(f.crust),
};

void main() {
  test('exports the schemes', () {
    final file = writeFixture('schemes.json', {
      'palettes': {
        'everforest': {
          'light': everforest(Oito2EverforestPalette.light),
          'dark': everforest(Oito2EverforestPalette.dark),
        },
        'rosePine': {
          'main': rosePine(Oito2RosePinePalette.main),
          'moon': rosePine(Oito2RosePinePalette.moon),
          'dawn': rosePine(Oito2RosePinePalette.dawn),
        },
        'nord': {
          'nord0': hex(Oito2NordPalette.nord0),
          'nord1': hex(Oito2NordPalette.nord1),
          'nord2': hex(Oito2NordPalette.nord2),
          'nord3': hex(Oito2NordPalette.nord3),
          'nord4': hex(Oito2NordPalette.nord4),
          'nord5': hex(Oito2NordPalette.nord5),
          'nord6': hex(Oito2NordPalette.nord6),
          'nord7': hex(Oito2NordPalette.nord7),
          'nord8': hex(Oito2NordPalette.nord8),
          'nord9': hex(Oito2NordPalette.nord9),
          'nord10': hex(Oito2NordPalette.nord10),
          'nord11': hex(Oito2NordPalette.nord11),
          'nord12': hex(Oito2NordPalette.nord12),
          'nord13': hex(Oito2NordPalette.nord13),
          'nord14': hex(Oito2NordPalette.nord14),
          'nord15': hex(Oito2NordPalette.nord15),
        },
        'dracula': {
          'dracula': dracula(Oito2DraculaPalette.dracula),
          'alucard': dracula(Oito2DraculaPalette.alucard),
        },
        'catppuccin': {
          'latte': flavor(catppuccin.latte),
          'frappe': flavor(catppuccin.frappe),
          'macchiato': flavor(catppuccin.macchiato),
          'mocha': flavor(catppuccin.mocha),
        },
      },
      'base': [
        for (final brightness in Brightness.values)
          for (final accent in Oito2AccentColor.values)
            for (final highContrast in [false, true])
              {
                'brightness': brightness.name,
                'accent': accent.name,
                'highContrast': highContrast,
                'theme': theme(
                  brightness == Brightness.dark
                      ? Oito2ColorTheme.dark(
                          accent: accent.color,
                          highContrast: highContrast,
                        )
                      : Oito2ColorTheme.light(
                          accent: accent.color,
                          highContrast: highContrast,
                        ),
                ),
              },
      ],
      'presets': [
        for (final preset in Oito2ThemePreset.values)
          for (final highContrast in [false, true])
            {
              'preset': preset.name,
              'label': preset.label,
              'isDark': preset.isDark,
              'highContrast': highContrast,
              'theme': theme(
                Oito2ColorTheme.fromRoles(
                  preset.roles,
                  highContrast: highContrast,
                ),
              ),
            },
      ],
    });
    expect(file.existsSync(), isTrue);
  });
}
