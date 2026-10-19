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
///
/// A theme carries it through the `Oito2SyntaxTheme` extension.
@immutable
class Oito2SyntaxPalette {
  /// Creates a syntax palette from explicit colors.
  const Oito2SyntaxPalette({
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
  Oito2SyntaxPalette ensureContrast(
    Iterable<Color> backgrounds, {
    double target = Oito2Contrast.textAA,
  }) {
    final list = backgrounds.toList(growable: false);
    Color fix(Color color) => Oito2Contrast.ensure(color, list, target);
    return Oito2SyntaxPalette(
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

  /// Returns a copy with the given roles replaced.
  Oito2SyntaxPalette copyWith({
    Color? foreground,
    Color? comment,
    Color? keyword,
    Color? string,
    Color? number,
    Color? function,
    Color? type,
    Color? tag,
    Color? attribute,
    Color? constant,
    Color? invalid,
  }) {
    return Oito2SyntaxPalette(
      foreground: foreground ?? this.foreground,
      comment: comment ?? this.comment,
      keyword: keyword ?? this.keyword,
      string: string ?? this.string,
      number: number ?? this.number,
      function: function ?? this.function,
      type: type ?? this.type,
      tag: tag ?? this.tag,
      attribute: attribute ?? this.attribute,
      constant: constant ?? this.constant,
      invalid: invalid ?? this.invalid,
    );
  }

  /// Linearly interpolates every role between this palette and [other].
  Oito2SyntaxPalette lerp(Oito2SyntaxPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return Oito2SyntaxPalette(
      foreground: mix(foreground, other.foreground),
      comment: mix(comment, other.comment),
      keyword: mix(keyword, other.keyword),
      string: mix(string, other.string),
      number: mix(number, other.number),
      function: mix(function, other.function),
      type: mix(type, other.type),
      tag: mix(tag, other.tag),
      attribute: mix(attribute, other.attribute),
      constant: mix(constant, other.constant),
      invalid: mix(invalid, other.invalid),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2SyntaxPalette &&
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
