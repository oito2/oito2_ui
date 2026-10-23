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

/// Shows [Oito2ScrollViewUndershoot] on a scrolling list.
class UndershootPage extends StatelessWidget {
  /// Creates the scroll view undershoot page.
  const UndershootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Scroll view undershoot',
          children: [
            SizedBox(
              width: 260,
              height: 200,
              child: Oito2BorderContainer(
                child: Oito2ScrollViewUndershoot(
                  child: ListView(
                    children: [
                      for (var i = 1; i <= 20; i++)
                        ListTile(dense: true, title: Text('Item $i')),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              'Shadows mark the edges where more content is hidden.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
