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

/// Shows [Oito2Banner] as selectable app cards.
class BannerPage extends StatefulWidget {
  /// Creates the banner page.
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ShowcasePageBody(
      children: [
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
                  selected: _selected == index,
                  onTap: () => setState(() => _selected = index),
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
      ],
    );
  }
}
