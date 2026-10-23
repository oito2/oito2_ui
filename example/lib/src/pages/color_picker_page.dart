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

// #region swatches
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
// #endregion

/// Documents [Oito2ColorPicker] inline and [Oito2ColorPickerButton].
class ColorPickerPage extends StatefulWidget {
  /// Creates the color picker page.
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  Color _inline = const Color(0xFF3584E4);
  Color _rgb = const Color(0xFFF6D32D);
  Color _button = const Color(0xFF2EC27E);

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Color Picker',
      description:
          'Picks a color with a saturation and brightness area, hue and '
          'opacity sliders, text fields and preset swatches.',
      source: 'lib/src/pages/color_picker_page.dart',
      children: [
        ExamplePanel(
          regions: const ['swatches', 'preview'],
          // #region preview
          child: Oito2ColorPicker(
            value: _inline,
            swatches: _swatches,
            onChanged: (color) => setState(() => _inline = color),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2ColorPicker` is controlled: give it the `value` and update '
          'it in `onChanged`, which is called with each new color. The '
          'fields apply their text on Enter or when they lose the focus, '
          'and text that isn\'t a valid color is replaced by the current '
          'one. `swatches` adds preset colors below the fields, and `width` '
          'sets the picker width, 264 by default.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'The picker keeps the hue while the color is gray, where the hue '
          'has no effect, so moving back out of gray returns to the same '
          'hue.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Format and opacity', level: 3),
        const DocText(
          'The buttons below the fields switch between one hex field and '
          'RGB or HSL fields; `initialFormat` chooses the one shown first. '
          'With `showAlpha` set to false the opacity slider hides, the hex '
          'field leaves out the alpha channel and edits keep the current '
          'opacity.',
        ),
        ExamplePanel(
          region: 'format',
          // #region format
          child: Oito2ColorPicker(
            value: _rgb,
            initialFormat: Oito2ColorFormat.rgb,
            showAlpha: false,
            onChanged: (color) => setState(() => _rgb = color),
          ),
          // #endregion
        ),
        const DocHeading('In a popover', level: 3),
        const DocText(
          '`Oito2ColorPickerButton` shows a swatch of the color and its hex '
          'value, and opens the picker in a popover. `semanticLabel` says '
          'what the color is for. A null `onChanged` disables the button.',
        ),
        ExamplePanel(
          regions: const ['swatches', 'button'],
          // #region button
          child: Oito2ColorPickerButton(
            value: _button,
            showAlpha: false,
            swatches: _swatches,
            semanticLabel: 'Tag color',
            onChanged: (color) => setState(() => _button = color),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies see the area as two sliders, saturation '
          'and brightness, and the hue and opacity as sliders that read '
          'their value in degrees or percent. The RGB and HSL fields are '
          'labeled with the channel names, and each swatch is named by its '
          'hex value.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              'Arrows on the area',
              'Move the saturation (across) or the brightness (up and down) '
                  'by 1%, or 10% with `Shift`.',
            ],
            [
              '`Right arrow` / `Left arrow` on a slider',
              'Raise or lower the value by 1%, or 10% with `Shift` '
                  '(mirrored in right-to-left layouts).',
            ],
            [
              '`Up arrow` / `Down arrow` on a slider',
              'Raise or lower the value by 1%.',
            ],
            ['`Enter` in a field', 'Applies the typed value.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2ColorPicker',
          'Oito2ColorPickerButton',
          'Oito2ColorFormat',
        ]),
      ],
    );
  }
}
