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

import 'package:flutter/gestures.dart' show Drag;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/list_collection.dart';
import '../l10n/oito2_localizations.dart';
import 'row_drag.dart';

/// Where a list drag would drop: the row whose edge shows the line,
/// before or after it, the gap between items it stands for, counted
/// before the dragged item is taken out, and whether it would leave the
/// item in place.
typedef _ListDrop = ({String row, DropPlacement placement, int gap, bool noop});

/// Reordering for the rows of a list of [T]: row drags with a drop line
/// and auto-scroll, Alt+Up and Alt+Down on the active row, the move
/// accessibility actions and the announcements, all reported through
/// [onReorder] with the item's index and the index it ends at once taken
/// out of its place.
mixin ListReorderMixin<T, W extends StatefulWidget> on State<W> {
  /// The items being reordered.
  Oito2ListCollection<T> get reorderCollection;

  /// Called with the old and the new index of a moved item.
  void Function(int from, int to)? get onReorder;

  /// Whether the items can be reordered now.
  bool get canReorder;

  /// The built rows, by item value.
  Iterable<MapEntry<String, BuildContext>> get builtRows;

  /// The box the rows scroll in.
  RenderBox? get reorderViewport;

  /// The scroll position of the rows, if they scroll.
  ScrollPosition? get reorderScroll;

  /// Makes [value] the active row, focusing the list.
  void activateForReorder(String value);

  /// Scrolls the row of [value] into view.
  void revealForReorder(String value);

  String? _dragValue;
  Offset _pointer = Offset.zero;
  _ListDrop? _drop;
  final _feedback = DragFeedback();
  late final _autoScroll = DragAutoScroller(_updateDrop);

  /// Whether a row drag is in progress.
  bool get reorderDragging => _dragValue != null;

  /// The cursor of the list: the grabbing hand during a drag over an
  /// allowed drop, the "no drop" sign over none, and the rows' own cursor
  /// otherwise.
  MouseCursor get reorderCursor => _dragValue == null
      ? MouseCursor.defer
      : _drop != null
      ? SystemMouseCursors.grabbing
      : SystemMouseCursors.noDrop;

  /// Starts dragging the item [value] from the global position [global],
  /// unless reordering is off, the item is disabled or a drag is already in
  /// progress.
  Drag? startRowDrag(String value, Offset global) {
    final item = reorderCollection.find(value);
    if (!canReorder ||
        _dragValue != null ||
        item == null ||
        reorderCollection.isDisabled(item)) {
      return null;
    }
    activateForReorder(value);
    setState(() {
      _dragValue = value;
      _pointer = global;
      _drop = null;
    });
    _feedback.show(context, reorderCollection.labelOf(item), global);
    _updateDrop();
    return RowDrag(onUpdate: _dragTo, onEnd: _endDrag);
  }

  /// Follows the pointer to [global]: updates the drop and scrolls near
  /// the edges.
  void _dragTo(Offset global) {
    if (_dragValue == null) return;
    _pointer = global;
    _feedback.move(global);
    _updateDrop();
    _autoScroll.update(global, reorderViewport, reorderScroll);
  }

  /// Ends the drag, calling [onReorder] when the pointer was released over
  /// a drop that moves the item.
  void _endDrag(bool dropped) {
    final value = _dragValue;
    final drop = _drop;
    if (value == null) return;
    stopRowDrag();
    if (!dropped || drop == null || drop.noop) return;
    final from = reorderCollection.indexOf(value);
    if (from < 0) return;
    onReorder?.call(from, reorderIndex(from, drop.gap));
  }

  /// Ends the drag without moving anything, rebuilding unless [rebuild]
  /// is false, as when the widget is about to build anyway.
  void stopRowDrag({bool rebuild = true}) {
    _autoScroll.stop();
    _feedback.hide();
    if (_dragValue == null) return;
    _dragValue = null;
    _drop = null;
    if (rebuild && mounted) setState(() {});
  }

  /// Recomputes the drop for the pointer and shows whether it is allowed.
  void _updateDrop() {
    final value = _dragValue;
    if (value == null || !mounted) return;
    final drop = _dropAt(value);
    _feedback.allowed = drop != null;
    if (drop != _drop) setState(() => _drop = drop);
  }

  /// The drop for the pointer while dragging [value]: before or after the
  /// built row nearest to the pointer, by which half of it the pointer is
  /// over, or null when the pointer is outside the list.
  _ListDrop? _dropAt(String value) {
    final viewport = reorderViewport;
    if (viewport == null || !viewport.hasSize) return null;
    final local = viewport.globalToLocal(_pointer);
    if (local.dx < 0 ||
        local.dy < 0 ||
        local.dx > viewport.size.width ||
        local.dy > viewport.size.height) {
      return null;
    }
    final y = _pointer.dy;
    _ListDrop? best;
    var distance = double.infinity;
    for (final MapEntry(key: row, value: context) in builtRows) {
      if (!context.mounted) continue;
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final index = reorderCollection.indexOf(row);
      if (index < 0) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      final double gap;
      final _ListDrop drop;
      if (y < (top + bottom) / 2) {
        gap = y < top ? top - y : 0;
        drop = (
          row: row,
          placement: DropPlacement.before,
          gap: index,
          noop: false,
        );
      } else {
        gap = y > bottom ? y - bottom : 0;
        drop = (
          row: row,
          placement: DropPlacement.after,
          gap: index + 1,
          noop: false,
        );
      }
      if (gap < distance) {
        distance = gap;
        best = drop;
      }
    }
    if (best == null) return null;
    final from = reorderCollection.indexOf(value);
    return (
      row: best.row,
      placement: best.placement,
      gap: best.gap,
      noop: best.gap == from || best.gap == from + 1,
    );
  }

  /// Adds the drop line to the [row] of [value] when the drop is on its
  /// edge, keeping the same structure while reordering is possible.
  Widget decorateReorderRow(String value, Widget row) {
    if (onReorder == null) return row;
    final drop = _drop;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        row,
        if (drop != null && !drop.noop && drop.row == value)
          DropLine(placement: drop.placement),
      ],
    );
  }

  /// Handles Escape during a drag, and Alt+Up and Alt+Down, which move the
  /// [active] row up or down by one; returns null for other keys.
  KeyEventResult? reorderKey(KeyEvent event, String? active) {
    if (_dragValue != null) {
      if (event.logicalKey == LogicalKeyboardKey.escape) stopRowDrag();
      return KeyEventResult.handled;
    }
    if (!HardwareKeyboard.instance.isAltPressed ||
        !canReorder ||
        active == null) {
      return null;
    }
    final delta = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => -1,
      LogicalKeyboardKey.arrowDown => 1,
      _ => 0,
    };
    if (delta == 0) return null;
    moveRowBy(active, delta);
    return KeyEventResult.handled;
  }

  /// Moves the item [value] [delta] places, -1 or 1, through [onReorder]
  /// and announces its new position; does nothing at either end or when
  /// the item is disabled.
  void moveRowBy(String value, int delta) {
    final reorder = onReorder;
    final item = reorderCollection.find(value);
    if (reorder == null || item == null || reorderCollection.isDisabled(item)) {
      return;
    }
    final from = reorderCollection.indexOf(value);
    final to = from + delta;
    if (to < 0 || to >= reorderCollection.length) return;
    reorder(from, to);
    announceTo(
      context,
      Oito2Localizations.of(context).movedToPosition(
        reorderCollection.labelOf(item),
        to + 1,
        reorderCollection.length,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) revealForReorder(value);
    });
  }

  /// The "Move up" and "Move down" accessibility actions of the row of
  /// [value], for the ways it can go, or null when it can't be reordered
  /// or is disabled.
  Map<CustomSemanticsAction, VoidCallback>? reorderActions(String value) {
    if (!canReorder) return null;
    final item = reorderCollection.find(value);
    if (item == null || reorderCollection.isDisabled(item)) return null;
    final index = reorderCollection.indexOf(value);
    if (index < 0) return null;
    final strings = Oito2Localizations.of(context);
    return {
      if (index > 0)
        CustomSemanticsAction(label: strings.moveUp): () =>
            moveRowBy(value, -1),
      if (index < reorderCollection.length - 1)
        CustomSemanticsAction(label: strings.moveDown): () =>
            moveRowBy(value, 1),
    };
  }

  /// Stops the drag and releases its resources.
  void disposeReorder() {
    _autoScroll.stop();
    _feedback.dispose();
  }
}
