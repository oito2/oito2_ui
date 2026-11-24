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

import '../collections/async_list_controller.dart';
import '../collections/list_collection.dart';
import '../collections/selection_controller.dart';
import '../tokens/geometry.dart';
import 'table_column.dart';
import 'table_header.dart';
import 'virtual_list.dart';
import 'widget_helpers.dart';

/// A table of the items of [collection] in [columns], built on an
/// [Oito2VirtualList]: only the rows in view are built, and it selects
/// and responds to the keyboard as the list does, with the selection kept
/// in [controller].
///
/// A header row with the column labels stays above the rows. A resizable
/// column has a handle at the end of its header, and [onColumnResized]
/// reports its width when a resize ends. A click, Enter or Space on the
/// header of a [Oito2TableColumn.sortable] column calls [onSortChanged]
/// with the next sort: ascending, then descending, then none. The header
/// of the [sort] column shows an arrow. The table doesn't sort: the app
/// sorts the items, or an [Oito2AsyncListController] reloads them, and
/// passes them back with the new [sort].
///
/// Columns wider in total than the table scroll sideways, with the header.
///
/// Assistive technologies read the header labels as headers, with their
/// sort state as the value of sortable ones, and each row as one item
/// labeled by [rowLabel], or by its cell texts in column order, with its
/// position among the rows.
///
/// With [onReorder], the user reorders the rows as in an
/// [Oito2VirtualList], by dragging a whole row.
///
/// The table needs a bounded height, such as from a [SizedBox] or an
/// [Expanded].
class Oito2DataTable<T> extends StatefulWidget {
  /// Creates a data table.
  const Oito2DataTable({
    super.key,
    required this.collection,
    required this.controller,
    required this.columns,
    this.sort,
    this.onSortChanged,
    this.onColumnResized,
    this.onActivate,
    this.rowHeight,
    this.cacheExtent,
    this.onReachEnd,
    this.asyncController,
    this.rowLabel,
    this.showHeader = true,
    this.placeholder,
    this.semanticLabel,
    this.autofocus = false,
    this.onReorder,
  });

  /// The rows.
  final Oito2ListCollection<T> collection;

  /// The selection over [collection].
  final Oito2SelectionController controller;

  /// The columns. The first column shows the item label when its
  /// [Oito2TableColumn.cellBuilder] is null; other columns without one
  /// show empty cells.
  final List<Oito2TableColumn<T>> columns;

  /// The current sort, by column id, or null.
  final Oito2SortDescriptor? sort;

  /// Called with the next sort when the header of a sortable column is
  /// activated: ascending for a column the table isn't sorted by,
  /// descending for an ascending one and null for a descending one.
  final ValueChanged<Oito2SortDescriptor?>? onSortChanged;

  /// Called with a column id and its new width when a resize of that
  /// column ends; the app can keep the width and pass it back as an
  /// [Oito2ColumnWidth.fixed] width.
  final void Function(String id, double width)? onColumnResized;

  /// Called on Enter or a double click on an enabled row.
  final ValueChanged<T>? onActivate;

  /// The height of the rows and the header; the theme's control height
  /// when null, except that, where the theme pads tap targets (touch
  /// platforms), the rows are then [Oito2Sizes.minTouchTarget] tall, as
  /// in an [Oito2VirtualList].
  ///
  /// A height set here is kept on every platform, even below the touch
  /// target size.
  final double? rowHeight;

  /// How far beyond the visible area rows are built ahead of scrolling.
  final double? cacheExtent;

  /// Called when the last rows come near the view, as
  /// [Oito2VirtualList.onReachEnd].
  final VoidCallback? onReachEnd;

  /// The controller the rows are loaded through, as
  /// [Oito2VirtualList.asyncController].
  final Oito2AsyncListController<Object?, Object?>? asyncController;

  /// Returns the accessibility label of a row; its cell texts when null.
  final String Function(T item)? rowLabel;

  /// Whether the header row shows.
  final bool showHeader;

  /// Shown when [collection] is empty and nothing is loading.
  final Widget? placeholder;

  /// The accessibility label of the table.
  final String? semanticLabel;

  /// Whether the table takes the focus when shown.
  final bool autofocus;

