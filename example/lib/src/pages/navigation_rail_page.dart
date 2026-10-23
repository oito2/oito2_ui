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

/// Documents [Oito2NavigationRail] in its three styles, with a trailing
/// widget; the width animates between the styles.
class NavigationRailPage extends StatefulWidget {
  /// Creates the navigation rail page.
  const NavigationRailPage({super.key});

  @override
  State<NavigationRailPage> createState() => _NavigationRailPageState();
}

class _NavigationRailPageState extends State<NavigationRailPage> {
  var _style = Oito2NavigationRailStyle.labelled;
  int _selected = 0;
  int _styled = 0;

  // #region items
  static const _items = [
    Oito2NavigationItem(icon: Icon(LucideIcons.inbox), label: 'Inbox'),
    Oito2NavigationItem(icon: Icon(LucideIcons.send), label: 'Sent'),
    Oito2NavigationItem(icon: Icon(LucideIcons.file_pen), label: 'Drafts'),
    Oito2NavigationItem(icon: Icon(LucideIcons.archive), label: 'Archive'),
    Oito2NavigationItem(icon: Icon(LucideIcons.trash), label: 'Trash'),
  ];
  // #endregion

  /// A bordered box with [rail] at the start and the name of the
  /// destination at [index] beside it.
  Widget _frame(BuildContext context, Widget rail, int index) => SizedBox(
    width: 520,
    height: 320,
    child: Oito2BorderContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          rail,
          const VerticalDivider(width: 1),
          Expanded(
            child: Center(
              child: Text(
                _items[index].label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Navigation Rail',
      description:
          'A vertical bar of destinations at the start side of a window, '
          'with icons only, labels below the icons or labels beside them.',
      source: 'lib/src/pages/navigation_rail_page.dart',
      children: [
        ExamplePanel(
          regions: const ['items', 'preview'],
          child: _frame(
            context,
            // #region preview
            Oito2NavigationRail(
              items: _items,
              selectedIndex: _selected,
              onDestinationSelected: (index) =>
                  setState(() => _selected = index),
              trailing: Oito2IconButton(
                icon: const Icon(LucideIcons.settings),
                tooltip: 'Settings',
                onPressed: () {},
              ),
            ),
            // #endregion
            _selected,
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'List the destinations as `Oito2NavigationItem`s. The rail is '
          'controlled: pass the `selectedIndex`, or -1 for none, and update '
          'it in `onDestinationSelected`. It fills the height it is given, '
          'so place it in a `Row` with `CrossAxisAlignment.stretch`, as '
          'here, or another bounded height.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For a whole window that switches between a bottom bar and a rail '
          'by width, use `Oito2NavigationPage`, which builds this rail.',
        ),
        const DocText(
          'The destinations scroll, with shadows at the edges, when they do '
          'not fit the height, and the selected one is scrolled into view. '
          '`leading` and `trailing` stay at the top and the bottom. The rail '
          'takes the chrome sidebar color unless `backgroundColor` is given.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Styles', level: 3),
        const DocText(
          '`style` picks an `Oito2NavigationRailStyle`: `compact` shows '
          'icons only, with the label as a tooltip, `labelled` adds a small '
          'label below each icon, and `labelledExtended` puts the label '
          'beside the icon in a wider rail. The width animates when the '
          'style changes, unless animations are disabled.',
        ),
        ExamplePanel(
          region: 'styles',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.md,
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
              _frame(
                context,
                // #region styles
                Oito2NavigationRail(
                  items: _items,
                  selectedIndex: _styled,
                  style: _style,
                  onDestinationSelected: (index) =>
                      setState(() => _styled = index),
                ),
                // #endregion
                _styled,
              ),
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each destination is a button named by its `label` and the '
          'selected one is reported as selected; the rail is one container '
          'for assistive technologies. The destinations show the focus '
          'ring when reached with the keyboard.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next destination.'],
            ['`Enter` / `Space`', 'Selects the focused destination.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2NavigationRail',
          'Oito2NavigationItem',
          'Oito2NavigationRailStyle',
          'Oito2NavigationRailItem',
        ]),
      ],
    );
  }
}
