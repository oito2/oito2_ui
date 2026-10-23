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

/// Documents [Oito2PlaceholderIcon] at several sizes and corner radii,
/// and in a list.
class PlaceholderIconPage extends StatelessWidget {
  /// Creates the placeholder icon page.
  const PlaceholderIconPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Placeholder Icon',
      description:
          'A decorative square that stands in for a missing picture, such '
          'as an album cover or an app icon that has not loaded.',
      source: 'lib/src/pages/placeholder_icon_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2PlaceholderIcon(),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2PlaceholderIcon` fills a rounded square with a container '
          'tone of the color scheme and draws a picture outline in its '
          'center. `size` sets the width and height, 48 pixels by default, '
          'and `borderRadius` the corners, the medium radius by default.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Sizes', level: 3),
        const DocText(
          'The outline scales with the square. Match the radius to the '
          'size, smaller corners for smaller squares.',
        ),
        const ExamplePanel(
          region: 'sizes',
          child: Wrap(
            spacing: Oito2Spacing.lg,
            runSpacing: Oito2Spacing.lg,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // #region sizes
              Oito2PlaceholderIcon(
                size: 24,
                borderRadius: Oito2Radius.checkAll,
              ),
              Oito2PlaceholderIcon(
                size: 32,
                borderRadius: Oito2Radius.smallAll,
              ),
              Oito2PlaceholderIcon(),
              Oito2PlaceholderIcon(
                size: 96,
                borderRadius: Oito2Radius.largeAll,
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Round', level: 3),
        const DocText('A radius of half the size makes a circle.'),
        const ExamplePanel(
          region: 'round',
          // #region round
          child: Oito2PlaceholderIcon(
            size: 64,
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          // #endregion
        ),
        const DocHeading('In a list', level: 3),
        const DocText(
          'As the `leading` of a list row, it keeps the layout of rows '
          'whose picture is missing.',
        ),
        ExamplePanel(
          region: 'list',
          child: SizedBox(
            width: 360,
            child: Column(
              children: [
                // #region list
                for (final title in ['Album one', 'Album two'])
                  Oito2ListTile(
                    leading: const Oito2PlaceholderIcon(size: 40),
                    title: Text(title),
                    subtitle: const Text('Cover not loaded'),
                  ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The placeholder is hidden from assistive technologies. Describe '
          'the missing picture in the surrounding text when it matters.',
        ),
        ...apiReferenceWidgets(['Oito2PlaceholderIcon']),
      ],
    );
  }
}
