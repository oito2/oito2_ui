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

/// Documents [Oito2ToggleButton] with a custom control: the whole row is
/// clickable and takes keyboard focus as one element.
class ToggleButtonPage extends StatefulWidget {
  /// Creates the toggle button page.
  const ToggleButtonPage({super.key});

  @override
  State<ToggleButtonPage> createState() => _ToggleButtonPageState();
}

class _ToggleButtonPageState extends State<ToggleButtonPage> {
  bool _sync = true;
  bool _notify = false;
  bool _preview = false;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Toggle Button',
      description:
          'A clickable row that pairs any toggle control with a label, the '
          'base of the check, radio and switch buttons.',
      source: 'lib/src/pages/toggle_button_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2ToggleButton(
            control: Oito2Checkbox(
              value: _sync,
              onChanged: (value) => setState(() => _sync = value ?? false),
            ),
            title: const Text('Sync files'),
            subtitle: const Text('Control before the text'),
            onToggled: () => setState(() => _sync = !_sync),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Pass the toggle as `control`, the label as `title` and, '
          'optionally, a `subtitle`. A click on the row, or `Space` or '
          '`Enter` while it has focus, calls `onToggled`, where you change '
          'the value the control shows. The control keeps its own callback, '
          'which runs when the control itself is clicked.',
        ),
        const DocText(
          'A null `onToggled` disables the row and dims its text, but not '
          'the control: give the control a null callback too.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For a check box, radio or switch, `Oito2CheckButton`, '
          '`Oito2RadioButton` and `Oito2SwitchButton` already wire the '
          'control and the row together. Use `Oito2ToggleButton` for another '
          'control, or a different arrangement.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Control at the end', level: 3),
        const DocText(
          'With `controlAtEnd: true`, the control follows the text, as in a '
          'switch button.',
        ),
        ExamplePanel(
          region: 'end',
          // #region end
          child: Oito2ToggleButton(
            control: Oito2Switch(
              value: _notify,
              onChanged: (value) => setState(() => _notify = value),
            ),
            controlAtEnd: true,
            title: const Text('Notify me'),
            subtitle: const Text('Control after the text'),
            onToggled: () => setState(() => _notify = !_notify),
          ),
          // #endregion
        ),
        const DocHeading('Custom control', level: 3),
        const DocText(
          'The control can be any widget. Here an `Oito2Swap` changes an '
          'eye icon, and the row handles the clicks.',
        ),
        ExamplePanel(
          region: 'custom',
          // #region custom
          child: Oito2ToggleButton(
            control: Oito2Swap(
              swapped: _preview,
              effect: Oito2SwapEffect.scale,
              off: const Icon(LucideIcons.eye_off),
              on: const Icon(LucideIcons.eye),
            ),
            title: Text(_preview ? 'Preview shown' : 'Preview hidden'),
            onToggled: () => setState(() => _preview = !_preview),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The row reads as one element to assistive technologies, merging '
          'the label with the state the control reports. It takes keyboard '
          'focus as a whole and shows the focus ring around itself; the '
          'control is kept out of focus traversal.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the row, and out of it.'],
            ['`Space` / `Enter`', 'Calls `onToggled`.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2ToggleButton']),
      ],
    );
  }
}
