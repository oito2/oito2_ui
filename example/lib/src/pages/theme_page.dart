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

import 'theme_colors_view.dart';
import 'theme_containers_view.dart';
import 'theme_controls_view.dart';
import 'theme_fonts_view.dart';
import 'theme_home_view.dart';
import 'theme_text_fields_view.dart';
import 'theme_tokens_view.dart';

/// A section of the Material theme page.
typedef _Section = ({
  String label,
  IconData icon,
  int badge,
  Widget Function(Oito2ColorTheme colors) builder,
});

final List<_Section> _sections = [
  (
    label: 'Home',
    icon: LucideIcons.house,
    badge: 3,
    builder: (_) => const ThemeHomeView(),
  ),
  (
    label: 'Colors',
    icon: LucideIcons.palette,
    badge: 0,
    builder: (colors) => ThemeColorsView(colors: colors),
  ),
  (
    label: 'Controls',
    icon: LucideIcons.toggle_right,
    badge: 0,
    builder: (_) => const ThemeControlsView(),
  ),
  (
    label: 'Text fields',
    icon: LucideIcons.text_cursor_input,
    badge: 0,
    builder: (_) => const ThemeTextFieldsView(),
  ),
  (
    label: 'Containers',
    icon: LucideIcons.app_window,
    badge: -1,
    builder: (_) => const ThemeContainersView(),
  ),
  (
    label: 'Fonts',
    icon: LucideIcons.type,
    badge: 0,
    builder: (_) => const ThemeFontsView(),
  ),
  (
    label: 'Tokens',
    icon: LucideIcons.ruler,
    badge: 0,
    builder: (_) => const ThemeTokensView(),
  ),
];

/// Shows the active theme on a sample Material app: an app bar, a
/// drawer, a navigation rail (a navigation bar when narrow), a floating
/// action button and badges around the Home, Colors, Controls, Text
/// fields, Containers, Fonts and Tokens sections.
class ThemePage extends StatefulWidget {
  /// Creates the Material theme page for [colors].
  const ThemePage({super.key, required this.colors});

  /// The active scheme, shown by the Colors section.
  final Oito2ColorTheme colors;

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  final _scaffold = GlobalKey<ScaffoldState>();
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  Widget _icon(_Section section) {
    final icon = Icon(section.icon);
    return switch (section.badge) {
      0 => icon,
      < 0 => Badge(child: icon),
      final count => Badge(label: Text('$count'), child: icon),
    };
  }

  @override
  Widget build(BuildContext context) {
    final section = _sections[_index];
    // A messenger of its own keeps the sample's snack bars and banners
    // inside the sample.
    return ScaffoldMessenger(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final body = KeyedSubtree(
            key: ValueKey(_index),
            child: section.builder(widget.colors),
          );
          return Scaffold(
            key: _scaffold,
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Menu',
                onPressed: () => _scaffold.currentState?.openDrawer(),
                icon: const Icon(LucideIcons.menu),
              ),
              title: Text(section.label),
              actions: [
                IconButton(
                  tooltip: 'Search',
                  onPressed: () {},
                  icon: const Icon(LucideIcons.search),
                ),
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () {},
                  icon: const Badge(
                    label: Text('5'),
                    child: Icon(LucideIcons.bell),
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: const EdgeInsets.all(Oito2Spacing.sm),
                children: [
                  DrawerHeader(
                    child: Align(
                      alignment: AlignmentDirectional.bottomStart,
                      child: Text(
                        'Material theme',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  for (final (i, item) in _sections.indexed)
                    ListTile(
                      leading: _icon(item),
                      title: Text(item.label),
                      selected: i == _index,
                      onTap: () {
                        _select(i);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('New item created'))),
              icon: const Icon(LucideIcons.plus),
              label: const Text('New'),
            ),
            body: wide
                ? Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _index,
                        onDestinationSelected: _select,
                        labelType: NavigationRailLabelType.all,
                        destinations: [
                          for (final item in _sections)
                            NavigationRailDestination(
                              icon: _icon(item),
                              label: Text(item.label),
                            ),
                        ],
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: body),
                    ],
                  )
                : body,
            bottomNavigationBar: wide
                ? null
                : NavigationBar(
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    destinations: [
                      for (final item in _sections)
                        NavigationDestination(
                          icon: _icon(item),
                          label: item.label,
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
