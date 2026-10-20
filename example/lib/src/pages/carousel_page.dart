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

/// Shows [Oito2Carousel], with and without automatic scrolling.
class CarouselPage extends StatefulWidget {
  /// Creates the carousel page.
  const CarouselPage({super.key});

  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  final _auto = Oito2CarouselController(autoScroll: true);

  @override
  void dispose() {
    _auto.dispose();
    super.dispose();
  }

  List<Widget> _slides(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return [
      for (final (color, icon, title) in [
        (scheme.primaryContainer, LucideIcons.palette, 'Themes'),
        (scheme.secondaryContainer, LucideIcons.keyboard, 'Shortcuts'),
        (scheme.tertiaryContainer, LucideIcons.languages, 'Languages'),
        (scheme.surfaceContainerHighest, LucideIcons.accessibility, 'Access'),
      ])
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Oito2Spacing.xs),
          decoration: BoxDecoration(
            color: color,
            borderRadius: Oito2Radius.largeAll,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: Oito2Spacing.sm,
            children: [
              Icon(icon, size: 48),
              Text(title, style: textTheme.headlineSmall),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Buttons, dots, arrow keys and swipes',
          children: [
            SizedBox(
              width: 560,
              child: Oito2Carousel(children: _slides(context)),
            ),
          ],
        ),
        ShowcaseSection(
          'Automatic scrolling: pauses on hover and focus',
          children: [
            SizedBox(
              width: 560,
              child: Oito2Carousel(
                controller: _auto,
                height: 180,
                children: _slides(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
