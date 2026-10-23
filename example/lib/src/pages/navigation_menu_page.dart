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
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2NavigationMenu] and [Oito2NavigationMenuItem]: links,
/// flyout panels and the line under the current page.
class NavigationMenuPage extends StatefulWidget {
  /// Creates the navigation menu page.
  const NavigationMenuPage({super.key});

  @override
  State<NavigationMenuPage> createState() => _NavigationMenuPageState();
}

class _NavigationMenuPageState extends State<NavigationMenuPage> {
  int _selected = 0;
  int _section = 0;

  // #region links
  /// A menu panel of [links], each a title with a short description.
  Widget _links(List<(String, String)> links) => SizedBox(
    width: 420,
    child: Wrap(
      spacing: Oito2Spacing.lg,
      runSpacing: Oito2Spacing.md,
      children: [
        for (final (title, text) in links)
          SizedBox(
            width: 190,
            child: Oito2ListTile(
              title: Text(title),
              subtitle: Text(text),
              onTap: () {},
            ),
          ),
      ],
    ),
  );
  // #endregion

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const pages = ['Home', 'Components', 'Docs', 'Blog'];
    const sections = ['Overview', 'Pricing', 'Changelog'];
    return DocPage(
      title: 'Navigation Menu',
      description:
          'A website-style header menu of links and triggers that open '
          'flyout panels, with a line under the current page.',
      source: 'lib/src/pages/navigation_menu_page.dart',
      children: [
        ExamplePanel(
          regions: const ['preview', 'links'],
          child: SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Oito2Spacing.md,
                    vertical: Oito2Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: Oito2Radius.mediumAll,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // #region preview
                    child: Oito2NavigationMenu(
                      selectedIndex: _selected,
                      semanticLabel: 'Main',
                      items: [
                        Oito2NavigationMenuItem(
                          label: 'Home',
                          onPressed: () => setState(() => _selected = 0),
                        ),
                        Oito2NavigationMenuItem(
                          label: 'Components',
                          panelBuilder: (_) => _links(const [
                            ('Inputs', 'Fields, pickers and toggles'),
                            ('Overlays', 'Popovers, sheets and toasts'),
                            ('Data', 'Trees, lists and pagination'),
                            ('Window', 'Title bars and controls'),
                          ]),
                        ),
                        Oito2NavigationMenuItem(
                          label: 'Docs',
                          panelBuilder: (_) => _links(const [
                            ('Getting started', 'Install and theme'),
                            ('Accessibility', 'Keyboard and screen readers'),
                          ]),
                        ),
                        Oito2NavigationMenuItem(
                          label: 'Blog',
                          onPressed: () => setState(() => _selected = 3),
                        ),
                      ],
                    ),
                    // #endregion
                  ),
                ),
                Text('Current page: ${pages[_selected]}'),
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give the menu its `items`, in order. An `Oito2NavigationMenuItem` '
          'with `onPressed` is a link; one with `panelBuilder` is a trigger '
          'that opens the panel it builds below it; an item with neither is '
          'disabled. `selectedIndex` marks the current page with the accent '
          'color and a line that slides under it; null marks none.',
        ),
        const DocCode("import 'package:oito2_ui_extras/oito2_ui_extras.dart';"),
        const DocText(
          'A panel opens when its trigger is pressed, or on hover after '
          '`hoverDelay` (150 milliseconds by default); while a panel is '
          'open, hovering another trigger switches to its panel at once. '
          'The panel closes shortly after the pointer leaves both the '
          'trigger and the panel, on a tap outside, or on Escape. Panels '
          'are at most `panelMaxWidth` pixels wide, 560 by default.',
        ),
        const DocNote(
          'The menu lays its items out in one row at their natural width, '
          'so in narrow layouts place it in a horizontal scroll view, as '
          'here, or switch to a drawer or a menu button.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Links only', level: 3),
        const DocText(
          'Without panels the menu is a row of links with the sliding line '
          'under the selected one, such as the sections of a page.',
        ),
        ExamplePanel(
          region: 'links-only',
          child: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // #region links-only
              child: Oito2NavigationMenu(
                selectedIndex: _section,
                semanticLabel: 'Sections',
                items: [
                  for (var i = 0; i < sections.length; i++)
                    Oito2NavigationMenuItem(
                      label: sections[i],
                      onPressed: () => setState(() => _section = i),
                    ),
                ],
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The menu is a container labeled by `semanticLabel`. The item that '
          'marks the current page is reported as selected, and each trigger '
          'as expanded or collapsed. An open panel is labeled by its '
          'trigger\'s label. When a panel opens from the keyboard or a '
          'press, its first focusable widget takes the focus, and closing it '
          'with the focus inside returns the focus to where it was. The line under the selected item '
          'and the trigger chevron don\'t animate when the platform asks to '
          'reduce motion.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next item or panel content.'],
            [
              '`Enter` / `Space`',
              'Follows a link, or opens or closes the panel of a trigger.',
            ],
            ['`Down arrow`', 'Opens the panel of the focused trigger.'],
            ['`Escape`', 'Closes the open panel.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2NavigationMenu',
          'Oito2NavigationMenuItem',
        ]),
      ],
    );
  }
}
