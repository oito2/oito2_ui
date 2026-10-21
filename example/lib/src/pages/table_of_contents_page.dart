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

import '../widgets/showcase_widgets.dart';

const _sections = [
  ('Introduction', 0),
  ('Installation', 0),
  ('Linux', 1),
  ('Windows', 1),
  ('Usage', 0),
  ('Theming', 1),
  ('License', 0),
];

/// Shows [Oito2TableOfContents] following a document.
class TableOfContentsPage extends StatefulWidget {
  /// Creates the table of contents page.
  const TableOfContentsPage({super.key});

  @override
  State<TableOfContentsPage> createState() => _TableOfContentsPageState();
}

class _TableOfContentsPageState extends State<TableOfContentsPage> {
  final _scroll = ScrollController();
  final _keys = [for (final _ in _sections) GlobalKey()];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Scroll the document or pick a section',
          children: [
            SizedBox(
              width: 640,
              height: 360,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
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
                  ),
                  const SizedBox(width: Oito2Spacing.lg),
                  Expanded(
                    child: ListView(
                      controller: _scroll,
                      children: [
                        for (var i = 0; i < _sections.length; i++)
                          Padding(
                            key: _keys[i],
                            padding: const EdgeInsets.only(
                              bottom: Oito2Spacing.xl,
                            ),
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
                                Text(
                                  'Text of the ${_sections[i].$1} section. ' *
                                      12,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 240),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
