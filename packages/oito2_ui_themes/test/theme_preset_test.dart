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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_themes/oito2_ui_themes.dart';

void main() {
  test('defines the 13 presets with their brightness', () {
    const expected = {
      Oito2ThemePreset.everforestLight: false,
      Oito2ThemePreset.everforestDark: true,
      Oito2ThemePreset.rosePine: true,
      Oito2ThemePreset.rosePineMoon: true,
      Oito2ThemePreset.rosePineDawn: false,
      Oito2ThemePreset.nordDark: true,
      Oito2ThemePreset.nordLight: false,
      Oito2ThemePreset.dracula: true,
      Oito2ThemePreset.alucard: false,
      Oito2ThemePreset.catppuccinLatte: false,
      Oito2ThemePreset.catppuccinFrappe: true,
      Oito2ThemePreset.catppuccinMacchiato: true,
      Oito2ThemePreset.catppuccinMocha: true,
    };
    expect(Oito2ThemePreset.values, hasLength(13));
    expected.forEach((preset, isDark) {
      expect(preset.isDark, isDark, reason: preset.name);
      expect(
        preset.brightness,
        isDark ? Brightness.dark : Brightness.light,
        reason: preset.name,
      );
    });
  });

  test('presets have display names and a high contrast theme', () {
    expect(Oito2ThemePreset.catppuccinMocha.label, 'Catppuccin Mocha');
    expect({
      for (final preset in Oito2ThemePreset.values) preset.label,
    }, hasLength(Oito2ThemePreset.values.length));
    expect(
      Oito2ThemePreset.nordDark.roles,
      same(Oito2ThemePreset.nordDark.roles),
    );
    final high = Oito2ThemePreset.nordDark.theme(highContrast: true);
    final normal = Oito2ThemePreset.nordDark.theme();
    expect(high, isNot(same(normal)));
    for (final preset in Oito2ThemePreset.values) {
      expect(preset.roles.brightness, preset.brightness, reason: preset.name);
    }
  });
}
