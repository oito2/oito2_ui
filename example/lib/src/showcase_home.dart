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

import 'pages/colors_page.dart';
import 'pages/components_page.dart';
import 'pages/foundation_page.dart';
import 'pages/tokens_page.dart';
import 'pages/typography_page.dart';
import 'pages/window_page.dart';
import 'showcase_options.dart';

/// A showcase page with its navigation label and icon.
class _ShowcasePage {
  const _ShowcasePage(this.label, this.icon, this.builder);

  final String label;
  final IconData icon;
  final Widget Function(Oito2ColorTheme colors) builder;
}

final _pages = [
  _ShowcasePage(
    'Foundation',
    Icons.devices_outlined,
    (_) => const FoundationPage(),
  ),
  _ShowcasePage('Tokens', Icons.straighten_outlined, (_) => const TokensPage()),
  _ShowcasePage(
    'Colors',
    Icons.palette_outlined,
    (colors) => ColorsPage(colors: colors),
  ),
  _ShowcasePage(
    'Components',
    Icons.widgets_outlined,
    (_) => const ComponentsPage(),
  ),
  _ShowcasePage('Window', Icons.web_asset_outlined, (_) => const WindowPage()),
  _ShowcasePage(
    'Typography',
    Icons.text_fields_outlined,
    (_) => const TypographyPage(),
  ),
];

/// Showcase shell: a navigation rail with one entry per page and the
/// appearance selectors in the app bar.
class ShowcaseHome extends StatefulWidget {
  /// Creates the showcase shell.
  const ShowcaseHome({
    super.key,
    required this.options,
    required this.onOptionsChanged,
  });

  /// The current appearance.
  final ShowcaseOptions options;

  /// Called when the user changes the appearance.
  final ValueChanged<ShowcaseOptions> onOptionsChanged;

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final page = _pages[_selected];
    final options = widget.options;
    final colors = options.colorsFor(Theme.of(context).brightness);
    final isBase = options.preset == null;

    return Scaffold(
      appBar: Oito2WindowTitleBar(
        platform: Oito2SystemScope.of(context).platform,
        title: Text('oito2_ui · ${page.label}'),
        actions: [
          _SchemeMenu(options: options, onChanged: widget.onOptionsChanged),
          if (isBase) ...[
            _AccentMenu(options: options, onChanged: widget.onOptionsChanged),
            IconButton(
              tooltip: 'High contrast',
              isSelected: options.highContrast,
              icon: const Icon(Icons.contrast_outlined),
              onPressed: () => widget.onOptionsChanged(
                options.copyWith(highContrast: !options.highContrast),
              ),
            ),
            const SizedBox(width: Oito2Spacing.sm),
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
              selected: {options.themeMode},
              onSelectionChanged: (modes) => widget.onOptionsChanged(
                options.copyWith(themeMode: modes.single),
              ),
            ),
          ],
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
          Expanded(child: page.builder(colors)),
        ],
      ),
    );
  }
}

/// Selects the oito2 base scheme or one of the presets.
class _SchemeMenu extends StatelessWidget {
  const _SchemeMenu({required this.options, required this.onChanged});

  final ShowcaseOptions options;
  final ValueChanged<ShowcaseOptions> onChanged;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: options.preset == null
              ? const Icon(Icons.check)
              : const SizedBox.square(dimension: 24),
          onPressed: () => onChanged(options.copyWith(clearPreset: true)),
          child: const Text('oito2'),
        ),
        const Divider(height: 1),
        for (final preset in Oito2ThemePreset.values)
          MenuItemButton(
            leadingIcon: options.preset == preset
                ? const Icon(Icons.check)
                : const SizedBox.square(dimension: 24),
            onPressed: () => onChanged(options.copyWith(preset: preset)),
            child: Text(preset.name),
          ),
      ],
      builder: (context, controller, _) => TextButton.icon(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(Icons.style_outlined),
        label: Text(options.preset?.name ?? 'oito2'),
      ),
    );
  }
}

/// Selects the accent color of the base scheme.
class _AccentMenu extends StatelessWidget {
  const _AccentMenu({required this.options, required this.onChanged});

  final ShowcaseOptions options;
  final ValueChanged<ShowcaseOptions> onChanged;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        for (final accent in Oito2AccentColor.values)
          MenuItemButton(
            leadingIcon: Icon(Icons.circle, color: accent.color),
            trailingIcon: options.accent == accent
                ? const Icon(Icons.check)
                : null,
            onPressed: () => onChanged(options.copyWith(accent: accent)),
            child: Text(accent.name),
          ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: 'Accent color',
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: Icon(Icons.circle, color: options.accent.color),
      ),
    );
  }
}
