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

const _rules = r'''
# Dependencies and build output
/build/
.dart_tool/
node_modules/

# Logs, except the release notes
*.log
!release.log

# Editor backups in any folder
**/*.swp
*~
\#*#''';

const _problems =
    '# Unclosed bracket\n'
    'cache[0-9.tmp\n'
    '# Trailing spaces are dropped by git\n'
    'dist   \n'
    '# Same rule twice\n'
    '*.log\n'
    '*.log';

const _dart = r'''
/// A counter that never goes below zero.
class Counter extends ValueNotifier<int> {
  Counter([super.value = 0]);

  void decrement() {
    if (value > 0) value--;
  }
}''';

/// Returns markers for the problems of the rules written in [text]: an
/// unclosed `[`, unescaped trailing spaces and repeated rules.
Map<int, Oito2LineMarker> _lint(String text) {
  final markers = <int, Oito2LineMarker>{};
  final seen = <String, int>{};
  final lines = text.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = Oito2GitignoreRule.trimTrailingSpaces(line);
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    if (!Oito2GitignoreMatcher.parse(trimmed).rules.single.isValid) {
      markers[i + 1] = const Oito2LineMarker.error(
        'The "[" is never closed, so this rule matches nothing.',
      );
    } else if (trimmed != line) {
      markers[i + 1] = const Oito2LineMarker.warning(
        r'Git drops trailing spaces; escape them as "\ " to keep them.',
      );
    } else if (seen[trimmed] case final first?) {
      markers[i + 1] = Oito2LineMarker.info('Same rule as line $first.');
    }
    seen.putIfAbsent(trimmed, () => i + 1);
  }
  return markers;
}

/// Documents [Oito2CodeEditor]: a gitignore editor with a rule tester,
/// line markers, and a read-only, sized editor.
class CodeEditorPage extends StatefulWidget {
  /// Creates the code editor page.
  const CodeEditorPage({super.key});

  @override
  State<CodeEditorPage> createState() => _CodeEditorPageState();
}

class _CodeEditorPageState extends State<CodeEditorPage> {
  final _rulesController = CodeLineEditingController.fromText(_rules);
  final _problemsController = CodeLineEditingController.fromText(_problems);
  final _dartController = CodeLineEditingController.fromText(_dart);
  final _path = TextEditingController(text: 'logs/debug.log');
  Oito2GitignoreMatcher _matcher = Oito2GitignoreMatcher.parse(_rules);
  Map<int, Oito2LineMarker> _markers = _lint(_problems);

