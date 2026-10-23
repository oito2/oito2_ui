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

const _settings = [
  (LucideIcons.wifi, 'Network', 'Wi-Fi, VPN and proxy'),
  (LucideIcons.bluetooth, 'Bluetooth', 'Devices and pairing'),
  (LucideIcons.palette, 'Appearance', 'Style, accent and wallpaper'),
  (LucideIcons.bell, 'Notifications', 'Banners and sounds'),
  (LucideIcons.lock, 'Privacy', 'Location, camera and history'),
];

/// Shows [Oito2MasterDetailPage] in a frame you can resize: side by side
/// when wide, a list that pushes pages when narrow.
class MasterDetailPage extends StatelessWidget {
  /// Creates the master-detail page.
  const MasterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Master-detail',
          children: [
            ShowcaseFrame(
              child: Oito2MasterDetailPage(
                length: _settings.length,
                tileBuilder: (context, index, selected, width) {
                  final (icon, title, _) = _settings[index];
                  return Oito2MasterTile(
                    leading: Icon(icon),
                    title: Text(title),
                  );
                },
                pageBuilder: (context, index) {
                  final (icon, title, subtitle) = _settings[index];
                  return Oito2DetailPage(
                    title: Text(title),
                    body: Oito2Watermark(
                      watermark: Icon(icon, size: 140),
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Padding(
                          padding: const EdgeInsets.all(Oito2Spacing.xl),
                          child: Text(subtitle, style: textTheme.bodyLarge),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
