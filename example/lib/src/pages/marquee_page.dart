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

/// Documents [Oito2Marquee] horizontal, reversed, vertical and without
/// faded edges.
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
    return DocPage(
      title: 'Marquee',
      description:
          'Scrolls content that is longer than its space continuously, '
          'such as a news ticker or a long song title.',
      source: 'lib/src/pages/marquee_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: frame(
            // #region preview
            const Oito2Marquee(
              child: Text(
                'oito2_ui 0.1.0 · Linux, Windows, macOS, Android, iOS and '
                'web · GPL-3.0 · Inter and Lucide icons',
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Wrap the content in `Oito2Marquee`. When the content is longer '
          'than the space it has, it moves toward the start at `speed` '
          'pixels per second, 40 by default, followed by a copy after '
          '`gap` pixels; content that fits stays still. The marquee pauses '
          'while the pointer is over it or the focus is inside it, and '
          'stays at its start when animations are disabled.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'While it scrolls, the child is built twice, so it must not hold '
          'a `GlobalKey` and each copy keeps its own state. Plain content, '
          'such as text or icons, fits best.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Reversed and faster', level: 3),
        const DocText(
          '`reverse` moves the content toward the end instead, and `speed` '
          'sets how fast.',
        ),
        ExamplePanel(
          region: 'reverse',
          child: frame(
            // #region reverse
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
            // #endregion
          ),
        ),
        const DocHeading('Vertical', level: 3),
        const DocText(
          'With `axis: Axis.vertical` the content moves up, or down when '
          'reversed. Give the marquee a bounded height.',
        ),
        ExamplePanel(
          region: 'vertical',
          child: frame(
            width: 220,
            height: 96,
            // #region vertical
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
            // #endregion
          ),
        ),
        const DocHeading('Edges and pausing', level: 3),
        const DocText(
          'By default the content fades over `fadeExtent` pixels, 24, at '
          'both ends; `fadeEdges: false` cuts it sharply instead. '
          '`pauseOnHover: false` keeps it moving under the pointer and the '
          'focus.',
        ),
        ExamplePanel(
          region: 'edges',
          child: frame(
            // #region edges
            const Oito2Marquee(
              fadeEdges: false,
              pauseOnHover: false,
              gap: 64,
              child: Text(
                'Breaking: a marquee without faded edges keeps moving even '
                'under the pointer.',
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read the content once, not its moving '
          'copy. Since the motion pauses under the pointer and stops when '
          'animations are disabled, keep `pauseOnHover` on for content '
          'people need to read.',
        ),
        ...apiReferenceWidgets(['Oito2Marquee']),
      ],
    );
  }
}
