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

/// Documents [Oito2Rating]: whole and half values, more stars, a custom
/// color and read-only.
class RatingPage extends StatefulWidget {
  /// Creates the rating page.
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _whole = 3;
  double _half = 2.5;
  double _score = 7;
  double _love = 2;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Rating',
      description:
          'A row of stars that shows a value and lets the user change it by '
          'clicking, tapping or with the keyboard.',
      source: 'lib/src/pages/rating_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // #region preview
              Oito2Rating(
                value: _whole,
                semanticLabel: 'Quality',
                onChanged: (value) => setState(() => _whole = value),
              ),
              // #endregion
              Text('$_whole'),
            ],
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Pass the current `value`, from 0 to `max`, and update it in '
          '`onChanged`. Hovering previews the value under the pointer, and a '
          'click picks it and focuses the stars, so the keys work next. A '
          'null `onChanged` makes the rating read-only. Give it a '
          '`semanticLabel` that says what is rated.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'A `value` outside 0 to `max`, or a `max` that isn\'t greater than '
          'zero, fails an assertion in debug builds.',
          type: Oito2InfoType.warning,
        ),
        const DocHeading('Examples'),
        const DocHeading('Half stars', level: 3),
        const DocText(
          'With `allowHalf: true`, the value moves in halves: the start half '
          'of a star gives the half value. `size` sets the star size, 24 by '
          'default.',
        ),
        ExamplePanel(
          region: 'half',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // #region half
              Oito2Rating(
                value: _half,
                allowHalf: true,
                size: 32,
                semanticLabel: 'Service',
                onChanged: (value) => setState(() => _half = value),
              ),
              // #endregion
              Text('$_half'),
            ],
          ),
        ),
        const DocHeading('Number of stars', level: 3),
        const DocText('`max` sets the number of stars, 5 by default.'),
        ExamplePanel(
          region: 'max',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // #region max
              Oito2Rating(
                value: _score,
                max: 10,
                size: 20,
                semanticLabel: 'Score',
                onChanged: (value) => setState(() => _score = value),
              ),
              // #endregion
              Text('$_score'),
            ],
          ),
        ),
        const DocHeading('Color', level: 3),
        const DocText(
          '`color` sets the color of the filled stars, the theme\'s warning '
          'color by default.',
        ),
        ExamplePanel(
          region: 'color',
          // #region color
          child: Oito2Rating(
            value: _love,
            color: Oito2AccentColor.pink.color,
            semanticLabel: 'Favorite',
            onChanged: (value) => setState(() => _love = value),
          ),
          // #endregion
        ),
        const DocHeading('Read-only', level: 3),
        const DocText(
          'Without `onChanged`, the rating only shows its value: it takes '
          'no focus and ignores the pointer.',
        ),
        const ExamplePanel(
          region: 'readonly',
          // #region readonly
          child: Oito2Rating(
            value: 4,
            onChanged: null,
            semanticLabel: 'Average rating',
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies see an editable rating as a slider with '
          'its `semanticLabel` and a localized value, such as "3 of 5 '
          'stars", and can increase or decrease it by one step. A read-only '
          'rating reads its label and value only.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the stars, and out of them.'],
            [
              '`Right arrow` / `Up arrow`',
              'Increases the value by one step; in right-to-left layouts, '
                  '`Left arrow` increases it.',
            ],
            [
              '`Left arrow` / `Down arrow`',
              'Decreases the value by one step; in right-to-left layouts, '
                  '`Right arrow` decreases it.',
            ],
            ['`Home` / `End`', 'Sets the value to 0 or to `max`.'],
            ['`0` to `9`', 'Sets that whole value, up to `max`.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2Rating']),
      ],
    );
  }
}
