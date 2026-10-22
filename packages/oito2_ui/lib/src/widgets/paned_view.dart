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

import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'resize_handle.dart';

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
    this.resizeLabel,
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

  /// The accessibility label of the divider; defaults to
  /// [Oito2Localizations.resizePane].
  final String? resizeLabel;

  @override
  State<Oito2PanedView> createState() => _Oito2PanedViewState();
}

class _Oito2PanedViewState extends State<Oito2PanedView> {
  late double _size = widget.initialPaneSize;
  double _available = 0;

  double _clamp(double value) {
    final max = math.max(widget.minPaneSize, _available - widget.minPageSize);
    return value.clamp(widget.minPaneSize, max).toDouble();
  }

  /// Sets the pane size to [value] within the limits; callers start from
  /// the clamped size, so a pane wider than the window allows moves on
  /// the first step.
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
          color: scheme.outlineVariant,
        );

        final step = widget.keyboardStep;
        final handle = ResizeHandle(
          axis: vertical ? Axis.vertical : Axis.horizontal,
          keyboardStep: step,
          onMove: (delta) =>
              _resize(_clamp(_size) + (forward ? delta : -delta)),
          semanticLabel:
              widget.resizeLabel ?? Oito2Localizations.of(context).resizePane,
          value: '${size.round()}',
          increasedValue: '${_clamp(size + step).round()}',
          decreasedValue: '${_clamp(size - step).round()}',
          onIncrease: () => _resize(size + step),
          onDecrease: () => _resize(size - step),
        );

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
        final content = Stack(
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
        // A pane wider than the space keeps its minimum size and the end is
        // clipped, instead of overflowing.
        final needed = size + 1;
        if (needed <= _available) return content;
        return ClipRect(
          child: OverflowBox(
            alignment: AlignmentDirectional.topStart,
            minWidth: vertical ? null : needed,
            maxWidth: vertical ? null : needed,
            minHeight: vertical ? needed : null,
            maxHeight: vertical ? needed : null,
            child: content,
          ),
        );
      },
    );
  }
}
