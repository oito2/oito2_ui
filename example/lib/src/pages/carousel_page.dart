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

/// Documents [Oito2Carousel]: buttons, dots, keys and swipes, automatic
/// scrolling and a carousel that stops at its ends.
class CarouselPage extends StatefulWidget {
  /// Creates the carousel page.
  const CarouselPage({super.key});

  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  // #region auto-data
  final _auto = Oito2CarouselController(autoScroll: true);
  // #endregion
  int _page = 0;

  @override
  void dispose() {
    _auto.dispose();
    super.dispose();
  }

  /// The four colored slides, each with an icon and a title.
  List<Widget> _slides(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return [
      for (final (color, icon, title) in [
        (scheme.primaryContainer, LucideIcons.palette, 'Themes'),
        (scheme.secondaryContainer, LucideIcons.keyboard, 'Shortcuts'),
        (scheme.tertiaryContainer, LucideIcons.languages, 'Languages'),
        (scheme.surfaceContainerHighest, LucideIcons.accessibility, 'Access'),
      ])
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Oito2Spacing.xs),
          decoration: BoxDecoration(
            color: color,
            borderRadius: Oito2Radius.largeAll,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: Oito2Spacing.sm,
            children: [
              Icon(icon, size: 48),
              Text(title, style: textTheme.headlineSmall),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Carousel',
      description:
          'A row of pages shown one at a time, with previous and next '
          'buttons, a page indicator and optional automatic scrolling.',
      source: 'lib/src/pages/carousel_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 560,
            // #region preview
            child: Oito2Carousel(children: _slides(context)),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2Carousel` its pages in `children`; they are `height` '
          'pixels tall, 240 by default, and as wide as the carousel. Pages '
          'change with the previous and next buttons, the dots of the '
          '`Oito2PageIndicator` below, the arrow keys, or a swipe, also '
          'with a mouse. Past the last page, the buttons and keys return to '
          'the first, and back, jumping straight there.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The carousel keeps the current page itself and reports it to '
          '`onPageChanged`. An `Oito2CarouselController`, a `PageController`, '
          'sets the initial page, moves to a page with `goTo` and turns on '
          'automatic scrolling.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Automatic scrolling', level: 3),
        const DocText(
          'A controller with `autoScroll` moves to the next page every '
          '`autoScrollInterval`, 4 seconds by default, wrapping to the '
          'first. It pauses while a pointer hovers the carousel or anything '
          'inside it has focus, and it never scrolls by itself when '
          'animations are disabled. Dispose of the controller with the '
          'state that creates it.',
        ),
        ExamplePanel(
          regions: const ['auto-data', 'auto'],
          child: SizedBox(
            width: 560,
            // #region auto
            child: Oito2Carousel(
              controller: _auto,
              height: 180,
              children: _slides(context),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Stopping at the ends', level: 3),
        const DocText(
          'With `loop: false`, the previous button is disabled on the first '
          'page and the next button on the last. Here `onPageChanged` '
          'reports the page shown, and `pageIndicator: false` hides the '
          'dots.',
        ),
        ExamplePanel(
          region: 'no-loop',
          child: SizedBox(
            width: 560,
            child: Column(
              spacing: Oito2Spacing.sm,
              children: [
                // #region no-loop
                Oito2Carousel(
                  loop: false,
                  pageIndicator: false,
                  height: 160,
                  onPageChanged: (page) => setState(() => _page = page),
                  children: _slides(context),
                ),
                Text('Page ${_page + 1} of 4'),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The previous and next buttons are named by their tooltips, '
          '"Previous page" and "Next page", and each dot reads as "Page 2 '
          'of 4". The carousel takes focus as a whole and shows the focus '
          'ring around it. Since automatic scrolling pauses while the '
          'carousel has focus, keyboard and screen reader users can read a '
          'page without it moving away.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Tab`',
              'Moves the focus to the carousel and through its buttons and '
                  'dots.',
            ],
            [
              '`Right arrow`',
              'Shows the next page; the previous one in right-to-left '
                  'layouts.',
            ],
            [
              '`Left arrow`',
              'Shows the previous page; the next one in right-to-left '
                  'layouts.',
            ],
            [
              '`Home` / `End`',
              'With the dots focused, shows the first or the last page.',
            ],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2Carousel',
          'Oito2CarouselController',
          'Oito2PageIndicator',
        ]),
      ],
    );
  }
}
