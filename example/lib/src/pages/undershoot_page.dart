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

/// Documents [Oito2ScrollViewUndershoot] on vertical and horizontal
/// scrolling lists.
class UndershootPage extends StatelessWidget {
  /// Creates the scroll view undershoot page.
  const UndershootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Scroll View Undershoot',
      description:
          'Fades soft shadows in at the edges of a scroll view while there '
          'is more content beyond them.',
      source: 'lib/src/pages/undershoot_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 260,
            height: 200,
            child: Oito2BorderContainer(
              // #region preview
              child: Oito2ScrollViewUndershoot(
                child: ListView(
                  children: [
                    for (var i = 1; i <= 20; i++)
                      ListTile(dense: true, title: Text('Item $i')),
                  ],
                ),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Wrap a scroll view in `Oito2ScrollViewUndershoot`; it needs no '
          'controller. A shadow fades in at each edge with content hidden '
          'beyond it, and out when the scroll reaches that edge. Only the '
          'scroll view directly below it counts, not scroll views nested '
          'inside that one.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Horizontal', level: 3),
        const DocText(
          'The shadows follow the scroll direction: in a horizontal scroll '
          'view they sit at the start and end sides, mirrored in '
          'right-to-left layouts. The vertical mouse wheel and mouse drags '
          'scroll it too, which Flutter otherwise leaves to Shift+wheel and '
          'touch; `pointerScrolling: false` turns that off.',
        ),
        ExamplePanel(
          region: 'horizontal',
          child: SizedBox(
            width: 320,
            height: 72,
            child: Oito2BorderContainer(
              // #region horizontal
              child: Oito2ScrollViewUndershoot(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(Oito2Spacing.sm),
                  children: [
                    for (var i = 1; i <= 12; i++)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: Oito2Spacing.sm,
                        ),
                        child: Chip(label: Text('Tag $i')),
                      ),
                  ],
                ),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('One edge and depth', level: 3),
        const DocText(
          '`start` and `end` turn the shadow of each edge on or off, and '
          '`extent` sets how deep the shadows reach, 12 pixels by default.',
        ),
        ExamplePanel(
          region: 'edges',
          child: SizedBox(
            width: 260,
            height: 200,
            child: Oito2BorderContainer(
              // #region edges
              child: Oito2ScrollViewUndershoot(
                start: false,
                extent: 32,
                child: ListView(
                  children: [
                    for (var i = 1; i <= 20; i++)
                      ListTile(dense: true, title: Text('Message $i')),
                  ],
                ),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The shadows are decorative: they ignore the pointer and add '
          'nothing for assistive technologies. When animations are '
          'disabled they appear and disappear at once, without fading.',
        ),
        ...apiReferenceWidgets(['Oito2ScrollViewUndershoot']),
      ],
    );
  }
}
