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

/// The Containers section of the Material theme page: cards, list
/// tiles, dialogs, sheets, banners, snack bars, menus and tooltips, as
/// `Oito2Theme` styles them.
class ThemeContainersView extends StatefulWidget {
  /// Creates the containers section.
  const ThemeContainersView({super.key});

  @override
  State<ThemeContainersView> createState() => _ThemeContainersViewState();
}

class _ThemeContainersViewState extends State<ThemeContainersView> {
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

  void _showSimpleDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Open with'),
        children: [
          for (final app in ['Text Editor', 'Files', 'Browser'])
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(app),
            ),
        ],
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(
          Oito2Spacing.xl,
          0,
          Oito2Spacing.xl,
          Oito2Spacing.xl,
        ),
        child: Text('A modal bottom sheet in the dialog tone.'),
      ),
    );
  }

  void _showBanner() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showMaterialBanner(
      MaterialBanner(
        content: const Text('You are offline. Changes are kept locally.'),
        leading: const Icon(LucideIcons.wifi_off),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('Dismiss'),
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
    final theme = Theme.of(context);
    final link = Oito2SemanticColors.maybeOf(context)?.link;
    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'Cards',
          children: [
            SizedBox(
              width: 300,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(Oito2Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Oito2Spacing.sm,
                    children: [
                      Text('Card', style: theme.textTheme.titleMedium),
                      const Text(
                        'Flat, with a thin outline and the large radius.',
                      ),
                      Text(
                        'A link-colored line',
                        style: TextStyle(color: link),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: Card(
                child: Column(
                  children: [
                    for (final (index, (icon, title)) in const [
                      (LucideIcons.folder, 'Documents'),
                      (LucideIcons.image, 'Pictures'),
                      (LucideIcons.audio_lines, 'Music'),
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
            const SizedBox(
              width: 300,
              child: Card(
                child: ExpansionTile(
                  leading: Icon(LucideIcons.info),
                  title: Text('Expansion tile'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(Oito2Spacing.lg),
                      child: Text('Content revealed on demand.'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Dialogs and sheets',
          children: [
            OutlinedButton(
              onPressed: _showDialog,
              child: const Text('Open dialog'),
            ),
            OutlinedButton(
              onPressed: _showSimpleDialog,
              child: const Text('Open simple dialog'),
            ),
            OutlinedButton(
              onPressed: _showBottomSheet,
              child: const Text('Open bottom sheet'),
            ),
          ],
        ),
        ShowcaseSection(
          'Messages',
          children: [
            OutlinedButton(
              onPressed: _showBanner,
              child: const Text('Show banner'),
            ),
            OutlinedButton(
              onPressed: _showSnackBar,
              child: const Text('Show snack bar'),
            ),
            const Tooltip(
              message: 'Tooltips use the inverse surface',
              child: Chip(label: Text('Hover me')),
            ),
          ],
        ),
        ShowcaseSection(
          'Menus and tabs',
          children: [
            MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(LucideIcons.copy),
                  onPressed: () {},
                  child: const Text('Copy'),
                ),
                MenuItemButton(
                  leadingIcon: const Icon(LucideIcons.clipboard_paste),
                  onPressed: () {},
                  child: const Text('Paste'),
                ),
                const Divider(),
                MenuItemButton(
                  leadingIcon: const Icon(LucideIcons.trash),
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
            const SizedBox(
              width: 360,
              child: DefaultTabController(
                length: 3,
                child: TabBar(
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
