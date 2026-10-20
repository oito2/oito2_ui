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

/// Shows [Oito2NavigationRail] in its three styles; the width animates
/// between them.
class NavigationRailPage extends StatefulWidget {
  /// Creates the navigation rail page.
  const NavigationRailPage({super.key});

  @override
  State<NavigationRailPage> createState() => _NavigationRailPageState();
}

class _NavigationRailPageState extends State<NavigationRailPage> {
  var _style = Oito2NavigationRailStyle.labelled;
  int _selected = 0;

  static const _items = [
    Oito2NavigationItem(icon: Icon(LucideIcons.inbox), label: 'Inbox'),
    Oito2NavigationItem(icon: Icon(LucideIcons.send), label: 'Sent'),
    Oito2NavigationItem(icon: Icon(LucideIcons.file_pen), label: 'Drafts'),
    Oito2NavigationItem(icon: Icon(LucideIcons.archive), label: 'Archive'),
    Oito2NavigationItem(icon: Icon(LucideIcons.trash), label: 'Trash'),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Style',
          children: [
            SegmentedButton<Oito2NavigationRailStyle>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: Oito2NavigationRailStyle.compact,
                  label: Text('Compact'),
                ),
                ButtonSegment(
                  value: Oito2NavigationRailStyle.labelled,
                  label: Text('Labelled'),
                ),
                ButtonSegment(
                  value: Oito2NavigationRailStyle.labelledExtended,
                  label: Text('Extended'),
                ),
              ],
              selected: {_style},
              onSelectionChanged: (v) => setState(() => _style = v.single),
            ),
          ],
        ),
        ShowcaseSection(
          'Rail',
          children: [
            SizedBox(
              width: 560,
              height: 320,
              child: Oito2BorderContainer(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Oito2NavigationRail(
                      items: _items,
                      selectedIndex: _selected,
                      style: _style,
                      onDestinationSelected: (i) =>
                          setState(() => _selected = i),
                      trailing: Oito2IconButton(
                        icon: const Icon(LucideIcons.settings),
                        tooltip: 'Settings',
                        onPressed: () {},
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Center(
                        child: Text(
                          _items[_selected].label,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
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
