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

/// Shows [Oito2ScrollArea] scrolling up and down, across and both ways.
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
    Widget frame(double width, double height, Widget child) =>
        Oito2BorderContainer(width: width, height: height, child: child);
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Up and down, with the undershoot shadow',
          children: [
            frame(
              280,
              180,
              const Oito2ScrollArea(
                undershoot: true,
                padding: EdgeInsets.all(Oito2Spacing.md),
                child: Text('$_text\n\n$_text'),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Across, bars always shown',
          children: [
            frame(
              280,
              80,
              Oito2ScrollArea(
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
            ),
          ],
        ),
        ShowcaseSection(
          'Both ways',
          children: [
            frame(
              280,
              200,
              Oito2ScrollArea(
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
            ),
          ],
        ),
      ],
    );
  }
}
