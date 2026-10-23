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

import 'package:material_ui/material_ui.dart';

import '../../foundation/contrast.dart';

/// Colors of the structural window chrome: the page background, a narrow
/// sidebar column, a wider mainbar panel, the title bar and modal surfaces.
///
/// [Oito2ChromeColors.fromColorScheme] takes them from the Material 3
/// surface container roles, so the same rule holds in every scheme.
@immutable
class Oito2ChromeColors extends ThemeExtension<Oito2ChromeColors> {
  /// Creates chrome colors from explicit values.
  const Oito2ChromeColors({
    required this.background,
    required this.sidebar,
    required this.mainbar,
    required this.titleBar,
    required this.dialog,
  });

  /// Takes the chrome colors from the surface roles of [colorScheme],
  /// using [background] as the page background.
  ///
  /// - The mainbar is `surfaceContainerHighest`, moved in lightness when
  ///   needed until it reaches [minimumStep] contrast against the page
  ///   background.
  /// - The sidebar is `surfaceContainer`, moved in lightness when needed
  ///   until it reaches [minimumStep] contrast against both the page
  ///   background and the mainbar, so the three stay apart even when a
  ///   scheme's background sits inside its container range.
  /// - The title bar is [titleBar] when given, otherwise
  ///   `surfaceContainer`.
  /// - Dialogs, sheets and drawers use `surface` in a light scheme and
  ///   `surfaceContainerHigh` in a dark one, where a raised surface reads
  ///   lighter.
  ///
  /// Use it while building a theme, before a [ThemeData] exists.
  factory Oito2ChromeColors.fromColorScheme(
    ColorScheme colorScheme, {
    required Color background,
    Color? titleBar,
  }) {
    final mainbar = Oito2Contrast.ensure(colorScheme.surfaceContainerHighest, [
      background,
    ], minimumStep);
    final sidebar = Oito2Contrast.ensure(colorScheme.surfaceContainer, [
      background,
      mainbar,
    ], minimumStep);
    return Oito2ChromeColors(
      background: background,
      sidebar: sidebar,
      mainbar: mainbar,
      titleBar: titleBar ?? colorScheme.surfaceContainer,
      dialog: colorScheme.brightness == Brightness.dark
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surface,
    );
  }

  /// Takes the chrome colors from [theme], using its
  /// `scaffoldBackgroundColor` as the page background.
  factory Oito2ChromeColors.fromTheme(ThemeData theme, {Color? titleBar}) {
    return Oito2ChromeColors.fromColorScheme(
      theme.colorScheme,
      background: theme.scaffoldBackgroundColor,
      titleBar: titleBar,
    );
  }

  /// The minimum contrast ratio between adjacent chrome surfaces: the
  /// page background, the sidebar and the mainbar.
  static const double minimumStep = 1.04;

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

  /// Dialogs, bottom sheets and drawers.
  final Color dialog;

  @override
  Oito2ChromeColors copyWith({
    Color? background,
    Color? sidebar,
    Color? mainbar,
    Color? titleBar,
    Color? dialog,
  }) {
    return Oito2ChromeColors(
      background: background ?? this.background,
      sidebar: sidebar ?? this.sidebar,
      mainbar: mainbar ?? this.mainbar,
      titleBar: titleBar ?? this.titleBar,
      dialog: dialog ?? this.dialog,
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
      dialog: Color.lerp(dialog, other.dialog, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2ChromeColors &&
      other.background == background &&
      other.sidebar == sidebar &&
      other.mainbar == mainbar &&
      other.titleBar == titleBar &&
      other.dialog == dialog;

  @override
  int get hashCode =>
      Object.hash(background, sidebar, mainbar, titleBar, dialog);
}
