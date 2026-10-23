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

const _percentMarks = [
  Oito2SliderMark(0, label: '0%'),
  Oito2SliderMark(25, label: '25%'),
  Oito2SliderMark(50, label: '50%'),
  Oito2SliderMark(75, label: '75%'),
  Oito2SliderMark(100, label: '100%'),
];

/// Shows [Oito2Slider] and [Oito2RangeSlider] with labels, steps, marks
/// and a vertical track.
class SliderPage extends StatefulWidget {
  /// Creates the slider page.
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  double _volume = 40;
  double _steps = 50;
  double _level = 60;
  RangeValues _price = const RangeValues(20, 80);

  String _percent(double value) => '${value.round()}%';

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Label and value',
          children: [
            SizedBox(
              width: 300,
              child: Oito2Slider(
                value: _volume,
                max: 100,
                label: const Text('Volume'),
                valueText: _percent,
                showValueIndicator: true,
                onChanged: (v) => setState(() => _volume = v),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Steps with marks',
          children: [
            SizedBox(
              width: 300,
              child: Oito2Slider(
                value: _steps,
                max: 100,
                divisions: 4,
                marks: _percentMarks,
                onChanged: (v) => setState(() => _steps = v),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Range',
          children: [
            SizedBox(
              width: 300,
              child: Oito2RangeSlider(
                values: _price,
                max: 100,
                label: const Text('Price'),
                valueText: (v) => '\$${v.round()}',
                showValueIndicator: true,
                onChanged: (v) => setState(() => _price = v),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Vertical and disabled',
          children: [
            Oito2Slider(
              value: _level,
              max: 100,
              orientation: Axis.vertical,
              length: 160,
              marks: const [
                Oito2SliderMark(0, label: 'Low'),
                Oito2SliderMark(50),
                Oito2SliderMark(100, label: 'High'),
              ],
              onChanged: (v) => setState(() => _level = v),
            ),
            const SizedBox(
              width: 240,
              child: Oito2Slider(value: 0.3, onChanged: null),
            ),
          ],
        ),
      ],
    );
  }
}
