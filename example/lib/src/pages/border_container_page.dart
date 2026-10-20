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

/// Shows [Oito2BorderContainer] with its default and custom colors.
class BorderContainerPage extends StatelessWidget {
  /// Creates the border container page.
  const BorderContainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Border containers',
          children: [
            const Oito2BorderContainer(
              width: 200,
              height: 120,
              padding: EdgeInsets.all(Oito2Spacing.md),
              child: Text('Default surface'),
            ),
            Oito2BorderContainer(
              width: 200,
              height: 120,
              padding: const EdgeInsets.all(Oito2Spacing.md),
              color: scheme.surfaceContainerHigh,
              child: const Text('surfaceContainerHigh'),
            ),
          ],
        ),
      ],
    );
  }
}
