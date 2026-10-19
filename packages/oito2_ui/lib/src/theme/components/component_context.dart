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

import '../../foundation/contrast.dart';
import '../../foundation/platform_info.dart';
import '../../tokens/geometry.dart';
import '../color_theme.dart';
import '../extensions/chrome_colors.dart';
import '../extensions/semantic_colors.dart';

/// The inputs shared by every component theme builder: the resolved
/// colors, the platform and the text theme, plus the metrics derived from
/// them.
@immutable
class ComponentThemeContext {
  /// Creates a context for building component themes.
  const ComponentThemeContext({
    required this.colors,
    required this.platform,
    required this.textTheme,
  });

  /// The resolved colors.
  final Oito2ColorTheme colors;

  /// The platform the theme targets.
  final Oito2Platform platform;

  /// The text theme, already colored for the scheme.
  final TextTheme textTheme;

  /// The Material color scheme.
  ColorScheme get scheme => colors.colorScheme;

  /// The text-safe semantic colors.
  Oito2SemanticColors get semantic => colors.semantic;

  /// The chrome colors.
  Oito2ChromeColors get chrome => colors.chrome;

  /// Whether the primary input is touch.
  bool get isTouch => platform.usesTouchInput;

  /// Height of buttons and single-line fields.
  double get controlHeight =>
      isTouch ? Oito2Sizes.touchButtonHeight : Oito2Sizes.buttonHeight;

  /// Size of icons inside controls.
  double get iconSize => isTouch ? 24 : Oito2Sizes.iconSize;

  /// The color for selected toggles, indicators and focus rings: the
  /// text-safe primary tone, which reaches 3:1 against every surface.
  Color get indicator => semantic.primaryText;

  /// The foreground drawn on top of [indicator].
  Color get onIndicator => Oito2Contrast.foregroundFor(indicator);

  /// A border that shows only while the control has keyboard focus: a
  /// [Oito2Sizes.focusBorderWidth] ring in [indicator], drawn outside the
  /// control. Other states use [otherwise].
  WidgetStateProperty<BorderSide?> focusRing({BorderSide? otherwise}) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return BorderSide(
          color: indicator,
          width: Oito2Sizes.focusBorderWidth,
          strokeAlign: BorderSide.strokeAlignOutside,
        );
      }
      return otherwise;
    });
  }

  /// [color] at [opacity] alpha.
  static Color fade(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
