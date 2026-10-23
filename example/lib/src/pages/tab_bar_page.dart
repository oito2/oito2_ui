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

/// Shows [Oito2TabBar] with fixed and scrollable tabs, in both styles.
class TabBarPage extends StatelessWidget {
  /// Creates the tab bar page.
  const TabBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Tabs sharing the width',
          children: [
            SizedBox(
              width: 520,
              height: 160,
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const Oito2TabBar(
                      tabs: [
                        Oito2Tab(
                          icon: Icon(LucideIcons.settings),
                          label: Text('General'),
                        ),
                        Oito2Tab(
                          icon: Icon(LucideIcons.palette),
                          label: Text('Appearance'),
                        ),
                        Oito2Tab(
                          icon: Icon(LucideIcons.info),
                          label: Text('About'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          for (final name in ['General', 'Appearance', 'About'])
                            Center(child: Text('$name settings')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Scrollable tabs',
          children: [
            SizedBox(
              width: 360,
              child: DefaultTabController(
                length: 6,
                child: Oito2TabBar(
                  isScrollable: true,
                  tabs: [
                    for (final month in [
                      'January',
                      'February',
                      'March',
                      'April',
                      'May',
                      'June',
                    ])
                      Oito2Tab(label: Text(month)),
                  ],
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Subtle style: accent tint, tabs at the start',
          children: [
            SizedBox(
              width: 520,
              height: 160,
              child: DefaultTabController(
                length: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Oito2TabBar(
                      style: Oito2TabBarStyle.subtle,
                      tabs: [
                        Oito2Tab(label: Text('Account')),
                        Oito2Tab(label: Text('Password')),
                        Oito2Tab(label: Text('Billing')),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          for (final name in ['Account', 'Password', 'Billing'])
                            Padding(
                              padding: const EdgeInsets.all(Oito2Spacing.md),
                              child: Text('$name details'),
                            ),
                        ],
                      ),
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
