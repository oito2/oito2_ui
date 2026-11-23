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

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';
import 'package:re_highlight/re_highlight.dart';

/// Collects the runs of a highlight result as (text, scope) pairs, with the
/// scope of the innermost token node holding each run.
class _Runs implements HighlightRenderer {
  final List<(String, String?)> runs = [];
  final List<DataNode> _stack = [];

  @override
  void addText(String text) =>
      runs.add((text, _stack.isEmpty ? null : _stack.last.scope));

  @override
  void openNode(DataNode node) => _stack.add(node);

  @override
  void closeNode(DataNode node) => _stack.removeLast();
}

List<(String, String?)> _tokens(String code, [String language = 'gitignore']) {
  final highlight = Highlight()..registerLanguages(oito2DefaultLanguages);
  final runs = _Runs();
  highlight.highlight(code: code, language: language).render(runs);
  return [
    for (final run in runs.runs)
      if (run.$2 != null) run,
  ];
}

void main() {
  test('is a default language with its aliases', () {
    expect(oito2DefaultLanguages['gitignore'], same(langGitignore));
    final highlighter = Oito2Highlighter();
    expect(highlighter.supports('gitignore'), isTrue);
    expect(highlighter.supports('ignore'), isTrue);
    expect(highlighter.supports('dockerignore'), isTrue);
    expect(highlighter.supports('GitIgnore'), isTrue);
  });

  test('comments only at the start of a line', () {
    expect(_tokens('# build output\nfoo#bar\n'), [
      ('# build output', 'comment'),
    ]);
  });

  test('negation, anchors and directory slashes', () {
    expect(_tokens('!/keep/me/\n'), [
      ('!', 'keyword'),
      ('/', 'keyword'),
      ('/', 'keyword'),
    ]);
    expect(_tokens('a/b\n'), isEmpty);
  });

  test('wildcards', () {
    expect(_tokens('**/logs/*.log?\n'), [
      ('**', 'meta'),
      ('*', 'meta'),
      ('?', 'meta'),
    ]);
  });

  test('character classes, with escapes inside', () {
    expect(_tokens('file[0-9].txt\n'), [('[0-9]', 'regexp')]);
    expect(
      _tokens(
        r'[!\]a]'
        '\n',
      ),
      [('[!', 'regexp'), (r'\]', 'symbol'), ('a]', 'regexp')],
    );
    // An unclosed bracket is plain text.
    expect(_tokens('a[b\n'), isEmpty);
  });

  test('escapes', () {
    expect(
      _tokens(
        r'\#not-comment'
        '\n'
        r'\!not-negated'
        '\n'
        r'a\ '
        '\n',
      ),
      [(r'\#', 'symbol'), (r'\!', 'symbol'), (r'\ ', 'symbol')],
    );
    expect(
      _tokens(
        r'\*'
        '\n',
      ),
      [(r'\*', 'symbol')],
    );
  });

  test('trailing spaces', () {
    expect(_tokens('build  \n'), [('  ', 'deletion')]);
  });

  test('colors through the palette roles', () {
    for (final scope in ['comment', 'keyword', 'meta', 'regexp', 'symbol']) {
      expect(Oito2HighlighterTheme.scopeRoles, contains(scope), reason: scope);
    }
  });
}
