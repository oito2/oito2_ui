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

/// Documents [Oito2ScrollArea] scrolling up and down, across and both
/// ways.
class ScrollAreaPage extends StatelessWidget {
  /// Creates the scroll area page.
  const ScrollAreaPage({super.key});

  static const _text =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
      'ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut '
      'aliquip ex ea commodo consequat. Duis aute irure dolor in '
      'reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla '
      'pariatur. Excepteur sint occaecat cupidatat non proident, sunt in '
      'culpa qui officia deserunt mollit anim id est laborum.';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DocPage(
      title: 'Scroll Area',
      description:
          'A scrollable box for content larger than it, with the themed '
          'scroll bars on the axes it scrolls in.',
      source: 'lib/src/pages/scroll_area_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          child: Oito2BorderContainer(
            width: 280,
            height: 180,
            // #region preview
            child: Oito2ScrollArea(
              padding: EdgeInsets.all(Oito2Spacing.md),
              child: Text('$_text\n\n$_text'),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Wrap content that may not fit in an `Oito2ScrollArea` and give '
          'the area a bounded size. It scrolls up and down by default; '
          '`direction` chooses across or both ways. `padding` is the space '
          'around the content, inside the scrolled part.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The bars show while scrolling. `thumbVisibility: true` shows '
          'them all the time, and null follows the scroll bar theme. To '
          'read or move the scroll position, pass a `verticalController` '
          'or a `horizontalController`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Undershoot shadow', level: 3),
        const DocText(
          'With `undershoot`, a soft shadow marks the edges with more '
          'content beyond them.',
        ),
        const ExamplePanel(
          region: 'undershoot',
          child: Oito2BorderContainer(
            width: 280,
            height: 180,
            // #region undershoot
            child: Oito2ScrollArea(
              undershoot: true,
              padding: EdgeInsets.all(Oito2Spacing.md),
              child: Text('$_text\n\n$_text'),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Across, bars always shown', level: 3),
        const DocText(
          '`Oito2ScrollDirection.horizontal` scrolls a row from side to '
          'side.',
        ),
        ExamplePanel(
          region: 'horizontal',
          child: Oito2BorderContainer(
            width: 280,
            height: 80,
            // #region horizontal
            child: Oito2ScrollArea(
              direction: Oito2ScrollDirection.horizontal,
              thumbVisibility: true,
              padding: const EdgeInsets.all(Oito2Spacing.sm),
              child: Row(
                spacing: Oito2Spacing.sm,
                children: [
                  for (var i = 1; i <= 12; i++) Chip(label: Text('Item $i')),
                ],
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Both ways', level: 3),
        const DocText(
          '`Oito2ScrollDirection.both` scrolls large content in both '
          'directions, with a scroll bar on each axis. With `undershoot`, '
          'the shadows follow the vertical axis only.',
        ),
        ExamplePanel(
          region: 'both',
          child: Oito2BorderContainer(
            width: 280,
            height: 200,
            // #region both
            child: Oito2ScrollArea(
              direction: Oito2ScrollDirection.both,
              thumbVisibility: true,
              child: SizedBox(
                width: 640,
                height: 480,
                child: GridView.count(
                  crossAxisCount: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 0; i < 48; i++)
                      Container(
                        margin: const EdgeInsets.all(2),
                        color: i.isEven
                            ? scheme.surfaceContainerHigh
                            : scheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Text('$i'),
                      ),
                  ],
                ),
              ),
            ),
            // #endregion
          ),
        ),
        ...apiReferenceWidgets(['Oito2ScrollArea', 'Oito2ScrollDirection']),
      ],
    );
  }
}
