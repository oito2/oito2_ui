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

import '../docs/doc_widgets.dart';

/// Documents [Oito2HighlightedText]: matching a query as you type, its
/// matching options and a custom highlight style.
class HighlightedTextPage extends StatefulWidget {
  /// Creates the highlighted text page.
  const HighlightedTextPage({super.key});

  @override
  State<HighlightedTextPage> createState() => _HighlightedTextPageState();
}

class _HighlightedTextPageState extends State<HighlightedTextPage> {
  late final _controller = TextEditingController(text: 'acao conf');
  late String _query = _controller.text;
  bool _ignoreCase = true;
  bool _wholeWords = false;
  bool _matchAll = true;
  bool _splitWords = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // #region lines
  static const _lines = [
    'Configurações de ação',
    'Confirm the action before deleting',
    'Ações rápidas e acessibilidade',
    'Keyboard configuration',
  ];
  // #endregion

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DocPage(
      title: 'Highlighted Text',
      description:
          'Text with the matches of a search query emphasized, such as '
          'search results that show why each item matched.',
      source: 'lib/src/pages/highlighted_text_page.dart',
      children: [
        ExamplePanel(
          regions: const ['lines', 'preview'],
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Oito2Spacing.md,
              children: [
                // #region preview
                Oito2SearchField(
                  controller: _controller,
                  onChanged: (text) => setState(() => _query = text),
                ),
                for (final line in _lines)
                  Oito2HighlightedText(line, query: _query),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give the widget the full `text` and the `query`. By default each '
          'word of the query matches on its own, everywhere in the text, '
          'ignoring case and accents: "acao" matches "Ação". Overlapping '
          'matches merge. The matches are drawn bold in the text-safe '
          'primary tone.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The static `Oito2HighlightedText.matches` returns the matched '
          'ranges of a text with the same options, for drawing the '
          'highlight your own way.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Matching options', level: 3),
        const DocText(
          '`queries` highlights more queries along with `query`. '
          '`ignoreCase` set to false makes matches keep their case and '
          'accents, `wholeWords` matches only whole words, `matchAll` set '
          'to false highlights only the first occurrence of each term, and '
          '`splitWords` set to false matches each query as a whole phrase. '
          'Here the queries are "ark", "ui" and "kit".',
        ),
        ExamplePanel(
          region: 'options',
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.md,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Oito2CheckButton(
                      value: _ignoreCase,
                      onChanged: (v) =>
                          setState(() => _ignoreCase = v ?? false),
                      title: const Text('Ignore case and accents'),
                    ),
                    Oito2CheckButton(
                      value: _wholeWords,
                      onChanged: (v) =>
                          setState(() => _wholeWords = v ?? false),
                      title: const Text('Whole words only'),
                    ),
                    Oito2CheckButton(
                      value: _matchAll,
                      onChanged: (v) => setState(() => _matchAll = v ?? false),
                      title: const Text('Every occurrence'),
                    ),
                    Oito2CheckButton(
                      value: _splitWords,
                      onChanged: (v) =>
                          setState(() => _splitWords = v ?? false),
                      title: const Text('Each word apart'),
                    ),
                  ],
                ),
                // #region options
                Oito2HighlightedText(
                  'Ark UI builds UI kits; the ark sails past the UI kit shop.',
                  query: 'ark',
                  queries: const ['ui', 'kit'],
                  ignoreCase: _ignoreCase,
                  wholeWords: _wholeWords,
                  matchAll: _matchAll,
                  splitWords: _splitWords,
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Highlight style', level: 3),
        const DocText(
          '`highlightStyle` is merged into the matches instead of the '
          'default bold text, and `style` sets the style of the whole '
          'text. `maxLines` and `overflow` work as in `Text`.',
        ),
        ExamplePanel(
          region: 'style',
          child: SizedBox(
            width: 320,
            // #region style
            child: Oito2HighlightedText(
              'Keyboard shortcuts and keyboard navigation',
              query: 'keyboard',
              highlightStyle: TextStyle(
                backgroundColor: scheme.tertiaryContainer,
                color: scheme.onTertiaryContainer,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // #endregion
          ),
        ),
        ...apiReferenceWidgets(['Oito2HighlightedText']),
      ],
    );
  }
}
