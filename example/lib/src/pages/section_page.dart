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

/// Shows [Oito2Section] with a headline, actions and a tile list.
class SectionPage extends StatelessWidget {
  /// Creates the section page.
  const SectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Section',
          children: [
            SizedBox(
              width: 520,
              child: Oito2Section(
                headline: const Text('Storage'),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('Clean up')),
                ],
                child: const Text(
                  'A section groups related content under a headline, with '
                  'optional actions beside it.',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
