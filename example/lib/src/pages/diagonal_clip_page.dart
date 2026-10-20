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

/// Shows [Oito2DiagonalClip] splitting a preview between two styles.
class DiagonalClipPage extends StatelessWidget {
  /// Creates the diagonal clip page.
  const DiagonalClipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Diagonal clip',
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
