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

/// Shows [Oito2Radio] in a group, a toggleable group and disabled.
class RadioPage extends StatefulWidget {
  /// Creates the radio page.
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  int? _size = 1;
  int? _toggleable;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Group',
          children: [
            for (var i = 0; i < 3; i++)
              Oito2Radio<int>(
                value: i,
                groupValue: _size,
                semanticLabel: 'Size ${i + 1}',
                onChanged: (v) => setState(() => _size = v),
              ),
          ],
        ),
        ShowcaseSection(
          'Toggleable: tap the selected radio to clear it',
          children: [
            for (var i = 0; i < 3; i++)
              Oito2Radio<int>(
                value: i,
                groupValue: _toggleable,
                toggleable: true,
                semanticLabel: 'Option ${i + 1}',
                onChanged: (v) => setState(() => _toggleable = v),
              ),
          ],
        ),
        const ShowcaseSection(
          'Disabled',
          children: [
            Oito2Radio<int>(value: 0, groupValue: 1, onChanged: null),
            Oito2Radio<int>(value: 1, groupValue: 1, onChanged: null),
          ],
        ),
      ],
    );
  }
}
