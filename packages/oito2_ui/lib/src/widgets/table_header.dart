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

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/async_list_controller.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'resize_handle.dart';
import 'table_column.dart';

/// Returns the padding of the cell in the column at [index] of a widget
/// with table columns: none at the start of the first column.
EdgeInsetsDirectional tableCellPadding(int index) => EdgeInsetsDirectional.only(
  start: index == 0 ? 0 : Oito2Spacing.xs,
  end: Oito2Spacing.sm,
);

/// The column widths of a widget with table columns: the widths of the
/// last layout and the widths set by resizing, kept until the app
/// changes that column's width.
class TableColumnWidths {
  final Map<String, double> _overrides = {};

  /// The column widths of the last [resolve].
  List<double> widths = const [];

  /// Forgets the resized width of each column of [previous] whose width
  /// differs in [current].
  void update<R>(
    List<Oito2TableColumn<R>>? previous,
    List<Oito2TableColumn<R>>? current,
  ) {
    final next = {
      for (final column in current ?? const []) column.id: column.width,
    };
    for (final old in previous ?? const []) {
      if (next[old.id] != old.width) _overrides.remove(old.id);
    }
  }

  /// Returns, and keeps in [widths], the width of each of [columns] that
  /// fits in [available] logical pixels, with the resized widths.
  List<double> resolve<R>(
    List<Oito2TableColumn<R>> columns,
    double available,
  ) => widths = Oito2TableColumn.resolveWidths(
    columns,
    available,
    overrides: _overrides,
  );

  /// Returns the width of [column], the one at [index]: its resized width,
  /// or else the one of the last layout; null before the first layout.
  double? widthOf<R>(Oito2TableColumn<R> column, int index) =>
      _overrides[column.id] ?? (index < widths.length ? widths[index] : null);

  /// Grows [column], the one at [index], by [delta] in screen coordinates
  /// under [direction], no narrower than its resize minimum.
  ///
  /// Returns whether the width could be computed.
  bool resize<R>(
    Oito2TableColumn<R> column,
    int index,
    double delta,
    TextDirection direction,
  ) {
    final current = widthOf(column, index);
    if (current == null) return false;
    _overrides[column.id] = math.max(
      column.width.resizeMin,
      current + (direction == TextDirection.rtl ? -delta : delta),
    );
    return true;
  }
}

/// The header row of a widget with table columns: the label of each
/// column, a resize handle at the end of each resizable one and, on
/// sortable ones, a sort button with an arrow for the current [sort].
class TableHeader<R> extends StatelessWidget {
  /// Creates a table header.
  const TableHeader({
    super.key,
    required this.columns,
    required this.widths,
    required this.height,
    required this.margin,
    required this.padding,
    required this.onResize,
    required this.onResizeEnd,
    this.sort,
    this.onSort,
  });

  /// The columns.
  final List<Oito2TableColumn<R>> columns;

  /// The width of each of [columns].
  final List<double> widths;

  /// The height of the header row.
  final double height;

  /// The space around the header row.
  final EdgeInsetsGeometry margin;

  /// The space inside the header row, around the cells.
  final EdgeInsetsGeometry padding;

  /// Called with a column index and a movement in screen coordinates
  /// while its resize handle moves.
  final void Function(int index, double delta) onResize;

  /// Called with a column index when a resize of that column ends.
  final ValueChanged<int> onResizeEnd;

  /// The current sort, or null.
  final Oito2SortDescriptor? sort;

  /// Called with the index of a sortable column whose header was
  /// activated; sortable headers aren't buttons when null.
  final ValueChanged<int>? onSort;

  /// Returns the accessibility value of the header of [column]: its sort
  /// direction, or that it isn't sorted.
  String _sortValue(Oito2Localizations strings, Oito2TableColumn<R> column) {
    final sort = this.sort;
    if (sort == null || sort.column != column.id) return strings.notSorted;
    return sort.direction == Oito2SortDirection.ascending
        ? strings.sortedAscending
        : strings.sortedDescending;
  }

