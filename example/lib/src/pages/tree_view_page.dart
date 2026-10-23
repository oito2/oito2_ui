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

import '../widgets/showcase_widgets.dart';

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

/// Shows [Oito2TreeView] with filtering, check boxes, renaming and lazy
/// loading.
class TreeViewPage extends StatefulWidget {
  /// Creates the tree view page.
  const TreeViewPage({super.key});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  var _files = Oito2TreeCollection<void>.fromPaths(_paths);
  var _remote = Oito2TreeCollection<void>([
    const Oito2TreeNode(
      value: 'server',
      label: 'server (loads on open)',
      children: [],
    ),
  ]);
  final _tree = Oito2TreeController(
    selectionMode: Oito2SelectionMode.multiple,
    expanded: const ['lib'],
  );
  final _checks = Oito2TreeController(expanded: const ['lib', 'test']);
  final _lazy = Oito2TreeController();
  String _query = '';
  String _activated = 'None';

  @override
  void dispose() {
    _tree.dispose();
    _checks.dispose();
    _lazy.dispose();
    super.dispose();
  }

  /// A folder icon, open or closed, for branches and a file icon for
  /// leaves.
  Widget? _icon(Oito2TreeNode<void> node, bool open) => Icon(
    node.isBranch
        ? (open ? LucideIcons.folder_open : LucideIcons.folder)
        : LucideIcons.file,
  );

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
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Files: arrows, Shift/Ctrl, type to jump, F2 renames, Enter opens',
          children: [
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
                controller: _tree,
                query: _query,
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
            ),
            Text('Last opened: $_activated'),
          ],
        ),
        ShowcaseSection(
          'Check boxes and lazy loading',
          children: [
            _frame(
              Oito2TreeView(
                collection: _files,
                controller: _checks,
                checkable: true,
              ),
            ),
            _frame(
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
                        Oito2TreeNode(
                          value: '${node.value}/$name',
                          label: name,
                        ),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
