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

import 'color_theme.dart';

/// Material [ColorScheme]s of the oito2 schemes.
///
/// Shortcuts to [Oito2ColorTheme.colorScheme]; use [Oito2ColorTheme] when
/// the semantic, chrome or syntax colors are needed too.
abstract final class Oito2ColorScheme {
  /// The light oito2 base scheme with [accent] as the primary hue.
  static ColorScheme light({Color? accent, bool highContrast = false}) =>
      Oito2ColorTheme.light(
        accent: accent,
        highContrast: highContrast,
      ).colorScheme;

  /// The dark oito2 base scheme with [accent] as the primary hue.
  static ColorScheme dark({Color? accent, bool highContrast = false}) =>
      Oito2ColorTheme.dark(
        accent: accent,
        highContrast: highContrast,
      ).colorScheme;
}
