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

/// The official Rosé Pine palette: main and Moon (dark) and Dawn (light).
@immutable
class Oito2RosePinePalette {
  /// Creates a Rosé Pine palette from explicit colors.
  const Oito2RosePinePalette({
    required this.base,
    required this.surface,
    required this.overlay,
    required this.muted,
    required this.subtle,
    required this.text,
    required this.love,
    required this.gold,
    required this.rose,
    required this.pine,
    required this.foam,
    required this.iris,
  });

  /// Rosé Pine, the main dark variant.
  static const main = Oito2RosePinePalette(
    base: Color(0xFF191724),
    surface: Color(0xFF1F1D2E),
    overlay: Color(0xFF26233A),
    muted: Color(0xFF6E6A86),
    subtle: Color(0xFF908CAA),
    text: Color(0xFFE0DEF4),
    love: Color(0xFFEB6F92),
    gold: Color(0xFFF6C177),
    rose: Color(0xFFEBBCBA),
    pine: Color(0xFF31748F),
    foam: Color(0xFF9CCFD8),
    iris: Color(0xFFC4A7E7),
  );

  /// Rosé Pine Moon, the second dark variant.
  static const moon = Oito2RosePinePalette(
    base: Color(0xFF232136),
    surface: Color(0xFF2A273F),
    overlay: Color(0xFF393552),
    muted: Color(0xFF6E6A86),
    subtle: Color(0xFF908CAA),
    text: Color(0xFFE0DEF4),
    love: Color(0xFFEB6F92),
    gold: Color(0xFFF6C177),
    rose: Color(0xFFEA9A97),
    pine: Color(0xFF3E8FB0),
    foam: Color(0xFF9CCFD8),
    iris: Color(0xFFC4A7E7),
  );

  /// Rosé Pine Dawn, the light variant.
  static const dawn = Oito2RosePinePalette(
    base: Color(0xFFFAF4ED),
    surface: Color(0xFFFFFAF3),
    overlay: Color(0xFFF2E9E1),
    muted: Color(0xFF9893A5),
    subtle: Color(0xFF797593),
    text: Color(0xFF464261),
    love: Color(0xFFB4637A),
    gold: Color(0xFFEA9D34),
    rose: Color(0xFFD7827E),
    pine: Color(0xFF286983),
    foam: Color(0xFF56949F),
    iris: Color(0xFF907AA9),
  );

  /// Base background.
  final Color base;

  /// Raised surface.
  final Color surface;

  /// Overlay surface.
  final Color overlay;

  /// Muted text.
  final Color muted;

  /// Subtle text.
  final Color subtle;

  /// Primary text.
  final Color text;

  /// Love (red).
  final Color love;

  /// Gold (yellow).
  final Color gold;

  /// Rose (pink).
  final Color rose;

  /// Pine (deep blue-green).
  final Color pine;

  /// Foam (cyan).
  final Color foam;

  /// Iris (purple).
  final Color iris;
}
