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

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';

// #region data
/// A file transfer: name, size in bytes, progress from 0 to 1 and status.
typedef _Transfer = ({String name, int size, double progress, String status});

const _statuses = ['Queued', 'Uploading', 'Paused', 'Done', 'Failed'];

/// 5,000 transfers with sample names, sizes and states.
final List<_Transfer> _allTransfers = () {
  final random = math.Random(2);
  const kinds = ['report.pdf', 'photos.zip', 'notes.txt', 'backup.tar'];
  return [
    for (var i = 0; i < 5000; i++)
      (
        name: '${i + 1}-${kinds[i % kinds.length]}',
        size: random.nextInt(1 << 30),
        progress: random.nextInt(11) / 10,
        status: _statuses[random.nextInt(_statuses.length)],
      ),
  ];
}();
// #endregion

/// Documents [Oito2DataTable] with sortable and resizable columns over
/// 5,000 transfers.
class DataTablePage extends StatefulWidget {
  /// Creates the data table page.
  const DataTablePage({super.key});

  @override
  State<DataTablePage> createState() => _DataTablePageState();
}

class _DataTablePageState extends State<DataTablePage> {
  // #region state
  Oito2SortDescriptor? _sort;
  late var _rows = _collectionOf(_allTransfers);
  late final _selection = Oito2SelectionController(
    collection: _rows,
    mode: Oito2SelectionMode.multiple,
  );

  /// The widths the user gave the resizable columns, by column id.
  final Map<String, double> _widths = {};

  /// Returns a collection of [transfers], keyed by name.
  static Oito2ListCollection<_Transfer> _collectionOf(
    List<_Transfer> transfers,
  ) => Oito2ListCollection(transfers, valueOf: (t) => t.name);

  /// Sorts the transfers by [sort], or restores their order when null.
  void _setSort(Oito2SortDescriptor? sort) {
    final sorted = [..._allTransfers];
    if (sort != null) {
      int compare(_Transfer a, _Transfer b) => switch (sort.column) {
        'size' => a.size.compareTo(b.size),
        'progress' => a.progress.compareTo(b.progress),
        'status' => a.status.compareTo(b.status),
        _ => a.name.compareTo(b.name),
      };
      sorted.sort(
        sort.direction == Oito2SortDirection.ascending
            ? compare
            : (a, b) => compare(b, a),
      );
    }
    setState(() {
      _sort = sort;
      _rows = _collectionOf(sorted);
      _selection.collection = _rows;
      _columnsSelection.collection = _rows;
    });
  }
  // #endregion

  // #region columns-state
  late final _columnsSelection = Oito2SelectionController(collection: _rows);

  /// The columns the user hid and the order they put them in.
  Set<String> _hidden = const {};
  List<String>? _order;

  /// Whether the first column stays in place while the others scroll.
  bool _pinFirst = true;
  // #endregion

  @override
  void dispose() {
    _columnsSelection.dispose();
    _selection.dispose();
    super.dispose();
  }

  /// Returns the width the user gave the column [id], or [fallback].
  Oito2ColumnWidth _width(String id, Oito2ColumnWidth fallback) {
    final width = _widths[id];
    return width == null ? fallback : Oito2ColumnWidth.fixed(width);
  }

