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

// #region data
const _paths = [
  'lib/main.dart',
  'lib/src/app.dart',
  'lib/src/pages/home_page.dart',
  'lib/src/pages/settings_page.dart',
  'lib/src/widgets/avatar.dart',
  'test/app_test.dart',
  'test/widgets/avatar_test.dart',
  'pubspec.yaml',
  'README.md',
];
// #endregion

/// Documents [Oito2TreeView]: selection, renaming, filtering, check boxes
/// and lazy loading.
class TreeViewPage extends StatefulWidget {
  /// Creates the tree view page.
  const TreeViewPage({super.key});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  // #region preview-data
  var _files = Oito2TreeCollection<void>.fromPaths(_paths);
  final _tree = Oito2TreeController(
    selectionMode: Oito2SelectionMode.multiple,
    expanded: const ['lib'],
  );
  // #endregion
  // #region lazy-data
  var _remote = Oito2TreeCollection<void>([
    const Oito2TreeNode(
      value: 'server',
      label: 'server (loads on open)',
      children: [],
    ),
  ]);
  // #endregion
  final _filtered = Oito2TreeController();
  final _checks = Oito2TreeController(expanded: const ['lib', 'test']);
  final _lazy = Oito2TreeController();
  String _query = '';
  String _activated = 'None';

  @override
  void dispose() {
    _tree.dispose();
    _filtered.dispose();
    _checks.dispose();
    _lazy.dispose();
    super.dispose();
  }

  // #region icon
  /// A folder icon, open or closed, for branches and a file icon for
  /// leaves.
  Widget? _icon(Oito2TreeNode<void> node, bool open) => Icon(
    node.isBranch
        ? (open ? LucideIcons.folder_open : LucideIcons.folder)
        : LucideIcons.file,
  );
  // #endregion

