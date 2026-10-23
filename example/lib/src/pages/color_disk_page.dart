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

/// Shows [Oito2ColorDisk] in a group whose arrow-key focus stays inside
/// an [Oito2EdgeFocusInterceptor].
class ColorDiskPage extends StatefulWidget {
  /// Creates the color disk page.
  const ColorDiskPage({super.key});

  @override
  State<ColorDiskPage> createState() => _ColorDiskPageState();
}

class _ColorDiskPageState extends State<ColorDiskPage> {
  Oito2AccentColor _accent = Oito2AccentColor.blue;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Color disks',
          children: [
            Oito2EdgeFocusInterceptor(
              child: Wrap(
                spacing: Oito2Spacing.xs,
                children: [
                  for (final accent in Oito2AccentColor.values)
                    Oito2ColorDisk(
                      color: accent.color,
                      label: accent.name,
                      selected: _accent == accent,
                      onPressed: () => setState(() => _accent = accent),
                    ),
                ],
              ),
            ),
            Text(
              'Arrow keys stay inside this group; Tab leaves it.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
