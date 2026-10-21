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
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2NavigationMenu] as a website header.
class NavigationMenuPage extends StatefulWidget {
  /// Creates the navigation menu page.
  const NavigationMenuPage({super.key});

  @override
  State<NavigationMenuPage> createState() => _NavigationMenuPageState();
}

class _NavigationMenuPageState extends State<NavigationMenuPage> {
  int _selected = 0;

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pages = ['Home', 'Components', 'Docs', 'Blog'];
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Hover or press the triggers; arrows, Down and Escape work too',
          children: [
            Container(
              width: 640,
              padding: const EdgeInsets.symmetric(
                horizontal: Oito2Spacing.md,
                vertical: Oito2Spacing.sm,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: Oito2Radius.mediumAll,
              ),
              child: Row(
                children: [
                  const Text('oito2'),
                  const Spacer(),
                  Oito2NavigationMenu(
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
                ],
              ),
            ),
            Text('Current page: ${pages[_selected]}'),
          ],
        ),
      ],
    );
  }
}
