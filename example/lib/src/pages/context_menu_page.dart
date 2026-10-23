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

/// Documents [Oito2ContextMenuRegion]: a menu with nested entries, check
/// marks, open and close callbacks and a disabled region.
class ContextMenuPage extends StatefulWidget {
  /// Creates the context menu page.
  const ContextMenuPage({super.key});

  @override
  State<ContextMenuPage> createState() => _ContextMenuPageState();
}

class _ContextMenuPageState extends State<ContextMenuPage> {
  String _picked = 'Nothing yet';
  bool _pinned = false;
  bool _open = false;

  void _pick(String value) => setState(() => _picked = value);

  /// A focusable card the menus of this page open over.
  Widget _card(String label) {
    final scheme = Theme.of(context).colorScheme;
    return Focus(
      child: Container(
        width: 280,
        height: 120,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(Oito2Spacing.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: Oito2Radius.largeAll,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Context Menu',
      description:
          'Opens a menu of actions over a widget on a right click, a long '
          'press or the keyboard.',
      source: 'lib/src/pages/context_menu_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2ContextMenuRegion(
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(LucideIcons.copy),
                onPressed: () => _pick('Copy'),
                child: const Text('Copy'),
              ),
              MenuItemButton(
                leadingIcon: const Icon(LucideIcons.pencil),
                onPressed: () => _pick('Rename'),
                child: const Text('Rename'),
              ),
              MenuItemButton(
                leadingIcon: const Icon(LucideIcons.trash),
                onPressed: () => _pick('Delete'),
                child: const Text('Delete'),
              ),
            ],
            child: _card('Right-click or long-press: $_picked'),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Wrap the widget in `Oito2ContextMenuRegion` and give the entries '
          'in `menuChildren`. The menu is a `MenuAnchor`, so the entries are '
          '`MenuItemButton`s, `SubmenuButton`s for nested menus, '
          '`Oito2CheckedMenuItem`s and dividers.',
        ),
        const DocText(
          'A secondary click or a long press opens the menu where the '
          'pointer is. Shift+F10 or the menu key open it over the center of '
          'the child, which needs the focus inside the child: wrap it in a '
          '`Focus`, or use a focusable widget. On the web, the browser\'s '
          'own menu is turned off while the pointer is over the region.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For a menu that opens from a visible button, use '
          '`Oito2PopupMenuButton` instead.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Submenus and check marks', level: 3),
        const DocText(
          'A `SubmenuButton` opens a nested menu, and an '
          '`Oito2CheckedMenuItem` shows a check mark when `checked`.',
        ),
        ExamplePanel(
          region: 'nested',
          child: Column(
            spacing: Oito2Spacing.sm,
            children: [
              // #region nested
              Oito2ContextMenuRegion(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(LucideIcons.copy),
                    onPressed: () => _pick('Copy'),
                    child: const Text('Copy'),
                  ),
                  Oito2CheckedMenuItem(
                    checked: _pinned,
                    onPressed: () => setState(() => _pinned = !_pinned),
                    child: const Text('Pinned'),
                  ),
                  SubmenuButton(
                    leadingIcon: const Icon(LucideIcons.share),
                    menuChildren: [
                      for (final format in ['PDF', 'PNG', 'Markdown'])
                        MenuItemButton(
                          onPressed: () => _pick('Export as $format'),
                          child: Text(format),
                        ),
                    ],
                    child: const Text('Export'),
                  ),
                  const Divider(),
                  MenuItemButton(
                    leadingIcon: const Icon(LucideIcons.trash),
                    onPressed: () => _pick('Delete'),
                    child: const Text('Delete'),
                  ),
                ],
                child: _card('Report.pdf'),
              ),
              // #endregion
              Text('Last choice: $_picked'),
            ],
          ),
        ),
        const DocHeading('Open and close callbacks', level: 3),
        const DocText(
          '`onOpen` and `onClose` run when the menu opens and closes, for '
          'example to highlight the item it belongs to.',
        ),
        ExamplePanel(
          region: 'callbacks',
          // #region callbacks
          child: Oito2ContextMenuRegion(
            onOpen: () => setState(() => _open = true),
            onClose: () => setState(() => _open = false),
            menuChildren: [
              MenuItemButton(
                onPressed: () => _pick('Open'),
                child: const Text('Open'),
              ),
            ],
            child: _card(_open ? 'Menu open' : 'Menu closed'),
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'With `enabled: false` the menu does not open, and on the web the '
          'browser\'s own menu stays available.',
        ),
        ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2ContextMenuRegion(
            enabled: false,
            menuChildren: const [],
            child: _card('No menu here'),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The menu opens from the keyboard as well as from the pointer, so '
          'its actions do not depend on a right click or a long press.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Shift+F10` / `Menu`',
              'Opens the menu over the center of the region, when the focus '
                  'is inside it.',
            ],
            ['Arrow keys', 'Move between the entries and into submenus.'],
            ['`Enter` / `Space`', 'Activates the focused entry.'],
            ['`Escape`', 'Closes the menu.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2ContextMenuRegion',
          'Oito2CheckedMenuItem',
        ]),
      ],
    );
  }
}
