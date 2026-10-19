// Copyright (C) 2026  oito2
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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// The side of an [Oito2PanedView] its pane is placed on.
enum Oito2PaneSide {
  /// The start side: left in left-to-right text, right otherwise.
  start,

  /// The end side: right in left-to-right text, left otherwise.
  end,

  /// The top.
  top,

  /// The bottom.
  bottom;

  /// Whether the pane and the page are stacked vertically.
  bool get isVertical => this == top || this == bottom;
}

/// Splits its area between a [pane] and a [page], separated by a divider.
///
/// When [resizable], the divider can be dragged with the pointer or moved
/// with the arrow keys once focused, and it is exposed to assistive
/// technologies as an adjustable control. The pane never shrinks below
/// [minPaneSize] and never leaves less than [minPageSize] for the page.
class Oito2PanedView extends StatefulWidget {
  /// Creates a paned view.
  const Oito2PanedView({
    super.key,
    required this.pane,
    required this.page,
    this.paneSide = Oito2PaneSide.start,
    this.initialPaneSize = 280,
    this.minPaneSize = 180,
    this.minPageSize = 320,
    this.resizable = true,
    this.onPaneSizeChanged,
    this.keyboardStep = 16,
    this.resizeLabel = 'Resize pane',
  });

  /// The side widget, such as a list.
  final Widget pane;

  /// The main widget.
  final Widget page;

  /// Which side the pane is on.
  final Oito2PaneSide paneSide;

  /// The initial pane width (or height, when stacked vertically).
  final double initialPaneSize;

  /// The smallest pane size.
  final double minPaneSize;

  /// The smallest size left for the page.
  final double minPageSize;

  /// Whether the divider can be moved.
  final bool resizable;

  /// Called with the new pane size while it is resized.
  final ValueChanged<double>? onPaneSizeChanged;

  /// How far one arrow key press moves the divider.
  final double keyboardStep;

  /// The accessibility label of the divider.
  final String resizeLabel;

  @override
  State<Oito2PanedView> createState() => _Oito2PanedViewState();
}

class _Oito2PanedViewState extends State<Oito2PanedView> {
  late double _size = widget.initialPaneSize;
  double _available = 0;
  bool _focused = false;
  bool _hovered = false;

  double _clamp(double value) {
    final max = math.max(widget.minPaneSize, _available - widget.minPageSize);
    return value.clamp(widget.minPaneSize, max).toDouble();
  }

  void _resize(double value) {
    final next = _clamp(value);
    if (next == _size) return;
    setState(() => _size = next);
    widget.onPaneSizeChanged?.call(next);
  }

  /// Whether growing the pane means moving the divider toward the
  /// positive axis direction (right or down).
  bool _growsForward(TextDirection direction) => switch (widget.paneSide) {
    Oito2PaneSide.top => true,
    Oito2PaneSide.bottom => false,
    Oito2PaneSide.start => direction == TextDirection.ltr,
    Oito2PaneSide.end => direction == TextDirection.rtl,
  };

  KeyEventResult _onKey(FocusNode node, KeyEvent event, bool forward) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final vertical = widget.paneSide.isVertical;
    final decrease = vertical
        ? LogicalKeyboardKey.arrowUp
        : LogicalKeyboardKey.arrowLeft;
    final increase = vertical
        ? LogicalKeyboardKey.arrowDown
        : LogicalKeyboardKey.arrowRight;
    final step = widget.keyboardStep;
    if (event.logicalKey == increase) {
      _resize(_size + (forward ? step : -step));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == decrease) {
      _resize(_size + (forward ? -step : step));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final indicator = semanticColorsOf(context).primaryText;
    final vertical = widget.paneSide.isVertical;
    final direction = Directionality.of(context);
    final forward = _growsForward(direction);

    return LayoutBuilder(
      builder: (context, constraints) {
        _available = vertical ? constraints.maxHeight : constraints.maxWidth;
        final size = _clamp(_size);

        final divider = Container(
          width: vertical ? null : 1,
          height: vertical ? 1 : null,
          color: _focused || _hovered ? indicator : scheme.outlineVariant,
        );

        Widget handle = divider;
        if (widget.resizable) {
          handle = Semantics(
            label: widget.resizeLabel,
            value: '${size.round()}',
            increasedValue: '${_clamp(size + widget.keyboardStep).round()}',
            decreasedValue: '${_clamp(size - widget.keyboardStep).round()}',
            onIncrease: () => _resize(size + widget.keyboardStep),
            onDecrease: () => _resize(size - widget.keyboardStep),
            child: Focus(
              onFocusChange: (value) => setState(() => _focused = value),
              onKeyEvent: (node, event) => _onKey(node, event, forward),
              child: MouseRegion(
                cursor: vertical
                    ? SystemMouseCursors.resizeUpDown
                    : SystemMouseCursors.resizeLeftRight,
                onEnter: (_) => setState(() => _hovered = true),
                onExit: (_) => setState(() => _hovered = false),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: vertical
                      ? null
                      : (d) => _resize(
                          _size + (forward ? d.delta.dx : -d.delta.dx),
                        ),
                  onVerticalDragUpdate: vertical
                      ? (d) => _resize(
                          _size + (forward ? d.delta.dy : -d.delta.dy),
                        )
                      : null,
                  child: SizedBox(
                    width: vertical ? double.infinity : Oito2Spacing.sm,
                    height: vertical ? Oito2Spacing.sm : double.infinity,
                    child: Center(
                      child: SizedBox(
                        width: vertical ? double.infinity : (_focused ? 2 : 1),
                        height: vertical ? (_focused ? 2 : 1) : double.infinity,
                        child: divider,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final pane = SizedBox(
          width: vertical ? null : size,
          height: vertical ? size : null,
          child: widget.pane,
        );
        final page = Expanded(child: widget.page);
        final paneFirst =
            widget.paneSide == Oito2PaneSide.start ||
            widget.paneSide == Oito2PaneSide.top;
        final children = paneFirst ? [pane, page] : [page, pane];
        // The handle is centered on the 1-pixel divider and overlaps half of
        // each neighbour, so the drag area is wider than the line without
        // shifting the layout. The divider sits after the pane when the
        // pane is on the left or top, and before it otherwise.
        final dividerStart = forward ? size : _available - size - 1;
        final handleStart = dividerStart + 0.5 - Oito2Spacing.sm / 2;
        return Stack(
          children: [
            Flex(
              direction: vertical ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [children[0], divider, children[1]],
            ),
            if (widget.resizable)
              Positioned(
                left: vertical ? 0 : handleStart,
                top: vertical ? handleStart : 0,
                right: vertical ? 0 : null,
                bottom: vertical ? null : 0,
                child: handle,
              ),
          ],
        );
      },
    );
  }
}
