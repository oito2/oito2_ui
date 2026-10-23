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
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';

import '../docs/doc_widgets.dart';

const _samples = {
  'dart': r'''
import 'package:flutter/widgets.dart';

/// A counter that never goes below zero.
class Counter extends ValueNotifier<int> {
  Counter([super.value = 0]);

  void decrement() {
    if (value > 0) value--;
  }

  @override
  String toString() => 'Counter($value)';
}''',
  'python': r'''
from dataclasses import dataclass

@dataclass
class Point:
    x: float = 0.0
    y: float = 0.0

    def distance(self, other: "Point") -> float:
        return ((self.x - other.x) ** 2 + (self.y - other.y) ** 2) ** 0.5

print(Point(3, 4).distance(Point()))  # 5.0''',
  'yaml': r'''
name: oito2_ui_example
environment:
  sdk: ^3.13.0
dependencies:
  oito2_ui: ^0.1.0   # the design system
  enabled: true
  retries: 3''',
  'bash': r'''
#!/usr/bin/env bash
set -euo pipefail
for file in "$HOME"/Pictures/*.png; do
  echo "Optimizing ${file##*/}"
  optipng -quiet "$file" || exit 1
done''',
  'html': '''
<!doctype html>
<html lang="en">
  <body class="page">
    <a href="https://oito2.github.io/oito2_ui/">Showcase</a>
  </body>
</html>''',
  'sql': '''
SELECT name, COUNT(*) AS total
FROM downloads
WHERE created_at >= '2026-01-01'
GROUP BY name
ORDER BY total DESC
LIMIT 10;''',
  'diff': '''
@@ -1,3 +1,3 @@
 dependencies:
-  syntax_highlight: ^0.5.0
+  re_highlight: ^0.0.3''',
};

/// Documents [Oito2CodeBlock] and [Oito2Highlighter]: highlighting several
/// languages with the active scheme's syntax palette.
class CodeBlockPage extends StatefulWidget {
  /// Creates the code block page.
  const CodeBlockPage({super.key});

  @override
  State<CodeBlockPage> createState() => _CodeBlockPageState();
}

class _CodeBlockPageState extends State<CodeBlockPage> {
  String _language = 'dart';
  bool _lineNumbers = true;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Code Block',
      description:
          'Shows source code highlighted with the syntax colors of the '
          'active scheme, with optional line numbers and a copy button.',
      source: 'lib/src/pages/code_block_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 420,
            // #region preview
            child: Oito2CodeBlock(
              code: "void main() => print('Hello, oito2!');",
              language: 'dart',
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2CodeBlock` the `code` and its `language`, a registered '
          'name or alias such as `dart` or `yml`, in any letter case. A '
          'null or unregistered language shows plain text. The block '
          'scrolls sideways when a line is too long, and its text can be '
          'selected.',
        ),
        const DocCode("import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';"),
        const DocText(
          'The colors come from `Oito2SyntaxTheme.of(context)`, the '
          'syntax palette of the theme, which follows the color scheme. '
          'The code uses the bundled JetBrains Mono font, and its license '
          'is listed in the app\'s license page.',
        ),
        const DocNote(
          'Tokenizing runs synchronously in pure Dart through '
          '`re_highlight`, with no native code and no asset loading. The '
          'block highlights again only when the code, language, palette, '
          'style or highlighter changes.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Languages and line numbers', level: 3),
        DocText(
          '${Oito2Highlighter.instance.languages.length} languages are '
          'registered by default, listed in `oito2DefaultLanguages`. '
          '`showLineNumbers` adds a column of line numbers in the comment '
          'color.',
        ),
        ExamplePanel(
          region: 'languages',
          child: SizedBox(
            width: 640,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.md,
              children: [
                Oito2ChoiceChipBar(
                  style: Oito2ChoiceChipBarStyle.wrap,
                  labels: [for (final name in _samples.keys) Text(name)],
                  isSelected: [
                    for (final name in _samples.keys) name == _language,
                  ],
                  onSelected: (i) =>
                      setState(() => _language = _samples.keys.elementAt(i)),
                ),
                Oito2SwitchButton(
                  value: _lineNumbers,
                  onChanged: (v) => setState(() => _lineNumbers = v),
                  title: const Text('Line numbers'),
                ),
                // #region languages
                Oito2CodeBlock(
                  code: _samples[_language]!.trim(),
                  language: _language,
                  showLineNumbers: _lineNumbers,
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Plain text, without the copy button', level: 3),
        const DocText(
          'Without a `language` the code keeps the foreground color. '
          '`showCopyButton: false` removes the copy button from the top '
          'end corner, for text that isn\'t meant to be copied.',
        ),
        const ExamplePanel(
          region: 'plain',
          child: SizedBox(
            width: 420,
            // #region plain
            child: Oito2CodeBlock(
              code: 'Build finished in 12.4s\n3 warnings, 0 errors',
              showCopyButton: false,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Text style and padding', level: 3),
        const DocText(
          '`textStyle` is merged over `Oito2CodeBlock.defaultTextStyle`, '
          '13-point JetBrains Mono with a 1.45 line height; the palette '
          'still sets the colors. `padding` is the space around the code.',
        ),
        const ExamplePanel(
          region: 'style',
          child: SizedBox(
            width: 420,
            // #region style
            child: Oito2CodeBlock(
              code: '{"name": "oito2_ui", "private": true}',
              language: 'json',
              textStyle: TextStyle(fontSize: 16),
              padding: EdgeInsets.all(Oito2Spacing.sm),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Highlighting without the block', level: 3),
        const DocText(
          '`Oito2Highlighter.highlight` returns the colored `TextSpan`, for '
          'code inside your own widgets. With `autoDetect`, a null '
          '`language` is guessed among the registered ones.',
        ),
        ExamplePanel(
          region: 'highlighter',
          // #region highlighter
          child: Text.rich(
            Oito2Highlighter.instance.highlight(
              'SELECT * FROM users WHERE id = 42;',
              language: 'sql',
              palette: Oito2SyntaxTheme.of(context),
              style: Oito2CodeBlock.defaultTextStyle,
            ),
          ),
          // #endregion
        ),
        const DocHeading('More languages', level: 3),
        const DocText(
          '`re_highlight` ships many more grammars under '
          '`package:re_highlight/languages/`. Create an `Oito2Highlighter` '
          'with the languages you need and pass it as `highlighter`; only '
          'the grammars referenced are compiled into the app.',
        ),
        const DocCode('''
import 'package:re_highlight/languages/lua.dart';

final highlighter = Oito2Highlighter(
  languages: {...oito2DefaultLanguages, 'lua': langLua},
);

Oito2CodeBlock(code: source, language: 'lua', highlighter: highlighter);'''),
        const DocHeading('Accessibility'),
        const DocText(
          'The code is selectable text, read as written. Line numbers are '
          'hidden from assistive technologies. Every syntax color of an '
          'oito2 scheme reaches a 4.5:1 contrast against the scheme '
          'surfaces, 7:1 with high contrast.',
        ),
        ...apiReferenceWidgets([
          'Oito2CodeBlock',
          'Oito2Highlighter',
          'oito2DefaultLanguages',
          'Oito2SyntaxTheme',
          'Oito2SyntaxPalette',
          'Oito2HighlighterTheme',
          'Oito2SyntaxRole',
        ]),
      ],
    );
  }
}
