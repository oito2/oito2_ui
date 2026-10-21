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

const _sample = {
  'name': 'oito2_ui',
  'version': '0.1.0',
  'private': false,
  'license': 'GPL-3.0',
  'homepage': null,
  'platforms': ['linux', 'windows', 'macos', 'android', 'ios', 'web'],
  'packages': {
    'oito2_ui': {'tests': 963, 'native': false},
    'oito2_ui_window': {'tests': 7, 'native': true},
  },
};

/// Shows [Oito2JsonTreeView] with a filter.
class JsonTreeViewPage extends StatefulWidget {
  /// Creates the JSON tree view page.
  const JsonTreeViewPage({super.key});

  @override
  State<JsonTreeViewPage> createState() => _JsonTreeViewPageState();
}

class _JsonTreeViewPageState extends State<JsonTreeViewPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Decoded JSON in syntax colors',
          children: [
            SizedBox(
              width: 360,
              child: Oito2SearchField(
                hintText: 'Filter keys and values',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(
              width: 360,
              height: 360,
              child: Oito2JsonTreeView(
                data: _sample,
                expandDepth: 2,
                query: _query,
                rootLabel: 'pubspec',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
