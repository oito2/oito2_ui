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

/// Documents [Oito2Expandable]: a collapsed summary, the button at the
/// start and a controlled section.
class ExpandablePage extends StatefulWidget {
  /// Creates the expandable page.
  const ExpandablePage({super.key});

  @override
  State<ExpandablePage> createState() => _ExpandablePageState();
}

class _ExpandablePageState extends State<ExpandablePage> {
  bool _details = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DocPage(
      title: 'Expandable',
      description:
          'A header that shows or hides the content under it, optionally '
          'with a summary while it is hidden.',
      source: 'lib/src/pages/expandable_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 420,
            child: Oito2BorderContainer(
              padding: const EdgeInsets.all(Oito2Spacing.md),
              // #region preview
              child: Oito2Expandable(
                header: const Text('Advanced options'),
                collapsedChild: Text(
                  '3 options hidden',
                  style: textTheme.bodySmall,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enable experimental features'),
                    Text('Send usage statistics'),
                    Text('Use legacy renderer'),
                  ],
                ),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2Expandable` a `header` and the `child` it shows. The '
          'whole header row toggles the content, with a chevron that turns '
          'over when it opens, and the content slides open. While closed, '
          'the optional `collapsedChild` shows in its place, such as a '
          'summary. `gap` sets the space between the header and the '
          'content.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'Without `onChanged`, the section keeps its own state and '
          '`isExpanded` is only the initial one. With `onChanged`, it is '
          'controlled: activating the header only reports the requested '
          'state, and the content follows `isExpanded`.',
        ),
        const DocNote(
          'For several sections in one bordered box, where opening one can '
          'close the others, use `Oito2ExpansionPanel`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Button at the start', level: 3),
        const DocText(
          '`buttonPosition: Oito2ExpandButtonPosition.start` puts the '
          'chevron before the header. This section also starts open with '
          '`isExpanded: true`.',
        ),
        const ExamplePanel(
          region: 'start',
          child: SizedBox(
            width: 420,
            // #region start
            child: Oito2Expandable(
              buttonPosition: Oito2ExpandButtonPosition.start,
              isExpanded: true,
              header: Text('Release notes'),
              child: Text('Fixes the window size on the second monitor.'),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Controlled', level: 3),
        const DocText(
          'With `onChanged`, the parent decides whether the section opens. '
          'Here a switch outside the section opens and closes it too.',
        ),
        ExamplePanel(
          region: 'controlled',
          child: SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.md,
              children: [
                // #region controlled
                SwitchListTile(
                  title: const Text('Show details'),
                  value: _details,
                  onChanged: (value) => setState(() => _details = value),
                ),
                Oito2Expandable(
                  header: const Text('Details'),
                  isExpanded: _details,
                  onChanged: (value) => setState(() => _details = value),
                  child: const Text('Size 2.4 MB, modified today.'),
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The header is a button that reports whether the content is '
          'expanded. When animations are disabled, the content appears and '
          'disappears without sliding.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the header.'],
            ['`Enter` / `Space`', 'Shows or hides the content.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2Expandable',
          'Oito2ExpandButtonPosition',
        ]),
      ],
    );
  }
}
