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

import '../foundation/platform_info.dart';
import '../foundation/system_settings.dart';
import '../tokens/typography.dart';
import 'color_theme.dart';
import 'components/buttons.dart';
import 'components/component_context.dart';
import 'components/inputs.dart';
import 'components/menus.dart';
import 'components/navigation.dart';
import 'components/selection.dart';
import 'components/surfaces.dart';
import 'extensions/syntax_theme.dart';
import 'page_transitions.dart';
import 'theme_preset.dart';

/// Builds the oito2 Material 3 [ThemeData].
///
/// Every builder accepts an optional [Oito2Platform]; it defaults to
/// [Oito2Platform.current] and drives density, control sizes, tap targets,
/// splash effects and page transitions.
abstract final class Oito2Theme {
  /// The light oito2 base theme with [accent] as the primary hue.
  static ThemeData light({
    Color? accent,
    bool highContrast = false,
    Oito2Platform? platform,
  }) => fromColors(
    Oito2ColorTheme.light(accent: accent, highContrast: highContrast),
    platform: platform,
  );

  /// The dark oito2 base theme with [accent] as the primary hue.
  static ThemeData dark({
    Color? accent,
    bool highContrast = false,
    Oito2Platform? platform,
  }) => fromColors(
    Oito2ColorTheme.dark(accent: accent, highContrast: highContrast),
    platform: platform,
  );

  /// The theme of [preset].
  static ThemeData fromPreset(
    Oito2ThemePreset preset, {
    Oito2Platform? platform,
  }) => fromColors(Oito2ColorTheme.fromPreset(preset), platform: platform);

  /// The theme that follows the system [settings] for [brightness].
  ///
  /// Uses [preset] when given. Otherwise builds the base theme with
  /// [accent], falling back to the system accent color, and the system
  /// high-contrast preference. The platform comes from [settings].
  static ThemeData fromSystem(
    Oito2SystemSettings settings, {
    required Brightness brightness,
    Color? accent,
    Oito2ThemePreset? preset,
  }) {
    if (preset != null) return fromPreset(preset, platform: settings.platform);
    final color = accent ?? settings.accentColor;
    return brightness == Brightness.dark
        ? dark(
            accent: color,
            highContrast: settings.highContrast,
            platform: settings.platform,
          )
        : light(
            accent: color,
            highContrast: settings.highContrast,
            platform: settings.platform,
          );
  }

  /// The theme for already resolved [colors].
  ///
  /// [colors] provides the `ColorScheme`, the scaffold background and the
  /// [ThemeExtension]s ([Oito2ColorTheme.semantic],
  /// [Oito2ColorTheme.chrome] and [Oito2ColorTheme.syntax] wrapped in
  /// [Oito2SyntaxTheme]).
  static ThemeData fromColors(
    Oito2ColorTheme colors, {
    Oito2Platform? platform,
  }) {
    final target = platform ?? Oito2Platform.current();
    final scheme = colors.colorScheme;
    final textTheme = Oito2Typography.textTheme(colors.brightness)
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final c = ComponentThemeContext(
      colors: colors,
      platform: target,
      textTheme: textTheme,
    );
    final inputDecorationTheme = buildInputDecorationTheme(c);
    final menuStyle = buildMenuStyle(c);
    final pointerDesktop = !target.usesTouchInput;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      platform: target.targetPlatform,
      visualDensity: target.visualDensity,
      materialTapTargetSize: target.usesTouchInput
          ? MaterialTapTargetSize.padded
          : MaterialTapTargetSize.shrinkWrap,
      splashFactory: pointerDesktop ? NoSplash.splashFactory : null,
      fontFamily: Oito2Typography.fontFamily,
      fontFamilyFallback: Oito2Typography.fontFamilyFallback,
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      hoverColor: ComponentThemeContext.fade(scheme.onSurface, 0.04),
      focusColor: ComponentThemeContext.fade(c.indicator, 0.12),
      iconTheme: IconThemeData(color: scheme.onSurface, size: c.iconSize),
      pageTransitionsTheme: oito2PageTransitionsTheme(),
      extensions: [
        colors.semantic,
        colors.chrome,
        Oito2SyntaxTheme(colors.syntax),
      ],
      appBarTheme: buildAppBarTheme(c),
      bottomSheetTheme: buildBottomSheetTheme(c),
      cardTheme: buildCardTheme(c),
      carouselViewTheme: buildCarouselViewTheme(c),
      checkboxTheme: buildCheckboxTheme(c),
      chipTheme: buildChipTheme(c),
      dialogTheme: buildDialogTheme(c),
      dividerTheme: buildDividerTheme(c),
      drawerTheme: buildDrawerTheme(c),
      dropdownMenuTheme: buildDropdownMenuTheme(
        c,
        inputDecorationTheme,
        menuStyle,
      ),
      elevatedButtonTheme: buildElevatedButtonTheme(c),
      expansionTileTheme: buildExpansionTileTheme(c),
      filledButtonTheme: buildFilledButtonTheme(c),
      floatingActionButtonTheme: buildFloatingActionButtonTheme(c),
      iconButtonTheme: buildIconButtonTheme(c),
      inputDecorationTheme: inputDecorationTheme,
      listTileTheme: buildListTileTheme(c),
      menuBarTheme: buildMenuBarTheme(c),
      menuButtonTheme: buildMenuButtonTheme(c),
      menuTheme: buildMenuTheme(menuStyle),
      navigationBarTheme: buildNavigationBarTheme(c),
      navigationDrawerTheme: buildNavigationDrawerTheme(c),
      navigationRailTheme: buildNavigationRailTheme(c),
      outlinedButtonTheme: buildOutlinedButtonTheme(c),
      popupMenuTheme: buildPopupMenuTheme(c),
      progressIndicatorTheme: buildProgressIndicatorTheme(c),
      radioTheme: buildRadioTheme(c),
      scrollbarTheme: buildScrollbarTheme(c),
      segmentedButtonTheme: buildSegmentedButtonTheme(c),
      sliderTheme: buildSliderTheme(c),
      snackBarTheme: buildSnackBarTheme(c),
      switchTheme: buildSwitchTheme(c),
      tabBarTheme: buildTabBarTheme(c),
      textButtonTheme: buildTextButtonTheme(c),
      textSelectionTheme: buildTextSelectionTheme(c),
      tooltipTheme: buildTooltipTheme(c),
    );
  }
}
