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

/// Shows [Oito2ExpansionPanel] as an accordion and with independent
/// sections.
class ExpansionPanelPage extends StatelessWidget {
  /// Creates the expansion panel page.
  const ExpansionPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    const headers = [
      Text('What is oito2_ui?'),
      Text('Which platforms does it support?'),
      Text('Is it free software?'),
    ];
    const answers = [
      Text('A Material 3 design system for the oito2 Flutter apps.'),
      Text('Linux desktops, Windows, macOS, Android, iOS and the web.'),
      Text('Yes, under the GNU GPL version 3 or later.'),
    ];
    return const ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Accordion: one section open at a time',
          children: [
            SizedBox(
              width: 480,
              child: Oito2ExpansionPanel(
                initiallyExpanded: {0},
                headers: headers,
                children: answers,
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Independent sections',
          children: [
            SizedBox(
              width: 480,
              child: Oito2ExpansionPanel(
                collapseOnExpand: false,
                headers: headers,
                children: answers,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
