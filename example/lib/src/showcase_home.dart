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

import 'pages/foundation_page.dart';
import 'pages/tokens_page.dart';
import 'pages/typography_page.dart';

/// A showcase page with its navigation label and icon.
class _ShowcasePage {
  const _ShowcasePage(this.label, this.icon, this.builder);

  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

final _pages = [
  _ShowcasePage(
    'Foundation',
    Icons.devices_outlined,
    (_) => const FoundationPage(),
  ),
  _ShowcasePage('Tokens', Icons.palette_outlined, (_) => const TokensPage()),
  _ShowcasePage(
    'Typography',
    Icons.text_fields_outlined,
    (_) => const TypographyPage(),
  ),
];

/// Showcase shell: a navigation rail with one entry per page and a theme
/// mode selector.
class ShowcaseHome extends StatefulWidget {
  /// Creates the showcase shell.
  const ShowcaseHome({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  /// The current theme mode.
  final ThemeMode themeMode;

  /// Called when the user picks another theme mode.
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final page = _pages[_selected];
    return Scaffold(
      appBar: AppBar(
        title: Text('oito2_ui · ${page.label}'),
        actions: [
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                tooltip: 'Light',
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_outlined),
                tooltip: 'System',
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                tooltip: 'Dark',
              ),
            ],
            selected: {widget.themeMode},
            onSelectionChanged: (modes) =>
                widget.onThemeModeChanged(modes.single),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selected,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (index) => setState(() => _selected = index),
            destinations: [
              for (final p in _pages)
                NavigationRailDestination(
                  icon: Icon(p.icon),
                  label: Text(p.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: page.builder(context)),
        ],
      ),
    );
  }
}
