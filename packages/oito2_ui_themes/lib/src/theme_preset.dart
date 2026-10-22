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
import 'package:oito2_ui/oito2_ui.dart';

import 'preset_roles.dart';

/// The named color presets, each with a fixed signature color.
///
/// Each preset maps the official palette of its theme family to
/// [Oito2ColorRoles], from which [colors] derives a complete
/// [Oito2ColorTheme] and [theme] a Material `ThemeData`.
enum Oito2ThemePreset {
  /// Everforest Light.
  everforestLight(label: 'Everforest Light', isDark: false),

  /// Everforest Dark.
  everforestDark(label: 'Everforest Dark', isDark: true),

  /// Rosé Pine.
  rosePine(label: 'Rosé Pine', isDark: true),

  /// Rosé Pine Moon.
  rosePineMoon(label: 'Rosé Pine Moon', isDark: true),

  /// Rosé Pine Dawn.
  rosePineDawn(label: 'Rosé Pine Dawn', isDark: false),

  /// Nord, dark.
  nordDark(label: 'Nord Dark', isDark: true),

  /// Nord, light: an unofficial derivation with Polar Night and Snow Storm
  /// swapped.
  nordLight(label: 'Nord Light', isDark: false),

  /// Dracula.
  dracula(label: 'Dracula', isDark: true),

  /// Alucard, the light variant of Dracula.
  alucard(label: 'Alucard', isDark: false),

  /// Catppuccin Latte.
  catppuccinLatte(label: 'Catppuccin Latte', isDark: false),

  /// Catppuccin Frappé.
  catppuccinFrappe(label: 'Catppuccin Frappé', isDark: true),

  /// Catppuccin Macchiato.
  catppuccinMacchiato(label: 'Catppuccin Macchiato', isDark: true),

  /// Catppuccin Mocha.
  catppuccinMocha(label: 'Catppuccin Mocha', isDark: true);

  const Oito2ThemePreset({required this.label, required this.isDark});

  /// The display name of this preset, such as `Catppuccin Mocha`.
  final String label;

  /// Whether this preset is a dark theme.
  final bool isDark;

  /// The brightness of this preset.
  Brightness get brightness => isDark ? Brightness.dark : Brightness.light;

  /// The role colors of this preset, as published by its theme family.
  Oito2ColorRoles get roles => _roles[this] ??= presetRoles(this);

  /// The complete colors of this preset.
  Oito2ColorTheme get colors => Oito2ColorTheme.fromRoles(roles);

  /// The oito2 Material theme of this preset for [platform], which
  /// defaults to [Oito2Platform.current], with text and outlines raised
  /// to WCAG AAA when [highContrast] is set.
  ThemeData theme({Oito2Platform? platform, bool highContrast = false}) =>
      Oito2Theme.fromColors(
        Oito2ColorTheme.fromRoles(roles, highContrast: highContrast),
        platform: platform,
      );
}

/// The role colors of each preset, built once.
final Map<Oito2ThemePreset, Oito2ColorRoles> _roles = {};
