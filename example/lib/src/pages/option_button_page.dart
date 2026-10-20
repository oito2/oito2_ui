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

/// Shows [Oito2OptionButton] with icons and with a color.
class OptionButtonPage extends StatefulWidget {
  /// Creates the option button page.
  const OptionButtonPage({super.key});

  @override
  State<OptionButtonPage> createState() => _OptionButtonPageState();
}

class _OptionButtonPageState extends State<OptionButtonPage> {
  int _accent = 0;

  @override
  Widget build(BuildContext context) {
    final accent = Oito2AccentColor.values[_accent];
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Option buttons',
          children: [
            Oito2OptionButton(
              onPressed: () {},
              label: 'Add',
              child: const Icon(LucideIcons.plus),
            ),
            Oito2OptionButton(
              onPressed: () {},
              label: 'Remove',
              child: const Icon(LucideIcons.minus),
            ),
            Oito2OptionButton.color(
              onPressed: () => setState(
                () => _accent = (_accent + 1) % Oito2AccentColor.values.length,
              ),
              color: accent.color,
              label: 'Accent color: ${accent.name}',
            ),
          ],
        ),
      ],
    );
  }
}