  @override
  Widget build(BuildContext context) {
    final format = Oito2Format.of(context);
    final scheme = Theme.of(context).colorScheme;
    return DocPage(
      title: 'Data Table',
      description:
          'A table that builds only the rows in view, with a sticky header '
          'and sortable, resizable columns that the user can hide and move, '
          'with pinned columns.',
      source: 'lib/src/pages/data_table_page.dart',
      children: [
        ExamplePanel(
          regions: const ['data', 'state', 'preview'],
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: Oito2Radius.mediumAll,
            ),
            // #region preview
            child: Oito2DataTable<_Transfer>(
              collection: _rows,
              controller: _selection,
              semanticLabel: 'Transfers',
              sort: _sort,
              onSortChanged: _setSort,
              onColumnResized: (id, width) =>
                  setState(() => _widths[id] = width),
              columns: [
                Oito2TableColumn(
                  id: 'name',
                  label: 'Name',
                  width: _width(
                    'name',
                    const Oito2ColumnWidth.flex(1, min: 160),
                  ),
                  sortable: true,
                  resizable: true,
                ),
                Oito2TableColumn(
                  id: 'size',
                  label: 'Size',
                  width: _width('size', const Oito2ColumnWidth.fixed(96)),
                  alignment: AlignmentDirectional.centerEnd,
                  sortable: true,
                  resizable: true,
                  cellBuilder: (context, t) => Text(format.bytes(t.size)),
                ),
                Oito2TableColumn(
                  id: 'progress',
                  label: 'Progress',
                  width: _width('progress', const Oito2ColumnWidth.fixed(140)),
                  sortable: true,
                  resizable: true,
                  cellBuilder: (context, t) => Oito2LinearProgressIndicator(
                    value: t.progress,
                    semanticsLabel: t.name,
                  ),
                ),
                Oito2TableColumn(
                  id: 'status',
                  label: 'Status',
                  width: _width('status', const Oito2ColumnWidth.fixed(110)),
                  sortable: true,
                  cellBuilder: (context, t) => Text(t.status),
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2DataTable` an `Oito2ListCollection` of the rows, an '
          '`Oito2SelectionController` over it, the `columns` and a bounded '
          'height. Each `Oito2TableColumn` has an id, a header label, a '
          'width (`fixed` or a `flex` share of the space left), an alignment '
          'and a `cellBuilder`; the first column shows the item label '
          'without one. The rows are those of an `Oito2VirtualList`: only '
          'the rows in view are built, and selection, keyboard, '
          '`onReachEnd` and `asyncController` work the same.',
        ),
        const DocText(
          'A click on the header of a `sortable` column calls '
          '`onSortChanged` with the next sort: ascending, descending, then '
          'none. The table does not sort: sort the items (or call '
          '`setSort` on an `Oito2AsyncListController`) and pass them back '
          'with the new `sort`, whose column shows an arrow. A `resizable` '
          'column has a handle at the end of its header; `onColumnResized` '
          'reports the width when a resize ends, to keep it as a fixed '
          'width. Columns wider than the table scroll sideways, header '
          'included.',
        ),
        const DocText(
          'To let the user choose the columns, keep `hiddenColumns` and '
          '`columnOrder` (column ids) in the app and update them from '
          '`onHiddenColumnsChanged` and `onColumnsReordered`. The header '
          'menu then shows or hides each column (at least one stays, and a '
          'column with `hideable: false` never hides), and dragging a header '
          'with the mouse moves its column (Escape cancels the drag). With '
          '`onResetColumns`, the menu also has "Reset columns", where the '
          'app puts back its own defaults. `pinnedColumns` keeps the first '
          'shown columns in place while the others scroll sideways; pinned '
          'columns move only among themselves. `Oito2TreeView` takes '
          '`pinnedColumns` too.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Customize columns', level: 3),
        const DocText(
          'Right-click a header (or long-press it, or press the menu key or '
          'Shift+F10 on it) to show or hide columns, or reset them; Status '
          'always shows. '
          'Drag a header with the mouse, or press Alt with Left or Right on '
          'it, to move its column. The first column stays in place while the '
          'others scroll sideways.',
        ),
        ExamplePanel(
          regions: const ['columns-state', 'columns-preview'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Oito2SwitchButton(
                value: _pinFirst,
                onChanged: (value) => setState(() => _pinFirst = value),
                title: const Text('Pin the first column'),
              ),
              Container(
                height: 300,
                constraints: const BoxConstraints(maxWidth: 440),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: Oito2Radius.mediumAll,
                ),
                // #region columns-preview
                child: Oito2DataTable<_Transfer>(
                  collection: _rows,
                  controller: _columnsSelection,
                  semanticLabel: 'Transfers with chosen columns',
                  sort: _sort,
                  onSortChanged: _setSort,
                  hiddenColumns: _hidden,
                  onHiddenColumnsChanged: (hidden) =>
                      setState(() => _hidden = hidden),
                  columnOrder: _order,
                  onColumnsReordered: (order) => setState(() => _order = order),
                  onResetColumns: () => setState(() {
                    _hidden = const {};
                    _order = null;
                  }),
                  pinnedColumns: _pinFirst ? 1 : 0,
                  columns: [
                    const Oito2TableColumn(
                      id: 'name',
                      label: 'Name',
                      width: Oito2ColumnWidth.fixed(160),
                      sortable: true,
                    ),
                    Oito2TableColumn(
                      id: 'size',
                      label: 'Size',
                      width: const Oito2ColumnWidth.fixed(96),
                      alignment: AlignmentDirectional.centerEnd,
                      sortable: true,
                      cellBuilder: (context, t) => Text(format.bytes(t.size)),
                    ),
                    Oito2TableColumn(
                      id: 'progress',
                      label: 'Progress',
                      width: const Oito2ColumnWidth.fixed(140),
                      cellBuilder: (context, t) => Oito2LinearProgressIndicator(
                        value: t.progress,
                        semanticsLabel: t.name,
                      ),
                    ),
                    Oito2TableColumn(
                      id: 'status',
                      label: 'Status',
                      width: const Oito2ColumnWidth.fixed(110),
                      hideable: false,
                      cellBuilder: (context, t) => Text(t.status),
                    ),
                  ],
                ),
                // #endregion
              ),
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The table is a semantics container labeled by `semanticLabel`. '
          'Header labels are headers; a sortable one is a button whose value '
          'reads "Sorted ascending", "Sorted descending" or "Not sorted". '
          'Each row reads as one item labeled by its cell texts in column '
          'order, or by `rowLabel`, with its position among the rows and its '
          'selection state. Resize handles are sliders that the arrow keys '
          'move. When the columns can move, each header has the "Move column '
          'left" and "Move column right" actions, and a move announces the '
          'new position, such as "Moved column Size to position 2 of 4".',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Tab`',
              'Moves through the sortable headers (every header when the '
                  'columns can be hidden or moved) and resize handles, then '
                  'the rows.',
            ],
            ['`Enter` / `Space` on a header', 'Sorts by that column.'],
            [
              '`Menu` / `Shift+F10` on a header',
              'Opens the column menu, with `onHiddenColumnsChanged` or '
                  '`onColumnsReordered`.',
            ],
            [
              '`Alt+Left` / `Alt+Right` on a header',
              'Moves the column left or right, with `onColumnsReordered`.',
            ],
            ['`Escape`', 'Cancels a column drag in progress.'],
            [
              '`Left arrow` / `Right arrow` on a handle',
              'Narrows or widens the column.',
            ],
            [
              'Arrows, `Page Up`, `Page Down`, `Home`, `End`',
              'Move the active row, as in `Oito2VirtualList`.',
            ],
            ['`Enter` on a row', 'Activates the active row.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2DataTable',
          'Oito2TableColumn',
          'Oito2ColumnWidth',
          'Oito2SortDescriptor',
          'Oito2SortDirection',
        ]),
      ],
    );
  }
}