  /// Called when the user moves a row, with its index in
  /// [Oito2ListCollection.items] and the index it ends at, counted once it
  /// is taken out of its place, as [Oito2VirtualList.onReorder] reports
  /// it: by dragging the row, by Alt with Up or Down on the active row, or
  /// by the "Move up" and "Move down" accessibility actions. The rows can't
  /// be reordered when null.
  ///
  /// The table doesn't move the row: the app does, and usually clears
  /// [sort], as the new order no longer follows it.
  final void Function(int from, int to)? onReorder;

  /// Returns the sort after activating the header of the column [id] in a
  /// table sorted by [current]: ascending, then descending, then none.
  static Oito2SortDescriptor? nextSort(
    Oito2SortDescriptor? current,
    String id,
  ) {
    if (current == null || current.column != id) {
      return Oito2SortDescriptor(id);
    }
    return current.direction == Oito2SortDirection.ascending
        ? Oito2SortDescriptor(id, Oito2SortDirection.descending)
        : null;
  }

  @override
  State<Oito2DataTable<T>> createState() => _Oito2DataTableState<T>();
}

/// Keeps the column widths and the sideways scroll of [Oito2DataTable].
class _Oito2DataTableState<T> extends State<Oito2DataTable<T>> {
  final _horizontalScroll = ScrollController();
  final _columnWidths = TableColumnWidths();

  /// The space around the rows and inside them, on both sides.
  static const _margin = Oito2Spacing.xs;
  static const _padding = Oito2Spacing.sm;

  @override
  void didUpdateWidget(Oito2DataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _columnWidths.update(oldWidget.columns, widget.columns);
  }

  @override
  void dispose() {
    _horizontalScroll.dispose();
    super.dispose();
  }

  /// Grows the column at [index] by [delta] in screen coordinates.
  void _resize(int index, double delta) {
    setState(() {
      _columnWidths.resize(
        widget.columns[index],
        index,
        delta,
        Directionality.of(context),
      );
    });
  }

  /// Reports the width of the column at [index] through
  /// [Oito2DataTable.onColumnResized].
  void _endResize(int index) {
    final column = widget.columns[index];
    final width = _columnWidths.widthOf(column, index);
    if (width != null) widget.onColumnResized?.call(column.id, width);
  }

  /// Reports the next sort after the header of the column at [index] is
  /// activated.
  void _sort(int index) {
    widget.onSortChanged?.call(
      Oito2DataTable.nextSort(widget.sort, widget.columns[index].id),
    );
  }

  /// Builds the cells of the row of [item].
  Widget _cells(BuildContext context, T item) {
    final columns = widget.columns;
    final widths = _columnWidths.widths;
    final row = Row(
      children: [
        for (var i = 0; i < columns.length && i < widths.length; i++)
          SizedBox(
            width: widths[i],
            child: Padding(
              padding: tableCellPadding(i),
              child: Align(
                alignment: columns[i].alignment,
                child:
                    columns[i].cellBuilder?.call(context, item) ??
                    (i == 0
                        ? Text(
                            widget.collection.labelOf(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null),
              ),
            ),
          ),
      ],
    );
    final label = widget.rowLabel;
    if (label == null) return row;
    return Semantics(label: label(item), excludeSemantics: true, child: row);
  }

  @override
  Widget build(BuildContext context) {
    final columns = widget.columns;
    final height = widget.rowHeight ?? controlHeightOf(context);
    return Semantics(
      label: widget.semanticLabel,
      container: true,
      explicitChildNodes: true,
      child: TableColumnsView(
        controller: _horizontalScroll,
        chrome: 2 * _margin + 2 * _padding,
        resolve: (available) => _columnWidths.resolve(columns, available),
        header: !widget.showHeader
            ? null
            : (context) => TableHeader(
                columns: columns,
                widths: _columnWidths.widths,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: _margin),
                padding: const EdgeInsets.symmetric(horizontal: _padding),
                onResize: _resize,
                onResizeEnd: _endResize,
                sort: widget.sort,
                onSort: widget.onSortChanged == null ? null : _sort,
              ),
        body: Oito2VirtualList<T>(
          collection: widget.collection,
          controller: widget.controller,
          itemBuilder: (context, item, selected) => _cells(context, item),
          onActivate: widget.onActivate,
          itemExtent: widget.rowHeight,
          cacheExtent: widget.cacheExtent,
          onReachEnd: widget.onReachEnd,
          asyncController: widget.asyncController,
          placeholder: widget.placeholder,
          showCheckmarks: false,
          autofocus: widget.autofocus,
          onReorder: widget.onReorder,
        ),
      ),
    );
  }
}
