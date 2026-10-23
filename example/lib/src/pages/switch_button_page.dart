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

/// Documents [Oito2SwitchButton]: plain, with a subtitle and disabled.
class SwitchButtonPage extends StatefulWidget {
  /// Creates the switch button page.
  const SwitchButtonPage({super.key});

  @override
  State<SwitchButtonPage> createState() => _SwitchButtonPageState();
}

class _SwitchButtonPageState extends State<SwitchButtonPage> {
  bool _sounds = true;
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Switch Button',
      description:
          'A switch with a clickable label before it, for a setting that '
          'takes effect at once.',
      source: 'lib/src/pages/switch_button_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2SwitchButton(
            value: _sounds,
            onChanged: (value) => setState(() => _sounds = value),
            title: const Text('Alert sounds'),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2SwitchButton` a `title` and the current `value`, and '
          'update the value in `onChanged`. The label comes first and the '
          'switch after it; a click anywhere on the row toggles it. A null '
          '`onChanged` disables the button and dims its text.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'The switch button is an `Oito2Switch` inside an '
          '`Oito2ToggleButton`. In a list of tiles, use '
          '`Oito2SwitchListTile`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('With a subtitle', level: 3),
        const DocText(
          'A `subtitle` adds secondary text under the label. Give the button '
          'a bounded width so the text wraps.',
        ),
        ExamplePanel(
          region: 'subtitle',
          child: SizedBox(
            width: 320,
            // #region subtitle
            child: Oito2SwitchButton(
              value: _dark,
              onChanged: (value) => setState(() => _dark = value),
              title: const Text('Dark style'),
              subtitle: const Text('Applies to this window'),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'Without `onChanged`, the button keeps showing its value but '
          'can\'t be changed.',
        ),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2SwitchButton(
            value: false,
            onChanged: null,
            title: Text('Unavailable option'),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The row reads as one element to assistive technologies: the '
          'label with the on or off state of the switch. It takes keyboard '
          'focus as a whole and shows the focus ring around itself; the '
          'switch inside is kept out of focus traversal.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the button, and out of it.'],
            ['`Space` / `Enter`', 'Toggles the focused button.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2SwitchButton']),
      ],
    );
  }
}
