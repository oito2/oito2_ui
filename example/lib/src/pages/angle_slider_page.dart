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

/// Shows [Oito2AngleSlider] turning a preview.
class AngleSliderPage extends StatefulWidget {
  /// Creates the angle slider page.
  const AngleSliderPage({super.key});

  @override
  State<AngleSliderPage> createState() => _AngleSliderPageState();
}

class _AngleSliderPageState extends State<AngleSliderPage> {
  double _angle = 45;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Drag the dial, or arrows and Page Up/Down; steps of 5°',
          children: [
            Oito2AngleSlider(
              value: _angle,
              step: 5,
              markers: const [0, 45, 90, 135, 180, 225, 270, 315],
              semanticLabel: 'Rotation',
              onChanged: (v) => setState(() => _angle = v),
            ),
            Transform.rotate(
              angle: _angle * 3.141592653589793 / 180,
              child: Icon(
                LucideIcons.navigation_2,
                size: 64,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
