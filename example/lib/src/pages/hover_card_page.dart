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

/// Documents [Oito2HoverCard]: a profile preview, a placement without an
/// arrow and custom delays.
class HoverCardPage extends StatelessWidget {
  /// Creates the hover card page.
  const HoverCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DocPage(
      title: 'Hover Card',
      description:
          'A card of extra detail that opens while the pointer rests on a '
          'widget or the focus is inside it, such as a profile preview on a '
          'user name.',
      source: 'lib/src/pages/hover_card_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2HoverCard(
            cardBuilder: (context) => const Text('github.com/oito2/oito2_ui'),
            child: TextButton(onPressed: () {}, child: const Text('oito2_ui')),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Wrap the widget in `Oito2HoverCard` and build the card in '
          '`cardBuilder`. The card opens `openDelay` after the pointer enters '
          'the child or the focus moves inside it, 500 ms by default, and '
          'closes `closeDelay` after the pointer leaves both the child and '
          'the card, or the focus leaves the child, 300 ms by default.',
        ),
        const DocText(
          'A long press opens the card on touch screens; Escape and a tap '
          'outside close it.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'The card does not take the focus, so its content must only '
          'repeat or preview what the child leads to. For interactive '
          'content, use `Oito2Popover`.',
          type: Oito2InfoType.warning,
        ),
        const DocHeading('Examples'),
        const DocHeading('Profile preview', level: 3),
        const DocText(
          'The card content can be any widget, up to `maxWidth` wide, 320 by '
          'default.',
        ),
        ExamplePanel(
          region: 'profile',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            alignment: WrapAlignment.center,
            children: [
              // #region profile
              for (final (name, role) in [
                ('Ana Souza', 'Maintainer'),
                ('Bruno Lima', 'Designer'),
              ])
                Oito2HoverCard(
                  cardBuilder: (context) => Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Oito2Spacing.md,
                    children: [
                      const Oito2PlaceholderIcon(
                        size: 48,
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: theme.textTheme.titleMedium),
                            Text(role),
                          ],
                        ),
                      ),
                    ],
                  ),
                  child: TextButton(onPressed: () {}, child: Text(name)),
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Above, without an arrow', level: 3),
        const DocText(
          '`placement` and `alignment` position the card as in '
          '`Oito2Popover`, below and centered by default; `showArrow: false` '
          'removes the arrow.',
        ),
        ExamplePanel(
          region: 'placement',
          // #region placement
          child: Oito2HoverCard(
            placement: Oito2PopoverPlacement.top,
            showArrow: false,
            cardBuilder: (context) => const Text('github.com/oito2/oito2_ui'),
            child: TextButton(
              onPressed: () {},
              child: const Text('Repository'),
            ),
          ),
          // #endregion
        ),
        const DocHeading('Delays', level: 3),
        const DocText(
          'Shorter delays make the card feel quicker; longer ones avoid '
          'opening it while the pointer only passes over the child.',
        ),
        ExamplePanel(
          region: 'delays',
          // #region delays
          child: Oito2HoverCard(
            openDelay: Duration.zero,
            closeDelay: const Duration(seconds: 1),
            cardBuilder: (context) =>
                const Text('Opens at once, closes after a second.'),
            child: TextButton(
              onPressed: () {},
              child: const Text('Quick card'),
            ),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The card opens when the keyboard focus moves inside the child, '
          'not only on hover, and leaves the focus where it is.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Focusing the child opens the card after `openDelay`.'],
            ['`Escape`', 'Closes the open card, wherever the focus is.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2HoverCard']),
      ],
    );
  }
}
