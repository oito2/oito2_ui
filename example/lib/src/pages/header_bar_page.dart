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
import '../widgets/preview_window_controller.dart';

const _fruits = [
  'Apple',
  'Apricot',
  'Banana',
  'Blueberry',
  'Cherry',
  'Grape',
  'Mango',
  'Orange',
  'Peach',
  'Pear',
];

/// Documents [Oito2HeaderBar]: a title with buttons and a menu, tabs, and
/// the search that replaces the title.
class HeaderBarPage extends StatefulWidget {
  /// Creates the header bar page.
  const HeaderBarPage({super.key});

  @override
  State<HeaderBarPage> createState() => _HeaderBarPageState();
}

class _HeaderBarPageState extends State<HeaderBarPage> {
  final _preview = PreviewWindowController();
  String _query = '';
  String _last = 'Nothing yet';

  @override
  void dispose() {
    _preview.dispose();
    super.dispose();
  }

  /// A small window: [bar] over [body], in a frame up to 560 pixels wide.
  Widget _window(PreferredSizeWidget bar, Widget body) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 560),
    child: Oito2BorderContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: bar.preferredSize.height, child: bar),
          SizedBox(height: 140, child: body),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final matches = [
      for (final fruit in _fruits)
        if (fruit.toLowerCase().contains(_query.toLowerCase())) fruit,
    ];
    return DocPage(
      title: 'Header Bar',
      description:
          'The window title bar with the app\'s controls in it: buttons and '
          'menus at both ends, a title or tabs in the middle, and a search '
          'that takes the title\'s place.',
      source: 'lib/src/pages/header_bar_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: _window(
            // #region preview
            Oito2HeaderBar(
              controller: _preview,
              title: const Text('Documents'),
              start: [
                Oito2IconButton(
                  tooltip: 'Back',
                  icon: const Icon(LucideIcons.arrow_left),
                  onPressed: () => setState(() => _last = 'Back'),
                ),
              ],
              end: [
                Oito2IconButton(
                  tooltip: 'New folder',
                  icon: const Icon(LucideIcons.folder_plus),
                  onPressed: () => setState(() => _last = 'New folder'),
                ),
              ],
              search: const Oito2HeaderBarSearch(),
              menuChildren: [
                MenuItemButton(
                  onPressed: () => setState(() => _last = 'Preferences'),
                  child: const Text('Preferences'),
                ),
                MenuItemButton(
                  onPressed: () => setState(() => _last = 'About'),
                  child: const Text('About Documents'),
                ),
              ],
            ),
            // #endregion
            Center(child: Text('Last action: $_last')),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Use `Oito2HeaderBar` as the `appBar` of the window\'s `Scaffold`. '
          'It is an `Oito2WindowTitleBar`, so it shows the system window '
          'controls, moves the window when dragged and maximizes it on '
          'double click. `start` widgets sit after the leading window '
          'buttons and `end` widgets before the trailing ones.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocCode('''Scaffold(
  appBar: Oito2HeaderBar(
    title: const Text('Documents'),
    end: [newFolderButton],
    menuChildren: [preferencesItem, aboutItem],
  ),
  body: content,
)'''),
        const DocNote(
          'The previews on this page use a window controller of their own, '
          'so their window buttons don\'t affect this window.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Tabs', level: 3),
        const DocText(
          '`tabs` puts an `Oito2TabBar` in the middle in place of the title. '
          'It drives the closest `DefaultTabController`, or `tabController`, '
          'which a `TabBarView` in the body shares. The tabs stay centered, '
          '`tabWidth` wide each.',
        ),
        ExamplePanel(
          region: 'tabs',
          child: DefaultTabController(
            length: 3,
            child: _window(
              // #region tabs
              Oito2HeaderBar(
                controller: _preview,
                tabs: const [
                  Oito2Tab(
                    icon: Icon(LucideIcons.headphones),
                    label: Text('Albums'),
                  ),
                  Oito2Tab(
                    icon: Icon(LucideIcons.users),
                    label: Text('Artists'),
                  ),
                  Oito2Tab(
                    icon: Icon(LucideIcons.list_music),
                    label: Text('Playlists'),
                  ),
                ],
              ),
              // #endregion
              const TabBarView(
                children: [
                  Center(child: Text('Albums')),
                  Center(child: Text('Artists')),
                  Center(child: Text('Playlists')),
                ],
              ),
            ),
          ),
        ),
        const DocHeading('Subtle tabs', level: 3),
        const DocText(
          '`tabStyle: Oito2TabBarStyle.subtle` draws the tabs with an accent '
          'tint instead of a pill.',
        ),
        ExamplePanel(
          region: 'subtle',
          child: DefaultTabController(
            length: 2,
            child: _window(
              // #region subtle
              Oito2HeaderBar(
                controller: _preview,
                tabStyle: Oito2TabBarStyle.subtle,
                tabs: const [
                  Oito2Tab(label: Text('Inbox')),
                  Oito2Tab(label: Text('Archive')),
                ],
              ),
              // #endregion
              const TabBarView(
                children: [
                  Center(child: Text('Inbox')),
                  Center(child: Text('Archive')),
                ],
              ),
            ),
          ),
        ),
        const DocHeading('Search', level: 3),
        const DocText(
          'With `search`, a search button joins the end widgets. While the '
          'search is open, a search field takes the place of the title or '
          'the tabs and gets the focus; Escape clears it and, on an empty '
          'field, closes the search, giving the focus back to the button. '
          '`Oito2HeaderBarSearch` reports the text through `onChanged` and '
          '`onSubmitted`.',
        ),
        ExamplePanel(
          region: 'search',
          child: _window(
            // #region search
            Oito2HeaderBar(
              controller: _preview,
              title: const Text('Fruits'),
              search: Oito2HeaderBarSearch(
                hintText: 'Search fruits',
                onChanged: (text) => setState(() => _query = text),
              ),
              onSearchActiveChanged: (active) {
                if (!active) setState(() => _query = '');
              },
            ),
            // #endregion
            ListView(
              children: [
                for (final fruit in matches)
                  ListTile(dense: true, title: Text(fruit)),
              ],
            ),
          ),
        ),
        const DocText(
          'The bar keeps the search state itself. To open or close it from '
          'elsewhere, such as a Control+F shortcut, pass `searchActive` and '
          'update it in `onSearchActiveChanged`.',
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The search and menu buttons are labeled by their tooltips, '
          '"Search" and "Main menu" by default, and report whether the '
          'search or the menu is open. A plain title lets the window move '
          'from it; tabs and the search field take clicks instead.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus through the bar\'s buttons and tabs.'],
            [
              '`Enter` / `Space` on the search button',
              'Opens or closes the search.',
            ],
            [
              '`Escape` in the search field',
              'Clears the text; on an empty field, closes the search.',
            ],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2HeaderBar',
          'Oito2HeaderBarSearch',
          'Oito2WindowTitleBar',
        ]),
      ],
    );
  }
}
