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

/// Documents [Oito2Splitter]: two panes, three nested and collapsible
/// panes, and a pane that starts collapsed.
class SplitterPage extends StatelessWidget {
  /// Creates the splitter page.
  const SplitterPage({super.key});

  /// A pane filled with [color] showing [label] in the middle.
  Widget _pane(String label, Color color) => ColoredBox(
    color: color,
    child: Center(child: Text(label)),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DocPage(
      title: 'Splitter',
      description:
          'Panes side by side or stacked, with a draggable divider between '
          'each two, that can nest and collapse.',
      source: 'lib/src/pages/splitter_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 520,
            height: 220,
            child: Oito2BorderContainer(
              // #region preview
              child: Oito2Splitter(
                panes: [
                  Oito2SplitterPane(
                    initialFraction: 0.4,
                    minSize: 120,
                    child: _pane('Start', scheme.surfaceContainer),
                  ),
                  Oito2SplitterPane(
                    minSize: 120,
                    child: _pane('End', scheme.surface),
                  ),
                ],
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'List two or more `Oito2SplitterPane`s in `panes`, from the start, '
          'or the top when `axis` is vertical. A pane starts at its '
          '`initialFraction` of the space, and the panes without one share '
          'what is left equally. `minSize` and `maxSize` bound each pane in '
          'pixels, and a divider keeps both of its panes within their '
          'limits. The splitter keeps the sizes itself and reports them to '
          '`onSizesChanged` after each change.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For a single resizable side pane, `Oito2PanedView` is simpler.',
        ),
        const DocText(
          'When the window is resized, the panes keep their proportions. '
          'When the minimum sizes do not fit, the panes keep them and the '
          'end of the splitter is clipped instead of overflowing.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Nested and collapsible', level: 3),
        const DocText(
          'A pane can hold another splitter on the other axis. A '
          '`collapsible` pane collapses to `collapsedSize`, zero by default, '
          'and back to its previous size with a double click on the divider '
          'beside it, or `Enter` or `Space` while the divider has focus. A '
          'divider between two collapsible panes collapses the one before '
          'it.',
        ),
        ExamplePanel(
          region: 'nested',
          child: SizedBox(
            width: 640,
            height: 320,
            child: Oito2BorderContainer(
              // #region nested
              child: Oito2Splitter(
                panes: [
                  Oito2SplitterPane(
                    initialFraction: 0.25,
                    minSize: 120,
                    collapsible: true,
                    child: _pane('Sidebar', scheme.surfaceContainer),
                  ),
                  Oito2SplitterPane(
                    minSize: 200,
                    child: Oito2Splitter(
                      axis: Axis.vertical,
                      panes: [
                        Oito2SplitterPane(
                          child: _pane('Editor', scheme.surface),
                        ),
                        Oito2SplitterPane(
                          initialFraction: 0.3,
                          collapsible: true,
                          child: _pane('Terminal', scheme.surfaceContainerHigh),
                        ),
                      ],
                    ),
                  ),
                  Oito2SplitterPane(
                    initialFraction: 0.25,
                    minSize: 120,
                    maxSize: 260,
                    collapsible: true,
                    child: _pane('Outline', scheme.surfaceContainer),
                  ),
                ],
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Starting collapsed', level: 3),
        const DocText(
          '`initiallyCollapsed` starts a collapsible pane collapsed; it '
          'opens at its `minSize` the first time. A non-zero '
          '`collapsedSize` keeps a strip of the pane visible.',
        ),
        ExamplePanel(
          region: 'collapsed',
          child: SizedBox(
            width: 520,
            height: 200,
            child: Oito2BorderContainer(
              // #region collapsed
              child: Oito2Splitter(
                panes: [
                  Oito2SplitterPane(
                    minSize: 160,
                    collapsible: true,
                    collapsedSize: 32,
                    initiallyCollapsed: true,
                    child: _pane('Filters', scheme.surfaceContainer),
                  ),
                  Oito2SplitterPane(
                    minSize: 200,
                    child: _pane('Results', scheme.surface),
                  ),
                ],
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each divider is a slider for assistive technologies, labeled '
          '"Resize pane" by default or `resizeLabel`, with the share of the '
          'space of the pane before it as a percentage; raising or lowering '
          'it moves the divider by `keyboardStep`. A divider is highlighted '
          'while hovered and drawn thicker while focused.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next divider.'],
            [
              '`Left arrow` / `Right arrow`',
              'Moves a divider between side-by-side panes by `keyboardStep`, '
                  '16 pixels by default, in that direction on screen.',
            ],
            [
              '`Up arrow` / `Down arrow`',
              'Moves a divider between stacked panes by `keyboardStep`.',
            ],
            [
              '`Home`',
              'Shrinks the pane before the divider to its smallest size, as '
                  'far as the limits of both panes allow.',
            ],
            [
              '`End`',
              'Grows the pane before the divider as far as the limits of '
                  'both panes allow.',
            ],
            [
              '`Enter` / `Space`',
              'Collapses or restores the collapsible pane next to the '
                  'divider.',
            ],
          ],
        ),
        ...apiReferenceWidgets(['Oito2Splitter', 'Oito2SplitterPane']),
      ],
    );
  }
}
