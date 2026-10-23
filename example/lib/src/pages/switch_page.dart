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

/// Documents [Oito2Switch]: plain, with on/off shapes and disabled.
class SwitchPage extends StatefulWidget {
  /// Creates the switch page.
  const SwitchPage({super.key});

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  bool _plain = true;
  bool _shapes = false;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Switch',
      description:
          'A track with a sliding thumb that turns a setting on or off, '
          'painted in the oito2 style.',
      source: 'lib/src/pages/switch_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2Switch(
            value: _plain,
            semanticLabel: 'Switch',
            onChanged: (value) => setState(() => _plain = value),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Pass the current `value` and update it in `onChanged`. The thumb '
          'slides to the end side when on: the right in left-to-right '
          'layouts, the left in right-to-left ones. A null `onChanged` '
          'disables the switch. When no label around the switch names it, '
          'give it a `semanticLabel`.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'A switch usually comes with a label. `Oito2SwitchButton` adds a '
          'clickable one before it, and `Oito2SwitchListTile` puts the '
          'switch in a list tile.',
        ),
        const DocHeading('Examples'),
        const DocHeading('On and off shapes', level: 3),
        const DocText(
          'With `onOffShapes: true`, the track also shows an "I" while on '
          'and an "O" while off, so the state doesn\'t rely on color alone.',
        ),
        ExamplePanel(
          region: 'shapes',
          // #region shapes
          child: Oito2Switch(
            value: _shapes,
            onOffShapes: true,
            semanticLabel: 'Switch with shapes',
            onChanged: (value) => setState(() => _shapes = value),
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'Without `onChanged`, the switch shows its value dimmed and '
          'ignores taps and keys.',
        ),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Oito2Switch(value: false, onChanged: null),
              Oito2Switch(value: true, onChanged: null),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read the switch as toggled on or off, '
          'with its `semanticLabel`. The track is 42 × 24 pixels on pointer '
          'platforms and 52 × 30 on touch platforms. The focus ring shows in '
          'keyboard navigation.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the switch, and out of it.'],
            ['`Space` / `Enter`', 'Toggles the focused switch.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2Switch']),
      ],
    );
  }
}
