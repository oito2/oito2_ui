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

/// Shows [Oito2Tile] rows inside an [Oito2TileList].
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
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Tile list',
          children: [
            SizedBox(
              width: 520,
              child: Oito2TileList(
                children: [
                  Oito2Tile(
                    leading: const Icon(LucideIcons.wifi),
                    title: const Text('Wi-Fi'),
                    subtitle: const Text('Home network'),
                    trailing: Switch(
                      value: _wifi,
                      onChanged: (v) => setState(() => _wifi = v),
                    ),
                  ),
                  Oito2Tile(
                    leading: const Icon(LucideIcons.bluetooth),
                    title: const Text('Bluetooth'),
                    subtitle: const Text('No devices'),
                    trailing: Switch(
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
            ),
          ],
        ),
      ],
    );
  }
}
