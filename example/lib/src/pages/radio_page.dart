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

/// Documents [Oito2Radio]: a group, a toggleable group and disabled.
class RadioPage extends StatefulWidget {
  /// Creates the radio page.
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  int? _size = 1;
  int? _toggleable;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Radio',
      description:
          'A round button that selects one value of a group, painted in the '
          'oito2 style.',
      source: 'lib/src/pages/radio_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Oito2Radio<int>(
                  value: i,
                  groupValue: _size,
                  semanticLabel: 'Size ${i + 1}',
                  onChanged: (value) => setState(() => _size = value),
                ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give each `Oito2Radio` of a group its own `value` and the same '
          '`groupValue`, the selected value. A radio is selected when its '
          '`value` equals `groupValue`; activating it calls `onChanged` with '
          'its `value`, and activating the selected one does nothing. A '
          'null `onChanged` disables the radio. When no label around the '
          'radio names it, give it a `semanticLabel`.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'A radio usually comes with a label. `Oito2RadioButton` adds a '
          'clickable one beside it, and `Oito2RadioListTile` puts the radio '
          'in a list tile.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Toggleable', level: 3),
        const DocText(
          'With `toggleable: true`, tapping the selected radio clears the '
          'group: `onChanged` receives null, so the group value must be '
          'nullable.',
        ),
        ExamplePanel(
          region: 'toggleable',
          // #region toggleable
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Oito2Radio<int>(
                  value: i,
                  groupValue: _toggleable,
                  toggleable: true,
                  semanticLabel: 'Option ${i + 1}',
                  onChanged: (value) => setState(() => _toggleable = value),
                ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'Without `onChanged`, the radio shows whether it is selected, '
          'dimmed, and ignores taps and keys.',
        ),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Oito2Radio<int>(value: 0, groupValue: 1, onChanged: null),
              Oito2Radio<int>(value: 1, groupValue: 1, onChanged: null),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read each radio as checked or not, in a '
          'group of mutually exclusive choices, with its `semanticLabel`. '
          'The ring is 20 pixels on pointer platforms and 24 on touch '
          'platforms. Each radio is its own focus stop, and the focus ring '
          'shows in keyboard navigation.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next radio.'],
            [
              '`Space` / `Enter`',
              'Selects the focused radio, or clears it when toggleable.',
            ],
          ],
        ),
        ...apiReferenceWidgets(['Oito2Radio']),
      ],
    );
  }
}
