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

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';
import 'package:re_highlight/languages/lua.dart';

/// Collects every (text, color) pair of a span tree, resolving inherited
/// colors.
List<(String, Color?)> _runs(InlineSpan span, [Color? inherited]) {
  final runs = <(String, Color?)>[];
  void visit(InlineSpan node, Color? color) {
    if (node is! TextSpan) return;
    final own = node.style?.color ?? color;
    if (node.text != null) runs.add((node.text!, own));
    for (final child in node.children ?? const <InlineSpan>[]) {
      visit(child, own);
    }
  }

  visit(span, inherited);
  return runs;
}

/// Returns the resolved color, font style and weight of every code unit of
/// a span tree.
List<(Color?, FontStyle?, FontWeight?)> _unitStyles(InlineSpan span) {
  final units = <(Color?, FontStyle?, FontWeight?)>[];
  void visit(InlineSpan node, TextStyle inherited) {
    if (node is! TextSpan) return;
    final style = inherited.merge(node.style);
    final text = node.text;
    if (text != null) {
      for (var i = 0; i < text.length; i++) {
        units.add((style.color, style.fontStyle, style.fontWeight));
      }
    }
    for (final child in node.children ?? const <InlineSpan>[]) {
      visit(child, style);
    }
  }

  visit(span, const TextStyle());
  return units;
}

Color? _colorOf(List<(String, Color?)> runs, String text) =>
    runs.firstWhere((r) => r.$1.contains(text)).$2;

const _dart = '''
// A comment
@override
class Greeter extends Base {
  final int count = 42;
  String greet(String name) => 'Hello, \$name';
  bool get ready => true;
}
''';

