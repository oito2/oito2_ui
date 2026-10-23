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

/// Shows [Oito2PanedView] with a pane you can resize by pointer or
/// keyboard.
class PanedViewPage extends StatelessWidget {
  /// Creates the paned view page.
  const PanedViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Paned view',
          children: [
            ShowcaseFrame(
              child: Oito2PanedView(
                initialPaneSize: 240,
                minPaneSize: 160,
                minPageSize: 160,
                pane: Material(
                  color: Oito2ChromeColors.maybeOf(context)?.mainbar,
                  child: const Center(
                    child: Text('Pane · drag or focus the divider'),
                  ),
                ),
                page: const Center(child: Text('Page')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
