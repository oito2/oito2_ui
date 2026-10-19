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

import '../foundation/contrast.dart';

/// Colors for the token roles of a syntax-highlighted code block.
@immutable
class SyntaxHighlightPalette {
  /// Creates a syntax palette from explicit colors.
  const SyntaxHighlightPalette({
    required this.foreground,
    required this.comment,
    required this.keyword,
    required this.string,
    required this.number,
    required this.function,
    required this.type,
    required this.tag,
    required this.attribute,
    required this.constant,
    required this.invalid,
  });

  /// Plain code text.
  final Color foreground;

  /// Comments.
  final Color comment;

  /// Keywords and control flow.
  final Color keyword;

  /// String literals.
  final Color string;

  /// Numeric literals.
  final Color number;

  /// Function and method names.
  final Color function;

  /// Type and class names.
  final Color type;

  /// Markup tags.
  final Color tag;

  /// Markup attributes and object properties.
  final Color attribute;

  /// Constants, booleans and enum values.
  final Color constant;

  /// Invalid or erroneous code.
  final Color invalid;

  /// All roles, in declaration order.
  List<Color> get colors => [
    foreground,
    comment,
    keyword,
    string,
    number,
    function,
    type,
    tag,
    attribute,
    constant,
    invalid,
  ];

  /// Returns a copy where every role reaches [target] contrast against
  /// every color in [backgrounds], adjusting only the lightness of the
  /// roles that don't.
  SyntaxHighlightPalette ensureContrast(
    Iterable<Color> backgrounds, {
    double target = Oito2Contrast.textAA,
  }) {
    final list = backgrounds.toList(growable: false);
    Color fix(Color color) => Oito2Contrast.ensure(color, list, target);
    return SyntaxHighlightPalette(
      foreground: fix(foreground),
      comment: fix(comment),
      keyword: fix(keyword),
      string: fix(string),
      number: fix(number),
      function: fix(function),
      type: fix(type),
      tag: fix(tag),
      attribute: fix(attribute),
      constant: fix(constant),
      invalid: fix(invalid),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SyntaxHighlightPalette &&
      other.foreground == foreground &&
      other.comment == comment &&
      other.keyword == keyword &&
      other.string == string &&
      other.number == number &&
      other.function == function &&
      other.type == type &&
      other.tag == tag &&
      other.attribute == attribute &&
      other.constant == constant &&
      other.invalid == invalid;

  @override
  int get hashCode => Object.hashAll(colors);
}
