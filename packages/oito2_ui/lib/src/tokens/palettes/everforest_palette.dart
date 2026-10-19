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

/// The official Everforest palette, medium contrast variant.
///
/// The light variant has no separate `bg2` tone: it uses the same value as
/// [bgDim].
@immutable
class Oito2EverforestPalette {
  /// Creates an Everforest palette from explicit colors.
  const Oito2EverforestPalette({
    required this.bgDim,
    required this.bg0,
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.bg4,
    required this.fg,
    required this.red,
    required this.orange,
    required this.yellow,
    required this.green,
    required this.aqua,
    required this.blue,
    required this.purple,
    required this.grey0,
    required this.grey1,
    required this.grey2,
  });

  /// Everforest Dark, medium contrast.
  static const dark = Oito2EverforestPalette(
    bgDim: Color(0xFF232A2E),
    bg0: Color(0xFF2D353B),
    bg1: Color(0xFF343F44),
    bg2: Color(0xFF3D484D),
    bg3: Color(0xFF475258),
    bg4: Color(0xFF4F585E),
    fg: Color(0xFFD3C6AA),
    red: Color(0xFFE67E80),
    orange: Color(0xFFE69875),
    yellow: Color(0xFFDBBC7F),
    green: Color(0xFFA7C080),
    aqua: Color(0xFF83C092),
    blue: Color(0xFF7FBBB3),
    purple: Color(0xFFD699B6),
    grey0: Color(0xFF7A8478),
    grey1: Color(0xFF859289),
    grey2: Color(0xFF9DA9A0),
  );

  /// Everforest Light, medium contrast.
  static const light = Oito2EverforestPalette(
    bgDim: Color(0xFFEFEBD4),
    bg0: Color(0xFFFDF6E3),
    bg1: Color(0xFFF4F0D9),
    bg2: Color(0xFFEFEBD4),
    bg3: Color(0xFFE6E2CC),
    bg4: Color(0xFFE0DCC7),
    fg: Color(0xFF5C6A72),
    red: Color(0xFFF85552),
    orange: Color(0xFFF57D26),
    yellow: Color(0xFFDFA000),
    green: Color(0xFF8DA101),
    aqua: Color(0xFF35A77C),
    blue: Color(0xFF3A94C5),
    purple: Color(0xFFDF69BA),
    grey0: Color(0xFFA6B0A0),
    grey1: Color(0xFF939F91),
    grey2: Color(0xFF829181),
  );

  /// Dimmed background.
  final Color bgDim;

  /// Default background.
  final Color bg0;

  /// Background, level 1.
  final Color bg1;

  /// Background, level 2.
  final Color bg2;

  /// Background, level 3.
  final Color bg3;

  /// Background, level 4.
  final Color bg4;

  /// Foreground text.
  final Color fg;

  /// Red.
  final Color red;

  /// Orange.
  final Color orange;

  /// Yellow.
  final Color yellow;

  /// Green.
  final Color green;

  /// Aqua.
  final Color aqua;

  /// Blue.
  final Color blue;

  /// Purple.
  final Color purple;

  /// Grey, level 0.
  final Color grey0;

  /// Grey, level 1.
  final Color grey1;

  /// Grey, level 2.
  final Color grey2;
}
