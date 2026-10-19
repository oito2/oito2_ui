// Copyright (C) 2026  oito2
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

import 'package:material_ui/material_ui.dart';

/// The named color presets, each with a fixed signature color.
enum Oito2ThemePreset {
  /// Everforest Light.
  everforestLight(isDark: false),

  /// Everforest Dark.
  everforestDark(isDark: true),

  /// Rosé Pine.
  rosePine(isDark: true),

  /// Rosé Pine Moon.
  rosePineMoon(isDark: true),

  /// Rosé Pine Dawn.
  rosePineDawn(isDark: false),

  /// Nord, dark.
  nordDark(isDark: true),

  /// Nord, light: an unofficial derivation with Polar Night and Snow Storm
  /// swapped.
  nordLight(isDark: false),

  /// Dracula.
  dracula(isDark: true),

  /// Alucard, the light variant of Dracula.
  alucard(isDark: false),

  /// Catppuccin Latte.
  catppuccinLatte(isDark: false),

  /// Catppuccin Frappé.
  catppuccinFrappe(isDark: true),

  /// Catppuccin Macchiato.
  catppuccinMacchiato(isDark: true),

  /// Catppuccin Mocha.
  catppuccinMocha(isDark: true);

  const Oito2ThemePreset({required this.isDark});

  /// Whether this preset is a dark theme.
  final bool isDark;

  /// The brightness of this preset.
  Brightness get brightness => isDark ? Brightness.dark : Brightness.light;
}
