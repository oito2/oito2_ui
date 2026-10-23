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

import '../syntax/syntax_palette.dart';

/// The handful of role colors a color theme family defines, from which
/// [Oito2ColorTheme.fromRoles] derives a complete oito2 scheme.
///
/// The roles follow the vocabulary most theme families publish: a page
/// [background], a [card] surface, a [secondary] surface, a [border], the
/// text colors and the accents. Values are taken as given; contrast
/// adjustments happen in [Oito2ColorTheme.fromRoles].
@immutable
class Oito2ColorRoles {
  /// Creates the role colors of a scheme.
  const Oito2ColorRoles({
    required this.brightness,
    required this.background,
    required this.card,
    required this.foreground,
    required this.primary,
    required this.secondary,
    required this.mutedForeground,
    required this.destructive,
    required this.border,
    required this.success,
    required this.warning,
    required this.info,
    required this.syntax,
  });

  /// Whether the scheme is light or dark.
  final Brightness brightness;

  /// The page background.
  final Color background;

  /// The main surface of cards, panes and fields.
  final Color card;

  /// The body text color.
  final Color foreground;

  /// The signature accent, used as the primary fill.
  final Color primary;

  /// A surface one step above [card], such as a selected row.
  final Color secondary;

  /// Secondary text, such as captions and placeholders.
  final Color mutedForeground;

  /// The color of errors and destructive actions.
  final Color destructive;

  /// Borders and dividers.
  final Color border;

  /// The color of success states.
  final Color success;

  /// The color of warning states.
  final Color warning;

  /// The color of informational states.
  final Color info;

  /// The syntax highlighting colors.
  final Oito2SyntaxPalette syntax;

  @override
  bool operator ==(Object other) =>
      other is Oito2ColorRoles &&
      other.brightness == brightness &&
      other.background == background &&
      other.card == card &&
      other.foreground == foreground &&
      other.primary == primary &&
      other.secondary == secondary &&
      other.mutedForeground == mutedForeground &&
      other.destructive == destructive &&
      other.border == border &&
      other.success == success &&
      other.warning == warning &&
      other.info == info &&
      other.syntax == syntax;

  @override
  int get hashCode => Object.hash(
    brightness,
    background,
    card,
    foreground,
    primary,
    secondary,
    mutedForeground,
    destructive,
    border,
    success,
    warning,
    info,
    syntax,
  );
}