  /// A bordered box of fixed size around a tree view.
  Widget _frame(Widget child) => Container(
    width: 300,
    height: 280,
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: Oito2Radius.mediumAll,
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Tree View',
      description:
          'A tree of nested items, such as files and folders, that the user '
          'opens, selects, checks and renames with the mouse or the '
          'keyboard.',
      source: 'lib/src/pages/tree_view_page.dart',
      children: [
        ExamplePanel(
          regions: const ['data', 'preview-data', 'icon', 'preview'],
          child: Column(
            spacing: Oito2Spacing.sm,
            children: [
              _frame(
                // #region preview
                Oito2TreeView(
                  collection: _files,
                  controller: _tree,
                  iconBuilder: _icon,
                  semanticLabel: 'Files',
                  onActivate: (node) => setState(() => _activated = node.label),
                  onRename: (node, label) => setState(
                    () => _files = _files.replace(
                      node.value,
                      node.copyWith(label: label),
                    ),
                  ),
                ),
                // #endregion
              ),
              Text('Last opened: $_activated'),
            ],
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2TreeView` an `Oito2TreeCollection` of the nodes and an '
          '`Oito2TreeController`, which keeps the open, selected and checked '
          'node values; dispose of the controller with the state that owns '
          'it. The controller\'s `selectionMode` is `single` by default; '
          '`multiple` allows several and `none` disables selection.',
        ),
        const DocText(
          '`iconBuilder` adds an icon before each label, given whether the '
          'node is open, and `itemBuilder` replaces the row content. Only '
          'the rows in view are built, so the tree handles large trees.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'Collections are immutable: `replace` and `insert` return a new '
          '`Oito2TreeCollection`, which the page stores and passes again.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Activating and renaming', level: 3),
        const DocText(
          '`onActivate` runs on Enter or a double click on a node, as in the '
          'tree above; when it is null, those open or close a branch '
          'instead. With `onRename`, F2 starts an inline rename of the '
          'active node, and the callback receives the new, trimmed label '
          'when it is not empty and differs from the old one.',
        ),
        const DocHeading('Controlling from code', level: 3),
        const DocText(
          'The controller opens and closes branches and changes the '
          'selection: `expandAll`, `collapseAll`, `setExpanded`, '
          '`setSelected` and `toggleSelected`.',
        ),
        ExamplePanel(
          region: 'code',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            alignment: WrapAlignment.center,
            children: [
              // #region code
              OutlinedButton(
                onPressed: () => _tree.expandAll(_files),
                child: const Text('Expand all'),
              ),
              OutlinedButton(
                onPressed: _tree.collapseAll,
                child: const Text('Collapse all'),
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Filtering', level: 3),
        const DocText(
          'A non-empty `query` shows only the matching nodes and their '
          'ancestors, all open, with the match highlighted. Branches cannot '
          'be opened or closed while filtering.',
        ),
        ExamplePanel(
          region: 'filter',
          child: Column(
            spacing: Oito2Spacing.sm,
            children: [
              // #region filter
              SizedBox(
                width: 300,
                child: Oito2SearchField(
                  hintText: 'Filter',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              _frame(
                Oito2TreeView(
                  collection: _files,
                  controller: _filtered,
                  query: _query,
                  iconBuilder: _icon,
                  semanticLabel: 'Filtered files',
                ),
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Check boxes', level: 3),
        const DocText(
          'With `checkable`, each row has a tristate check box, tracked in '
          'the controller\'s `checked` leaves. Checking a branch checks all '
          'its leaves, and a branch with only some leaves checked shows a '
          'mixed state.',
        ),
        ExamplePanel(
          region: 'checkable',
          child: _frame(
            // #region checkable
            Oito2TreeView(
              collection: _files,
              controller: _checks,
              checkable: true,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Lazy loading', level: 3),
        const DocText(
          'A branch with no children yet and an `onLoadChildren` shows a '
          'spinner while its children load the first time it opens; the app '
          'adds them to the collection. When the future fails, the branch '
          'closes, and opening it again retries.',
        ),
        ExamplePanel(
          regions: const ['lazy-data', 'lazy'],
          child: _frame(
            // #region lazy
            Oito2TreeView(
              collection: _remote,
              controller: _lazy,
              iconBuilder: _icon,
              onLoadChildren: (node) async {
                await Future<void>.delayed(const Duration(seconds: 1));
                if (!mounted) return;
                setState(
                  () => _remote = _remote.insert(node.value, [
                    for (final name in ['a.log', 'b.log', 'c.log'])
                      Oito2TreeNode(value: '${node.value}/$name', label: name),
                  ]),
                );
              },
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The tree is labeled by `semanticLabel`. Each row is labeled by '
          'its node label and reports whether it is selected, enabled and '
          'active, whether a branch is expanded, and, in a checkable tree, '
          'whether it is checked or mixed. Set `autofocus` to give the tree '
          'the focus when it shows.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Down arrow` / `Up arrow`',
              'Moves the active row; a single-selection tree also selects it.',
            ],
            ['`Home` / `End`', 'Moves to the first or the last row.'],
            [
              '`Shift` + arrows, `Home`, `End`',
              'Extends the selection, in a multiple-selection tree.',
            ],
            [
              '`Right arrow`',
              'Opens a branch, or moves to its first child (`Left arrow` in '
                  'right-to-left layouts).',
            ],
            [
              '`Left arrow`',
              'Closes a branch, or moves to the parent (`Right arrow` in '
                  'right-to-left layouts).',
            ],
            [
              '`Space`',
              'Toggles the check box of a checkable tree, or else the '
                  'selection of a multiple-selection one.',
            ],
            [
              '`Ctrl+A` / `Cmd+A`',
              'Selects every shown, enabled node, in a multiple-selection '
                  'tree.',
            ],
            [
              '`Enter`',
              'Calls `onActivate`, or opens or closes a branch when it is '
                  'null.',
            ],
            [
              '`F2`',
              'Renames the active node, when `onRename` is set; `Enter` '
                  'confirms and `Escape` cancels.',
            ],
            ['Letters', 'Jump to the next shown label that starts with them.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2TreeView',
          'Oito2TreeController',
          'Oito2TreeItemBuilder',
          'Oito2TreeCollection',
          'Oito2TreeNode',
        ]),
      ],
    );
  }
}
