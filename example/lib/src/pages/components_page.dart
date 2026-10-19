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

/// Shows the Material components styled by `Oito2Theme`.
class ComponentsPage extends StatefulWidget {
  /// Creates the components page.
  const ComponentsPage({super.key});

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  bool _checked = true;
  bool _switched = true;
  int _radio = 0;
  double _slider = 0.4;
  Set<String> _segment = {'day'};
  final Set<String> _chips = {'Linux'};
  int _selectedTile = 0;

  void _showDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'The document has unsaved changes that will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('File moved to trash'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Oito2SemanticColors.maybeOf(context);
    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'Buttons',
          children: [
            FilledButton(onPressed: () {}, child: const Text('Filled')),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined),
              label: const Text('Download'),
            ),
            ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            TextButton(onPressed: () {}, child: const Text('Text')),
            const FilledButton(onPressed: null, child: Text('Disabled')),
            IconButton(
              tooltip: 'Search',
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton.filledTonal(
              tooltip: 'Settings',
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined),
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
          'Inputs',
          children: [
            const SizedBox(
              width: 260,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Your full name',
                ),
              ),
            ),
            const SizedBox(
              width: 260,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  errorText: 'Enter a valid address',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
            ),
            DropdownMenu<String>(
              width: 220,
              initialSelection: 'GNOME',
              label: const Text('Desktop'),
              dropdownMenuEntries: [
                for (final name in ['GNOME', 'KDE Plasma', 'Xfce', 'COSMIC'])
                  DropdownMenuEntry(value: name, label: name),
              ],
            ),
          ],
        ),
        ShowcaseSection(
          'Selection',
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _checked,
                  onChanged: (v) => setState(() => _checked = v ?? false),
                ),
                const Text('Checkbox'),
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
              children: [
                Switch(
                  value: _switched,
                  onChanged: (v) => setState(() => _switched = v),
                ),
                const SizedBox(width: Oito2Spacing.sm),
                const Text('Switch'),
              ],
            ),
            SizedBox(
              width: 240,
              child: Slider(
                value: _slider,
                onChanged: (v) => setState(() => _slider = v),
              ),
            ),
            Wrap(
              spacing: Oito2Spacing.sm,
              children: [
                for (final name in ['Linux', 'Windows', 'macOS', 'Web'])
                  FilterChip(
                    label: Text(name),
                    selected: _chips.contains(name),
                    onSelected: (selected) => setState(
                      () => selected ? _chips.add(name) : _chips.remove(name),
                    ),
                  ),
              ],
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
          ],
        ),
        ShowcaseSection(
          'Containers',
          children: [
            SizedBox(
              width: 320,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(Oito2Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: Oito2Spacing.sm),
                      const Text(
                        'Flat, with a thin outline and the large radius.',
                      ),
                      const SizedBox(height: Oito2Spacing.sm),
                      Text(
                        'A link-colored line',
                        style: TextStyle(color: semantic?.link),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 320,
              child: Card(
                child: Column(
                  children: [
                    for (final (index, (icon, title)) in const [
                      (Icons.folder_outlined, 'Documents'),
                      (Icons.image_outlined, 'Pictures'),
                      (Icons.music_note_outlined, 'Music'),
                    ].indexed)
                      ListTile(
                        leading: Icon(icon),
                        title: Text(title),
                        subtitle: const Text('Local folder'),
                        selected: _selectedTile == index,
                        onTap: () => setState(() => _selectedTile = index),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Overlays',
          children: [
            OutlinedButton(
              onPressed: _showDialog,
              child: const Text('Open dialog'),
            ),
            OutlinedButton(
              onPressed: _showSnackBar,
              child: const Text('Show snack bar'),
            ),
            MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.copy_outlined),
                  onPressed: () {},
                  child: const Text('Copy'),
                ),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.content_paste_outlined),
                  onPressed: () {},
                  child: const Text('Paste'),
                ),
                const Divider(),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.delete_outline),
                  onPressed: () {},
                  child: const Text('Delete'),
                ),
              ],
              builder: (context, controller, _) => OutlinedButton(
                onPressed: () =>
                    controller.isOpen ? controller.close() : controller.open(),
                child: const Text('Open menu'),
              ),
            ),
            const Tooltip(
              message: 'Tooltips use the inverse surface',
              child: Chip(label: Text('Hover me')),
            ),
          ],
        ),
        ShowcaseSection(
          'Tabs',
          children: [
            SizedBox(
              width: 420,
              child: DefaultTabController(
                length: 3,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'General'),
                    Tab(text: 'Appearance'),
                    Tab(text: 'About'),
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
