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

/// Documents [Oito2DiagonalClip]: two clips combined into a split square,
/// and each of the four corners.
class DiagonalClipPage extends StatelessWidget {
  /// Creates the diagonal clip page.
  const DiagonalClipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DocPage(
      title: 'Diagonal Clip',
      description:
          'Clips content along a diagonal, keeping the triangle of one '
          'corner, for example to split a swatch between two themes.',
      source: 'lib/src/pages/diagonal_clip_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox.square(
            dimension: 160,
            child: Oito2BorderContainer(
              // #region preview
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Oito2DiagonalClip(
                    corner: Oito2DiagonalCorner.topLeft,
                    child: const ColoredBox(color: Color(0xFFFAFAFA)),
                  ),
                  Oito2DiagonalClip(
                    corner: Oito2DiagonalCorner.bottomRight,
                    child: const ColoredBox(color: Color(0xFF242424)),
                  ),
                ],
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2DiagonalClip` cuts its `child` along the diagonal between '
          'the two corners next to `corner`, and keeps the triangle on the '
          'side of `corner`. Stack two clips of opposite corners to split '
          'an area in two, as in the preview of a light and a dark theme.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'The corners are physical: `topLeft` stays at the top left in '
          'right-to-left layouts too.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Corners', level: 3),
        const DocText(
          'Each `Oito2DiagonalCorner` keeps a different half of the square.',
        ),
        ExamplePanel(
          region: 'corners',
          child: Wrap(
            spacing: Oito2Spacing.lg,
            runSpacing: Oito2Spacing.lg,
            children: [
              // #region corners
              for (final corner in Oito2DiagonalCorner.values)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Oito2Spacing.sm,
                  children: [
                    SizedBox.square(
                      dimension: 96,
                      child: Oito2BorderContainer(
                        color: scheme.surfaceContainerHigh,
                        child: Oito2DiagonalClip(
                          corner: corner,
                          child: ColoredBox(color: scheme.primary),
                        ),
                      ),
                    ),
                    Text(corner.name),
                  ],
                ),
              // #endregion
            ],
          ),
        ),
        ...apiReferenceWidgets(['Oito2DiagonalClip', 'Oito2DiagonalCorner']),
      ],
    );
  }
}
