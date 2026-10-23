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

/// Typography tokens: the bundled Inter font and the oito2 [TextTheme].
abstract final class Oito2Typography {
  /// The font family name of Inter, as bundled by this package.
  ///
  /// Use it directly as `TextStyle.fontFamily`; it already carries the
  /// package prefix, so don't pass `package: 'oito2_ui'` along with it.
  static const String fontFamily = 'packages/oito2_ui/Inter';

  /// System font families used for glyphs Inter lacks, in order.
  static const List<String> fontFamilyFallback = [
    'Ubuntu',
    'Cantarell',
    'Roboto',
    'Segoe UI',
    'SF Pro Text',
    'Noto Sans',
  ];

  /// Font size of [TextTheme.bodyLarge]: 16.
  static const double bodyLargeSize = 16;

  /// Font size of [TextTheme.bodyMedium]: 14.
  static const double bodyMediumSize = 14;

  /// Font size of [TextTheme.bodySmall]: 12.
  static const double bodySmallSize = 12;

  /// Weight applied to headlines, titles and [TextTheme.labelLarge].
  static const FontWeight emphasisWeight = FontWeight.w600;

  /// Returns the oito2 text theme for [brightness].
  ///
  /// Starts from the Material 2021 typography (white glyphs for dark,
  /// black glyphs for light), sets [fontFamily] and [fontFamilyFallback] on
  /// every style, sets the body sizes to 16, 14 and 12, and applies
  /// [emphasisWeight] to every headline and title style and to
  /// [TextTheme.labelLarge].
  static TextTheme textTheme(Brightness brightness) {
    final typography = Typography.material2021();
    final base = brightness == Brightness.dark
        ? typography.white
        : typography.black;
    final themed = base.apply(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );
    TextStyle? emphasized(TextStyle? style) =>
        style?.copyWith(fontWeight: emphasisWeight);
    return themed.copyWith(
      bodyLarge: themed.bodyLarge?.copyWith(fontSize: bodyLargeSize),
      bodyMedium: themed.bodyMedium?.copyWith(fontSize: bodyMediumSize),
      bodySmall: themed.bodySmall?.copyWith(fontSize: bodySmallSize),
      headlineLarge: emphasized(themed.headlineLarge),
      headlineMedium: emphasized(themed.headlineMedium),
      headlineSmall: emphasized(themed.headlineSmall),
      titleLarge: emphasized(themed.titleLarge),
      titleMedium: emphasized(themed.titleMedium),
      titleSmall: emphasized(themed.titleSmall),
      labelLarge: emphasized(themed.labelLarge),
    );
  }
}
