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

const _languages = [
  ('dart', 'Dart', 'Compiled'),
  ('go', 'Go', 'Compiled'),
  ('rust', 'Rust', 'Compiled'),
  ('cobol', 'COBOL (unavailable)', 'Compiled'),
  ('python', 'Python', 'Interpreted'),
  ('ruby', 'Ruby', 'Interpreted'),
  ('lua', 'Lua', 'Interpreted'),
];

/// Documents the pure Dart collections: a list with selection, a tree
/// built from file paths and a list loaded page by page.
class CollectionsPage extends StatefulWidget {
  /// Creates the collections page.
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  // #region list-data
  final _list = Oito2ListCollection(
    _languages,
    valueOf: (language) => language.$1,
    labelOf: (language) => language.$2,
    groupOf: (language) => language.$3,
    isDisabled: (language) => language.$1 == 'cobol',
  );
  late final _selection = Oito2SelectionController(
    collection: _list,
    mode: Oito2SelectionMode.multiple,
  );
  // #endregion
  // #region tree-data
  final _tree = Oito2TreeCollection<void>.fromPaths(const [
    'lib/main.dart',
    'lib/src/app.dart',
    'lib/src/pages/home_page.dart',
    'lib/src/pages/settings_page.dart',
    'test/app_test.dart',
    'pubspec.yaml',
  ]);
  final Set<String> _expanded = {'lib'};
  // #endregion
  // #region async-data
  late final _numbers = Oito2AsyncListController<int, int>(
    load: (request) async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final start = request.cursor ?? 0;
      final next = start + 20;
      return Oito2AsyncListPage([
        for (var i = start; i < next; i++) i + 1,
      ], cursor: next < 100 ? next : null);
    },
  )..reload();
  // #endregion

  @override
  void dispose() {
    _selection.dispose();
    _numbers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DocPage(
      title: 'Collections',
      description:
          'Pure Dart descriptions of lists and trees of items, with their '
          'selection and loading, that the list, select, tree and '
          'autocomplete components share.',
      source: 'lib/src/pages/collections_page.dart',
      children: [
        const DocHeading('Usage'),
        const DocText(
          'A collection wraps your own items and says how to read them: '
          'the `valueOf` that identifies each one, the `labelOf` to show '
          'and search, an optional `groupOf` and `isDisabled`. Components '
          'take the collection instead of a list of widgets, so the same '
          'items feed several of them.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocTable(
          header: ['Collection', 'Describes'],
          rows: [
            ['`Oito2ListCollection`', 'A flat list, optionally grouped'],
            ['`Oito2TreeCollection`', 'A tree of `Oito2TreeNode`s'],
            [
              '`Oito2AsyncListController`',
              'A list loaded from a source page by page',
            ],
            [
              '`Oito2SelectionController`',
              'The selected values of a list, single or multiple',
            ],
          ],
        ),
        const DocHeading('Examples'),
        const DocHeading('List and selection', level: 3),
        const DocText(
          'An `Oito2SelectionController` keeps the selected values of a '
          'list collection, skipping disabled items. In `multiple` mode, '
          'Control or Command+click toggles an item and Shift+click '
          'selects a range, as in `Oito2ListBox`.',
        ),
        ExamplePanel(
          regions: const ['list-data', 'list-ui'],
          child: SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                // #region list-ui
                Oito2ListBox(
                  collection: _list,
                  controller: _selection,
                  maxHeight: 280,
                ),
                ListenableBuilder(
                  listenable: _selection,
                  builder: (context, _) =>
                      Text('Selected: ${_selection.selectedValues.join(', ')}'),
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Tree from paths', level: 3),
        const DocText(
          '`Oito2TreeCollection.fromPaths` builds folders from slash '
          'separated paths. `visible` lists the nodes to show for a set of '
          'open branches, each with its depth, which is all a custom tree '
          'needs; `Oito2TreeView` adds the keyboard, selection and '
          'filtering.',
        ),
        ExamplePanel(
          regions: const ['tree-data', 'tree-ui'],
          child: SizedBox(
            width: 320,
            child: Column(
              children: [
                // #region tree-ui
                for (final entry in _tree.visible(_expanded))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsetsDirectional.only(
                      start: 12.0 + entry.depth * 20,
                      end: 12,
                    ),
                    leading: Icon(
                      entry.node.isBranch
                          ? LucideIcons.folder
                          : LucideIcons.file,
                      size: 18,
                    ),
                    title: Text(entry.node.label),
                    onTap: entry.node.isBranch
                        ? () => setState(
                            () => _expanded.contains(entry.node.value)
                                ? _expanded.remove(entry.node.value)
                                : _expanded.add(entry.node.value),
                          )
                        : null,
                  ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Loading page by page', level: 3),
        const DocText(
          '`Oito2AsyncListController` calls `load` with a cursor for each '
          'page and keeps the items, the loading state and the error. '
          '`reload` starts over and `loadMore` asks for the next page; a '
          'null cursor in the result means there is no more.',
        ),
        ExamplePanel(
          regions: const ['async-data', 'async-ui'],
          // #region async-ui
          child: ListenableBuilder(
            listenable: _numbers,
            builder: (context, _) => Column(
              spacing: Oito2Spacing.sm,
              children: [
                Text('${_numbers.items.length} of 100 items loaded'),
                if (_numbers.isLoading || _numbers.isLoadingMore)
                  const SizedBox(
                    width: 200,
                    child: Oito2LinearProgressIndicator(),
                  )
                else
                  OutlinedButton(
                    onPressed: _numbers.hasMore ? _numbers.loadMore : null,
                    child: const Text('Load more'),
                  ),
              ],
            ),
          ),
          // #endregion
        ),
        DocText(
          'The collections are plain Dart: they have no widgets and can be '
          'tested and filtered without a `BuildContext`.',
          style: textTheme.bodyMedium,
        ),
        ...apiReferenceWidgets([
          'Oito2ListCollection',
          'Oito2SelectionController',
          'Oito2SelectionMode',
          'Oito2TreeCollection',
          'Oito2TreeNode',
          'Oito2AsyncListController',
          'Oito2AsyncListPage',
        ]),
      ],
    );
  }
}
