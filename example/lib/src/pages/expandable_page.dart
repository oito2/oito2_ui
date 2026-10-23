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

/// Shows [Oito2Expandable] with a collapsed summary.
class ExpandablePage extends StatelessWidget {
  /// Creates the expandable page.
  const ExpandablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Expandable',
          children: [
            SizedBox(
              width: 420,
              child: Oito2BorderContainer(
                padding: const EdgeInsets.all(Oito2Spacing.md),
                child: Oito2Expandable(
                  header: const Text('Advanced options'),
                  collapsedChild: Text(
                    '3 options hidden',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enable experimental features'),
                      Text('Send usage statistics'),
                      Text('Use legacy renderer'),
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
