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

/// The user-selected appearance of the showcase.
@immutable
class ShowcaseOptions {
  /// Creates showcase options.
  const ShowcaseOptions({
    this.themeMode = ThemeMode.system,
    this.preset,
    this.accent,
    this.highContrast = false,
  });

  /// Light, dark or system brightness for the base scheme. Presets have a
  /// fixed brightness and ignore it.
  final ThemeMode themeMode;

  /// The selected preset, or null for the oito2 base scheme.
  final Oito2ThemePreset? preset;

  /// The accent color of the base scheme, or null to follow the system
  /// accent.
  final Oito2AccentColor? accent;

  /// Whether the base scheme forces high contrast, on top of the system
  /// preference.
  final bool highContrast;

  /// The accent the base scheme uses with [system]: [accent], then the
  /// system accent, then [Oito2AccentColor.fallback].
  Color accentFor(Oito2SystemSettings system) =>
      accent?.color ?? system.accentColor ?? Oito2AccentColor.fallback.color;

  /// The theme mode the app applies: the preset's brightness when a
  /// preset is selected, otherwise [themeMode].
  ThemeMode get effectiveThemeMode => switch (preset) {
    null => themeMode,
    final preset => preset.isDark ? ThemeMode.dark : ThemeMode.light,
  };

  /// The resolved colors for [brightness] with the [system] accent and
  /// contrast preferences.
  Oito2ColorTheme colorsFor(Brightness brightness, Oito2SystemSettings system) {
    if (preset case final preset?) return Oito2ColorTheme.fromPreset(preset);
    final color = accentFor(system);
    final contrast = highContrast || system.highContrast;
    return brightness == Brightness.dark
        ? Oito2ColorTheme.dark(accent: color, highContrast: contrast)
        : Oito2ColorTheme.light(accent: color, highContrast: contrast);
  }

  /// Returns a copy with the given fields replaced. Pass [clearPreset] to
  /// return to the base scheme and [clearAccent] to follow the system
  /// accent.
  ShowcaseOptions copyWith({
    ThemeMode? themeMode,
    Oito2ThemePreset? preset,
    bool clearPreset = false,
    Oito2AccentColor? accent,
    bool clearAccent = false,
    bool? highContrast,
  }) {
    return ShowcaseOptions(
      themeMode: themeMode ?? this.themeMode,
      preset: clearPreset ? null : preset ?? this.preset,
      accent: clearAccent ? null : accent ?? this.accent,
      highContrast: highContrast ?? this.highContrast,
    );
  }
}
