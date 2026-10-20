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

/// Shows [Oito2SwitchButton] with and without a subtitle.
class SwitchButtonPage extends StatefulWidget {
  /// Creates the switch button page.
  const SwitchButtonPage({super.key});

  @override
  State<SwitchButtonPage> createState() => _SwitchButtonPageState();
}

class _SwitchButtonPageState extends State<SwitchButtonPage> {
  bool _dark = false;
  bool _sounds = true;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Switch buttons',
          children: [
            SizedBox(
              width: 320,
              child: Column(
                children: [
                  Oito2SwitchButton(
                    value: _dark,
                    onChanged: (v) => setState(() => _dark = v),
                    title: const Text('Dark style'),
                    subtitle: const Text('Applies to this window'),
                  ),
                  Oito2SwitchButton(
                    value: _sounds,
                    onChanged: (v) => setState(() => _sounds = v),
                    title: const Text('Alert sounds'),
                  ),
                  const Oito2SwitchButton(
                    value: false,
                    onChanged: null,
                    title: Text('Unavailable option'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
