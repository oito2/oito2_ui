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
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';

import '../widgets/showcase_widgets.dart';

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

/// Shows code highlighted with the active scheme's syntax palette.
class CodePage extends StatefulWidget {
  /// Creates the code page.
  const CodePage({super.key});

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  String _language = 'dart';
  bool _lineNumbers = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'Language',
          children: [
            Oito2ChoiceChipBar(
              style: Oito2ChoiceChipBarStyle.wrap,
              labels: [for (final name in _samples.keys) Text(name)],
              isSelected: [for (final name in _samples.keys) name == _language],
              onSelected: (i) =>
                  setState(() => _language = _samples.keys.elementAt(i)),
            ),
            Oito2SwitchButton(
              value: _lineNumbers,
              onChanged: (v) => setState(() => _lineNumbers = v),
              title: const Text('Line numbers'),
            ),
          ],
        ),
        ShowcaseSection(
          'Code block',
          children: [
            SizedBox(
              width: 680,
              child: Oito2CodeBlock(
                code: _samples[_language]!.trim(),
                language: _language,
                showLineNumbers: _lineNumbers,
              ),
            ),
            Text(
              '${Oito2Highlighter.instance.languages.length} languages '
              'registered by default; every token color reaches 4.5:1 on '
              'the scheme surfaces.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