  @override
  void dispose() {
    _rulesController.dispose();
    _problemsController.dispose();
    _dartController.dispose();
    _path.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = _matcher.match(_path.text.trim());
    final rule = match?.rule;
    final verdict = switch (match) {
      null => 'Not ignored: no rule matches.',
      _ when !match.isIgnored =>
        'Not ignored: re-included by line ${match.rule.line}, '
            '"${match.rule.pattern}".',
      _ when match.path != _path.text.trim().replaceAll(RegExp(r'/+$'), '') =>
        'Ignored: its folder "${match.path}" is ignored by line '
            '${match.rule.line}, "${match.rule.pattern}".',
      _ => 'Ignored by line ${match.rule.line}, "${match.rule.pattern}".',
    };
    return DocPage(
      title: 'Code Editor',
      description:
          'Edits code highlighted with the syntax colors of the active '
          'scheme, with line numbers, highlighted lines and line markers.',
      source: 'lib/src/pages/code_editor_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 560,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.md,
              children: [
                // #region preview
                Oito2CodeEditor(
                  controller: _rulesController,
                  language: 'gitignore',
                  minLines: 8,
                  maxLines: 14,
                  highlightedLines: {?rule?.line},
                  onChanged: (text) => setState(
                    () => _matcher = Oito2GitignoreMatcher.parse(text),
                  ),
                ),
                TextField(
                  controller: _path,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Path to test, with "/" at the end for a folder',
                  ),
                ),
                Text(verdict),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2CodeEditor` a `CodeLineEditingController` and the '
          '`language`, a registered name or alias such as `dart` or '
          '`gitignore`. The controller holds the text and the selection: '
          '`CodeLineEditingController.fromText` creates one with text, and '
          'its `text` reads and replaces it. `onChanged` receives the whole '
          'text after every edit.',
        ),
        const DocCode("import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';"),
        const DocText(
          'With `minLines` or `maxLines`, the editor is as tall as its '
          'lines within those bounds and scrolls beyond them; without '
          'both, it fills the height its parent gives it. Long lines '
          'scroll sideways.',
        ),
        const DocNote(
          'The editor is built on `re_editor`, which highlights, folds and '
          'searches in three background isolates per editor on native '
          'platforms and in the main thread on the web. Web builds with '
          '`--wasm` aren\'t supported, and the editor colors a token by the '
          'first segment of its scope, so class names take the function '
          'color, unlike `Oito2CodeBlock`. The `gitignore` grammar is part '
          'of `oito2_ui_syntax` and also works in `Oito2CodeBlock`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Testing gitignore rules', level: 3),
        const DocText(
          'The preview tests a path against the rules: `highlightedLines` '
          'marks the rule that decides whether the path is ignored, the '
          'last one that matches it or one of its folders. '
          '`Oito2GitignoreMatcher` parses the rules and matches paths '
          'with git\'s semantics: anchoring, directory rules, `*`, `?`, '
          'classes and `**`, negation, and no re-including inside an '
          'ignored folder.',
        ),
        const DocHeading('Line markers', level: 3),
        const DocText(
          '`lineMarkers` maps line numbers to an `Oito2LineMarker`: an '
          'error, a warning or information, shown as an icon in the gutter '
          'with its message as the tooltip. Here they come from checking '
          'the rules on every change.',
        ),
        ExamplePanel(
          region: 'markers',
          child: SizedBox(
            width: 560,
            // #region markers
            child: Oito2CodeEditor(
              controller: _problemsController,
              language: 'gitignore',
              minLines: 7,
              maxLines: 10,
              lineMarkers: _markers,
              onChanged: (text) => setState(() => _markers = _lint(text)),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Read only', level: 3),
        const DocText(
          '`readOnly` keeps the text from changing while it can still be '
          'selected and copied. `showLineNumbers: false` hides the line '
          'numbers.',
        ),
        ExamplePanel(
          region: 'readOnly',
          child: SizedBox(
            width: 560,
            // #region readOnly
            child: Oito2CodeEditor(
              controller: _dartController,
              language: 'dart',
              readOnly: true,
              showLineNumbers: false,
              highlightedLines: const {5, 6, 7},
              minLines: 3,
              maxLines: 6,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Keyboard'),
        const DocTable(
          header: ['Keys', 'Action'],
          rows: [
            ['Ctrl+Z, Ctrl+Shift+Z', 'Undo and redo'],
            ['Tab, Shift+Tab', 'Indent and outdent the selected lines'],
            ['Ctrl+Tab, Ctrl+Shift+Tab', 'Move the focus out of the editor'],
            ['Ctrl+A', 'Select all'],
            ['Ctrl+L', 'Select the line'],
            ['Ctrl+D', 'Delete the line'],
            ['Alt+Up, Alt+Down', 'Move the line up or down'],
          ],
        ),
        const DocText(
          'Find (Ctrl+F), replace (Ctrl+Alt+F) and save (Ctrl+S) aren\'t '
          'handled by the editor and reach the app, as do the shortcuts it '
          'doesn\'t use, such as the Ctrl+K command palette of this '
          'showcase. On macOS, Cmd replaces Ctrl.',
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The editor is announced as a multiline text field with its '
          'label, "Code editor" by default, and its text. Each line marker '
          'is announced with its line, kind and message, such as "Line 2, '
          'Error: …". The border turns into the focus ring while the '
          'editor has the focus.',
        ),
        ...apiReferenceWidgets([
          'Oito2CodeEditor',
          'Oito2LineMarker',
          'Oito2LineMarkerType',
          'Oito2GitignoreMatcher',
          'Oito2GitignoreRule',
          'Oito2GitignoreMatch',
          'langGitignore',
        ]),
      ],
    );
  }
}