  /// Builds the label of the column at [index], as a sort button when it
  /// is sortable.
  Widget _label(BuildContext context, int index) {
    final column = columns[index];
    final strings = Oito2Localizations.of(context);
    final onSort = this.onSort;
    final sortable = column.sortable && onSort != null;
    final sorted = sort?.column == column.id ? sort!.direction : null;
    final end = column.alignment.resolve(Directionality.of(context)).x > 0;
    final text = Text(
      column.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    Widget label = !sortable
        ? Semantics(header: true, child: text)
        : Semantics(
            header: true,
            button: true,
            label: column.label,
            value: _sortValue(strings, column),
            onTap: () => onSort(index),
            excludeSemantics: true,
            child: InkWell(
              mouseCursor: WidgetStateMouseCursor.clickable,
              borderRadius: Oito2Radius.smallAll,
              onTap: () => onSort(index),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Oito2Spacing.xxs,
                children: [
                  if (end && sorted != null) _arrow(sorted),
                  Flexible(child: text),
                  if (!end && sorted != null) _arrow(sorted),
                ],
              ),
            ),
          );
    final tooltip = column.tooltip;
    if (tooltip != null) label = Tooltip(message: tooltip, child: label);
    return label;
  }

  /// The arrow of a column sorted in [direction].
  Widget _arrow(Oito2SortDirection direction) => Icon(
    direction == Oito2SortDirection.ascending
        ? LucideIcons.arrow_up
        : LucideIcons.arrow_down,
    size: 14,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    const step = 8.0;
    return Container(
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: scheme.onSurfaceVariant),
        child: DefaultTextStyle.merge(
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          child: Row(
            children: [
              for (var i = 0; i < columns.length; i++)
                SizedBox(
                  width: widths[i],
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: tableCellPadding(i),
                          child: Align(
                            alignment: columns[i].alignment,
                            child: _label(context, i),
                          ),
                        ),
                      ),
                      if (columns[i].resizable)
                        PositionedDirectional(
                          top: 0,
                          bottom: 0,
                          end: 0,
                          child: ResizeHandle(
                            axis: Axis.horizontal,
                            keyboardStep: step,
                            onMove: (delta) => onResize(i, delta),
                            onMoveEnd: () => onResizeEnd(i),
                            semanticLabel: strings.resizeColumn(
                              columns[i].label,
                            ),
                            value: '${widths[i].round()}',
                            increasedValue: '${(widths[i] + step).round()}',
                            decreasedValue:
                                '${math.max(columns[i].width.resizeMin, widths[i] - step).round()}',
                            onIncrease: () {
                              onResize(i, rtl ? -step : step);
                              onResizeEnd(i);
                            },
                            onDecrease: () {
                              onResize(i, rtl ? step : -step);
                              onResizeEnd(i);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays out a widget with table columns: resolves the column widths for
/// the available width, and shows the [header] row above the [body],
/// both scrolling sideways when the columns are wider than the space.
class TableColumnsView extends StatelessWidget {
  /// Creates a table columns view.
  const TableColumnsView({
    super.key,
    required this.controller,
    required this.chrome,
    required this.resolve,
    required this.body,
    this.header,
  });

  /// The controller of the sideways scroll.
  final ScrollController controller;

  /// The horizontal space the rows take beside the columns, such as
  /// margins and padding.
  final double chrome;

  /// Resolves and returns the column widths for an available width.
  final List<double> Function(double available) resolve;

  /// Builds the header row after [resolve]; no header when null.
  final WidgetBuilder? header;

  /// The rows, which take the remaining height.
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widths = resolve(constraints.maxWidth - chrome);
        final total = widths.fold(chrome, (sum, w) => sum + w);
        final header = this.header;
        return SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(total, constraints.maxWidth),
            height: constraints.maxHeight,
            child: Column(
              children: [
                if (header != null) header(context),
                Expanded(child: body),
              ],
            ),
          ),
        );
      },
    );
  }
}
