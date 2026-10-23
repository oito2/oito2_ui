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

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2AngleSlider]: steps and markers turning a preview, a
/// compact dial and a read-only one.
class AngleSliderPage extends StatefulWidget {
  /// Creates the angle slider page.
  const AngleSliderPage({super.key});

  @override
  State<AngleSliderPage> createState() => _AngleSliderPageState();
}

class _AngleSliderPageState extends State<AngleSliderPage> {
  double _direction = 90;
  double _angle = 45;
  double _hue = 200;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DocPage(
      title: 'Angle Slider',
      description:
          'A round dial that picks an angle in degrees, such as a rotation '
          'or a gradient direction.',
      source: 'lib/src/pages/angle_slider_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2AngleSlider(
            value: _direction,
            semanticLabel: 'Direction',
            onChanged: (value) => setState(() => _direction = value),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'The dial is controlled: give it the `value` and update it in '
          '`onChanged`. Angles run from 0 at the top, clockwise, to just '
          'under 360, and wrap around. Dragging or tapping points the dial '
          'at the pointer. `onChangeEnd` receives the final angle when a '
          'drag or tap ends, and after each key press.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Steps and markers', level: 3),
        const DocText(
          '`step` is the increment the angle snaps to, 1 by default, and '
          'the turn of one arrow key; `pageStep`, 15 by default, is the '
          'turn of Page Up and Page Down. `markers` draws ticks at the '
          'given angles, the four quarter turns by default.',
        ),
        ExamplePanel(
          region: 'steps',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.xl,
            children: [
              // #region steps
              Oito2AngleSlider(
                value: _angle,
                step: 5,
                markers: const [0, 45, 90, 135, 180, 225, 270, 315],
                semanticLabel: 'Rotation',
                onChanged: (value) => setState(() => _angle = value),
              ),
              Transform.rotate(
                angle: _angle * math.pi / 180,
                child: Icon(
                  LucideIcons.navigation_2,
                  size: 64,
                  color: scheme.primary,
                ),
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Size and value', level: 3),
        const DocText(
          '`size` is the dial diameter, 96 by default. With `showValue` set '
          'to false the angle isn\'t written in the middle, which suits a '
          'small dial.',
        ),
        ExamplePanel(
          region: 'compact',
          // #region compact
          child: Oito2AngleSlider(
            value: _hue,
            size: 48,
            showValue: false,
            markers: const [],
            semanticLabel: 'Hue',
            onChanged: (value) => setState(() => _hue = value),
          ),
          // #endregion
        ),
        const DocHeading('Read-only', level: 3),
        const DocText(
          'A null `onChanged` makes the dial read-only: it ignores input '
          'and its hand greys out.',
        ),
        const ExamplePanel(
          region: 'read-only',
          // #region read-only
          child: Oito2AngleSlider(
            value: 135,
            semanticLabel: 'Wind direction',
            onChanged: null,
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies see the dial as a slider named by '
          '`semanticLabel`, read the angle in the locale\'s number format '
          'with a degree sign, and can raise or lower it by one `step`. A '
          'read-only dial reports its label and value only. The dial shows '
          'the focus ring when reached with the keyboard.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Up arrow` / `Right arrow`',
              'Turns the dial clockwise by `step`.',
            ],
            [
              '`Down arrow` / `Left arrow`',
              'Turns the dial counterclockwise by `step`.',
            ],
            ['`Page Up` / `Page Down`', 'Turns the dial by `pageStep`.'],
            ['`Home`', 'Sets the angle to 0.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2AngleSlider']),
      ],
    );
  }
}
