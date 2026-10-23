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

/// Documents [Oito2CheckButton]: two-state, with a subtitle, tri-state and
/// disabled.
class CheckButtonPage extends StatefulWidget {
  /// Creates the check button page.
  const CheckButtonPage({super.key});

  @override
  State<CheckButtonPage> createState() => _CheckButtonPageState();
}

class _CheckButtonPageState extends State<CheckButtonPage> {
  bool _symlinks = true;
  bool _backups = false;
  bool? _hidden = false;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Check Button',
      description:
          'A check box with a clickable label, for an option that is on or '
          'off.',
      source: 'lib/src/pages/check_button_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2CheckButton(
            value: _symlinks,
            onChanged: (value) => setState(() => _symlinks = value ?? false),
            title: const Text('Follow symbolic links'),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2CheckButton` a `title` and the current `value`, and '
          'update the value in `onChanged`. A click anywhere on the row, the '
          'box or the label, toggles it. A null `onChanged` disables the '
          'button and dims its text.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'The check button is an `Oito2Checkbox` inside an '
          '`Oito2ToggleButton`. Use a bare `Oito2Checkbox` when the label is '
          'elsewhere, such as in a table cell, and `Oito2CheckboxListTile` '
          'in a list of tiles.',
        ),
        const DocHeading('Examples'),
        const DocHeading('With a subtitle', level: 3),
        const DocText('A `subtitle` adds secondary text under the label.'),
        ExamplePanel(
          region: 'subtitle',
          // #region subtitle
          child: Oito2CheckButton(
            value: _backups,
            onChanged: (value) => setState(() => _backups = value ?? false),
            title: const Text('Keep backups'),
            subtitle: const Text('Saves a copy before each change'),
          ),
          // #endregion
        ),
        const DocHeading('Tri-state', level: 3),
        const DocText(
          'With `tristate: true`, a null `value` is the mixed state, shown '
          'as a dash. Each click moves from unchecked to checked, from '
          'checked to mixed, and from mixed back to unchecked.',
        ),
        ExamplePanel(
          region: 'tristate',
          // #region tristate
          child: Oito2CheckButton(
            value: _hidden,
            tristate: true,
            onChanged: (value) => setState(() => _hidden = value),
            title: const Text('Show hidden files'),
            subtitle: const Text('Checked, mixed or unchecked'),
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'Without `onChanged`, the button keeps showing its value but '
          'can\'t be changed.',
        ),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2CheckButton(
            value: true,
            onChanged: null,
            title: Text('Disabled option'),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The row reads as one element to assistive technologies: the '
          'label with the checked, unchecked or mixed state of the box. It '
          'takes keyboard focus as a whole and shows the focus ring around '
          'itself; the box inside is kept out of focus traversal.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the button, and out of it.'],
            ['`Space` / `Enter`', 'Toggles the focused button.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2CheckButton']),
      ],
    );
  }
}
