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

/// Shows [Oito2DiagonalClip] cutting each of the four corners, and two
/// clips combined into a split square.
class DiagonalClipPage extends StatelessWidget {
  /// Creates the diagonal clip page.
  const DiagonalClipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget sample(Oito2DiagonalCorner corner) => Column(
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
    );
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Corners',
          children: [
            for (final corner in Oito2DiagonalCorner.values) sample(corner),
          ],
        ),
        ShowcaseSection(
          'Two clips combined',
          children: [
            SizedBox.square(
              dimension: 160,
              child: Oito2BorderContainer(
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
              ),
            ),
          ],
        ),
      ],
    );
  }
}
