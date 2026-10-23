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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2ListTile]: rounded rows in a list and square rows in an
/// [Oito2TileList].
class ListTilePage extends StatefulWidget {
  /// Creates the list tile page.
  const ListTilePage({super.key});

  @override
  State<ListTilePage> createState() => _ListTilePageState();
}

class _ListTilePageState extends State<ListTilePage> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    const folders = [
      (LucideIcons.house, 'Home'),
      (LucideIcons.file_text, 'Documents'),
      (LucideIcons.download, 'Downloads'),
      (LucideIcons.audio_lines, 'Music'),
    ];
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Sidebar rows',
          children: [
            SizedBox(
              width: 260,
              child: Column(
                children: [
                  for (final (index, (icon, name)) in folders.indexed)
                    Oito2ListTile(
                      leading: Icon(icon),
                      titleText: name,
                      selected: _selected == index,
                      onTap: () => setState(() => _selected = index),
                    ),
                ],
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Square rows in a tile list',
          children: [
            SizedBox(
              width: 420,
              child: Oito2TileList(
                children: [
                  Oito2ListTile.square(
                    leading: const Icon(LucideIcons.monitor),
                    titleText: 'Displays',
                    subtitleText: 'Resolution, scale and night light',
                    trailing: const Icon(LucideIcons.chevron_right),
                    onTap: () {},
                  ),
                  Oito2ListTile.square(
                    leading: const Icon(LucideIcons.volume_2),
                    titleText: 'Sound',
                    trailing: const Icon(LucideIcons.chevron_right),
                    onTap: () {},
                  ),
                  const Oito2ListTile.square(
                    leading: Icon(LucideIcons.printer),
                    titleText: 'Printers',
                    subtitleText: 'No printers found',
                    enabled: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
