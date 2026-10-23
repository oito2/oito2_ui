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

/// Documents [Oito2NumberEntry]: whole numbers, decimal steps and a
/// read-only entry.
class NumberEntryPage extends StatefulWidget {
  /// Creates the number entry page.
  const NumberEntryPage({super.key});

  @override
  State<NumberEntryPage> createState() => _NumberEntryPageState();
}

class _NumberEntryPageState extends State<NumberEntryPage> {
  double _copies = 1;
  double _scale = 1.5;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Number Entry',
      description:
          'A number field with decrease and increase buttons, stepped with '
          'the keyboard, the mouse wheel or by dragging the buttons.',
      source: 'lib/src/pages/number_entry_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 200,
            // #region preview
            child: Oito2NumberEntry(
              value: _copies,
              min: 1,
              max: 99,
              labelText: 'Copies',
              onChanged: (value) => setState(() => _copies = value),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'The entry is controlled: give it the `value` and update it in '
          '`onChanged`. It shows the value in the locale\'s number format. '
          'Typed text is read when the field loses the focus or on Enter: '
          'it is rounded, kept between `min` and `max` and reported, and '
          'text that isn\'t a number is replaced by the current value.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The buttons change the value by `step`, 1 by default, and turn '
          'off at the bounds. While the field has the focus the mouse '
          'wheel steps too, and dragging sideways on the buttons changes '
          'the value one step per 4 pixels.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Decimals and step', level: 3),
        const DocText(
          '`decimals` sets the decimal places shown and kept, 0 by default, '
          'and `step` the change of the buttons, the arrow keys and the '
          'wheel. `pageStep`, ten steps by default, is the change of Page '
          'Up and Page Down.',
        ),
        ExamplePanel(
          region: 'decimals',
          child: SizedBox(
            width: 200,
            // #region decimals
            child: Oito2NumberEntry(
              value: _scale,
              min: 0.25,
              max: 4,
              step: 0.25,
              decimals: 2,
              labelText: 'Scale',
              onChanged: (value) => setState(() => _scale = value),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Read-only', level: 3),
        const DocText(
          'A null `onChanged` makes the entry read-only: the text can\'t '
          'be edited and the buttons, the arrow keys and the wheel do nothing.',
        ),
        const ExamplePanel(
          region: 'read-only',
          child: SizedBox(
            width: 200,
            // #region read-only
            child: Oito2NumberEntry(
              value: 42,
              onChanged: null,
              labelText: 'Read-only',
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The buttons have the tooltips "Decrease" and "Increase", which '
          'also name them for assistive technologies. The field opens a '
          'numeric keyboard, with a sign key when `min` is negative and a '
          'decimal key when `decimals` is above 0.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Up arrow` / `Down arrow`',
              'Raises or lowers the value by `step`.',
            ],
            [
              '`Page Up` / `Page Down`',
              'Raises or lowers the value by `pageStep`.',
            ],
            [
              '`Home` / `End`',
              'Sets the value to `min` or `max`, when that bound is finite.',
            ],
            ['`Enter`', 'Applies the typed text.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2NumberEntry']),
      ],
    );
  }
}
