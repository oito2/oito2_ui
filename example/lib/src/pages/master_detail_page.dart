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
import '../widgets/showcase_widgets.dart';

// #region data
const _settings = [
  (LucideIcons.wifi, 'Network', 'Wi-Fi, VPN and proxy'),
  (LucideIcons.bluetooth, 'Bluetooth', 'Devices and pairing'),
  (LucideIcons.palette, 'Appearance', 'Style, accent and wallpaper'),
  (LucideIcons.bell, 'Notifications', 'Banners and sounds'),
  (LucideIcons.lock, 'Privacy', 'Location, camera and history'),
];
// #endregion

/// Documents [Oito2MasterDetailPage]: the adaptive layout, the narrow
/// layout, a fixed pane with a footer and an empty list.
class MasterDetailPage extends StatelessWidget {
  /// Creates the master-detail page.
  const MasterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DocPage(
      title: 'Master Detail',
      description:
          'A list of items beside the page of the selected one, as in '
          'settings apps, that becomes a list pushing pages when narrow.',
      source: 'lib/src/pages/master_detail_page.dart',
      children: [
        ExamplePanel(
          regions: const ['data', 'preview'],
          child: ShowcaseFrame(
            // #region preview
            child: Oito2MasterDetailPage(
              length: _settings.length,
              tileBuilder: (context, index, selected, width) {
                final (icon, title, _) = _settings[index];
                return Oito2MasterTile(leading: Icon(icon), title: Text(title));
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
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2MasterDetailPage` the number of items in `length`, a '
          '`tileBuilder` for the list and a `pageBuilder` for the page of '
          'an item. `Oito2MasterTile` takes its selection and tap action '
          'from the list, and `Oito2DetailPage` adds a title bar with a back '
          'button when the page can be popped. Instead of `length`, an '
          '`Oito2PageController` can hold the item count and the selection; '
          'give one or the other.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'At or above `breakpoint` wide, 620 pixels by default, the list is '
          'a resizable pane beside the page, and the first item is selected '
          'when nothing is. Below it, the list fills the view and selecting '
          'an item pushes its page on a nested navigator; going back clears '
          'the selection. The selection survives switching between the two '
          'layouts. Resize the frame above to see both.',
        ),
        const DocNote(
          'The breakpoint, pane sizes, list padding, tile spacing and pane '
          'color default to the theme\'s `Oito2MasterDetailThemeData`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Narrow layout', level: 3),
        const DocText(
          'In a view narrower than the breakpoint, the list starts without '
          'a selection. Select an item to push its page, then use the back '
          'button of its title bar; the system back button also returns to '
          'the list.',
        ),
        ExamplePanel(
          region: 'narrow',
          child: SizedBox(
            width: 360,
            height: 340,
            child: Oito2BorderContainer(
              // #region narrow
              child: Oito2MasterDetailPage(
                length: _settings.length,
                tileBuilder: (context, index, selected, width) {
                  final (icon, title, subtitle) = _settings[index];
                  return Oito2MasterTile(
                    leading: Icon(icon),
                    title: Text(title),
                    subtitle: Text(subtitle),
                  );
                },
                pageBuilder: (context, index) => Oito2DetailPage(
                  title: Text(_settings[index].$2),
                  body: Center(child: Text(_settings[index].$3)),
                ),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Fixed pane and footer', level: 3),
        const DocText(
          'With `resizable: false` the pane keeps `paneSize`. '
          '`masterFooter` sits below the list, and `masterBar` above it, '
          'such as a title bar with a search field.',
        ),
        ExamplePanel(
          region: 'footer',
          child: SizedBox(
            width: 560,
            height: 300,
            child: Oito2BorderContainer(
              // #region footer
              child: Oito2MasterDetailPage(
                length: _settings.length,
                resizable: false,
                breakpoint: 480,
                paneSize: 200,
                minPageSize: 200,
                masterFooter: Padding(
                  padding: const EdgeInsets.all(Oito2Spacing.md),
                  child: Text(
                    '${_settings.length} sections',
                    style: textTheme.bodySmall,
                  ),
                ),
                tileBuilder: (context, index, selected, width) =>
                    Oito2MasterTile(title: Text(_settings[index].$2)),
                pageBuilder: (context, index) => Oito2DetailPage(
                  title: Text(_settings[index].$2),
                  body: Center(child: Text(_settings[index].$3)),
                ),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Empty list', level: 3),
        const DocText(
          'When there are no items, `emptyBuilder` replaces the list. A '
          '`masterBar` and a `masterFooter` stay around it, so a search that '
          'matches nothing can still be cleared.',
        ),
        ExamplePanel(
          region: 'empty',
          child: SizedBox(
            width: 360,
            height: 200,
            child: Oito2BorderContainer(
              // #region empty
              child: Oito2MasterDetailPage(
                length: 0,
                emptyBuilder: (context) =>
                    const Center(child: Text('No settings match')),
                tileBuilder: (context, index, selected, width) =>
                    const SizedBox.shrink(),
                pageBuilder: (context, index) => const SizedBox.shrink(),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The tiles of `Oito2MasterTile` are `ListTile`s that report the '
          'shown item as selected. The list scrolls the selected tile into '
          'view when the selection changes. In the side-by-side layout the '
          'divider is a "Resize pane" slider, as in `Oito2PanedView`.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus through the tiles and the divider.'],
            ['`Enter` / `Space`', 'Selects the focused tile.'],
            [
              '`Left arrow` / `Right arrow`',
              'Moves the focused divider, when the pane is resizable.',
            ],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2MasterDetailPage',
          'Oito2MasterTile',
          'Oito2DetailPage',
          'Oito2MasterTileBuilder',
          'Oito2MasterListView',
          'Oito2MasterTileScope',
          'Oito2MasterDetailThemeData',
        ]),
      ],
    );
  }
}
