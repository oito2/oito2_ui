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

/// Shows [Oito2ContextMenuRegion] with a nested menu.
class ContextMenuPage extends StatefulWidget {
  /// Creates the context menu page.
  const ContextMenuPage({super.key});

  @override
  State<ContextMenuPage> createState() => _ContextMenuPageState();
}

class _ContextMenuPageState extends State<ContextMenuPage> {
  String _picked = 'Nothing yet';
  bool _pinned = false;

  void _pick(String value) => setState(() => _picked = value);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Right-click, long-press or Shift+F10 on the card',
          children: [
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
              child: Focus(
                child: Container(
                  width: 280,
                  height: 140,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: Oito2Radius.largeAll,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: const Text('Report.pdf'),
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection('Last choice', children: [Text(_picked)]),
      ],
    );
  }
}
