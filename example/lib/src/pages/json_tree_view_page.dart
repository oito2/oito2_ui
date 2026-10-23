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

import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';

// #region data
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
// #endregion

/// Documents [Oito2JsonTreeView] and [oito2JsonTree]: syntax colors, a
/// filter, the open depth and node paths.
class JsonTreeViewPage extends StatefulWidget {
  /// Creates the JSON tree view page.
  const JsonTreeViewPage({super.key});

  @override
  State<JsonTreeViewPage> createState() => _JsonTreeViewPageState();
}

class _JsonTreeViewPageState extends State<JsonTreeViewPage> {
  String _query = '';
  // #region paths-data
  final _paths = oito2JsonTree(
    jsonDecode('{"user": {"name": "Ana", "roles": ["admin", "editor"]}}'),
  );
  final _pathsController = Oito2TreeController(
    expanded: const [r'$', r'$.user', r'$.user.roles'],
  );
  String _path = 'None';
  // #endregion

  @override
  void dispose() {
    _pathsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'JSON Tree View',
      description:
          'A tree view of decoded JSON, with keys and values in the theme\'s '
          'syntax colors and the size of each object and list.',
      source: 'lib/src/pages/json_tree_view_page.dart',
      children: [
        ExamplePanel(
          regions: const ['data', 'preview'],
          child: SizedBox(
            width: 360,
            height: 360,
            // #region preview
            child: Oito2JsonTreeView(
              data: _sample,
              expandDepth: 2,
              rootLabel: 'pubspec',
              semanticLabel: 'Package details',
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2JsonTreeView` the decoded JSON in `data`: maps, lists, '
          'strings, numbers, booleans and null, as `jsonDecode` returns. '
          'Objects and lists become branches that show their size, and the '
          'top node is labeled `rootLabel`, "root" by default.',
        ),
        const DocText(
          'Branches up to `expandDepth` levels deep start open, 1 by '
          'default; the tree opens to that depth again when `data` or '
          '`expandDepth` changes. It has the keyboard of `Oito2TreeView`.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Filtering', level: 3),
        const DocText(
          '`query` filters the nodes by key and value, showing the matches '
          'and their ancestors, all open.',
        ),
        ExamplePanel(
          region: 'filter',
          child: SizedBox(
            width: 360,
            child: Column(
              spacing: Oito2Spacing.sm,
              children: [
                // #region filter
                Oito2SearchField(
                  hintText: 'Filter keys and values',
                  onChanged: (v) => setState(() => _query = v),
                ),
                SizedBox(
                  height: 300,
                  child: Oito2JsonTreeView(
                    data: _sample,
                    expandDepth: 2,
                    query: _query,
                    rootLabel: 'pubspec',
                  ),
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Closed at start', level: 3),
        const DocText('With `expandDepth: 0`, every branch starts closed.'),
        ExamplePanel(
          region: 'closed',
          child: SizedBox(
            width: 360,
            height: 160,
            // #region closed
            child: Oito2JsonTreeView(
              data: _sample,
              expandDepth: 0,
              rootLabel: 'pubspec',
            ),
            // #endregion
          ),
        ),
        const DocHeading('Node paths', level: 3),
        const DocText(
          '`oito2JsonTree` returns the `Oito2TreeCollection` behind the '
          'view, for an `Oito2TreeView` of your own. The node values are '
          'JSON paths, such as `\$.user.roles[0]`, and each node\'s `data` '
          'holds its key and value as an `Oito2JsonEntry`. Double-click a '
          'node or press Enter to show its path.',
        ),
        ExamplePanel(
          regions: const ['paths-data', 'paths'],
          child: SizedBox(
            width: 360,
            child: Column(
              spacing: Oito2Spacing.sm,
              children: [
                SizedBox(
                  height: 200,
                  // #region paths
                  child: Oito2TreeView(
                    collection: _paths,
                    controller: _pathsController,
                    onActivate: (node) => setState(() => _path = node.value),
                  ),
                  // #endregion
                ),
                Text('Path: $_path'),
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The tree is labeled by `semanticLabel`, and each row by its key '
          'and value, as in `Oito2TreeView`.',
        ),
        ...apiReferenceWidgets([
          'Oito2JsonTreeView',
          'oito2JsonTree',
          'Oito2JsonEntry',
        ]),
      ],
    );
  }
}
