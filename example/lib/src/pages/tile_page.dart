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

/// Documents [Oito2Tile] rows inside an [Oito2TileList].
class TilePage extends StatefulWidget {
  /// Creates the tile page.
  const TilePage({super.key});

  @override
  State<TilePage> createState() => _TilePageState();
}

class _TilePageState extends State<TilePage> {
  bool _wifi = true;
  bool _bluetooth = false;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Tile',
      description:
          'A settings row with an icon, a title, a subtitle and a trailing '
          'control, grouped in a bordered list.',
      source: 'lib/src/pages/tile_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 420,
            // #region preview
            child: Oito2TileList(
              children: [
                Oito2Tile(
                  leading: const Icon(LucideIcons.wifi),
                  title: const Text('Wi-Fi'),
                  subtitle: const Text('Home network'),
                  trailing: Oito2Switch(
                    value: _wifi,
                    onChanged: (v) => setState(() => _wifi = v),
                  ),
                ),
                Oito2Tile(
                  leading: const Icon(LucideIcons.bluetooth),
                  title: const Text('Bluetooth'),
                  subtitle: const Text('No devices'),
                  trailing: Oito2Switch(
                    value: _bluetooth,
                    onChanged: (v) => setState(() => _bluetooth = v),
                  ),
                ),
                Oito2Tile(
                  leading: const Icon(LucideIcons.shield),
                  title: const Text('VPN'),
                  subtitle: const Text('Opens the VPN settings'),
                  trailing: const Icon(LucideIcons.chevron_right),
                  onTap: () {},
                ),
                const Oito2Tile(
                  leading: Icon(LucideIcons.plane),
                  title: Text('Airplane mode'),
                  subtitle: Text('Unavailable on this device'),
                  enabled: false,
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2Tile` lays out an optional `leading` widget, usually an '
          'icon, a `title`, a `subtitle` under it and a `trailing` widget, '
          'such as a switch or a value. `Oito2TileList` puts tiles in a '
          'bordered container with dividers between them.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'A tile is static by default: the controls inside it handle their '
          'own input. With `onTap` the whole row responds to taps with an '
          'ink highlight. `enabled: false` dims the tile and ignores taps.',
        ),
        const DocNote(
          'For rows meant to be activated or selected, with hover, '
          'selection and the oito2 focus ring, use `Oito2ListTile`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Read-only values', level: 3),
        const DocText(
          'Without `onTap`, a tile with a text `trailing` shows a property '
          'and its value.',
        ),
        ExamplePanel(
          region: 'values',
          child: SizedBox(
            width: 420,
            // #region values
            child: Oito2TileList(
              children: const [
                Oito2Tile(title: Text('Version'), trailing: Text('2.1.0')),
                Oito2Tile(title: Text('License'), trailing: Text('GPL-3.0')),
                Oito2Tile(
                  title: Text('Storage'),
                  subtitle: Text('Local cache'),
                  trailing: Text('128 MB'),
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Padding', level: 3),
        const DocText(
          '`padding` sets the space around the content, 16 pixels across '
          'and 12 down by default.',
        ),
        ExamplePanel(
          region: 'padding',
          child: SizedBox(
            width: 420,
            // #region padding
            child: Oito2TileList(
              children: const [
                Oito2Tile(
                  padding: EdgeInsets.symmetric(
                    horizontal: Oito2Spacing.md,
                    vertical: Oito2Spacing.xs,
                  ),
                  leading: Icon(LucideIcons.bell),
                  title: Text('Compact row'),
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each tile is a single node for assistive technologies, which '
          'read its title and subtitle together and report whether it is '
          'enabled. Controls in `trailing` keep their own semantics and '
          'focus.',
        ),
        ...apiReferenceWidgets(['Oito2Tile', 'Oito2TileList']),
      ],
    );
  }
}
