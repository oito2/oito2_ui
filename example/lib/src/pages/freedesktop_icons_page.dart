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

/// Shows every [Oito2FreedesktopIcons] value with its freedesktop name,
/// filtered by a search query.
class FreedesktopIconsPage extends StatefulWidget {
  /// Creates the freedesktop icons page.
  const FreedesktopIconsPage({super.key});

  @override
  State<FreedesktopIconsPage> createState() => _FreedesktopIconsPageState();
}

class _FreedesktopIconsPageState extends State<FreedesktopIconsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final words = _query.toLowerCase().split(' ').where((w) => w.isNotEmpty);
    final icons = [
      for (final icon in Oito2FreedesktopIcons.values)
        if (words.every(icon.iconName.contains)) icon,
    ];
    final small = Theme.of(context).textTheme.bodySmall;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Search ${Oito2FreedesktopIcons.values.length} icon names',
          children: [
            SizedBox(
              width: 300,
              child: Oito2SearchField(
                hintText: 'document-open',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          '${icons.length} icons',
          children: [
            for (final icon in icons)
              Tooltip(
                message: 'Oito2FreedesktopIcons.${icon.name}',
                child: SizedBox(
                  width: 140,
                  child: Column(
                    spacing: Oito2Spacing.xs,
                    children: [
                      Icon(icon.icon),
                      Oito2HighlightedText(
                        icon.iconName,
                        query: _query,
                        style: small,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
