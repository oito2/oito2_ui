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
import 'package:oito2_ui_themes/oito2_ui_themes.dart';

/// How the showcase sizes its controls.
enum ShowcaseDensity {
  /// Follows the platform the app runs on.
  auto,

  /// Pointer-sized controls, as on desktop platforms.
  desktop,

  /// Touch-sized controls, as on phones and tablets.
  touch,
}

/// The user-selected appearance and layout of the showcase.
@immutable
class ShowcaseOptions {
  /// Creates showcase options.
  const ShowcaseOptions({
    this.themeMode = ThemeMode.system,
    this.preset,
    this.accent,
    this.highContrast = false,
    this.compactMode = false,
    this.rtl = false,
    this.locale,
    this.density = ShowcaseDensity.auto,
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

  /// Whether the pages are listed in a navigation rail instead of a
  /// master-detail list.
  final bool compactMode;

  /// Whether the showcase is laid out right to left.
  final bool rtl;

  /// The app language, or null to follow the system.
  final Locale? locale;

  /// How the controls are sized.
  final ShowcaseDensity density;

  /// The platform the theme is built for: [system], or a desktop or touch
  /// platform when [density] forces one.
  Oito2Platform platformFor(Oito2Platform system) => switch (density) {
    ShowcaseDensity.auto => system,
    ShowcaseDensity.desktop when system.usesTouchInput => Oito2Platform(
      targetPlatform: TargetPlatform.linux,
      isWeb: system.isWeb,
    ),
    ShowcaseDensity.touch when !system.usesTouchInput => Oito2Platform(
      targetPlatform: TargetPlatform.android,
      isWeb: system.isWeb,
    ),
    _ => system,
  };

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
    final contrast = highContrast || system.highContrast;
    if (preset case final preset?) {
      return Oito2ColorTheme.fromRoles(preset.roles, highContrast: contrast);
    }
    final color = accentFor(system);
    return brightness == Brightness.dark
        ? Oito2ColorTheme.dark(accent: color, highContrast: contrast)
        : Oito2ColorTheme.light(accent: color, highContrast: contrast);
  }

  /// Returns a copy with the given fields replaced. Pass [clearPreset] to
  /// return to the base scheme, [clearAccent] to follow the system accent
  /// and [clearLocale] to follow the system language.
  ShowcaseOptions copyWith({
    ThemeMode? themeMode,
    Oito2ThemePreset? preset,
    bool clearPreset = false,
    Oito2AccentColor? accent,
    bool clearAccent = false,
    bool? highContrast,
    bool? compactMode,
    bool? rtl,
    Locale? locale,
    bool clearLocale = false,
    ShowcaseDensity? density,
  }) {
    return ShowcaseOptions(
      themeMode: themeMode ?? this.themeMode,
      preset: clearPreset ? null : preset ?? this.preset,
      accent: clearAccent ? null : accent ?? this.accent,
      highContrast: highContrast ?? this.highContrast,
      compactMode: compactMode ?? this.compactMode,
      rtl: rtl ?? this.rtl,
      locale: clearLocale ? null : locale ?? this.locale,
      density: density ?? this.density,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShowcaseOptions &&
      other.themeMode == themeMode &&
      other.preset == preset &&
      other.accent == accent &&
      other.highContrast == highContrast &&
      other.compactMode == compactMode &&
      other.rtl == rtl &&
      other.locale == locale &&
      other.density == density;

  @override
  int get hashCode => Object.hash(
    themeMode,
    preset,
    accent,
    highContrast,
    compactMode,
    rtl,
    locale,
    density,
  );
}

/// Holds the showcase options and notifies listeners when they change.
class ShowcaseController extends ValueNotifier<ShowcaseOptions> {
  /// Creates a controller with [initial] options.
  ShowcaseController([super.initial = const ShowcaseOptions()]);

  /// Replaces the options with the result of [change].
  void update(ShowcaseOptions Function(ShowcaseOptions options) change) =>
      value = change(value);
}
