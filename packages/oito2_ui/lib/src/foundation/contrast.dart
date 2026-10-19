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

  /// Returns the WCAG contrast ratio between [a] and [b], from 1 (no
  /// contrast) to 21 (black on white). The alpha channel is ignored.
  static double ratio(Color a, Color b) {
    final la = a.withValues(alpha: 1).computeLuminance();
    final lb = b.withValues(alpha: 1).computeLuminance();
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Returns black for backgrounds with a luminance above 0.5 and white
  /// otherwise.
  static Color foregroundFor(Color background) {
    return background.computeLuminance() > 0.5
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
  }
}
