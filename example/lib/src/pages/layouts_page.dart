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

const _settings = [
  (Icons.wifi, 'Network', 'Wi-Fi, VPN and proxy'),
  (Icons.bluetooth, 'Bluetooth', 'Devices and pairing'),
  (Icons.palette_outlined, 'Appearance', 'Style, accent and wallpaper'),
  (Icons.notifications_outlined, 'Notifications', 'Banners and sounds'),
  (Icons.lock_outline, 'Privacy', 'Location, camera and history'),
];

/// Shows the oito2 layout widgets: master-detail, paned view and
/// adaptive navigation, each inside a frame you can resize.
class LayoutsPage extends StatefulWidget {
  /// Creates the layouts page.
  const LayoutsPage({super.key});

  @override
  State<LayoutsPage> createState() => _LayoutsPageState();
}

class _LayoutsPageState extends State<LayoutsPage> {
  double _frameWidth = 760;

  Widget _frame(Widget child) => SizedBox(
    width: _frameWidth,
    height: 380,
    child: Oito2BorderContainer(child: child),
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'Frame width',
          children: [
            SizedBox(
              width: 420,
              child: Slider(
                min: 360,
                max: 900,
                value: _frameWidth,
                label: '${_frameWidth.round()}',
                divisions: 27,
                onChanged: (value) => setState(() => _frameWidth = value),
              ),
            ),
            Text(
              '${_frameWidth.round()} px · narrow frames switch to the '
              'compact layouts',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        ShowcaseSection(
          'Master-detail',
          children: [
            _frame(
              Oito2MasterDetailPage(
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
        ShowcaseSection(
          'Paned view',
          children: [
            _frame(
              Oito2PanedView(
                initialPaneSize: 240,
                minPaneSize: 160,
                minPageSize: 160,
                pane: Material(
                  color: Oito2ChromeColors.maybeOf(context)?.mainbar,
                  child: const Center(
                    child: Text('Pane · drag or focus the divider'),
                  ),
                ),
                page: const Center(child: Text('Page')),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Adaptive navigation',
          children: [
            _frame(
              Oito2NavigationPage(
                compactBreakpoint: 560,
                extendedBreakpoint: 820,
                items: const [
                  Oito2NavigationItem(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  Oito2NavigationItem(
                    icon: Icon(Icons.library_books_outlined),
                    selectedIcon: Icon(Icons.library_books),
                    label: 'Library',
                  ),
                  Oito2NavigationItem(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
                pageBuilder: (context, index) => Center(
                  child: Text(
                    ['Home', 'Library', 'Settings'][index],
                    style: textTheme.headlineSmall,
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
