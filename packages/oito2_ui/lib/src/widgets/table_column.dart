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

/// How wide an [Oito2TableColumn] is: a fixed width, or a share of the
/// space the fixed columns leave.
sealed class Oito2ColumnWidth {
  const Oito2ColumnWidth();

  /// A column [width] logical pixels wide.
  const factory Oito2ColumnWidth.fixed(double width) = Oito2FixedColumnWidth;

  /// A column that takes [flex] shares of the space the fixed columns
  /// leave, and at least [min] logical pixels.
  const factory Oito2ColumnWidth.flex(double flex, {double min}) =
      Oito2FlexColumnWidth;

  /// The narrowest a resize can make the column: [min] for a flexible
  /// column, and never less than [Oito2TableColumn.minResizeWidth].
  double get resizeMin => switch (this) {
    Oito2FlexColumnWidth(:final min) => math.max(
      min,
      Oito2TableColumn.minResizeWidth,
    ),
    Oito2FixedColumnWidth() => Oito2TableColumn.minResizeWidth,
  };
}

/// A column of a fixed [width].
final class Oito2FixedColumnWidth extends Oito2ColumnWidth {
  /// Creates a fixed column width.
  const Oito2FixedColumnWidth(this.width) : assert(width >= 0);

  /// The width, in logical pixels.
  final double width;

  @override
  bool operator ==(Object other) =>
      other is Oito2FixedColumnWidth && other.width == width;

  @override
  int get hashCode => width.hashCode;
}

/// A column that shares the space left by the fixed columns.
final class Oito2FlexColumnWidth extends Oito2ColumnWidth {
  /// Creates a flexible column width of [flex] shares, at least [min]
  /// logical pixels wide.
  const Oito2FlexColumnWidth(this.flex, {this.min = 0})
    : assert(flex > 0),
      assert(min >= 0);

  /// The shares of the free space this column takes.
  final double flex;

  /// The narrowest the column gets, in logical pixels.
  final double min;

  @override
  bool operator ==(Object other) =>
      other is Oito2FlexColumnWidth && other.flex == flex && other.min == min;

  @override
  int get hashCode => Object.hash(flex, min);
}

/// A column of a widget that shows rows of type [R] in columns, such as
/// an [Oito2DataTable], or an [Oito2TreeView] with columns, where [R] is
/// the tree's node type.
///
/// The column has a header [label] and builds each row's cell with
/// [cellBuilder].
class Oito2TableColumn<R> {
  /// Creates a column.
  const Oito2TableColumn({
    required this.id,
    required this.label,
    this.width = const Oito2ColumnWidth.flex(1),
    this.alignment = AlignmentDirectional.centerStart,
    this.resizable = false,
    this.sortable = false,
    this.cellBuilder,
    this.tooltip,
  });

  /// The narrowest a resize makes any column, in logical pixels.
  static const double minResizeWidth = 32;

  /// The column's identifier, reported when it is resized.
  final String id;

  /// The text of the column header.
  final String label;

  /// The width of the column.
  final Oito2ColumnWidth width;

  /// How the header label and the cells are aligned in the column.
  final AlignmentGeometry alignment;

  /// Whether the header has a handle that resizes the column.
  final bool resizable;

  /// Whether a click on the header sorts by this column, in a widget that
  /// sorts, such as an [Oito2DataTable].
  final bool sortable;

  /// Builds the cell of a row; the cell is empty when null, except where
  /// the widget showing the column documents a default content.
  final Widget Function(BuildContext context, R row)? cellBuilder;

  /// The tooltip of the column header.
  final String? tooltip;

  /// Returns the width of each of [columns] that fits in [available]
  /// logical pixels: fixed columns keep their width, or the one in
  /// [overrides] by column id, and flexible ones share what is left,
  /// each at least its minimum.
  static List<double> resolveWidths<R>(
    List<Oito2TableColumn<R>> columns,
    double available, {
    Map<String, double> overrides = const {},
  }) {
    var fixed = 0.0;
    var flex = 0.0;
    for (final column in columns) {
      final override = overrides[column.id];
      switch (column.width) {
        case _ when override != null:
          fixed += override;
        case Oito2FixedColumnWidth(:final width):
          fixed += width;
        case Oito2FlexColumnWidth(flex: final f):
          flex += f;
      }
    }
    final free = math.max(0.0, available - fixed);
    return [
      for (final column in columns)
        switch (column.width) {
          _ when overrides[column.id] != null => overrides[column.id]!,
          Oito2FixedColumnWidth(:final width) => width,
          Oito2FlexColumnWidth(flex: final f, :final min) => math.max(
            min,
            free * f / flex,
          ),
        },
    ];
  }
}
