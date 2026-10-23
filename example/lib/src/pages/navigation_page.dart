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
import '../widgets/showcase_widgets.dart';

// #region items
const _items = [
  Oito2NavigationItem(icon: Icon(LucideIcons.house), label: 'Home'),
  Oito2NavigationItem(icon: Icon(LucideIcons.library), label: 'Library'),
  Oito2NavigationItem(icon: Icon(LucideIcons.settings), label: 'Settings'),
];
// #endregion

/// Documents [Oito2NavigationPage]: the adaptive layout, a forced rail
/// style and a controller.
class NavigationPage extends StatefulWidget {
  /// Creates the navigation page.
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // #region controller-data
  final _controller = Oito2PageController(length: 3, initialIndex: 0);
  // #endregion

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The page of the destination at [index]: its name, centered.
  Widget _page(BuildContext context, int index) => Center(
    child: Text(
      _items[index].label,
      style: Theme.of(context).textTheme.headlineSmall,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Navigation Page',
      description:
          'Top-level navigation between pages that turns from a bottom bar '
          'into a rail, and then an extended rail, as the window widens.',
      source: 'lib/src/pages/navigation_page.dart',
      children: [
        ExamplePanel(
          regions: const ['items', 'preview'],
          child: ShowcaseFrame(
            // #region preview
            child: Oito2NavigationPage(
              items: _items,
              compactBreakpoint: 560,
              extendedBreakpoint: 820,
              pageBuilder: (context, index) => _page(context, index),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'List the destinations as `Oito2NavigationItem`s, each with an '
          '`icon` and a `label`, and build the page of each one in '
          '`pageBuilder`. The view keeps the selected destination itself, '
          'starting at `initialIndex`, and reports the user\'s choices to '
          '`onSelected`; the page fades in when it changes.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The layout follows the width of the view. On pointer platforms '
          'the destinations are an `Oito2NavigationRail`: icons only below '
          '`compactBreakpoint`, icons with labels below them up to '
          '`extendedBreakpoint`, and labels beside the icons from it. On '
          'touch platforms, below `compactBreakpoint`, they are a bottom '
          '`NavigationBar` instead. Resize the frame above to see the rail '
          'change.',
        ),
        const DocNote(
          'The breakpoints default to the theme\'s '
          '`Oito2NavigationPageThemeData`, then to 600 pixels for '
          '`compactBreakpoint`; without an `extendedBreakpoint` the rail '
          'never extends. The same theme sets the rail color and padding '
          'and the separator beside the rail.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Fixed rail style', level: 3),
        const DocText(
          '`railStyle` forces one `Oito2NavigationRailStyle` whatever the '
          'width, and also keeps the rail on touch platforms. `leading` and '
          '`trailing` sit above and below the destinations.',
        ),
        ExamplePanel(
          region: 'rail-style',
          child: SizedBox(
            width: 520,
            height: 300,
            child: Oito2BorderContainer(
              // #region rail-style
              child: Oito2NavigationPage(
                items: _items,
                railStyle: Oito2NavigationRailStyle.compact,
                leading: const Padding(
                  padding: EdgeInsets.only(bottom: Oito2Spacing.sm),
                  child: Icon(LucideIcons.book_open),
                ),
                trailing: Oito2IconButton(
                  icon: const Icon(LucideIcons.info),
                  tooltip: 'About',
                  onPressed: () {},
                ),
                pageBuilder: (context, index) => _page(context, index),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Controller', level: 3),
        const DocText(
          'An `Oito2PageController` selects a destination from outside the '
          'view, such as from a link inside a page. Its `length` must match '
          'the number of items.',
        ),
        ExamplePanel(
          regions: const ['controller-data', 'controller'],
          child: SizedBox(
            width: 520,
            height: 300,
            child: Oito2BorderContainer(
              // #region controller
              child: Oito2NavigationPage(
                items: _items,
                controller: _controller,
                railStyle: Oito2NavigationRailStyle.labelled,
                pageBuilder: (context, index) => Center(
                  child: index == 2
                      ? Text(_items[index].label)
                      : OutlinedButton(
                          onPressed: () => _controller.index = 2,
                          child: const Text('Open settings'),
                        ),
                ),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each rail destination is a button named by its `label`, and the '
          'selected one is reported as selected. In the compact rail the '
          'label shows as a tooltip, or `tooltip` when given. The '
          'destinations show the focus ring when reached with the keyboard.',
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
          'Oito2NavigationPage',
          'Oito2NavigationItem',
          'Oito2PageController',
          'Oito2NavigationPageThemeData',
        ]),
      ],
    );
  }
}
