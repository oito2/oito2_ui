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

// #region sections
const _sections = [
  ('Introduction', 0),
  ('Installation', 0),
  ('Linux', 1),
  ('Windows', 1),
  ('Usage', 0),
  ('Theming', 1),
  ('License', 0),
];
// #endregion

/// Documents [Oito2TableOfContents] following a document, and with an
/// activation line and a pick callback.
class TableOfContentsPage extends StatefulWidget {
  /// Creates the table of contents page.
  const TableOfContentsPage({super.key});

  @override
  State<TableOfContentsPage> createState() => _TableOfContentsPageState();
}

class _TableOfContentsPageState extends State<TableOfContentsPage> {
  // #region data
  final _scroll = ScrollController();
  final _keys = [for (final _ in _sections) GlobalKey()];
  // #endregion
  final _pickScroll = ScrollController();
  final _pickKeys = [for (final _ in _sections) GlobalKey()];
  String _picked = 'None';

  @override
  void dispose() {
    _scroll.dispose();
    _pickScroll.dispose();
    super.dispose();
  }

  /// The sample document: one heading per section, keyed by [keys], and
  /// a paragraph under it, scrolled by [controller].
  Widget _document(List<GlobalKey> keys, ScrollController controller) {
    final theme = Theme.of(context);
    return ListView(
      controller: controller,
      children: [
        for (var i = 0; i < _sections.length; i++)
          Padding(
            key: keys[i],
            padding: const EdgeInsets.only(bottom: Oito2Spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Oito2Spacing.sm,
              children: [
                Text(
                  _sections[i].$1,
                  style: _sections[i].$2 == 0
                      ? theme.textTheme.titleLarge
                      : theme.textTheme.titleMedium,
                ),
                Text('Text of the ${_sections[i].$1} section. ' * 12),
              ],
            ),
          ),
        const SizedBox(height: 240),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Table of Contents',
      description:
          'Lists the sections of a scrolling document, highlights the one in '
          'view and scrolls to the one picked.',
      source: 'lib/src/pages/table_of_contents_page.dart',
      children: [
        ExamplePanel(
          regions: const ['sections', 'data', 'preview'],
          child: SizedBox(
            width: 640,
            height: 360,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  // #region preview
                  child: Oito2TableOfContents(
                    controller: _scroll,
                    entries: [
                      for (var i = 0; i < _sections.length; i++)
                        Oito2TocEntry(
                          title: _sections[i].$1,
                          depth: _sections[i].$2,
                          target: _keys[i],
                        ),
                    ],
                  ),
                  // #endregion
                ),
                const SizedBox(width: Oito2Spacing.lg),
                Expanded(child: _document(_keys, _scroll)),
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give each section heading of the scroll view a `GlobalKey`, and '
          'list the sections as `Oito2TocEntry`s with their `title`, that '
          'key as `target` and a `depth` that indents subsections. Pass the '
          'scroll view\'s `ScrollController` as `controller`. Picking an '
          'entry scrolls its heading into view.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The current section is the last one whose heading has reached '
          '`activationOffset` pixels below the top of the view, 32 by '
          'default, or the last section when the view is scrolled to the '
          'end. The "On this page" list beside this documentation, on wide '
          'windows, is an `Oito2TableOfContents`.',
        ),
        const DocNote(
          'In a lazily built scroll view, such as a `ListView.builder`, only '
          'the headings that are built can be measured. Picking a section '
          'whose heading is not built only calls `onSelected`, which can '
          'scroll there itself.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Activation line and picks', level: 3),
        const DocText(
          'A larger `activationOffset` makes a section current while its '
          'heading is still lower in the view. `onSelected` receives the '
          'index of each picked entry before the view starts scrolling.',
        ),
        ExamplePanel(
          region: 'picks',
          child: SizedBox(
            width: 640,
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Oito2Spacing.md,
                    children: [
                      // #region picks
                      Oito2TableOfContents(
                        controller: _pickScroll,
                        activationOffset: 120,
                        onSelected: (index) =>
                            setState(() => _picked = _sections[index].$1),
                        entries: [
                          for (var i = 0; i < _sections.length; i++)
                            Oito2TocEntry(
                              title: _sections[i].$1,
                              depth: _sections[i].$2,
                              target: _pickKeys[i],
                            ),
                        ],
                      ),
                      Text('Picked: $_picked'),
                      // #endregion
                    ],
                  ),
                ),
                const SizedBox(width: Oito2Spacing.lg),
                Expanded(child: _document(_pickKeys, _pickScroll)),
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The current entry is reported as selected to assistive '
          'technologies, and each entry can be tapped by them and reached '
          'with the keyboard. Scrolling to a picked section is instant when '
          'animations are disabled.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next entry.'],
            ['`Enter` / `Space`', 'Scrolls to the section of the entry.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2TableOfContents', 'Oito2TocEntry']),
      ],
    );
  }
}
