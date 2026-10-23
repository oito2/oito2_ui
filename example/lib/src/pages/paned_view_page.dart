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
import '../widgets/showcase_widgets.dart';

/// Documents [Oito2PanedView]: pane sides, stacking, limits, a fixed
/// divider and size reports.
class PanedViewPage extends StatefulWidget {
  /// Creates the paned view page.
  const PanedViewPage({super.key});

  @override
  State<PanedViewPage> createState() => _PanedViewPageState();
}

class _PanedViewPageState extends State<PanedViewPage> {
  double _paneSize = 200;

  @override
  Widget build(BuildContext context) {
    final mainbar = Oito2ChromeColors.maybeOf(context)?.mainbar;
    return DocPage(
      title: 'Paned View',
      description:
          'Splits an area between a side pane and a page, with a divider '
          'that resizes the pane by pointer, keyboard or assistive '
          'technologies.',
      source: 'lib/src/pages/paned_view_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 520,
            height: 240,
            child: Oito2BorderContainer(
              // #region preview
              child: Oito2PanedView(
                initialPaneSize: 200,
                minPaneSize: 120,
                minPageSize: 160,
                pane: Material(
                  color: mainbar,
                  child: const Center(child: Text('Pane')),
                ),
                page: const Center(child: Text('Page')),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2PanedView` a `pane` and a `page`. The pane starts '
          '`initialPaneSize` pixels wide, or tall when stacked, and the page '
          'takes the rest. The view keeps its own pane size; '
          '`onPaneSizeChanged` reports it while it is resized. Place it '
          'where its size is bounded, such as the body of a window.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For one resizable side pane, use a paned view. For three or more '
          'panes, nested panes or collapsible panes, use `Oito2Splitter`. '
          '`Oito2MasterDetailPage` builds on a paned view for list and '
          'detail layouts.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Pane at the end', level: 3),
        const DocText(
          '`paneSide` places the pane. `Oito2PaneSide.start` and `end` '
          'follow the text direction: the end is on the right in '
          'left-to-right layouts and on the left in right-to-left ones.',
        ),
        ExamplePanel(
          region: 'end',
          child: SizedBox(
            width: 520,
            height: 240,
            child: Oito2BorderContainer(
              // #region end
              child: Oito2PanedView(
                paneSide: Oito2PaneSide.end,
                initialPaneSize: 180,
                minPaneSize: 120,
                minPageSize: 160,
                pane: const Center(child: Text('Details')),
                page: const Center(child: Text('Page')),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Stacked', level: 3),
        const DocText(
          'With `Oito2PaneSide.top` or `bottom`, the pane and the page are '
          'stacked and the sizes are heights.',
        ),
        ExamplePanel(
          region: 'stacked',
          child: SizedBox(
            width: 420,
            height: 280,
            child: Oito2BorderContainer(
              // #region stacked
              child: Oito2PanedView(
                paneSide: Oito2PaneSide.bottom,
                initialPaneSize: 100,
                minPaneSize: 60,
                minPageSize: 100,
                pane: const Center(child: Text('Terminal')),
                page: const Center(child: Text('Editor')),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Size limits', level: 3),
        const DocText(
          'The pane never shrinks below `minPaneSize` and never leaves less '
          'than `minPageSize` for the page. Narrow the frame below and the '
          'pane gives way to keep the page size. When even the smallest '
          'pane does not fit, the pane keeps its minimum and the end of the '
          'view is clipped instead of overflowing.',
        ),
        ExamplePanel(
          region: 'limits',
          child: ShowcaseFrame(
            height: 260,
            // #region limits
            child: Oito2PanedView(
              initialPaneSize: 240,
              minPaneSize: 160,
              minPageSize: 160,
              pane: Material(
                color: mainbar,
                child: const Center(child: Text('Pane · drag the divider')),
              ),
              page: const Center(child: Text('Page')),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Fixed pane', level: 3),
        const DocText(
          'With `resizable: false`, the divider is a plain line that cannot '
          'be dragged or focused.',
        ),
        const ExamplePanel(
          region: 'fixed',
          child: SizedBox(
            width: 520,
            height: 200,
            child: Oito2BorderContainer(
              // #region fixed
              child: Oito2PanedView(
                resizable: false,
                initialPaneSize: 160,
                minPaneSize: 120,
                minPageSize: 160,
                pane: Center(child: Text('Pane')),
                page: Center(child: Text('Page')),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Reacting to resizes', level: 3),
        const DocText(
          '`onPaneSizeChanged` receives the new pane size each time it '
          'changes, for example to save it and restore it later through '
          '`initialPaneSize`. `keyboardStep` sets how far one arrow key '
          'press moves the divider, 16 pixels by default.',
        ),
        ExamplePanel(
          region: 'callback',
          child: SizedBox(
            width: 520,
            height: 200,
            child: Oito2BorderContainer(
              // #region callback
              child: Oito2PanedView(
                initialPaneSize: 200,
                minPaneSize: 120,
                minPageSize: 160,
                keyboardStep: 40,
                onPaneSizeChanged: (size) => setState(() => _paneSize = size),
                pane: Center(child: Text('${_paneSize.round()} px')),
                page: const Center(child: Text('Page')),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'A resizable divider is a slider for assistive technologies, '
          'labeled "Resize pane" by default or `resizeLabel`, with the pane '
          'size in pixels as its value; raising or lowering it grows or '
          'shrinks the pane by `keyboardStep`. The divider is highlighted '
          'while hovered and drawn thicker while focused.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the divider.'],
            [
              '`Left arrow` / `Right arrow`',
              'Moves a side-by-side divider by `keyboardStep` in that '
                  'direction on screen.',
            ],
            [
              '`Up arrow` / `Down arrow`',
              'Moves a stacked divider by `keyboardStep` in that direction.',
            ],
          ],
        ),
        ...apiReferenceWidgets(['Oito2PanedView', 'Oito2PaneSide']),
      ],
    );
  }
}
