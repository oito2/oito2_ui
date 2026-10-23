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

/// Documents [Oito2CheckboxListTile], [Oito2RadioListTile] and
/// [Oito2SwitchListTile] in a tile list.
class ToggleListTilePage extends StatefulWidget {
  /// Creates the toggle list tile page.
  const ToggleListTilePage({super.key});

  @override
  State<ToggleListTilePage> createState() => _ToggleListTilePageState();
}

class _ToggleListTilePageState extends State<ToggleListTilePage> {
  bool _thumbnails = true;
  String _view = 'grid';
  bool _hidden = false;
  bool _wifi = true;
  bool? _all = false;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Toggle List Tile',
      description:
          'List tiles with a check box, a radio or a switch, toggled by a '
          'tap anywhere on the tile.',
      source: 'lib/src/pages/toggle_list_tile_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 420,
            // #region preview
            child: Oito2BorderContainer(
              child: Column(
                children: [
                  Oito2CheckboxListTile(
                    value: _thumbnails,
                    onChanged: (value) =>
                        setState(() => _thumbnails = value ?? false),
                    title: const Text('Show thumbnails'),
                    secondary: const Icon(LucideIcons.image),
                  ),
                  for (final (value, label) in const [
                    ('grid', 'Grid view'),
                    ('list', 'List view'),
                  ])
                    Oito2RadioListTile<String>(
                      value: value,
                      groupValue: _view,
                      onChanged: (value) => setState(() => _view = value!),
                      title: Text(label),
                    ),
                  Oito2SwitchListTile(
                    value: _hidden,
                    onChanged: (value) => setState(() => _hidden = value),
                    title: const Text('Hidden files'),
                    subtitle: const Text('Files whose name starts with a dot'),
                  ),
                ],
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Each tile is a `ListTile` with a control: `Oito2CheckboxListTile` '
          'takes the `value` and `onChanged` of an `Oito2Checkbox`, '
          '`Oito2RadioListTile` the `value`, `groupValue` and `onChanged` '
          'of an `Oito2Radio`, and `Oito2SwitchListTile` those of an '
          '`Oito2Switch`. A tap anywhere on the tile changes the value. A '
          'null `onChanged` disables the whole tile.',
        ),
        const DocText(
          'A `secondary` widget, such as an icon, sits on the side opposite '
          'the control. The tiles also take a `subtitle` and a '
          '`contentPadding`.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'Use these tiles in lists and settings panels made of `ListTile`s. '
          'For a compact row outside a list, use `Oito2CheckButton`, '
          '`Oito2RadioButton` or `Oito2SwitchButton`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Control side', level: 3),
        const DocText(
          '`controlAffinity` places the control. With the default, '
          '`Oito2ControlAffinity.platform`, check boxes and radios lead and '
          'switches trail; `leading` and `trailing` force a side.',
        ),
        ExamplePanel(
          region: 'affinity',
          child: SizedBox(
            width: 420,
            // #region affinity
            child: Oito2SwitchListTile(
              value: _wifi,
              onChanged: (value) => setState(() => _wifi = value),
              controlAffinity: Oito2ControlAffinity.leading,
              title: const Text('Wi-Fi'),
              secondary: const Icon(LucideIcons.wifi),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Tri-state', level: 3),
        const DocText(
          'With `tristate: true`, a check box tile cycles through the mixed '
          'state: a null `value`, shown as a dash.',
        ),
        ExamplePanel(
          region: 'tristate',
          child: SizedBox(
            width: 420,
            // #region tristate
            child: Oito2CheckboxListTile(
              value: _all,
              tristate: true,
              onChanged: (value) => setState(() => _all = value),
              title: const Text('Select all'),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'Without `onChanged`, the tile and its control are dimmed and '
          'ignore taps.',
        ),
        const ExamplePanel(
          region: 'disabled',
          child: SizedBox(
            width: 420,
            // #region disabled
            child: Oito2SwitchListTile(
              value: false,
              onChanged: null,
              title: Text('Unavailable option'),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each tile reads as one element to assistive technologies, '
          'merging its text with the state of its control. The tile takes '
          'keyboard focus; the control inside is kept out of focus '
          'traversal.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next tile.'],
            ['`Space` / `Enter`', 'Changes the value of the focused tile.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2CheckboxListTile',
          'Oito2RadioListTile',
          'Oito2SwitchListTile',
          'Oito2ControlAffinity',
        ]),
      ],
    );
  }
}
