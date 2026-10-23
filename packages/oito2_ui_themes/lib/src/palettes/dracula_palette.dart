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

/// The official Dracula palette and its light variant, Alucard.
@immutable
class Oito2DraculaPalette {
  /// Creates a Dracula-family palette from explicit colors.
  const Oito2DraculaPalette({
    required this.background,
    required this.currentLine,
    required this.foreground,
    required this.comment,
    required this.cyan,
    required this.green,
    required this.orange,
    required this.pink,
    required this.purple,
    required this.red,
    required this.yellow,
  });

  /// Dracula, the dark variant.
  static const dracula = Oito2DraculaPalette(
    background: Color(0xFF282A36),
    currentLine: Color(0xFF44475A),
    foreground: Color(0xFFF8F8F2),
    comment: Color(0xFF6272A4),
    cyan: Color(0xFF8BE9FD),
    green: Color(0xFF50FA7B),
    orange: Color(0xFFFFB86C),
    pink: Color(0xFFFF79C6),
    purple: Color(0xFFBD93F9),
    red: Color(0xFFFF5555),
    yellow: Color(0xFFF1FA8C),
  );

  /// Alucard, the light variant.
  static const alucard = Oito2DraculaPalette(
    background: Color(0xFFFFFBEB),
    currentLine: Color(0xFF6C664B),
    foreground: Color(0xFF1F1F1F),
    comment: Color(0xFF6C664B),
    cyan: Color(0xFF036A96),
    green: Color(0xFF14710A),
    orange: Color(0xFFA34D14),
    pink: Color(0xFFA3144D),
    purple: Color(0xFF644AC9),
    red: Color(0xFFCB3A2A),
    yellow: Color(0xFF846E15),
  );

  /// Background.
  final Color background;

  /// Current line highlight.
  final Color currentLine;

  /// Foreground text.
  final Color foreground;

  /// Comments.
  final Color comment;

  /// Cyan.
  final Color cyan;

  /// Green.
  final Color green;

  /// Orange.
  final Color orange;

  /// Pink.
  final Color pink;

  /// Purple.
  final Color purple;

  /// Red.
  final Color red;

  /// Yellow.
  final Color yellow;
}
