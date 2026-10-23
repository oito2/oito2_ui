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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2Marquee] horizontal, reversed and vertical.
class MarqueePage extends StatelessWidget {
  /// Creates the marquee page.
  const MarqueePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget frame(Widget child, {double width = 360, double? height}) =>
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(vertical: Oito2Spacing.sm),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: Oito2Radius.mediumAll,
          ),
          child: child,
        );
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Hover or focus to pause; still when animations are off',
          children: [
            frame(
              const Oito2Marquee(
                child: Text(
                  'oito2_ui 0.1.0 · Linux, Windows, macOS, Android, iOS and '
                  'web · GPL-3.0 · Inter and Lucide icons',
                ),
              ),
            ),
            frame(
              Oito2Marquee(
                reverse: true,
                speed: 60,
                child: Row(
                  spacing: Oito2Spacing.lg,
                  children: [
                    for (final icon in [
                      LucideIcons.monitor,
                      LucideIcons.smartphone,
                      LucideIcons.tablet,
                      LucideIcons.globe,
                      LucideIcons.laptop,
                      LucideIcons.tv,
                      LucideIcons.watch,
                      LucideIcons.server,
                      LucideIcons.cpu,
                      LucideIcons.hard_drive,
                    ])
                      Icon(icon),
                  ],
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Vertical',
          children: [
            frame(
              width: 220,
              height: 96,
              const Oito2Marquee(
                axis: Axis.vertical,
                speed: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Build 128 passed'),
                    Text('Deploy to Pages done'),
                    Text('3 new issues'),
                    Text('Release 0.1.0 tagged'),
                    Text('Goldens updated'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
