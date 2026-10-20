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

/// Shows [Oito2PlaceholderIcon] at several sizes and corner radii.
class PlaceholderIconPage extends StatelessWidget {
  /// Creates the placeholder icon page.
  const PlaceholderIconPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        const ShowcaseSection(
          'Sizes',
          children: [
            Oito2PlaceholderIcon(size: 24, borderRadius: Oito2Radius.checkAll),
            Oito2PlaceholderIcon(size: 32, borderRadius: Oito2Radius.smallAll),
            Oito2PlaceholderIcon(),
            Oito2PlaceholderIcon(size: 96, borderRadius: Oito2Radius.largeAll),
          ],
        ),
        const ShowcaseSection(
          'Round',
          children: [
            Oito2PlaceholderIcon(
              size: 64,
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
          ],
        ),
        ShowcaseSection(
          'In a list',
          children: [
            SizedBox(
              width: 360,
              child: Column(
                children: [
                  for (final title in ['Album one', 'Album two'])
                    Oito2ListTile(
                      leading: const Oito2PlaceholderIcon(size: 40),
                      title: Text(title),
                      subtitle: const Text('Cover not loaded'),
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
