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

// #region data
const _headers = [
  Text('What is oito2_ui?'),
  Text('Which platforms does it support?'),
  Text('Is it free software?'),
];
const _answers = [
  Text('A Material 3 design system for the oito2 Flutter apps.'),
  Text('Linux desktops, Windows, macOS, Android, iOS and the web.'),
  Text('Yes, under the GNU GPL version 3 or later.'),
];
// #endregion

/// Documents [Oito2ExpansionPanel]: an accordion, independent sections
/// and change reports.
class ExpansionPanelPage extends StatefulWidget {
  /// Creates the expansion panel page.
  const ExpansionPanelPage({super.key});

  @override
  State<ExpansionPanelPage> createState() => _ExpansionPanelPageState();
}

class _ExpansionPanelPageState extends State<ExpansionPanelPage> {
  final List<String> _log = [];

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Expansion Panel',
      description:
          'A bordered stack of sections whose headers show or hide their '
          'content, as an accordion.',
      source: 'lib/src/pages/expansion_panel_page.dart',
      children: [
        const ExamplePanel(
          regions: ['data', 'preview'],
          child: SizedBox(
            width: 480,
            // #region preview
            child: Oito2ExpansionPanel(
              initiallyExpanded: {0},
              headers: _headers,
              children: _answers,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2ExpansionPanel` the section `headers` and their '
          '`children`, paired by index; there must be one child per header. '
          '`initiallyExpanded` lists the indexes of the sections open at '
          'start. The panel keeps which sections are open itself, and each '
          'section is an `Oito2Expandable`.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'By default `collapseOnExpand` is true: opening a section closes '
          'the others, so at most one is open, and only the first index of '
          '`initiallyExpanded` opens. Dividers separate the sections unless '
          '`placeDividers` is false, and `padding` sets the space around '
          'each one.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Independent sections', level: 3),
        const DocText(
          'With `collapseOnExpand: false`, each section opens and closes on '
          'its own.',
        ),
        const ExamplePanel(
          region: 'independent',
          child: SizedBox(
            width: 480,
            // #region independent
            child: Oito2ExpansionPanel(
              collapseOnExpand: false,
              headers: _headers,
              children: _answers,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Reacting to changes', level: 3),
        const DocText(
          '`onExpansionChanged` receives the index of each section that '
          'opens or closes and whether it is now open. The sections that '
          '`collapseOnExpand` closes are reported first, then the one that '
          'opened.',
        ),
        ExamplePanel(
          region: 'callback',
          child: SizedBox(
            width: 480,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                // #region callback
                Oito2ExpansionPanel(
                  headers: _headers,
                  onExpansionChanged: (index, expanded) => setState(
                    () => _log.add('${index + 1} ${expanded ? '+' : '−'}'),
                  ),
                  children: _answers,
                ),
                Text(
                  'Changes: ${_log.reversed.take(6).join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each header is a button that reports whether its section is '
          'expanded, as in `Oito2Expandable`.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next header.'],
            ['`Enter` / `Space`', 'Opens or closes the focused section.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2ExpansionPanel', 'Oito2Expandable']),
      ],
    );
  }
}
