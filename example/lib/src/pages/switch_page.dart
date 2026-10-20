// Copyright (C) 2026  oito2
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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2Switch] with and without on/off shapes.
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
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Switch',
          children: [
            Oito2Switch(
              value: _plain,
              semanticLabel: 'Switch',
              onChanged: (v) => setState(() => _plain = v),
            ),
          ],
        ),
        ShowcaseSection(
          'On/off shapes, for states that do not rely on color',
          children: [
            Oito2Switch(
              value: _shapes,
              onOffShapes: true,
              semanticLabel: 'Switch with shapes',
              onChanged: (v) => setState(() => _shapes = v),
            ),
          ],
        ),
        const ShowcaseSection(
          'Disabled',
          children: [
            Oito2Switch(value: false, onChanged: null),
            Oito2Switch(value: true, onChanged: null),
          ],
        ),
      ],
    );
  }
}
