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

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_themes/oito2_ui_themes.dart';

/// The official signature color of every preset.
final _signatures = {
  Oito2ThemePreset.everforestLight: Oito2EverforestPalette.light.green,
  Oito2ThemePreset.everforestDark: Oito2EverforestPalette.dark.green,
  Oito2ThemePreset.rosePine: Oito2RosePinePalette.main.pine,
  Oito2ThemePreset.rosePineMoon: Oito2RosePinePalette.moon.pine,
  Oito2ThemePreset.rosePineDawn: Oito2RosePinePalette.dawn.pine,
  Oito2ThemePreset.nordDark: Oito2NordPalette.nord8,
  Oito2ThemePreset.nordLight: Oito2NordPalette.nord10,
  Oito2ThemePreset.dracula: Oito2DraculaPalette.dracula.purple,
  Oito2ThemePreset.alucard: Oito2DraculaPalette.alucard.purple,
  Oito2ThemePreset.catppuccinLatte: catppuccin.latte.mauve,
  Oito2ThemePreset.catppuccinFrappe: catppuccin.frappe.mauve,
  Oito2ThemePreset.catppuccinMacchiato: catppuccin.macchiato.mauve,
  Oito2ThemePreset.catppuccinMocha: catppuccin.mocha.mauve,
};

Matcher _atLeast(double target) => greaterThanOrEqualTo(target - 0.0001);

void main() {
  for (final preset in Oito2ThemePreset.values) {
    group(preset.name, () {
      final colors = preset.colors;
      final s = colors.colorScheme;
      final surfaces = colors.surfaces;

      test('keeps its signature color, error color and brightness', () {
        expect(preset.roles.brightness, preset.brightness);
        expect(colors.brightness, preset.brightness);
        expect(s.primary, _signatures[preset]);
        expect(s.onPrimary, Oito2Contrast.foregroundFor(s.primary));
        expect(s.error, preset.roles.destructive);
      });

      test('text roles reach 4.5:1 on every surface', () {
        for (final role in [
          s.onSurface,
          s.onSurfaceVariant,
          colors.semantic.primaryText,
          colors.semantic.errorText,
          colors.semantic.success,
          colors.semantic.warning,
          colors.semantic.info,
          colors.semantic.link,
        ]) {
          expect(
            Oito2Contrast.minRatio(role, surfaces),
            _atLeast(Oito2Contrast.textAA),
          );
        }
      });

      test('syntax roles reach 4.5:1 on every surface', () {
        final syntax = colors.syntax;
        for (final role in [
          syntax.foreground,
          syntax.comment,
          syntax.keyword,
          syntax.string,
          syntax.number,
          syntax.function,
          syntax.type,
          syntax.tag,
          syntax.attribute,
          syntax.constant,
          syntax.invalid,
        ]) {
          expect(
            Oito2Contrast.minRatio(role, surfaces),
            _atLeast(Oito2Contrast.textAA),
          );
        }
        expect(syntax.keyword, isNot(syntax.string));
      });

      test('outline reaches 3:1 on every surface', () {
        expect(
          Oito2Contrast.minRatio(s.outline, surfaces),
          _atLeast(Oito2Contrast.nonTextAA),
        );
      });

      test('chrome surfaces stay apart from the page background', () {
        final chrome = colors.chrome;
        for (final surface in [chrome.sidebar, chrome.mainbar]) {
          expect(
            Oito2Contrast.ratio(surface, chrome.background),
            _atLeast(Oito2ChromeColors.minimumStep),
          );
        }
      });

      test('theme wraps colors', () {
        final theme = preset.theme(
          platform: const Oito2Platform(
            targetPlatform: TargetPlatform.linux,
            isWeb: false,
          ),
        );
        expect(theme.colorScheme, s);
        expect(theme.scaffoldBackgroundColor, colors.background);
        expect(theme.extension<Oito2ChromeColors>(), colors.chrome);
      });
    });
  }

  test('presets differ from each other', () {
    final schemes = {
      for (final preset in Oito2ThemePreset.values) preset.colors.colorScheme,
    };
    expect(schemes, hasLength(Oito2ThemePreset.values.length));
  });
}
