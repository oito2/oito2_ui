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

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// A focusable divider line that resizes the panes beside it by dragging,
/// the arrow keys and assistive-technology adjustments.
///
/// It is [Oito2Spacing.sm] thick across [axis] and fills the other
/// direction. The line is highlighted while hovered or focused, and
/// thicker while focused. Movements come in screen coordinates: positive
/// toward the right for a horizontal [axis] and toward the bottom for a
/// vertical one, whatever the text direction.
class ResizeHandle extends StatefulWidget {
  /// Creates a resize handle.
  const ResizeHandle({
    super.key,
    required this.axis,
    required this.onMove,
    required this.keyboardStep,
    required this.semanticLabel,
    required this.value,
    required this.increasedValue,
    required this.decreasedValue,
    required this.onIncrease,
    required this.onDecrease,
    this.onToggle,
    this.onKey,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  /// The axis the divider moves along.
  final Axis axis;

  /// Called with each movement along [axis], in screen coordinates, from
  /// a drag or an arrow key.
  final ValueChanged<double> onMove;

  /// The movement of one arrow key press.
  final double keyboardStep;

  /// The accessibility label.
  final String semanticLabel;

  /// The accessibility value, such as the size of the pane it resizes.
  final String value;

  /// The accessibility value after [onIncrease].
  final String increasedValue;

  /// The accessibility value after [onDecrease].
  final String decreasedValue;

  /// Grows the pane, for assistive technologies.
  final VoidCallback onIncrease;

  /// Shrinks the pane, for assistive technologies.
  final VoidCallback onDecrease;

  /// Called on a double click, Enter or Space, such as to collapse a pane.
  final VoidCallback? onToggle;

  /// Handles other keys, such as Home and End, before the arrow keys.
  final KeyEventResult Function(KeyEvent event)? onKey;

  /// When a drag starts reporting movement.
  final DragStartBehavior dragStartBehavior;

  @override
  State<ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<ResizeHandle> {
  bool _hovered = false;
  bool _focused = false;

  bool get _horizontal => widget.axis == Axis.horizontal;

  /// Offers key presses to `onKey` first, then moves on the arrow keys of
  /// the axis and toggles on Enter or Space.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final extra = widget.onKey?.call(event) ?? KeyEventResult.ignored;
    if (extra != KeyEventResult.ignored) return extra;
    final key = event.logicalKey;
    final forward = _horizontal
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowDown;
    final backward = _horizontal
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowUp;
    final toggle = widget.onToggle;
    if (key == forward) {
      widget.onMove(widget.keyboardStep);
    } else if (key == backward) {
      widget.onMove(-widget.keyboardStep);
    } else if (toggle != null &&
        (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space)) {
      toggle();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = _hovered || _focused;
    final line = _focused ? 2.0 : 1.0;
    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: widget.value,
      increasedValue: widget.increasedValue,
      decreasedValue: widget.decreasedValue,
      onIncrease: widget.onIncrease,
      onDecrease: widget.onDecrease,
      child: Focus(
        onFocusChange: (focused) => setState(() => _focused = focused),
        onKeyEvent: _onKey,
        child: MouseRegion(
          cursor: _horizontal
              ? SystemMouseCursors.resizeLeftRight
              : SystemMouseCursors.resizeUpDown,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            dragStartBehavior: widget.dragStartBehavior,
            onDoubleTap: widget.onToggle,
            onHorizontalDragUpdate: _horizontal
                ? (d) => widget.onMove(d.delta.dx)
                : null,
            onVerticalDragUpdate: _horizontal
                ? null
                : (d) => widget.onMove(d.delta.dy),
            child: SizedBox(
              width: _horizontal ? Oito2Spacing.sm : double.infinity,
              height: _horizontal ? double.infinity : Oito2Spacing.sm,
              child: Center(
                child: Container(
                  width: _horizontal ? line : null,
                  height: _horizontal ? null : line,
                  color: highlighted
                      ? semanticColorsOf(context).primaryText
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
