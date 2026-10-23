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

// #region folders
const _folders = [
  (LucideIcons.house, 'Home'),
  (LucideIcons.file_text, 'Documents'),
  (LucideIcons.download, 'Downloads'),
  (LucideIcons.audio_lines, 'Music'),
];
// #endregion

/// Documents [Oito2ListTile]: rounded rows in a list, square rows in an
/// [Oito2TileList] and a centered title.
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
    return DocPage(
      title: 'List Tile',
      description:
          'An interactive row with a title, an optional subtitle and widgets '
          'on both sides, for sidebars, lists and settings pages.',
      source: 'lib/src/pages/list_tile_page.dart',
      children: [
        ExamplePanel(
          regions: const ['folders', 'preview'],
          child: SizedBox(
            width: 260,
            child: Column(
              children: [
                // #region preview
                for (final (index, (icon, name)) in _folders.indexed)
                  Oito2ListTile(
                    leading: Icon(icon),
                    titleText: name,
                    selected: _selected == index,
                    onTap: () => setState(() => _selected = index),
                  ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2ListTile` a `title` widget or a `titleText`, and '
          'optionally a `subtitle` or `subtitleText`, a `leading` and a '
          '`trailing` widget. Passing both forms of the title, or of the '
          'subtitle, is an error. With `onTap` the row shows hover, takes '
          'keyboard focus and can be activated; without it the row is '
          'static. `selected` fills it with the secondary container color.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The row is at least 40 pixels tall, 52 with a subtitle, on '
          'pointer platforms, and 56 or 72 on touch platforms.',
        ),
        const DocNote(
          'For static settings rows whose controls handle their own input, '
          '`Oito2Tile` is lighter.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Square rows in a tile list', level: 3),
        const DocText(
          '`Oito2ListTile.square` has square corners, for rows inside an '
          '`Oito2TileList`, whose border already rounds the corners. '
          '`enabled: false` dims a row and ignores taps.',
        ),
        ExamplePanel(
          region: 'square',
          child: SizedBox(
            width: 420,
            // #region square
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
            // #endregion
          ),
        ),
        const DocHeading('Centered title', level: 3),
        const DocText(
          '`centerTitle` centers the title and subtitle, as in a row that '
          'acts as a single button. `contentPadding` and `horizontalGap` '
          'set the space around and between the parts.',
        ),
        ExamplePanel(
          region: 'centered',
          child: SizedBox(
            width: 320,
            // #region centered
            child: Oito2TileList(
              children: [
                Oito2ListTile.square(
                  titleText: 'Add account',
                  centerTitle: true,
                  onTap: () {},
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'A row with `onTap` reads as a button to assistive technologies, '
          'with its enabled state; a selected row is reported as selected. '
          'Static rows declare neither, so they read as plain content. '
          'Only interactive rows take the focus, and the oito2 focus ring '
          'shows around them in keyboard navigation.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next interactive row.'],
            ['`Enter` / `Space`', 'Calls `onTap`.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2ListTile']),
      ],
    );
  }
}
