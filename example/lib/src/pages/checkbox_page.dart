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

/// Shows [Oito2Checkbox] in every state.
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
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Two states',
          children: [
            Oito2Checkbox(
              value: _checked,
              semanticLabel: 'Two-state check box',
              onChanged: (v) => setState(() => _checked = v ?? false),
            ),
          ],
        ),
        ShowcaseSection(
          'Three states',
          children: [
            Oito2Checkbox(
              value: _tristate,
              tristate: true,
              semanticLabel: 'Three-state check box',
              onChanged: (v) => setState(() => _tristate = v),
            ),
            Text(
              'Value: $_tristate',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const ShowcaseSection(
          'Disabled',
          children: [
            Oito2Checkbox(value: false, onChanged: null),
            Oito2Checkbox(value: true, onChanged: null),
            Oito2Checkbox(value: null, tristate: true, onChanged: null),
          ],
        ),
      ],
    );
  }
}
