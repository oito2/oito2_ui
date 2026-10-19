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

/// Color contrast helpers based on WCAG 2.2 relative luminance.
abstract final class Oito2Contrast {
  /// Minimum contrast ratio for normal text at WCAG level AA.
  static const double textAA = 4.5;

  /// Minimum contrast ratio for large text and for user interface
  /// components and graphics at WCAG level AA.
  static const double nonTextAA = 3;

  /// Minimum contrast ratio for normal text at WCAG level AAA.
  static const double textAAA = 7;

  static const _black = Color(0xFF000000);
  static const _white = Color(0xFFFFFFFF);

  /// Returns the WCAG contrast ratio between [a] and [b], from 1 (no
  /// contrast) to 21 (black on white). The alpha channel is ignored.
  static double ratio(Color a, Color b) {
    final la = a.withValues(alpha: 1).computeLuminance();
    final lb = b.withValues(alpha: 1).computeLuminance();
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Returns black or white, whichever has the higher contrast ratio
  /// against [background].
  static Color foregroundFor(Color background) {
    return ratio(_black, background) >= ratio(_white, background)
        ? _black
        : _white;
  }

  /// Returns the lowest contrast ratio between [color] and any of
  /// [backgrounds], or 21 when [backgrounds] is empty.
  static double minRatio(Color color, Iterable<Color> backgrounds) {
    var lowest = 21.0;
    for (final background in backgrounds) {
      final value = ratio(color, background);
      if (value < lowest) lowest = value;
    }
    return lowest;
  }

  /// Returns the color closest to [color] that reaches [target] contrast
  /// against every color in [backgrounds].
  ///
  /// Keeps hue and saturation and moves only the HSL lightness, searching
  /// in steps of 0.005 in both directions and returning the first
  /// lightness that satisfies [target]. Returns [color] unchanged when it
  /// already satisfies [target]. When no lightness satisfies it, returns
  /// black or white, whichever reaches the higher minimum ratio.
  static Color ensure(Color color, Iterable<Color> backgrounds, double target) {
    final list = backgrounds.toList(growable: false);
    if (minRatio(color, list) >= target) return color;
    final hsl = HSLColor.fromColor(color);
    for (var step = 1; step <= 200; step++) {
      for (final sign in const [-1, 1]) {
        final lightness = hsl.lightness + sign * step * 0.005;
        if (lightness < 0 || lightness > 1) continue;
        final candidate = hsl
            .withLightness(lightness)
            .toColor()
            .withValues(alpha: color.a);
        if (minRatio(candidate, list) >= target) return candidate;
      }
    }
    return minRatio(_black, list) >= minRatio(_white, list) ? _black : _white;
  }
}
