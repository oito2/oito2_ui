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

/// The official Nord palette.
///
/// Polar Night ([nord0] to [nord3]), Snow Storm ([nord4] to [nord6]), Frost
/// ([nord7] to [nord10]) and Aurora ([nord11] to [nord15]).
abstract final class Oito2NordPalette {
  /// Polar Night, darkest: #2E3440.
  static const Color nord0 = Color(0xFF2E3440);

  /// Polar Night: #3B4252.
  static const Color nord1 = Color(0xFF3B4252);

  /// Polar Night: #434C5E.
  static const Color nord2 = Color(0xFF434C5E);

  /// Polar Night, lightest: #4C566A.
  static const Color nord3 = Color(0xFF4C566A);

  /// Snow Storm, darkest: #D8DEE9.
  static const Color nord4 = Color(0xFFD8DEE9);

  /// Snow Storm: #E5E9F0.
  static const Color nord5 = Color(0xFFE5E9F0);

  /// Snow Storm, lightest: #ECEFF4.
  static const Color nord6 = Color(0xFFECEFF4);

  /// Frost, frozen polar water: #8FBCBB.
  static const Color nord7 = Color(0xFF8FBCBB);

  /// Frost, pure and clear ice: #88C0D0.
  static const Color nord8 = Color(0xFF88C0D0);

  /// Frost, arctic waters: #81A1C1.
  static const Color nord9 = Color(0xFF81A1C1);

  /// Frost, deep arctic ocean: #5E81AC.
  static const Color nord10 = Color(0xFF5E81AC);

  /// Aurora red: #BF616A.
  static const Color nord11 = Color(0xFFBF616A);

  /// Aurora orange: #D08770.
  static const Color nord12 = Color(0xFFD08770);

  /// Aurora yellow: #EBCB8B.
  static const Color nord13 = Color(0xFFEBCB8B);

  /// Aurora green: #A3BE8C.
  static const Color nord14 = Color(0xFFA3BE8C);

  /// Aurora purple: #B48EAD.
  static const Color nord15 = Color(0xFFB48EAD);
}
