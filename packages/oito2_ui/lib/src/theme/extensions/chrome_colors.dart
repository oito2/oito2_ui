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

import '../theme_preset.dart';

/// Colors of the structural window chrome: the page background, a narrow
/// sidebar column, a wider mainbar panel and the title bar.
///
/// [sidebar] and [mainbar] are derived from the scheme's background and
/// `onSurface` by [Oito2ChromeColors.derive], so their relationship holds
/// in every scheme: the mainbar is lighter than the sidebar in dark schemes
/// and darker in the light ones.
@immutable
class Oito2ChromeColors extends ThemeExtension<Oito2ChromeColors> {
  /// Creates chrome colors from explicit values.
  const Oito2ChromeColors({
    required this.background,
    required this.sidebar,
    required this.mainbar,
    required this.titleBar,
  });

  /// Derives the chrome colors from a scheme's [background] and
  /// [onSurface] colors.
  ///
  /// The sidebar blends [onSurface] at 3% opacity over [background]. The
  /// mainbar blends white at 5% opacity over the sidebar, or black at 4%
  /// opacity when [darkerMainbar] is true. [darkerMainbar] defaults to
  /// whether [preset] is in [darkerMainbarPresets]. The title bar is
  /// [titleBar] when given, otherwise the mainbar.
  factory Oito2ChromeColors.derive({
    required Color background,
    required Color onSurface,
    Color? titleBar,
    Oito2ThemePreset? preset,
    bool? darkerMainbar,
  }) {
    final sidebar = Color.alphaBlend(
      onSurface.withValues(alpha: 0.03),
      background,
    );
    final overlay = darkerMainbar ?? darkerMainbarPresets.contains(preset)
        ? const Color(0xFF000000).withValues(alpha: 0.04)
        : const Color(0xFFFFFFFF).withValues(alpha: 0.05);
    final mainbar = Color.alphaBlend(overlay, sidebar);
    return Oito2ChromeColors(
      background: background,
      sidebar: sidebar,
      mainbar: mainbar,
      titleBar: titleBar ?? mainbar,
    );
  }

  /// Derives the chrome colors from [colorScheme], using
  /// [background] as the page background.
  ///
  /// Use it while building a theme, before a [ThemeData] exists.
  factory Oito2ChromeColors.fromColorScheme(
    ColorScheme colorScheme, {
    required Color background,
    Color? titleBar,
    Oito2ThemePreset? preset,
    bool? darkerMainbar,
  }) {
    return Oito2ChromeColors.derive(
      background: background,
      onSurface: colorScheme.onSurface,
      titleBar: titleBar,
      preset: preset,
      darkerMainbar: darkerMainbar,
    );
  }

  /// Derives the chrome colors from [theme], using its
  /// `scaffoldBackgroundColor` as the page background.
  factory Oito2ChromeColors.fromTheme(
    ThemeData theme, {
    Color? titleBar,
    Oito2ThemePreset? preset,
    bool? darkerMainbar,
  }) {
    return Oito2ChromeColors.derive(
      background: theme.scaffoldBackgroundColor,
      onSurface: theme.colorScheme.onSurface,
      titleBar: titleBar,
      preset: preset,
      darkerMainbar: darkerMainbar,
    );
  }

  /// The presets whose mainbar blends black instead of white: the light
  /// presets, where blending white over their very light backgrounds leaves
  /// the mainbar almost indistinguishable from the sidebar.
  static const Set<Oito2ThemePreset> darkerMainbarPresets = {
    Oito2ThemePreset.everforestLight,
    Oito2ThemePreset.rosePineDawn,
    Oito2ThemePreset.nordLight,
    Oito2ThemePreset.alucard,
    Oito2ThemePreset.catppuccinLatte,
  };

  /// Returns the chrome colors of the closest [Theme], or null when the
  /// theme has none.
  static Oito2ChromeColors? maybeOf(BuildContext context) =>
      Theme.of(context).extension<Oito2ChromeColors>();

  /// The page background.
  final Color background;

  /// A narrow sidebar column, such as an icon rail.
  final Color sidebar;

  /// A wider mainbar panel, such as a file list or a master list.
  final Color mainbar;

  /// The window title bar.
  final Color titleBar;

  @override
  Oito2ChromeColors copyWith({
    Color? background,
    Color? sidebar,
    Color? mainbar,
    Color? titleBar,
  }) {
    return Oito2ChromeColors(
      background: background ?? this.background,
      sidebar: sidebar ?? this.sidebar,
      mainbar: mainbar ?? this.mainbar,
      titleBar: titleBar ?? this.titleBar,
    );
  }

  @override
  Oito2ChromeColors lerp(Oito2ChromeColors? other, double t) {
    if (other == null) return this;
    return Oito2ChromeColors(
      background: Color.lerp(background, other.background, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      mainbar: Color.lerp(mainbar, other.mainbar, t)!,
      titleBar: Color.lerp(titleBar, other.titleBar, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2ChromeColors &&
      other.background == background &&
      other.sidebar == sidebar &&
      other.mainbar == mainbar &&
      other.titleBar == titleBar;

  @override
  int get hashCode => Object.hash(background, sidebar, mainbar, titleBar);
}
