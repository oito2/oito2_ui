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

import '../../syntax/syntax_palette.dart';
import '../color_theme.dart';

/// Carries the [Oito2SyntaxPalette] that matches a theme's colors.
@immutable
class Oito2SyntaxTheme extends ThemeExtension<Oito2SyntaxTheme> {
  /// Creates a syntax theme extension for [palette].
  const Oito2SyntaxTheme(this.palette);

  /// Returns the syntax palette of the closest [Theme], or null when the
  /// theme has none.
  static Oito2SyntaxPalette? maybeOf(BuildContext context) =>
      Theme.of(context).extension<Oito2SyntaxTheme>()?.palette;

  /// Returns the syntax palette of the closest [Theme], or the oito2 base
  /// scheme's palette of the theme's brightness when it has none.
  static Oito2SyntaxPalette of(BuildContext context) =>
      maybeOf(context) ??
      (Theme.of(context).brightness == Brightness.dark
              ? Oito2ColorTheme.dark()
              : Oito2ColorTheme.light())
          .syntax;

  /// The syntax colors.
  final Oito2SyntaxPalette palette;

  @override
  Oito2SyntaxTheme copyWith({Oito2SyntaxPalette? palette}) =>
      Oito2SyntaxTheme(palette ?? this.palette);

  @override
  Oito2SyntaxTheme lerp(Oito2SyntaxTheme? other, double t) {
    if (other == null) return this;
    return Oito2SyntaxTheme(palette.lerp(other.palette, t));
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2SyntaxTheme && other.palette == palette;

  @override
  int get hashCode => palette.hashCode;
}
