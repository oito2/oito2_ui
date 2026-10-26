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

/// Documents [Oito2PageIndicator]: interactive dots, the spacing layouts,
/// the dot size and the counter shown when the dots do not fit.
class PageIndicatorPage extends StatefulWidget {
  /// Creates the page indicator page.
  const PageIndicatorPage({super.key});

  @override
  State<PageIndicatorPage> createState() => _PageIndicatorPageState();
}

class _PageIndicatorPageState extends State<PageIndicatorPage> {
  int _page = 0;
  int _large = 1;
  int _small = 2;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DocPage(
      title: 'Page Indicator',
      description:
          'Dots that show the current page of a carousel or a paged view, '
          'and can move to another page.',
      source: 'lib/src/pages/page_indicator_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2PageIndicator(
            length: 6,
            page: _page % 6,
            onTap: (index) => setState(() => _page = index),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2PageIndicator` the number of pages in `length` and the '
          'current `page`, counting from 0. The current page is a wider '
          'pill in the accent color. With `onTap`, each dot is a button '
          'that reports its index; a null `onTap` makes the dots a plain '
          'display.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          '`Oito2Carousel` shows a page indicator below its pages. For pages '
          'with numbered buttons, use `Oito2Pagination`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Spacing layouts', level: 3),
        const DocText(
          '`layout` picks how the dots are spaced: `fixed` always keeps '
          '`spacing` between them; `stepped` brings them closer as pages '
          'are added, the full spacing up to 5 pages, three quarters up to '
          '10 and half beyond; `bounded` keeps the full spacing when it fits '
          'and otherwise draws the dots as close as needed to fit the '
          'width, down to half the dot size. Here each indicator shows 12 '
          'pages in 200 pixels: the `fixed` dots do not fit, so it shows '
          'the counter described below.',
        ),
        const DocNote(
          'These indicators have no `onTap`, so they only show the page. '
          'An interactive dot sits in a target at least 24 pixels wide, and '
          'twelve of those do not fit in 200 pixels, so interactive dots '
          'would all turn into the counter.',
        ),
        ExamplePanel(
          region: 'layouts',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.sm,
            children: [
              // #region layouts
              for (final layout in Oito2PageIndicatorLayout.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Oito2Spacing.md,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(layout.name, style: textTheme.labelMedium),
                    ),
                    SizedBox(
                      width: 200,
                      child: Oito2PageIndicator(
                        length: 12,
                        page: _page % 12,
                        layout: layout,
                      ),
                    ),
                  ],
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Counter', level: 3),
        const DocText(
          'When the dots do not fit the available width, the indicator shows '
          'the page as "page / length" text instead. Here 24 pages are given '
          '72 pixels.',
        ),
        ExamplePanel(
          region: 'counter',
          child: SizedBox(
            width: 72,
            // #region counter
            child: Oito2PageIndicator(
              length: 24,
              page: _page,
              onTap: (index) => setState(() => _page = index),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Dot size', level: 3),
        const DocText(
          '`dotSize` sets the diameter of the dots, 8 pixels by default; '
          'the current page is three times as wide. `spacing` sets the '
          'space between them.',
        ),
        ExamplePanel(
          region: 'size',
          // #region size
          child: Oito2PageIndicator(
            length: 4,
            page: _large,
            dotSize: 12,
            spacing: Oito2Spacing.md,
            onTap: (index) => setState(() => _large = index),
          ),
          // #endregion
        ),
        const DocHeading('Target size', level: 3),
        const DocText(
          'An interactive dot sits in a target at least `minTargetSize` '
          'wide and tall, 24 pixels by default. When other controls, such '
          'as previous and next buttons, also move between the pages, a '
          'smaller value keeps the dots close together; 0 makes each '
          'target the size of its dot.',
        ),
        ExamplePanel(
          region: 'targets',
          // #region targets
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.sm,
            children: [
              Oito2IconButton(
                icon: const Icon(LucideIcons.chevron_left),
                tooltip: 'Previous',
                onPressed: _small > 0 ? () => setState(() => _small--) : null,
              ),
              Oito2PageIndicator(
                length: 8,
                page: _small,
                minTargetSize: 0,
                onTap: (index) => setState(() => _small = index),
              ),
              Oito2IconButton(
                icon: const Icon(LucideIcons.chevron_right),
                tooltip: 'Next',
                onPressed: _small < 7 ? () => setState(() => _small++) : null,
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each dot is labeled "Page 2 of 6", or by `pageLabel`, and the '
          'current one is reported as selected; interactive dots are '
          'buttons. The counter reads with the same label. Interactive '
          'dots are a single stop in keyboard navigation and show the '
          'focus ring around the whole row.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the dots.'],
            [
              '`Left arrow` / `Right arrow`',
              'Moves to the previous or next page, in the reading '
                  'direction: `Right arrow` moves back in right-to-left '
                  'layouts.',
            ],
            ['`Home`', 'Moves to the first page.'],
            ['`End`', 'Moves to the last page.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2PageIndicator',
          'Oito2PageIndicatorLayout',
        ]),
      ],
    );
  }
}
