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

import '../docs/doc_widgets.dart';

/// Documents [Oito2TabBar]: tabs sharing the width, scrollable tabs and
/// the subtle style.
class TabBarPage extends StatelessWidget {
  /// Creates the tab bar page.
  const TabBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Tab Bar',
      description:
          'A row of tabs with a rounded marker that slides to the selected '
          'one, for switching between views of the same content.',
      source: 'lib/src/pages/tab_bar_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 520,
            height: 160,
            // #region preview
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
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'List the tabs as `Oito2Tab`s, each with a `label` and an optional '
          '`icon`. Like Material\'s `TabBar`, the bar drives a '
          '`TabController`: the `controller` given, or the closest '
          '`DefaultTabController`, which a `TabBarView` can share to show '
          'the content of the selected tab. `onTap` reports each tapped '
          'tab.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'Without a `controller` or a `DefaultTabController` above it, the '
          'bar throws in debug builds. The bar is a `PreferredSizeWidget`, '
          'so it also fits the `bottom` of an app bar.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Scrollable', level: 3),
        const DocText(
          'By default the tabs share the bar width equally, and a label '
          'wider than its tab ends with an ellipsis. With `isScrollable`, '
          'the tabs keep their own width, start at the leading edge and '
          'scroll when they do not fit.',
        ),
        ExamplePanel(
          region: 'scrollable',
          child: SizedBox(
            width: 360,
            // #region scrollable
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
            // #endregion
          ),
        ),
        const DocHeading('Subtle style', level: 3),
        const DocText(
          '`Oito2TabBarStyle.subtle` tints the selected tab with a faint '
          'accent fill and accent text instead of the pill. Its tabs always '
          'keep their own width and start at the leading edge, whatever '
          '`isScrollable` says.',
        ),
        ExamplePanel(
          region: 'subtle',
          child: SizedBox(
            width: 520,
            height: 160,
            // #region subtle
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
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The bar is built on Material\'s `TabBar`, so it keeps its '
          'semantics: each tab has the tab role, is announced with its '
          'position outside the web, and the selected one is reported as '
          'selected.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next tab.'],
            ['`Enter` / `Space`', 'Selects the focused tab.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2TabBar', 'Oito2Tab', 'Oito2TabBarStyle']),
      ],
    );
  }
}
