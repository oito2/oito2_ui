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

/// Documents [Oito2RadioButton]: a group, subtitles, a toggleable group
/// and a disabled button.
class RadioButtonPage extends StatefulWidget {
  /// Creates the radio button page.
  const RadioButtonPage({super.key});

  @override
  State<RadioButtonPage> createState() => _RadioButtonPageState();
}

class _RadioButtonPageState extends State<RadioButtonPage> {
  String _sort = 'name';
  String _quality = 'high';
  String? _filter = 'images';

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Radio Button',
      description:
          'A radio with a clickable label, for picking one option of a '
          'group.',
      source: 'lib/src/pages/radio_button_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (value, label) in const [
                ('name', 'Sort by name'),
                ('size', 'Sort by size'),
                ('date', 'Sort by date'),
              ])
                Oito2RadioButton<String>(
                  value: value,
                  groupValue: _sort,
                  onChanged: (value) => setState(() => _sort = value!),
                  title: Text(label),
                ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give each `Oito2RadioButton` of a group its own `value` and the '
          'same `groupValue`, the selected value. A button is selected when '
          'its `value` equals `groupValue`; a click anywhere on the row calls '
          '`onChanged` with its `value`. A null `onChanged` disables the '
          'button and dims its text.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'The radio button is an `Oito2Radio` inside an '
          '`Oito2ToggleButton`. For a few short options on one line, '
          'consider `Oito2SegmentGroup`; in a list of tiles, use '
          '`Oito2RadioListTile`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('With subtitles', level: 3),
        const DocText('A `subtitle` adds secondary text under the label.'),
        ExamplePanel(
          region: 'subtitle',
          // #region subtitle
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Oito2RadioButton<String>(
                value: 'high',
                groupValue: _quality,
                onChanged: (value) => setState(() => _quality = value!),
                title: const Text('High quality'),
                subtitle: const Text('Larger files'),
              ),
              Oito2RadioButton<String>(
                value: 'low',
                groupValue: _quality,
                onChanged: (value) => setState(() => _quality = value!),
                title: const Text('Low quality'),
                subtitle: const Text('Smaller files'),
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Toggleable', level: 3),
        const DocText(
          'With `toggleable: true`, activating the selected button clears '
          'the group: `onChanged` receives null. Without it, activating the '
          'selected button does nothing.',
        ),
        ExamplePanel(
          region: 'toggleable',
          // #region toggleable
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (value, label) in const [
                ('images', 'Only images'),
                ('videos', 'Only videos'),
              ])
                Oito2RadioButton<String>(
                  value: value,
                  groupValue: _filter,
                  toggleable: true,
                  onChanged: (value) => setState(() => _filter = value),
                  title: Text(label),
                ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'Without `onChanged`, the button keeps showing whether it is '
          'selected but can\'t be picked.',
        ),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2RadioButton<String>(
            value: 'type',
            groupValue: 'name',
            onChanged: null,
            title: Text('Sort by type'),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each row reads as one element to assistive technologies: the '
          'label with the state of a radio in a group of mutually exclusive '
          'choices. The row takes keyboard focus as a whole and shows the '
          'focus ring around itself; the radio inside is kept out of focus '
          'traversal, so each button is its own `Tab` stop.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next button.'],
            ['`Space` / `Enter`', 'Selects the focused button.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2RadioButton']),
      ],
    );
  }
}
