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

import 'package:flutter/gestures.dart' show Drag;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/async_list_controller.dart';
import '../l10n/oito2_localizations.dart';
import 'context_menu.dart';
import 'menus.dart';
import 'row_drag.dart';
import 'table_column.dart';
import 'table_header.dart';

/// Lets the user choose the columns of a widget with table columns of
/// rows of type [R]: a header menu that shows and hides them and resets
/// them, header drags, Alt+Left and Alt+Right and accessibility actions
/// that move them, and pinned columns, all reported through the widget's
/// callbacks.
///
/// When [firstColumnFixed] is true, the first declared column always
/// shows first: it can't be hidden or moved, and its id is ignored in
/// [hiddenColumnIds] and [columnOrderIds].
mixin TableColumnsCustomization<R, W extends StatefulWidget> on State<W> {
  /// The columns as the widget declares them.
  List<Oito2TableColumn<R>> get declaredColumns;

  /// The ids of the columns the app hides.
  Set<String> get hiddenColumnIds;

  /// The order of the columns, by id, or null for the declared order.
  List<String>? get columnOrderIds;

  /// Called with the ids of the columns to hide; columns can't be hidden
  /// when null.
  ValueChanged<Set<String>>? get onHiddenColumnsChanged;

  /// Called with the new order of all the column ids; columns can't move
  /// when null.
  ValueChanged<List<String>>? get onColumnsReordered;

  /// Called when the user asks to reset the columns; the menu has no
  /// reset item when null.
  VoidCallback? get onResetColumns;

  /// How many shown columns the widget asks to keep in place.
  int get requestedPinnedColumns;

  /// Whether the first declared column always shows first and stays.
  bool get firstColumnFixed;

  /// The sideways scroll of the columns.
  ScrollController get columnsScroll;

  /// The column widths.
  TableColumnWidths get columnWidths;

  /// The space between the start edge of the widget and the first column.
  double get columnsStartInset;

  /// The key of the widget's box, the viewport of [columnsScroll].
  final columnsViewportKey = GlobalKey();

  /// The keys of the header cells, by column id, which keep a cell's state
  /// when its column moves and locate it during a column drag.
  final _headerKeys = <String, GlobalKey>{};

  /// The id of the column being dragged, or null.
  String? _dragColumn;

  /// The gap the dragged column would drop into, among the shown columns,
  /// or null when the drop wouldn't move it.
  int? _dropGap;

  Offset _pointer = Offset.zero;
  final _feedback = DragFeedback();
  late final _autoScroll = DragAutoScroller(_updateColumnDrop);

  /// The shown columns, in order, as of the last [refreshVisibleColumns].
  late List<Oito2TableColumn<R>> visibleColumns = _computeVisibleColumns();

  /// Whether the user can show and hide columns.
  bool get _hideable => onHiddenColumnsChanged != null;

  /// Whether the user can move columns.
  bool get _reorderable => onColumnsReordered != null;

  /// Whether the header has a column menu.
  bool get columnsCustomizable =>
      _hideable || _reorderable || onResetColumns != null;

  /// How many of the shown columns stay in place: at most all but the
  /// last one.
  int get pinnedColumnCount =>
      math.max(0, math.min(requestedPinnedColumns, visibleColumns.length - 1));

  /// How many columns at the start can't move.
  int get _fixedCount => firstColumnFixed && visibleColumns.isNotEmpty ? 1 : 0;

  /// Recomputes [visibleColumns] and forgets the header keys of columns
  /// that are gone; call at the start of each build.
  List<Oito2TableColumn<R>> refreshVisibleColumns() {
    final ids = {for (final column in declaredColumns) column.id};
    _headerKeys.removeWhere((id, _) => !ids.contains(id));
    return visibleColumns = _computeVisibleColumns();
  }

  /// All the columns, hidden ones included, in [columnOrderIds], with the
  /// fixed first column first.
  List<Oito2TableColumn<R>> orderedColumns() {
    final columns = declaredColumns;
    final order = columnOrderIds;
    if (columns.isEmpty) return columns;
    final fixed = firstColumnFixed ? columns.first : null;
    final byId = {
      for (final column in columns)
        if (!identical(column, fixed)) column.id: column,
    };
    final result = <Oito2TableColumn<R>>[?fixed];
    for (final id in order ?? const <String>[]) {
      final column = byId.remove(id);
      if (column != null) result.add(column);
    }
    return [
      ...result,
      for (final column in columns)
        if (byId.containsKey(column.id)) column,
    ];
  }

  /// The shown columns, in order: at least the first one when every column
  /// is hidden, and always the fixed first column.
  List<Oito2TableColumn<R>> _computeVisibleColumns() {
    final ordered = orderedColumns();
    final hidden = hiddenColumnIds;
    final fixed = firstColumnFixed ? ordered.firstOrNull : null;
    final visible = [
      for (final column in ordered)
        if (identical(column, fixed) || !hidden.contains(column.id)) column,
    ];
    return visible.isEmpty && ordered.isNotEmpty ? [ordered.first] : visible;
  }

  /// Returns the first and the last gap, among the shown columns, that the
  /// column at [index] can move to: the pinned columns move among
  /// themselves, the others after them, and none before a fixed column.
  (int, int) _gapRange(int index) {
    final pinned = pinnedColumnCount;
    final fixed = _fixedCount;
    final (first, last) = index < pinned
        ? (0, pinned)
        : (pinned, visibleColumns.length);
    return (math.max(first, fixed), last);
  }

  /// Returns whether the column at [index] can move [delta] places, -1 or
  /// 1, among the shown columns.
  bool _canMove(int index, int delta) {
    if (index < _fixedCount) return false;
    final (first, last) = _gapRange(index);
    final to = index + delta;
    return index >= 0 && to >= first && to < last;
  }

  /// Moves the shown column [id] into the gap [gap] among the shown
  /// columns through [onColumnsReordered], and announces its new
  /// position; does nothing when that leaves it in place.
  void _moveColumn(String id, int gap) {
    final onReordered = onColumnsReordered;
    final visible = visibleColumns;
    final from = visible.indexWhere((column) => column.id == id);
    if (onReordered == null || from < 0 || gap == from || gap == from + 1) {
      return;
    }
    final order = [for (final column in orderedColumns()) column.id];
    final anchor = gap < visible.length ? visible[gap].id : null;
    order.remove(id);
    if (anchor != null) {
      order.insert(order.indexOf(anchor), id);
    } else {
      order.insert(order.indexOf(visible.last.id) + 1, id);
    }
    onReordered(order);
    announceTo(
      context,
      Oito2Localizations.of(context).movedColumn(
        visible[from].label,
        reorderIndex(from, gap) + 1,
        visible.length,
      ),
    );
  }

  /// Moves the column at [index] one place toward the left when [delta]
  /// is -1, or toward the right when it is 1, as the screen shows them.
  void _moveVisually(int index, int delta) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final step = rtl ? -delta : delta;
    if (!_canMove(index, step)) return;
    _moveColumn(visibleColumns[index].id, step > 0 ? index + 2 : index - 1);
  }

  /// Returns whether the column at [index] can move one place toward the
  /// left when [delta] is -1, or toward the right when it is 1.
  bool _canMoveVisually(int index, int delta) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return _canMove(index, rtl ? -delta : delta);
  }

  /// Shows the column [id] when [shown], or hides it, through
  /// [onHiddenColumnsChanged].
  void _setShown(String id, bool shown) {
    final hidden = {...hiddenColumnIds};
    if (shown) {
      hidden.remove(id);
    } else {
      hidden.add(id);
    }
    onHiddenColumnsChanged?.call(hidden);
  }

  /// Starts dragging the column [id] from the global position [global],
  /// unless the columns can't move, the column is fixed or a drag is in
  /// progress.
  Drag? _startColumnDrag(String id, Offset global) {
    if (!_reorderable || _dragColumn != null) return null;
    final index = visibleColumns.indexWhere((c) => c.id == id);
    if (index < _fixedCount) return null;
    setState(() {
      _dragColumn = id;
      _pointer = global;
      _dropGap = null;
    });
    HardwareKeyboard.instance.addHandler(_dragKey);
    _feedback.show(context, visibleColumns[index].label, global);
    _updateColumnDrop();
    return RowDrag(onUpdate: _dragColumnTo, onEnd: _endColumnDrag);
  }

  /// Cancels the column drag on Escape, and keeps other keys from acting
  /// during it.
  bool _dragKey(KeyEvent event) {
    if (_dragColumn == null) return false;
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      stopColumnDrag();
    }
    return true;
  }

  /// Follows the pointer to [global]: updates the drop and scrolls sideways
  /// near the edges of the scrolling columns.
  void _dragColumnTo(Offset global) {
    if (_dragColumn == null) return;
    _pointer = global;
    _feedback.move(global);
    _updateColumnDrop();
    final viewport = columnsViewportKey.currentContext?.findRenderObject();
    final from = visibleColumns.indexWhere((c) => c.id == _dragColumn);
    // A scrolling column scrolls the widget when the pointer nears the end
    // of the pinned columns, not the edge of the widget.
    var inset = 0.0;
    final pinned = pinnedColumnCount;
    final widths = columnWidths.widths;
    if (from >= pinned && pinned > 0) {
      inset = columnsStartInset;
      for (var i = 0; i < pinned && i < widths.length; i++) {
        inset += widths[i];
      }
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    _autoScroll.update(
      global,
      viewport is RenderBox ? viewport : null,
      columnsScroll.hasClients ? columnsScroll.position : null,
      axis: Axis.horizontal,
      leadingInset: rtl ? 0 : inset,
      trailingInset: rtl ? inset : 0,
    );
  }

  /// Recomputes the gap the dragged column would drop into, from the
  /// header cell the pointer is over.
  void _updateColumnDrop() {
    final id = _dragColumn;
    if (id == null || !mounted) return;
    final visible = visibleColumns;
    final from = visible.indexWhere((c) => c.id == id);
    if (from < 0) return;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final (first, last) = _gapRange(from);
    var gap = last;
    for (var i = first; i < last; i++) {
      final box = _headerKeys[visible[i].id]?.currentContext
          ?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final local = box.globalToLocal(_pointer);
      final half = box.size.width / 2;
      if (rtl ? local.dx > half : local.dx < half) {
        gap = i;
        break;
      }
    }
    final drop = gap == from || gap == from + 1 ? null : gap;
    if (drop != _dropGap) setState(() => _dropGap = drop);
  }

  /// Ends the column drag, moving the column when the pointer was
  /// released over a gap that moves it.
  void _endColumnDrag(bool dropped) {
    final id = _dragColumn;
    final gap = _dropGap;
    if (id == null) return;
    stopColumnDrag();
    if (dropped && gap != null) _moveColumn(id, gap);
  }

  /// Ends the column drag without moving anything, rebuilding unless
  /// [rebuild] is false, as when the widget is about to build anyway.
  void stopColumnDrag({bool rebuild = true}) {
    _autoScroll.stop();
    _feedback.hide();
    HardwareKeyboard.instance.removeHandler(_dragKey);
    if (_dragColumn == null) return;
    _dragColumn = null;
    _dropGap = null;
    if (rebuild && mounted) setState(() {});
  }

  /// Stops a column drag when the columns can no longer move; call from
  /// `didUpdateWidget`.
  void updateColumnsCustomization() {
    if (!_reorderable) stopColumnDrag(rebuild: false);
  }

  /// Stops the column drag and releases its resources; call from
  /// `dispose`.
  void disposeColumnsCustomization() {
    _autoScroll.stop();
    HardwareKeyboard.instance.removeHandler(_dragKey);
    _feedback.dispose();
  }

  /// The "Move column left" and "Move column right" accessibility actions
  /// of the header of the column at [index], for the ways it can go.
  Map<CustomSemanticsAction, VoidCallback>? _columnActions(int index) {
    if (!_reorderable) return null;
    final strings = Oito2Localizations.of(context);
    return {
      if (_canMoveVisually(index, -1))
        CustomSemanticsAction(label: strings.moveColumnLeft): () =>
            _moveVisually(index, -1),
      if (_canMoveVisually(index, 1))
        CustomSemanticsAction(label: strings.moveColumnRight): () =>
            _moveVisually(index, 1),
    };
  }

  /// The items of the header menu of the column at [index]: a check box
  /// for each column that shows or hides it, the moves of the column and
  /// the reset of the columns.
  List<Widget> _menuItems(BuildContext context, int index) {
    final strings = Oito2Localizations.of(context);
    final visibleCount = visibleColumns.length;
    final shownIds = {for (final column in visibleColumns) column.id};
    final fixed = firstColumnFixed ? declaredColumns.firstOrNull : null;
    final reset = onResetColumns;
    return [
      if (_hideable)
        for (final column in orderedColumns())
          Oito2MultiSelectMenuItem(
            key: ValueKey('oito2-column-toggle-${column.id}'),
            checked: shownIds.contains(column.id),
            onChanged:
                identical(column, fixed) ||
                    shownIds.contains(column.id) &&
                        (!column.hideable || visibleCount <= 1)
                ? null
                : (shown) => _setShown(column.id, shown),
            child: Text(column.label),
          ),
      if (_hideable && _reorderable) const Divider(height: 1),
      if (_reorderable) ...[
        MenuItemButton(
          key: const ValueKey('oito2-column-move-left'),
          onPressed: _canMoveVisually(index, -1)
              ? () => _moveVisually(index, -1)
              : null,
          child: Text(strings.moveColumnLeft),
        ),
        MenuItemButton(
          key: const ValueKey('oito2-column-move-right'),
          onPressed: _canMoveVisually(index, 1)
              ? () => _moveVisually(index, 1)
              : null,
          child: Text(strings.moveColumnRight),
        ),
      ],
      if (reset != null) ...[
        if (_hideable || _reorderable) const Divider(height: 1),
        MenuItemButton(
          key: const ValueKey('oito2-column-reset'),
          onPressed: reset,
          child: Text(strings.resetColumns),
        ),
      ],
    ];
  }

  /// Adds to the header cell [content] of the column at [index] its menu,
  /// its column drag and the Alt+Left and Alt+Right moves.
  Widget _wrapHeaderCell(BuildContext context, int index, Widget content) {
    final id = visibleColumns[index].id;
    // A transparent box makes the whole cell take the pointer.
    Widget result = ColoredBox(color: const Color(0x00000000), child: content);
    if (_reorderable && index >= _fixedCount) {
      result = CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): () =>
              _moveVisually(index, -1),
          const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true): () =>
              _moveVisually(index, 1),
        },
        child: MouseRegion(
          cursor: _dragColumn != null
              ? SystemMouseCursors.grabbing
              : SystemMouseCursors.grab,
          child: RowDragDetector(
            onStart: (global) => _startColumnDrag(id, global),
            longPress: false,
            child: result,
          ),
        ),
      );
    }
    return Oito2ContextMenuRegion(
      menuChildren: _menuItems(context, index),
      child: result,
    );
  }

  /// Builds the header row of [visibleColumns], with the column menu,
  /// moves and pinning the widget's callbacks allow.
  TableHeader<R> buildColumnsHeader({
    required double height,
    required EdgeInsetsGeometry margin,
    required EdgeInsetsGeometry padding,
    required void Function(int index, double delta) onResize,
    required ValueChanged<int> onResizeEnd,
    Oito2SortDescriptor? sort,
    ValueChanged<int>? onSort,
  }) {
    final columns = visibleColumns;
    final customizable = columnsCustomizable;
    final draggable = _reorderable;
    return TableHeader<R>(
      columns: columns,
      widths: columnWidths.widths,
      height: height,
      margin: margin,
      padding: padding,
      onResize: onResize,
      onResizeEnd: onResizeEnd,
      sort: sort,
      onSort: onSort,
      pinned: pinnedColumnCount,
      scroll: columnsScroll,
      focusable: customizable,
      labelCursorOf: !draggable
          ? null
          : (index) => index < _fixedCount
                ? null
                : _dragColumn != null
                ? SystemMouseCursors.grabbing
                : SystemMouseCursors.grab,
      actionsOf: draggable ? _columnActions : null,
      wrapCell: customizable ? _wrapHeaderCell : null,
      dropGap: _dropGap,
      keyOf: (index) =>
          _headerKeys.putIfAbsent(columns[index].id, GlobalKey.new),
    );
  }
}
