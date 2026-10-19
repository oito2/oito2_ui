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
import 'package:oito2_ui/oito2_ui.dart';

/// A token role of a [SyntaxHighlightPalette].
enum Oito2SyntaxRole {
  /// Plain code text.
  foreground,

  /// Comments.
  comment,

  /// Keywords and control flow.
  keyword,

  /// String literals.
  string,

  /// Numeric literals.
  number,

  /// Function and method names.
  function,

  /// Type and class names.
  type,

  /// Markup tags.
  tag,

  /// Markup attributes, annotations and properties.
  attribute,

  /// Constants, booleans and enum values.
  constant,

  /// Invalid code and removed lines.
  invalid;

  /// The color of this role in [palette].
  Color colorIn(SyntaxHighlightPalette palette) => switch (this) {
    foreground => palette.foreground,
    comment => palette.comment,
    keyword => palette.keyword,
    string => palette.string,
    number => palette.number,
    function => palette.function,
    type => palette.type,
    tag => palette.tag,
    attribute => palette.attribute,
    constant => palette.constant,
    invalid => palette.invalid,
  };
}

/// Builds `re_highlight` themes from a [SyntaxHighlightPalette].
///
/// The highlighter tokenizes code with highlight.js grammars, whose token
/// scopes (such as `keyword`, `title.function` or `selector-tag`) are
/// mapped here to the 11 palette roles. Scopes not listed render in the
/// foreground color.
abstract final class Oito2HighlighterTheme {
  /// The palette role of every highlight.js scope the theme colors.
  static const Map<String, Oito2SyntaxRole> scopeRoles = {
    'comment': Oito2SyntaxRole.comment,
    'quote': Oito2SyntaxRole.comment,
    'keyword': Oito2SyntaxRole.keyword,
    'doctag': Oito2SyntaxRole.keyword,
    'template-tag': Oito2SyntaxRole.keyword,
    'bullet': Oito2SyntaxRole.keyword,
    'string': Oito2SyntaxRole.string,
    'regexp': Oito2SyntaxRole.string,
    'regex': Oito2SyntaxRole.string,
    'character': Oito2SyntaxRole.string,
    'code': Oito2SyntaxRole.string,
    'addition': Oito2SyntaxRole.string,
    'number': Oito2SyntaxRole.number,
    'title': Oito2SyntaxRole.function,
    'title.function': Oito2SyntaxRole.function,
    'title.function.invoke': Oito2SyntaxRole.function,
    'function': Oito2SyntaxRole.function,
    'function.dispatch': Oito2SyntaxRole.function,
    'type': Oito2SyntaxRole.type,
    'built_in': Oito2SyntaxRole.type,
    'title.class': Oito2SyntaxRole.type,
    'title.class.inherited': Oito2SyntaxRole.type,
    'tag': Oito2SyntaxRole.tag,
    'name': Oito2SyntaxRole.tag,
    'selector-tag': Oito2SyntaxRole.tag,
    'section': Oito2SyntaxRole.tag,
    'attr': Oito2SyntaxRole.attribute,
    'attribute': Oito2SyntaxRole.attribute,
    'property': Oito2SyntaxRole.attribute,
    'meta': Oito2SyntaxRole.attribute,
    'selector-attr': Oito2SyntaxRole.attribute,
    'selector-class': Oito2SyntaxRole.attribute,
    'selector-id': Oito2SyntaxRole.attribute,
    'selector-pseudo': Oito2SyntaxRole.attribute,
    'template-variable': Oito2SyntaxRole.attribute,
    'variable': Oito2SyntaxRole.attribute,
    'literal': Oito2SyntaxRole.constant,
    'symbol': Oito2SyntaxRole.constant,
    'char.escape': Oito2SyntaxRole.constant,
    'variable.constant': Oito2SyntaxRole.constant,
    'variable.language': Oito2SyntaxRole.constant,
    'link': Oito2SyntaxRole.constant,
    'label': Oito2SyntaxRole.constant,
    'deletion': Oito2SyntaxRole.invalid,
    'delete': Oito2SyntaxRole.invalid,
  };

  /// Returns the scope styles for [palette]: every scope of [scopeRoles]
  /// in its role color, comments in italics, plus italic `emphasis` and
  /// bold `strong` for markup.
  static Map<String, TextStyle> fromPalette(SyntaxHighlightPalette palette) {
    return {
      for (final MapEntry(key: scope, value: role) in scopeRoles.entries)
        scope: TextStyle(
          color: role.colorIn(palette),
          fontStyle: role == Oito2SyntaxRole.comment ? FontStyle.italic : null,
        ),
      'emphasis': const TextStyle(fontStyle: FontStyle.italic),
      'strong': const TextStyle(fontWeight: FontWeight.w700),
    };
  }
}
