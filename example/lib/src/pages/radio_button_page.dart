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

/// Shows [Oito2RadioButton] in a group.
class RadioButtonPage extends StatefulWidget {
  /// Creates the radio button page.
  const RadioButtonPage({super.key});

  @override
  State<RadioButtonPage> createState() => _RadioButtonPageState();
}

class _RadioButtonPageState extends State<RadioButtonPage> {
  String _sort = 'name';

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Radio buttons',
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (value, label) in const [
                  ('name', 'Sort by name'),
                  ('size', 'Sort by size'),
                  ('date', 'Sort by date'),
                ])
                  Oito2RadioButton<String>(
                    value: value,
                    groupValue: _sort,
                    onChanged: (v) => setState(() => _sort = v ?? 'name'),
                    title: Text(label),
                  ),
                const Oito2RadioButton<String>(
                  value: 'type',
                  groupValue: 'name',
                  onChanged: null,
                  title: Text('Sort by type (disabled)'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
