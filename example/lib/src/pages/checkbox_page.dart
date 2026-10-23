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

/// Documents [Oito2Checkbox]: two states, three states and disabled.
class CheckboxPage extends StatefulWidget {
  /// Creates the check box page.
  const CheckboxPage({super.key});

  @override
  State<CheckboxPage> createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  bool _checked = true;
  bool? _tristate;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Checkbox',
      description:
          'A box that is checked or unchecked, with an optional mixed '
          'state, painted in the oito2 style.',
      source: 'lib/src/pages/checkbox_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2Checkbox(
            value: _checked,
            semanticLabel: 'Two-state check box',
            onChanged: (value) => setState(() => _checked = value ?? false),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Pass the current `value` and update it in `onChanged`, which '
          'receives the next value. A null `onChanged` disables the box, '
          'which then shows dimmed. When no label around the box names it, '
          'give it a `semanticLabel`.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'A check box usually comes with a label. `Oito2CheckButton` adds a '
          'clickable one beside the box, and `Oito2CheckboxListTile` puts '
          'the box in a list tile.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Three states', level: 3),
        const DocText(
          'With `tristate: true`, a null `value` is the mixed state, shown '
          'as a dash. A tap moves from unchecked to checked, from checked '
          'to mixed, and from mixed back to unchecked. A null `value` '
          'without `tristate` fails an assertion in debug builds.',
        ),
        ExamplePanel(
          region: 'tristate',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // #region tristate
              Oito2Checkbox(
                value: _tristate,
                tristate: true,
                semanticLabel: 'Three-state check box',
                onChanged: (value) => setState(() => _tristate = value),
              ),
              // #endregion
              Text(
                'Value: $_tristate',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'Without `onChanged`, the box shows its value dimmed and ignores '
          'taps and keys.',
        ),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Oito2Checkbox(value: false, onChanged: null),
              Oito2Checkbox(value: true, onChanged: null),
              Oito2Checkbox(value: null, tristate: true, onChanged: null),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read the box as checked, unchecked or '
          'mixed, with its `semanticLabel`. The box is 20 pixels in a '
          '34-pixel target on pointer platforms, and 24 pixels in a '
          '48-pixel target on touch platforms. The focus ring shows in '
          'keyboard navigation.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the box, and out of it.'],
            ['`Space` / `Enter`', 'Toggles the focused box.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2Checkbox']),
      ],
    );
  }
}
