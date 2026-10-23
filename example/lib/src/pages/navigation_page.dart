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

/// Shows [Oito2NavigationPage] in a frame you can resize: a bottom bar
/// when narrow, a rail when wide and an extended rail when wider.
class NavigationPage extends StatelessWidget {
  /// Creates the navigation page.
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Library', 'Settings'];
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Adaptive navigation',
          children: [
            ShowcaseFrame(
              child: Oito2NavigationPage(
                compactBreakpoint: 560,
                extendedBreakpoint: 820,
                items: const [
                  Oito2NavigationItem(
                    icon: Icon(LucideIcons.house),
                    label: 'Home',
                  ),
                  Oito2NavigationItem(
                    icon: Icon(LucideIcons.library),
                    label: 'Library',
                  ),
                  Oito2NavigationItem(
                    icon: Icon(LucideIcons.settings),
                    label: 'Settings',
                  ),
                ],
                pageBuilder: (context, index) => Center(
                  child: Text(
                    labels[index],
                    style: Theme.of(context).textTheme.headlineSmall,
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
