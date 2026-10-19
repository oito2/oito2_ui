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

/// Shows the oito2 container widgets.
class ContainersPage extends StatefulWidget {
  /// Creates the containers page.
  const ContainersPage({super.key});

  @override
  State<ContainersPage> createState() => _ContainersPageState();
}

class _ContainersPageState extends State<ContainersPage> {
  bool _wifi = true;
  bool _bluetooth = false;
  int _style = 0;
  int _banner = 1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'Section and tile list',
          children: [
            SizedBox(
              width: 520,
              child: Oito2Section(
                headline: const Text('Connections'),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('Reset')),
                ],
                padding: EdgeInsets.zero,
                child: Oito2TileList(
                  children: [
                    Oito2Tile(
                      leading: const Icon(Icons.wifi),
                      title: const Text('Wi-Fi'),
                      subtitle: const Text('Home network'),
                      trailing: Switch(
                        value: _wifi,
                        onChanged: (v) => setState(() => _wifi = v),
                      ),
                    ),
                    Oito2Tile(
                      leading: const Icon(Icons.bluetooth),
                      title: const Text('Bluetooth'),
                      subtitle: const Text('No devices'),
                      trailing: Switch(
                        value: _bluetooth,
                        onChanged: (v) => setState(() => _bluetooth = v),
                      ),
                    ),
                    Oito2Tile(
                      leading: const Icon(Icons.vpn_lock_outlined),
                      title: const Text('VPN'),
                      subtitle: const Text('Opens the VPN settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Oito2Tile(
                      leading: Icon(Icons.airplanemode_active),
                      title: Text('Airplane mode'),
                      subtitle: Text('Unavailable on this device'),
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Selectable containers',
          children: [
            for (final (index, name) in const [
              'Light',
              'Dark',
              'System',
            ].indexed)
              SizedBox(
                width: 150,
                child: Oito2SelectableContainer(
                  selected: _style == index,
                  onTap: () => setState(() => _style = index),
                  child: Column(
                    children: [
                      Oito2BorderContainer(
                        height: 72,
                        color: switch (index) {
                          0 => const Color(0xFFFAFAFA),
                          1 => const Color(0xFF242424),
                          _ => Theme.of(context).colorScheme.surfaceContainer,
                        },
                      ),
                      const SizedBox(height: Oito2Spacing.sm),
                      Text(name),
                    ],
                  ),
                ),
              ),
          ],
        ),
        ShowcaseSection(
          'Banners',
          children: [
            for (final (index, (title, subtitle)) in const [
              ('Text Editor', 'Edit plain text files'),
              ('Files', 'Access and organize files'),
              ('Calculator', 'Perform calculations'),
            ].indexed)
              SizedBox(
                width: 240,
                child: Oito2Banner(
                  selected: _banner == index,
                  onTap: () => setState(() => _banner = index),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleMedium),
                      const SizedBox(height: Oito2Spacing.xs),
                      Text(subtitle, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
        ),
        ShowcaseSection(
          'Info boxes and badges',
          children: [
            for (final type in Oito2InfoType.values)
              SizedBox(
                width: 340,
                child: Oito2InfoBox(
                  type: type,
                  title: Text(
                    '${type.name[0].toUpperCase()}${type.name.substring(1)}',
                  ),
                  subtitle: const Text('A short message explaining the state.'),
                ),
              ),
            Wrap(
              spacing: Oito2Spacing.sm,
              children: [
                for (final type in Oito2InfoType.values)
                  Oito2InfoBadge(type: type, label: Text(type.name)),
              ],
            ),
          ],
        ),
        ShowcaseSection(
          'Expandable',
          children: [
            SizedBox(
              width: 420,
              child: Oito2BorderContainer(
                padding: const EdgeInsets.all(Oito2Spacing.md),
                child: Oito2Expandable(
                  header: const Text('Advanced options'),
                  collapsedChild: Text(
                    '3 options hidden',
                    style: textTheme.bodySmall,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enable experimental features'),
                      Text('Send usage statistics'),
                      Text('Use legacy renderer'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Watermark',
          children: [
            SizedBox(
              width: 420,
              height: 160,
              child: Oito2BorderContainer(
                child: Oito2Watermark(
                  watermark: const Icon(Icons.inbox_outlined, size: 120),
                  child: Center(
                    child: Text('No messages', style: textTheme.titleMedium),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
