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

const _categories = [
  'All',
  'Audio',
  'Development',
  'Education',
  'Games',
  'Graphics',
  'Internet',
  'Office',
  'Science',
  'Utilities',
];

/// Shows the oito2 controls, inputs and utilities.
class ControlsPage extends StatefulWidget {
  /// Creates the controls page.
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  bool? _hidden = false;
  bool _symlinks = true;
  String _sort = 'name';
  bool _dark = false;
  Oito2AccentColor _accent = Oito2AccentColor.blue;
  final Set<int> _chips = {0};
  int _page = 0;
  bool _searching = false;
  String _search = '';
  String _date = '—';
  String _segments = '';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'Check, radio and switch buttons',
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Oito2CheckButton(
                  value: _hidden,
                  tristate: true,
                  onChanged: (v) => setState(() => _hidden = v),
                  title: const Text('Show hidden files'),
                  subtitle: const Text('Tri-state: checked, mixed, unchecked'),
                ),
                Oito2CheckButton(
                  value: _symlinks,
                  onChanged: (v) => setState(() => _symlinks = v ?? false),
                  title: const Text('Follow symbolic links'),
                ),
                const Oito2CheckButton(
                  value: true,
                  onChanged: null,
                  title: Text('Disabled option'),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (value, label) in const [
                  ('name', 'Sort by name'),
                  ('size', 'Sort by size'),
                  ('date', 'Sort by date'),
                ])
                  Oito2RadioButton<String>(
                    value: value,
                    groupValue: _sort,
                    onChanged: (v) => setState(() => _sort = v ?? 'name'),
                    title: Text(label),
                  ),
              ],
            ),
            SizedBox(
              width: 260,
              child: Oito2SwitchButton(
                value: _dark,
                onChanged: (v) => setState(() => _dark = v),
                title: const Text('Dark style'),
                subtitle: const Text('Applies to this window'),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Split and option buttons',
          children: [
            for (final variant in Oito2SplitButtonVariant.values)
              Oito2SplitButton(
                variant: variant,
                onPressed: () {},
                menuChildren: [
                  MenuItemButton(
                    onPressed: () {},
                    child: const Text('Save as…'),
                  ),
                  MenuItemButton(
                    onPressed: () {},
                    child: const Text('Save a copy'),
                  ),
                ],
                child: Text('Save (${variant.name})'),
              ),
            Oito2OptionButton(
              onPressed: () {},
              label: 'Add',
              child: const Icon(Icons.add),
            ),
            Oito2OptionButton(
              onPressed: () {},
              label: 'Remove',
              child: const Icon(Icons.remove),
            ),
            Oito2OptionButton.color(
              onPressed: () {},
              color: _accent.color,
              label: 'Accent color',
            ),
          ],
        ),
        ShowcaseSection(
          'Color disks',
          children: [
            Oito2EdgeFocusInterceptor(
              child: Wrap(
                spacing: Oito2Spacing.xs,
                children: [
                  for (final accent in Oito2AccentColor.values)
                    Oito2ColorDisk(
                      color: accent.color,
                      label: accent.name,
                      selected: _accent == accent,
                      onPressed: () => setState(() => _accent = accent),
                    ),
                ],
              ),
            ),
            Text(
              'Arrow keys stay inside this group; Tab leaves it.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        ShowcaseSection(
          'Choice chip bar',
          children: [
            SizedBox(
              width: 520,
              child: Oito2ChoiceChipBar(
                labels: [for (final name in _categories) Text(name)],
                isSelected: [
                  for (var i = 0; i < _categories.length; i++)
                    _chips.contains(i),
                ],
                onSelected: (i) => setState(
                  () => _chips.contains(i) ? _chips.remove(i) : _chips.add(i),
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Page indicator',
          children: [
            Oito2PageIndicator(
              length: 6,
              page: _page,
              onTap: (i) => setState(() => _page = i),
            ),
            SizedBox(
              width: 72,
              child: Oito2PageIndicator(
                length: 24,
                page: _page,
                onTap: (i) => setState(() => _page = i),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Search',
          children: [
            SizedBox(
              width: 300,
              child: Oito2SearchField(
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            Oito2BorderContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: Oito2Spacing.md,
                vertical: Oito2Spacing.xs,
              ),
              child: Oito2SearchTitleField(
                title: Text('Files', style: textTheme.titleMedium),
                searchActive: _searching,
                onSearchActiveChanged: (v) => setState(() => _searching = v),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            Text('Query: "$_search"', style: textTheme.bodySmall),
          ],
        ),
        ShowcaseSection(
          'Date, time and segmented entries',
          children: [
            SizedBox(
              width: 520,
              child: Oito2DateTimeEntry(
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onChanged: (v) => setState(() => _date = v?.toString() ?? '—'),
              ),
            ),
            Text('Value: $_date', style: textTheme.bodySmall),
            Oito2SegmentedEntry(
              segments: const [
                Oito2EntrySegment(length: 3, hint: '192'),
                Oito2EntrySegment(length: 3, hint: '168'),
                Oito2EntrySegment(length: 3, hint: '0'),
                Oito2EntrySegment(length: 3, hint: '1'),
              ],
              onChanged: (v) => setState(() => _segments = v.join('.')),
            ),
            Text('IP: $_segments', style: textTheme.bodySmall),
          ],
        ),
        ShowcaseSection(
          'Utilities',
          children: [
            SizedBox(
              width: 240,
              height: 160,
              child: Oito2BorderContainer(
                child: Oito2ScrollViewUndershoot(
                  child: ListView(
                    children: [
                      for (var i = 1; i <= 20; i++)
                        ListTile(dense: true, title: Text('Item $i')),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox.square(
              dimension: 120,
              child: Oito2BorderContainer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Oito2DiagonalClip(
                      corner: Oito2DiagonalCorner.topLeft,
                      child: const ColoredBox(color: Color(0xFFFAFAFA)),
                    ),
                    Oito2DiagonalClip(
                      corner: Oito2DiagonalCorner.bottomRight,
                      child: const ColoredBox(color: Color(0xFF242424)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 320,
              height: 160,
              child: Oito2BorderContainer(
                child: Stack(
                  children: [
                    Oito2Draggable(
                      initialPosition: const Offset(24, 40),
                      child: Chip(
                        avatar: const Icon(Icons.open_with, size: 18),
                        label: const Text('Drag me or use arrows'),
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
