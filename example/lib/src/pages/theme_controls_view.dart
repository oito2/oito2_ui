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

/// The Controls section of the Material theme page: buttons, floating
/// action buttons, chips, toggles, sliders and progress indicators, as
/// `Oito2Theme` styles them.
class ThemeControlsView extends StatefulWidget {
  /// Creates the controls section.
  const ThemeControlsView({super.key});

  @override
  State<ThemeControlsView> createState() => _ThemeControlsViewState();
}

class _ThemeControlsViewState extends State<ThemeControlsView> {
  bool? _checked = true;
  bool _switched = true;
  int _radio = 0;
  double _slider = 0.4;
  RangeValues _range = const RangeValues(0.2, 0.7);
  Set<String> _segment = {'day'};
  final Set<String> _filters = {'Linux'};
  int _choice = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'Buttons',
          children: [
            FilledButton(onPressed: () {}, child: const Text('Filled')),
            FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.download),
              label: const Text('Download'),
            ),
            ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            TextButton(onPressed: () {}, child: const Text('Text')),
            const FilledButton(onPressed: null, child: Text('Disabled')),
            const OutlinedButton(onPressed: null, child: Text('Disabled')),
          ],
        ),
        ShowcaseSection(
          'Icon buttons and segments',
          children: [
            IconButton(
              tooltip: 'Search',
              onPressed: () {},
              icon: const Icon(LucideIcons.search),
            ),
            IconButton.filled(
              tooltip: 'Add',
              onPressed: () {},
              icon: const Icon(LucideIcons.plus),
            ),
            IconButton.filledTonal(
              tooltip: 'Settings',
              onPressed: () {},
              icon: const Icon(LucideIcons.settings),
            ),
            IconButton.outlined(
              tooltip: 'Share',
              onPressed: () {},
              icon: const Icon(LucideIcons.share_2),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'day', label: Text('Day')),
                ButtonSegment(value: 'week', label: Text('Week')),
                ButtonSegment(value: 'month', label: Text('Month')),
              ],
              selected: _segment,
              onSelectionChanged: (value) => setState(() => _segment = value),
            ),
          ],
        ),
        ShowcaseSection(
          'Floating action buttons',
          children: [
            FloatingActionButton.small(
              heroTag: null,
              tooltip: 'Small',
              onPressed: () {},
              child: const Icon(LucideIcons.pencil),
            ),
            FloatingActionButton(
              heroTag: null,
              tooltip: 'Regular',
              onPressed: () {},
              child: const Icon(LucideIcons.pencil),
            ),
            FloatingActionButton.large(
              heroTag: null,
              tooltip: 'Large',
              onPressed: () {},
              child: const Icon(LucideIcons.pencil),
            ),
            FloatingActionButton.extended(
              heroTag: null,
              onPressed: () {},
              icon: const Icon(LucideIcons.plus),
              label: const Text('New file'),
            ),
          ],
        ),
        ShowcaseSection(
          'Chips',
          children: [
            for (final name in ['Linux', 'Windows', 'macOS'])
              FilterChip(
                label: Text(name),
                selected: _filters.contains(name),
                onSelected: (selected) => setState(
                  () => selected ? _filters.add(name) : _filters.remove(name),
                ),
              ),
            for (final (i, name) in ['Small', 'Large'].indexed)
              ChoiceChip(
                label: Text(name),
                selected: _choice == i,
                onSelected: (_) => setState(() => _choice = i),
              ),
            InputChip(
              avatar: const Icon(LucideIcons.user_round),
              label: const Text('Ana'),
              onDeleted: () {},
            ),
            ActionChip(
              avatar: const Icon(LucideIcons.calendar_plus),
              label: const Text('Add event'),
              onPressed: () {},
            ),
            const Chip(label: Text('Plain chip')),
          ],
        ),
        ShowcaseSection(
          'Toggles',
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  tristate: true,
                  value: _checked,
                  onChanged: (v) => setState(() => _checked = v),
                ),
                const Text('Checkbox (tristate)'),
              ],
            ),
            RadioGroup<int>(
              groupValue: _radio,
              onChanged: (v) => setState(() => _radio = v ?? 0),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<int>(value: 0),
                  Radio<int>(value: 1),
                  Text('Radio'),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.sm,
              children: [
                Switch(
                  value: _switched,
                  onChanged: (v) => setState(() => _switched = v),
                ),
                const Text('Switch'),
              ],
            ),
          ],
        ),
        ShowcaseSection(
          'Sliders',
          children: [
            SizedBox(
              width: 240,
              child: Slider(
                value: _slider,
                onChanged: (v) => setState(() => _slider = v),
              ),
            ),
            SizedBox(
              width: 240,
              child: Slider(
                value: _slider,
                divisions: 5,
                label: '${(_slider * 100).round()}',
                onChanged: (v) => setState(() => _slider = v),
              ),
            ),
            SizedBox(
              width: 240,
              child: RangeSlider(
                values: _range,
                onChanged: (v) => setState(() => _range = v),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Progress',
          children: [
            const SizedBox(width: 240, child: LinearProgressIndicator()),
            SizedBox(
              width: 240,
              child: LinearProgressIndicator(value: _slider),
            ),
            const SizedBox.square(
              dimension: 32,
              child: CircularProgressIndicator(),
            ),
            SizedBox.square(
              dimension: 32,
              child: CircularProgressIndicator(value: _slider),
            ),
          ],
        ),
      ],
    );
  }
}
