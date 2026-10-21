// Copyright (C) 2026  oito2
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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2Splitter] with three panes, a collapsible one and nesting.
class SplitterPage extends StatelessWidget {
  /// Creates the splitter page.
  const SplitterPage({super.key});

  Widget _pane(BuildContext context, String label, Color color) => ColoredBox(
    color: color,
    child: Center(child: Text(label)),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Drag or focus a divider; arrows resize, Enter or a double click '
          'collapses the side panes',
          children: [
            Container(
              width: 640,
              height: 320,
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Oito2Splitter(
                panes: [
                  Oito2SplitterPane(
                    initialFraction: 0.25,
                    minSize: 120,
                    collapsible: true,
                    child: _pane(context, 'Sidebar', scheme.surfaceContainer),
                  ),
                  Oito2SplitterPane(
                    minSize: 200,
                    child: Oito2Splitter(
                      axis: Axis.vertical,
                      panes: [
                        Oito2SplitterPane(
                          child: _pane(context, 'Editor', scheme.surface),
                        ),
                        Oito2SplitterPane(
                          initialFraction: 0.3,
                          collapsible: true,
                          child: _pane(
                            context,
                            'Terminal',
                            scheme.surfaceContainerHigh,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Oito2SplitterPane(
                    initialFraction: 0.25,
                    minSize: 120,
                    maxSize: 260,
                    collapsible: true,
                    child: _pane(context, 'Outline', scheme.surfaceContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
