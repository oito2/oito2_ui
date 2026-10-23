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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../widgets/showcase_widgets.dart';

const _languages = [
  ('dart', 'Dart', 'Compiled'),
  ('go', 'Go', 'Compiled'),
  ('rust', 'Rust', 'Compiled'),
  ('cobol', 'COBOL (unavailable)', 'Compiled'),
  ('python', 'Python', 'Interpreted'),
  ('ruby', 'Ruby', 'Interpreted'),
  ('lua', 'Lua', 'Interpreted'),
];

/// Shows the pure Dart collections: a list with multiple selection, a
/// tree built from file paths and a list loaded page by page.
class CollectionsPage extends StatefulWidget {
  /// Creates the collections page.
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final _list = Oito2ListCollection(
    _languages,
    valueOf: (l) => l.$1,
    labelOf: (l) => l.$2,
    groupOf: (l) => l.$3,
    isDisabled: (l) => l.$1 == 'cobol',
  );
  late final _selection = Oito2SelectionController(
    collection: _list,
    mode: Oito2SelectionMode.multiple,
  );
  final _tree = Oito2TreeCollection<void>.fromPaths(const [
    'lib/main.dart',
    'lib/src/app.dart',
    'lib/src/pages/home_page.dart',
    'lib/src/pages/settings_page.dart',
    'test/app_test.dart',
    'pubspec.yaml',
  ]);
  final Set<String> _expanded = {'lib'};
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

  @override
  void dispose() {
    _selection.dispose();
    _numbers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'List collection and selection: click, Ctrl+click, Shift+click',
          children: [
            SizedBox(
              width: 360,
              child: Oito2BorderContainer(
                child: ListenableBuilder(
                  listenable: _selection,
                  builder: (context, _) => Column(
                    children: [
                      Oito2CheckboxListTile(
                        value: _selection.isAllSelected
                            ? true
                            : _selection.isSomeSelected
                            ? null
                            : false,
                        tristate: true,
                        title: const Text('Select all'),
                        onChanged: (_) => _selection.isAllSelected
                            ? _selection.clear()
                            : _selection.selectAll(),
                      ),
                      const Divider(height: 1),
                      for (final group in _list.groups) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              group.group ?? '',
                              style: textTheme.labelMedium,
                            ),
                          ),
                        ),
                        for (final item in group.items)
                          ListTile(
                            title: Text(_list.labelOf(item)),
                            enabled: !_list.isDisabled(item),
                            selected: _selection.isSelected(
                              _list.valueOf(item),
                            ),
                            onTap: () {
                              final keyboard = HardwareKeyboard.instance;
                              _selection.click(
                                _list.valueOf(item),
                                extend: keyboard.isShiftPressed,
                                toggle:
                                    keyboard.isControlPressed ||
                                    keyboard.isMetaPressed,
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            ListenableBuilder(
              listenable: _selection,
              builder: (context, _) => Text(
                'Selected: ${_selection.selectedValues.join(', ')}',
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Tree collection from file paths',
          children: [
            SizedBox(
              width: 360,
              child: Oito2BorderContainer(
                child: Column(
                  children: [
                    for (final entry in _tree.visible(_expanded))
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsetsDirectional.only(
                          start: 12.0 + entry.depth * 20,
                          end: 12,
                        ),
                        leading: Icon(
                          entry.node.isBranch
                              ? (_expanded.contains(entry.node.value)
                                    ? LucideIcons.folder_open
                                    : LucideIcons.folder)
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
                  ],
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Async list loaded page by page',
          children: [
            ListenableBuilder(
              listenable: _numbers,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Oito2Spacing.sm,
                children: [
                  Text(
                    '${_numbers.items.length} of 100 items loaded',
                    style: textTheme.bodyMedium,
                  ),
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
          ],
        ),
      ],
    );
  }
}