void main() {
  final palette = Oito2ColorTheme.light().syntax;
  final highlighter = Oito2Highlighter();

  group('Oito2HighlighterTheme', () {
    test('maps every scope to its role color', () {
      final theme = Oito2HighlighterTheme.fromPalette(palette);
      Oito2HighlighterTheme.scopeRoles.forEach((scope, role) {
        expect(theme[scope]!.color, role.colorIn(palette), reason: scope);
      });
      expect(theme['comment']!.fontStyle, FontStyle.italic);
      expect(theme['emphasis']!.fontStyle, FontStyle.italic);
      expect(theme['strong']!.fontWeight, FontWeight.w700);
    });

    test('every role is used by some scope except plain text', () {
      final used = Oito2HighlighterTheme.scopeRoles.values.toSet();
      expect(
        used,
        Oito2SyntaxRole.values.toSet()..remove(Oito2SyntaxRole.foreground),
      );
    });

    test('roles read their palette color', () {
      for (final role in Oito2SyntaxRole.values) {
        expect(
          palette.colors,
          contains(role.colorIn(palette)),
          reason: role.name,
        );
      }
    });
  });

  group('Oito2Highlighter', () {
    test('colors Dart tokens with the palette roles', () {
      final runs = _runs(
        highlighter.highlight(_dart, language: 'dart', palette: palette),
      );
      expect(_colorOf(runs, 'A comment'), palette.comment);
      expect(_colorOf(runs, 'class'), palette.keyword);
      expect(_colorOf(runs, 'Greeter'), palette.function);
      expect(_colorOf(runs, '42'), palette.number);
      expect(_colorOf(runs, 'Hello'), palette.string);
      // The Dart grammar lists true, false and null as keywords.
      expect(_colorOf(runs, 'true'), palette.keyword);
      expect(_colorOf(runs, '@override'), palette.attribute);
    });

    test('colors literals as constants', () {
      final runs = _runs(
        highlighter.highlight(
          'ready = True\ncount = 3',
          language: 'python',
          palette: palette,
        ),
      );
      expect(_colorOf(runs, 'True'), palette.constant);
      expect(_colorOf(runs, '3'), palette.number);
    });

    test('keeps the code text intact', () {
      final span = highlighter.highlight(
        _dart,
        language: 'dart',
        palette: palette,
      );
      expect(span.toPlainText(), _dart);
    });

    test('only uses palette colors, so every token reaches AA', () {
      for (final theme in [
        Oito2ColorTheme.light(),
        Oito2ColorTheme.dark(),
        Oito2ColorTheme.light(highContrast: true),
        Oito2ColorTheme.dark(highContrast: true),
      ]) {
        for (final language in oito2DefaultLanguages.keys) {
          final runs = _runs(
            highlighter.highlight(
              _dart,
              language: language,
              palette: theme.syntax,
            ),
          );
          for (final (_, color) in runs) {
            expect(theme.syntax.colors, contains(color), reason: language);
            expect(
              Oito2Contrast.minRatio(color!, theme.surfaces),
              greaterThanOrEqualTo(Oito2Contrast.textAA),
            );
          }
        }
      }
    });

    test('accepts language aliases in any letter case', () {
      for (final name in ['Dart', 'js', 'ts', 'sh', 'yml', 'py', 'rs']) {
        expect(highlighter.supports(name), isTrue, reason: name);
        final span = highlighter.highlight(
          'x = 1',
          language: name,
          palette: palette,
        );
        expect(span.children, isNotNull, reason: name);
      }
      expect(highlighter.supports('cobol'), isFalse);
    });

    test('returns plain text for unknown languages', () {
      final span = highlighter.highlight(
        'x = 1',
        language: 'cobol',
        palette: palette,
      );
      expect(span.children, isNull);
      expect(span.style!.color, palette.foreground);
      expect(span.toPlainText(), 'x = 1');
    });

    test('guesses the language when asked to', () {
      final plain = highlighter.highlight(_dart, palette: palette);
      expect(plain.children, isNull);
      final guessed = highlighter.highlight(
        _dart,
        palette: palette,
        autoDetect: true,
      );
      expect(guessed.children, isNotEmpty);
    });

    test('accepts extra languages', () {
      final custom = Oito2Highlighter(
        languages: {...oito2DefaultLanguages, 'lua': langLua},
      );
      expect(custom.languages, contains('lua'));
      final runs = _runs(
        custom.highlight('local x = "hi"', language: 'lua', palette: palette),
      );
      expect(_colorOf(runs, 'local'), palette.keyword);
      expect(_colorOf(runs, 'hi'), palette.string);
    });

    test('keeps the base style and applies the foreground', () {
      final span = highlighter.highlight(
        'int x;',
        language: 'dart',
        palette: palette,
        style: const TextStyle(fontSize: 20, color: Color(0xFFFF0000)),
      );
      expect(span.style!.fontSize, 20);
      expect(span.style!.color, palette.foreground);
    });
  });

  group('Oito2HighlightTokens', () {
    const markdown = '# Title\n\nSome *emphasis* and **strong** text.\n';
    const html = '<style>p { color: red; }</style><p class="a">Hi</p>';

    test('draw the same as highlight', () {
      for (final (code, language) in [
        (_dart, 'dart'),
        (markdown, 'markdown'),
        (html, 'html'),
        ('', 'dart'),
      ]) {
        final tokens = highlighter.tokenize(code, language: language)!;
        expect(tokens.code, code);
        final span = tokens.toSpan(palette: palette);
        expect(span.toPlainText(), code, reason: language);
        expect(
          _unitStyles(span),
          _unitStyles(
            highlighter.highlight(code, language: language, palette: palette),
          ),
          reason: language,
        );
      }
    });

    test('list runs with their scopes and join equal neighbors', () {
      final tokens = highlighter.tokenize('final x = 1;', language: 'dart')!;
      final runs = [
        for (var i = 0; i < tokens.length; i++)
          (tokens.textAt(i), tokens.scopeAt(i)),
      ];
      expect(runs.map((r) => r.$1).join(), 'final x = 1;');
      expect(runs, contains(('final', 'keyword')));
      expect(runs, contains(('1', 'number')));
      for (var i = 1; i < runs.length; i++) {
        expect(runs[i].$2, isNot(runs[i - 1].$2));
      }
    });

    test('color the same tokens with any palette', () {
      final tokens = highlighter.tokenize(_dart, language: 'dart')!;
      final dark = Oito2ColorTheme.dark().syntax;
      final runs = _runs(tokens.toSpan(palette: dark));
      expect(_colorOf(runs, 'class'), dark.keyword);
      expect(
        _runs(tokens.toSpan(palette: palette))
            .firstWhere((r) => r.$1.contains('class'))
            .$2,
        palette.keyword,
      );
    });

    test('keep the style and replace its color', () {
      final tokens = highlighter.tokenize('x', language: 'dart')!;
      final span = tokens.toSpan(
        palette: palette,
        style: const TextStyle(fontSize: 20, color: Color(0xFF123456)),
      );
      expect(span.style!.fontSize, 20);
      expect(span.style!.color, palette.foreground);
    });

    test('are null for an unregistered or missing language', () {
      expect(highlighter.tokenize('x', language: 'cobol'), isNull);
      expect(highlighter.tokenize('x'), isNull);
      expect(highlighter.tokenize('{"a": 1}', autoDetect: true), isNotNull);
      expect(highlighter.tokenize('x', language: 'DART'), isNotNull);
    });

    test('tokenize in another isolate', () async {
      final tokens = await compute(
        (String code) => highlighter.tokenize(code, language: 'dart'),
        _dart,
      );
      expect(
        _unitStyles(tokens!.toSpan(palette: palette)),
        _unitStyles(
          highlighter.highlight(_dart, language: 'dart', palette: palette),
        ),
      );
    });
  });
}
