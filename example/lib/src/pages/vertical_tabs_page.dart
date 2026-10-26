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

/// Documents [Oito2VerticalTabs] and [Oito2VerticalTabBar]: tabs in a
/// column beside their content, in both styles.
class VerticalTabsPage extends StatelessWidget {
  /// Creates the vertical tabs page.
  const VerticalTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Vertical Tabs',
      description:
          'A column of tabs beside the content of the selected one, with a '
          'rounded marker that slides between them.',
      source: 'lib/src/pages/vertical_tabs_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 520,
            height: 180,
            // #region preview
            child: DefaultTabController(
              length: 3,
              child: Oito2VerticalTabs(
                tabBarWidth: 180,
                tabs: const [
                  Oito2Tab(
                    icon: Icon(LucideIcons.settings),
                    label: Text('General'),
                  ),
                  Oito2Tab(
                    icon: Icon(LucideIcons.palette),
                    label: Text('Appearance'),
                  ),
                  Oito2Tab(icon: Icon(LucideIcons.info), label: Text('About')),
                ],
                children: [
                  for (final name in ['General', 'Appearance', 'About'])
                    Center(child: Text('$name settings')),
                ],
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'List the tabs as `Oito2Tab`s and the content of each tab in '
          '`children`, in the same order. Like `Oito2TabBar`, the tabs drive '
          'a `TabController`: the `controller` given, or the closest '
          '`DefaultTabController`. `tabBarWidth` sets the width of the tab '
          'column, which scrolls when the tabs do not fit its height, and '
          '`onTap` reports each selected tab.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'To lay the content out yourself, use `Oito2VerticalTabBar`, the '
          'tab column alone, and show the content of `controller.index` '
          'wherever it fits. Without a `controller` or a '
          '`DefaultTabController` above it, the bar throws in debug builds.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Subtle style', level: 3),
        const DocText(
          '`Oito2TabBarStyle.subtle` tints the selected tab with a faint '
          'accent fill and accent text instead of the pill.',
        ),
        ExamplePanel(
          region: 'subtle',
          child: SizedBox(
            width: 520,
            height: 180,
            // #region subtle
            child: DefaultTabController(
              length: 3,
              child: Oito2VerticalTabs(
                style: Oito2TabBarStyle.subtle,
                tabBarWidth: 160,
                tabs: const [
                  Oito2Tab(label: Text('Account')),
                  Oito2Tab(label: Text('Password')),
                  Oito2Tab(label: Text('Billing')),
                ],
                children: [
                  for (final name in ['Account', 'Password', 'Billing'])
                    Padding(
                      padding: const EdgeInsets.all(Oito2Spacing.md),
                      child: Text('$name details'),
                    ),
                ],
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The column has the tab bar role and each tab the tab role, with '
          'the selected one reported as selected; the content has the tab '
          'panel role. Only the selected tab is a stop in keyboard '
          'navigation, and the arrow keys move between the tabs.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Tab`',
              'Moves the focus to the selected tab, then past the tabs.',
            ],
            [
              '`Up arrow` / `Down arrow`',
              'Selects and focuses the previous or next tab.',
            ],
            ['`Home` / `End`', 'Selects and focuses the first or last tab.'],
            ['`Enter` / `Space`', 'Selects the focused tab.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2VerticalTabs', 'Oito2VerticalTabBar']),
      ],
    );
  }
}
