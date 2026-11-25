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

/// Documents [Oito2TreeView]: selection, renaming, filtering, check boxes,
/// lazy loading, context menus and columns.
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
  // #region controlled-data
  /// Shares on a server whose folders load on open; the check states are
  /// the server's, so a folder can be on before its children load.
  var _shares = Oito2TreeCollection<void>([
    const Oito2TreeNode(value: 'docs', children: []),
    const Oito2TreeNode(value: 'photos', children: []),
    const Oito2TreeNode(value: 'backups', children: []),
  ]);

  /// The applied state of each share: true, false or null for mixed.
  final Map<String, bool?> _applied = {'docs': true, 'photos': null};

  /// The changes the user made and hasn't applied yet.
  final Map<String, bool> _changes = {};
  // #endregion
  // #region menu-data
  final _menu = Oito2ContextMenuController();
  Oito2TreeNode<void>? _menuNode;
  String _menuAction = 'None';
  // #endregion
  // #region columns-data
  static const _sizes = {
    'lib/main.dart': '2 KB',
    'lib/src/app.dart': '6 KB',
    'lib/src/pages/home_page.dart': '12 KB',
    'lib/src/pages/settings_page.dart': '9 KB',
    'lib/src/widgets/avatar.dart': '3 KB',
    'test/app_test.dart': '1 KB',
    'test/widgets/avatar_test.dart': '2 KB',
    'pubspec.yaml': '1 KB',
    'README.md': '4 KB',
  };
  static const _modified = {'lib/src/app.dart', 'README.md'};

  /// The width of the Size column, kept when the user resizes it.
  double _sizeWidth = 88;

  /// The columns the user hid and the order they put them in.
  Set<String> _gridHidden = const {};
  List<String>? _gridOrder;
  // #endregion
  // #region organize-data
  var _folders = Oito2TreeCollection<void>([
    const Oito2TreeNode(
      value: 'projects',
      label: 'Projects',
      children: [
        Oito2TreeNode(value: 'website', label: 'Website', children: []),
        Oito2TreeNode(value: 'app', label: 'App', children: []),
      ],
    ),
    const Oito2TreeNode(
      value: 'docs',
      label: 'Docs',
      children: [
        Oito2TreeNode(value: 'guide.md', label: 'guide.md'),
        Oito2TreeNode(value: 'notes.md', label: 'notes.md'),
      ],
    ),
    const Oito2TreeNode(
      value: 'system',
      label: 'System (read-only)',
      children: [Oito2TreeNode(value: 'config', label: 'config')],
    ),
    const Oito2TreeNode(value: 'todo.txt', label: 'todo.txt'),
  ]);
  final _organize = Oito2TreeController(
    selectionMode: Oito2SelectionMode.multiple,
    expanded: const ['projects', 'docs'],
  );
  String _lastMove = 'None';
  bool _treeHandles = false;

  /// Whether [parent] is the read-only folder or inside it.
  bool _readOnly(String? parent) =>
      parent != null &&
      (parent == 'system' || _folders.ancestorsOf(parent).contains('system'));
  // #endregion
  final _controlled = Oito2TreeController(expanded: const ['docs']);
  final _menuTree = Oito2TreeController(expanded: const ['lib']);
  final _grid = Oito2TreeController(expanded: const ['lib', 'lib/src']);
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
    _controlled.dispose();
    _menuTree.dispose();
    _grid.dispose();
    _organize.dispose();
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

  /// A bordered box of fixed size around a tree view, [width] wide.
  Widget _frame(Widget child, {double width = 300}) => Container(
    width: width,
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
        const DocHeading('Controlled check boxes', level: 3),
        const DocText(
          'With `checkState`, the app owns the check states: the tree shows '
          'what it returns (null is mixed), and a click or `Space` only '
          'calls `onCheckChanged` with the next state, true for an '
          'unchecked or mixed node and false for a checked one, without '
          'checking children or parents. A branch whose children are not '
          'loaded yet can show as checked or mixed, as below. `isPending` '
          'marks the rows with a change not applied yet with a dot.',
        ),
        ExamplePanel(
          regions: const ['controlled-data', 'controlled'],
          child: Column(
            spacing: Oito2Spacing.sm,
            children: [
              // #region controlled
              _frame(
                Oito2TreeView(
                  collection: _shares,
                  controller: _controlled,
                  checkable: true,
                  iconBuilder: _icon,
                  semanticLabel: 'Shares',
                  checkState: (node) =>
                      _changes[node.value] ?? _applied[node.value] ?? false,
                  onCheckChanged: (node, checked) =>
                      setState(() => _changes[node.value] = checked),
                  isPending: (node) => _changes.containsKey(node.value),
                  onLoadChildren: (node) async {
                    await Future<void>.delayed(const Duration(seconds: 1));
                    if (!mounted) return;
                    setState(
                      () => _shares = _shares.insert(node.value, [
                        for (final name in ['2025', '2026'])
                          Oito2TreeNode(
                            value: '${node.value}/$name',
                            label: name,
                          ),
                      ]),
                    );
                  },
                ),
              ),
              Wrap(
                spacing: Oito2Spacing.sm,
                children: [
                  FilledButton(
                    onPressed: _changes.isEmpty
                        ? null
                        : () => setState(() {
                            _applied.addAll(_changes);
                            _changes.clear();
                          }),
                    child: const Text('Apply'),
                  ),
                  OutlinedButton(
                    onPressed: _changes.isEmpty
                        ? null
                        : () => setState(_changes.clear),
                    child: const Text('Discard'),
                  ),
                ],
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Context menu', level: 3),
        const DocText(
          '`onContextMenu` runs on a secondary click or a long press on a '
          'row, and on the `Menu` key or `Shift+F10` for the active row, '
          'with a global position: the pointer, or the bottom-start corner '
          'of the row, and whether the keyboard asked for it. The row '
          'becomes active and selected first; a multiple selection that '
          'already holds it is kept. Wrap the tree in an '
          '`Oito2ContextMenuRegion` with an `Oito2ContextMenuController` to '
          'open the menu there, passing `focusFirstItem: byKeyboard` so the '
          'keyboard lands on the first item.',
        ),
        ExamplePanel(
          regions: const ['menu-data', 'menu'],
          child: Column(
            spacing: Oito2Spacing.sm,
            children: [
              // #region menu
              _frame(
                Oito2ContextMenuRegion(
                  controller: _menu,
                  menuChildren: [
                    for (final action in ['Open', 'Rename', 'Delete'])
                      MenuItemButton(
                        onPressed: () => setState(
                          () =>
                              _menuAction = '$action ${_menuNode?.label ?? ''}',
                        ),
                        child: Text(action),
                      ),
                  ],
                  child: Oito2TreeView(
                    collection: _files,
                    controller: _menuTree,
                    iconBuilder: _icon,
                    semanticLabel: 'Files with a menu',
                    onContextMenu: (node, position, byKeyboard) {
                      setState(() => _menuNode = node);
                      _menu.open(
                        globalPosition: position,
                        focusFirstItem: byKeyboard,
                      );
                    },
                  ),
                ),
              ),
              Text('Last action: $_menuAction'),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Columns', level: 3),
        const DocText(
          'With `columns`, the tree is a tree grid. Each `Oito2TableColumn` '
          'has an `id`, a header `label`, a width (`Oito2ColumnWidth.fixed` '
          'or `.flex`, which shares the space left), an `alignment` and a '
          '`cellBuilder` that receives the node. The first column holds the '
          'indentation, disclosure, check box, icon and label; the other '
          'cells line up across every depth under a header that stays in '
          'place. A `resizable` column has a handle in the header, and '
          '`onColumnResized` reports its width when a resize ends, so the '
          'app can keep it and pass it back as a fixed width.',
        ),
        const DocText(
          'As in `Oito2DataTable`, `hiddenColumns`, `onHiddenColumnsChanged`, '
          '`columnOrder`, `onColumnsReordered` and `onResetColumns` let the '
          'user choose the other columns: right-click a header to show, hide, '
          'move or reset them, or drag a header with the mouse, or press Alt '
          'with Left or Right on it. The first column always shows first. '
          '`pinnedColumns` keeps the first columns in place while the others '
          'scroll sideways.',
        ),
        ExamplePanel(
          regions: const ['columns-data', 'columns'],
          child: _frame(
            width: 420,
            // #region columns
            Oito2TreeView(
              collection: _files,
              controller: _grid,
              iconBuilder: _icon,
              semanticLabel: 'Files with details',
              onColumnResized: (id, width) =>
                  setState(() => _sizeWidth = width),
              hiddenColumns: _gridHidden,
              onHiddenColumnsChanged: (hidden) =>
                  setState(() => _gridHidden = hidden),
              columnOrder: _gridOrder,
              onColumnsReordered: (order) => setState(() => _gridOrder = order),
              onResetColumns: () => setState(() {
                _gridHidden = const {};
                _gridOrder = null;
              }),
              columns: [
                const Oito2TableColumn(
                  id: 'name',
                  label: 'Name',
                  width: Oito2ColumnWidth.flex(1, min: 160),
                ),
                Oito2TableColumn(
                  id: 'size',
                  label: 'Size',
                  width: Oito2ColumnWidth.fixed(_sizeWidth),
                  alignment: AlignmentDirectional.centerEnd,
                  resizable: true,
                  cellBuilder: (context, node) =>
                      Text(_sizes[node.value] ?? ''),
                ),
                Oito2TableColumn(
                  id: 'status',
                  label: 'Status',
                  width: const Oito2ColumnWidth.fixed(96),
                  tooltip: 'Changes since the last commit',
                  cellBuilder: (context, node) => node.isBranch
                      ? const SizedBox.shrink()
                      : Text(
                          _modified.contains(node.value)
                              ? 'Modified'
                              : 'Unchanged',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Organize folders', level: 3),
        const DocText(
          'With `onMove`, rows can be dragged: the top quarter of a branch '
          'drops before it, the bottom quarter after it and the middle into '
          'it as its last child; a leaf takes the top or bottom half. A '
          'line or a frame shows the drop, a closed folder held under the '
          'pointer opens after 700 ms, and the tree scrolls near its edges. '
          'A drag that starts on a selected row of a multiple selection '
          'carries the whole selection. `Alt+Up` and `Alt+Down` move the '
          'active node among its siblings, and `Alt+Right` and `Alt+Left` '
          'indent it into the folder above or outdent it after its parent.',
        ),
        const DocText(
          '`onMove` receives the topmost moved nodes, the new parent (null '
          'for the top level) and the index after the nodes are taken out, '
          'which `Oito2TreeCollection.move` takes as is. `canDrop` refuses '
          'places, here the read-only folder; a node never drops into '
          'itself. A refused place shows a "no drop" sign. Rows cannot be '
          'moved while filtering or renaming.',
        ),
        const DocText(
          'Without a handle, a mouse drags a row once it moves a few pixels '
          'and a touch after a long press, unless `onContextMenu` is set. '
          'With `dragHandle`, only a grip at the end of the label drags, '
          'with any pointer at once, so a long press on the row stays free '
          'for the context menu. In a tree grid the grip sits inside the '
          'first column, so the other columns stay aligned with the header.',
        ),
        ExamplePanel(
          regions: const ['organize-data', 'organize'],
          child: Column(
            spacing: Oito2Spacing.sm,
            children: [
              Oito2SwitchButton(
                value: _treeHandles,
                onChanged: (value) => setState(() => _treeHandles = value),
                title: const Text('Drag handles'),
              ),
              _frame(
                // #region organize
                Oito2TreeView(
                  collection: _folders,
                  controller: _organize,
                  iconBuilder: _icon,
                  semanticLabel: 'Folders',
                  dragHandle: _treeHandles,
                  canDrop: (nodes, parent, index) => !_readOnly(parent),
                  onMove: (nodes, parent, index) => setState(() {
                    _folders = _folders.move(
                      [for (final node in nodes) node.value],
                      parent,
                      index: index,
                    );
                    _lastMove =
                        '${nodes.map((n) => n.label).join(', ')} to '
                        '${parent == null ? 'the top level' : _folders.find(parent)?.label}, '
                        'position ${index + 1}';
                  }),
                ),
                // #endregion
              ),
              Text('Last move: $_lastMove'),
            ],
          ),
        ),
        const DocText(
          'To receive drops from outside the tree on a row, such as the '
          "app's own `Draggable`s or files from `oito2_ui_files`, wrap each "
          'row with `rowDropTargetBuilder`, which gets the node and the '
          'built row, and set `dropHighlight` to the value of the hovered '
          'row to mark it as the tree marks a drop into a branch. The '
          "tree's own row drags never reach those targets.",
        ),
        const DocCode(
          'Oito2TreeView(\n'
          '  collection: files,\n'
          '  controller: controller,\n'
          '  dropHighlight: hovered,\n'
          '  rowDropTargetBuilder: (context, node, row) => !node.isBranch\n'
          '      ? row\n'
          '      : oito2PlatformDropTarget(\n'
          '          enabled: true,\n'
          '          onHover: (over) => setState(\n'
          '            () => hovered = over ? node.value : null,\n'
          '          ),\n'
          '          onDrop: (files) => upload(node, files),\n'
          '          child: row,\n'
          '        ),\n'
          ')',
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The tree is labeled by `semanticLabel`. Each row is labeled by '
          'its node label and reports whether it is selected, enabled and '
          'active, whether a branch is expanded, and, in a checkable tree, '
          'whether it is checked or mixed; a pending row adds a "pending '
          'change" hint. In a tree grid, the header labels are headers and '
          'the cells after the first are read after the row. Set '
          '`autofocus` to give the tree the focus when it shows. With '
          '`onMove`, rows offer the "Move up", "Move down", "Indent" and '
          '"Outdent" actions where they apply, and every keyboard or action '
          'move is announced, such as "Moved Docs into Projects, position '
          '3", or "Can\'t drop here" when `canDrop` refuses it.',
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
            [
              '`Menu` / `Shift+F10`',
              'Calls `onContextMenu` for the active row, when it is set.',
            ],
            [
              '`Alt+Up` / `Alt+Down`',
              'Moves the active node before its previous sibling or after its '
                  'next one, when `onMove` is set.',
            ],
            [
              '`Alt+Right`',
              'Moves the active node into the branch above it, as its last '
                  'child, when `onMove` is set (`Alt+Left` in right-to-left '
                  'layouts).',
            ],
            [
              '`Alt+Left`',
              'Moves the active node out of its branch, right after it, when '
                  '`onMove` is set (`Alt+Right` in right-to-left layouts).',
            ],
            ['`Escape`', 'Cancels a row or column drag in progress.'],
            ['Letters', 'Jump to the next shown label that starts with them.'],
            [
              '`Menu` / `Shift+F10` on a header',
              'Opens the column menu of a tree grid, with '
                  '`onHiddenColumnsChanged`, `onColumnsReordered` or '
                  '`onResetColumns`.',
            ],
            [
              '`Alt+Left` / `Alt+Right` on a header',
              'Moves that column (not the first one) left or right, with '
                  '`onColumnsReordered`.',
            ],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2TreeView',
          'Oito2TreeController',
          'Oito2TreeItemBuilder',
          'Oito2TableColumn',
          'Oito2ColumnWidth',
          'Oito2ContextMenuController',
          'Oito2TreeCollection',
          'Oito2TreeNode',
        ]),
      ],
    );
  }
}
