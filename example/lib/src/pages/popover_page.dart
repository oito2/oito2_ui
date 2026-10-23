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

/// Documents [Oito2Popover]: placements, an arrow, a form, the anchor
/// width and nesting.
class PopoverPage extends StatefulWidget {
  /// Creates the popover page.
  const PopoverPage({super.key});

  @override
  State<PopoverPage> createState() => _PopoverPageState();
}

class _PopoverPageState extends State<PopoverPage> {
  bool _arrow = true;

  /// A button labeled [label] that opens and closes the popover of
  /// [controller].
  Widget _anchor(String label, Oito2PopoverController controller) =>
      OutlinedButton(onPressed: controller.toggle, child: Text(label));

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Popover',
      description:
          'A non-modal panel anchored to a widget, such as a picker or a '
          'short form.',
      source: 'lib/src/pages/popover_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2Popover(
            builder: (context, controller) => OutlinedButton(
              onPressed: controller.toggle,
              child: const Text('Details'),
            ),
            popoverBuilder: (context, controller) =>
                const Text('Popovers hold short, related content.'),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`builder` builds the anchor and `popoverBuilder` the panel '
          'content. Both receive an `Oito2PopoverController`, which a button '
          'in the anchor typically toggles; pass your own `controller` to '
          'open and close the panel from elsewhere. `onOpenChanged` reports '
          'each change.',
        ),
        const DocText(
          'The panel follows the anchor as it moves or scrolls. It closes on '
          'Escape and, unless `closeOnTapOutside` is false, on a tap outside '
          'the anchor and the panel. It is at most `maxWidth` wide, 360 by '
          'default, and at most `maxHeight` tall.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For content that shows while the pointer rests on a link, use '
          '`Oito2HoverCard`; for a list of actions, a popup or context menu.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Placement and arrow', level: 3),
        const DocText(
          '`placement` picks the preferred side of the anchor; `start` and '
          '`end` follow the text direction, and the panel moves to the '
          'opposite side when the preferred one has too little room. '
          '`alignment` lines it up with the start, center or end of the '
          'anchor\'s edge, and `showArrow` points it at the anchor.',
        ),
        ExamplePanel(
          region: 'placement',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Oito2CheckButton(
                value: _arrow,
                onChanged: (v) => setState(() => _arrow = v ?? false),
                title: const Text('Show the arrow'),
              ),
              // #region placement
              for (final placement in Oito2PopoverPlacement.values)
                Oito2Popover(
                  placement: placement,
                  alignment: Oito2PopoverAlignment.center,
                  showArrow: _arrow,
                  builder: (context, c) => _anchor(placement.name, c),
                  popoverBuilder: (context, _) =>
                      Text('Opened on the ${placement.name} side.'),
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('A short form', level: 3),
        const DocText(
          'When the panel opens, its first focusable widget takes the focus '
          'unless `focusOnOpen` is false; when it closes with the focus '
          'inside, the focus returns to where it was. The content can close '
          'the panel through the controller it receives.',
        ),
        ExamplePanel(
          region: 'form',
          // #region form
          child: Oito2Popover(
            semanticLabel: 'Rename',
            builder: (context, c) => _anchor('Rename', c),
            popoverBuilder: (context, controller) => SizedBox(
              width: 260,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: Oito2Spacing.sm,
                children: [
                  const TextField(
                    decoration: InputDecoration(hintText: 'New name'),
                  ),
                  FilledButton(
                    onPressed: controller.close,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
          // #endregion
        ),
        const DocHeading('As wide as the anchor', level: 3),
        const DocText(
          'With `matchAnchorWidth`, a panel above or below the anchor takes '
          'the anchor\'s width.',
        ),
        ExamplePanel(
          region: 'match-width',
          // #region match-width
          child: Oito2Popover(
            matchAnchorWidth: true,
            builder: (context, c) => SizedBox(
              width: 240,
              child: _anchor('As wide as its anchor', c),
            ),
            popoverBuilder: (context, _) =>
                const Text('This panel takes the button width.'),
          ),
          // #endregion
        ),
        const DocHeading('Nested', level: 3),
        const DocText(
          'A popover opened from inside another one keeps the outer one '
          'open: a tap in the inner panel does not count as a tap outside '
          'the outer one.',
        ),
        ExamplePanel(
          region: 'nested',
          // #region nested
          child: Oito2Popover(
            builder: (context, c) => _anchor('Outer', c),
            popoverBuilder: (context, _) => Oito2Popover(
              placement: Oito2PopoverPlacement.end,
              builder: (context, c) => _anchor('Open inner', c),
              popoverBuilder: (context, _) =>
                  const Text('The outer panel stays open.'),
            ),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The panel is a separate semantics container labeled by '
          '`semanticLabel`. Since it takes the focus when it opens and gives '
          'it back when it closes, keyboard users land in the panel and '
          'return to the anchor.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Escape`', 'Closes the panel.'],
            ['`Tab`', 'Moves the focus through the panel content.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2Popover',
          'Oito2PopoverController',
          'Oito2PopoverPlacement',
          'Oito2PopoverAlignment',
          'Oito2PopoverWidgetBuilder',
        ]),
      ],
    );
  }
}
