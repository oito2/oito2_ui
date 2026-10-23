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

const _swatches = [
  Color(0xFFE01B24),
  Color(0xFFFF7800),
  Color(0xFFF6D32D),
  Color(0xFF2EC27E),
  Color(0xFF3584E4),
  Color(0xFF9141AC),
  Color(0xFF865E3C),
  Color(0xFF3D3846),
];

/// Shows [Oito2ColorPicker] inline and [Oito2ColorPickerButton].
class ColorPickerPage extends StatefulWidget {
  /// Creates the color picker page.
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  Color _inline = const Color(0xFF3584E4);
  Color _button = const Color(0xFF2EC27E);

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Inline',
          children: [
            Oito2ColorPicker(
              value: _inline,
              swatches: _swatches,
              onChanged: (c) => setState(() => _inline = c),
            ),
          ],
        ),
        ShowcaseSection(
          'In a popover, without opacity',
          children: [
            Oito2ColorPickerButton(
              value: _button,
              showAlpha: false,
              swatches: _swatches,
              semanticLabel: 'Tag color',
              onChanged: (c) => setState(() => _button = c),
            ),
          ],
        ),
      ],
    );
  }
}
