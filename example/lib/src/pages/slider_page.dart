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

const _percentMarks = [
  Oito2SliderMark(0, label: '0%'),
  Oito2SliderMark(25, label: '25%'),
  Oito2SliderMark(50, label: '50%'),
  Oito2SliderMark(75, label: '75%'),
  Oito2SliderMark(100, label: '100%'),
];

/// Documents [Oito2Slider] and [Oito2RangeSlider]: labels, steps, marks,
/// ranges and a vertical track.
class SliderPage extends StatefulWidget {
  /// Creates the slider page.
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  double _value = 30;
  double _volume = 40;
  double _steps = 50;
  double _level = 60;
  RangeValues _price = const RangeValues(20, 80);

  String _percent(double value) => '${value.round()}%';

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Slider',
      description:
          'Picks a value, or a range, by dragging a thumb along a track, '
          'with the arrow keys, or with assistive technologies.',
      source: 'lib/src/pages/slider_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 300,
            // #region preview
            child: Oito2Slider(
              value: _value,
              max: 100,
              onChanged: (value) => setState(() => _value = value),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2Slider` is controlled: give it the `value` and update it in '
          '`onChanged`. A null `onChanged` disables it. Values run from `min` '
          'to `max`, 0 to 1 by default.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'The slider is a Material `Slider` drawn with a thick rounded '
          'track and a ring thumb, so it keeps the keyboard, pointer and '
          'accessibility behavior of `Slider`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Label and value', level: 3),
        const DocText(
          'A `label` names the slider above the track, and `valueText` '
          'formats the value shown beside it. With `showValueIndicator`, '
          'the formatted value also floats above the thumb while dragging.',
        ),
        ExamplePanel(
          region: 'label',
          child: SizedBox(
            width: 300,
            // #region label
            child: Oito2Slider(
              value: _volume,
              max: 100,
              label: const Text('Volume'),
              valueText: _percent,
              showValueIndicator: true,
              onChanged: (value) => setState(() => _volume = value),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Steps and marks', level: 3),
        const DocText(
          '`divisions` splits the range into equal steps that the thumb '
          'snaps to. `marks` put a dot, and an optional label, under '
          'chosen values; the dots the value has reached take the accent '
          'color.',
        ),
        ExamplePanel(
          region: 'marks',
          child: SizedBox(
            width: 300,
            // #region marks
            child: Oito2Slider(
              value: _steps,
              max: 100,
              divisions: 4,
              marks: _percentMarks,
              onChanged: (value) => setState(() => _steps = value),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Range', level: 3),
        const DocText(
          '`Oito2RangeSlider` picks a start and an end with two thumbs. Its '
          '`valueText` formats each end, shown as "start – end".',
        ),
        ExamplePanel(
          region: 'range',
          child: SizedBox(
            width: 300,
            // #region range
            child: Oito2RangeSlider(
              values: _price,
              max: 100,
              label: const Text('Price'),
              valueText: (value) => '\$${value.round()}',
              onChanged: (values) => setState(() => _price = values),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Vertical', level: 3),
        const DocText(
          'With `orientation: Axis.vertical` the track stands `length` '
          'pixels tall with its minimum at the bottom, also in right-to-left '
          'layouts, and the mark labels sit beside it.',
        ),
        ExamplePanel(
          region: 'vertical',
          minHeight: 220,
          // #region vertical
          child: Oito2Slider(
            value: _level,
            max: 100,
            orientation: Axis.vertical,
            length: 160,
            marks: const [
              Oito2SliderMark(0, label: 'Low'),
              Oito2SliderMark(50),
              Oito2SliderMark(100, label: 'High'),
            ],
            onChanged: (value) => setState(() => _level = value),
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'A null `onChanged` disables the slider: it ignores input, greys '
          'out, and assistive technologies report it as disabled.',
        ),
        const ExamplePanel(
          region: 'disabled',
          child: SizedBox(
            width: 300,
            // #region disabled
            child: Oito2Slider(value: 0.3, onChanged: null),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each thumb is a slider for assistive technologies, which read '
          'its value through `valueText` and can raise or lower it. The '
          'thumb shows the focus ring when reached with the keyboard.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the thumb.'],
            [
              '`Right arrow` / `Up arrow`',
              'Raises the value by one division; without divisions, by 5% of the range (10% on macOS and iOS).',
            ],
            [
              '`Left arrow` / `Down arrow`',
              'Lowers the value by one division; without divisions, by 5% of the range (10% on macOS and iOS).',
            ],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2Slider',
          'Oito2RangeSlider',
          'Oito2SliderMark',
        ]),
      ],
    );
  }
}
