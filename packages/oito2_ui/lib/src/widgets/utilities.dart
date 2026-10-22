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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// Draws a 2-pixel ring in the text-safe primary tone around [child]
/// while a widget inside it has keyboard focus.
///
/// The ring shows only in keyboard navigation mode, not after pointer
/// clicks, and doesn't affect layout.
class Oito2FocusBorder extends StatefulWidget {
  /// Creates a focus border.
  const Oito2FocusBorder({
    super.key,
    required this.child,
    this.borderRadius = Oito2Radius.mediumAll,
    this.focused,
  });

  /// The content.
  final Widget child;

  /// The ring corner radius.
  final BorderRadius borderRadius;

  /// Forces the ring on or off; null follows keyboard focus.
  final bool? focused;

  @override
  State<Oito2FocusBorder> createState() => _Oito2FocusBorderState();
}

class _Oito2FocusBorderState extends State<Oito2FocusBorder> {
  bool _hasFocus = false;
  late FocusHighlightMode _mode = FocusManager.instance.highlightMode;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onMode);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onMode);
    super.dispose();
  }

  /// Tracks the highlight mode; only a border that could show, with the
  /// focus inside, rebuilds when it changes.
  void _onMode(FocusHighlightMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    if (_hasFocus && widget.focused == null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final show =
        widget.focused ??
        (_hasFocus && _mode == FocusHighlightMode.traditional);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (value) => setState(() => _hasFocus = value),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          border: show
              ? Border.all(
                  color: semanticColorsOf(context).primaryText,
                  width: Oito2Sizes.focusBorderWidth,
                  strokeAlign: BorderSide.strokeAlignOutside,
                )
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Keeps arrow-key focus navigation inside [child]: at the edges of the
/// group the arrow keys stop instead of moving focus out of it.
///
/// Useful for grids and toolbars navigated with the arrow keys, so the
/// keyboard user doesn't fall out of the group by accident. Tab and
/// Shift+Tab still move to the widgets around the group.
class Oito2EdgeFocusInterceptor extends StatefulWidget {
  /// Creates an edge focus interceptor.
  const Oito2EdgeFocusInterceptor({super.key, required this.child});

  /// The group of focusable widgets.
  final Widget child;

  @override
  State<Oito2EdgeFocusInterceptor> createState() =>
      _Oito2EdgeFocusInterceptorState();
}

class _Oito2EdgeFocusInterceptorState extends State<Oito2EdgeFocusInterceptor> {
  final _scope = FocusScopeNode(
    debugLabel: 'Oito2EdgeFocusInterceptor',
    traversalEdgeBehavior: TraversalEdgeBehavior.parentScope,
    directionalTraversalEdgeBehavior: TraversalEdgeBehavior.stop,
  );

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(node: _scope, child: widget.child);
  }
}

/// Fades a soft shadow in at the start and end edges of a scrollable
/// [child] while there is more content beyond them.
///
/// Works with any scroll view below it; no controller is needed.
class Oito2ScrollViewUndershoot extends StatefulWidget {
  /// Creates a scroll undershoot.
  const Oito2ScrollViewUndershoot({
    super.key,
    required this.child,
    this.start = true,
    this.end = true,
    this.extent = Oito2Spacing.md,
  });

  /// The scroll view.
  final Widget child;

  /// Whether the shadow at the start edge is shown.
  final bool start;

  /// Whether the shadow at the end edge is shown.
  final bool end;

  /// The depth of the shadows.
  final double extent;

  @override
  State<Oito2ScrollViewUndershoot> createState() =>
      _Oito2ScrollViewUndershootState();
}

class _Oito2ScrollViewUndershootState extends State<Oito2ScrollViewUndershoot> {
  bool _before = false;
  bool _after = false;
  Axis _axis = Axis.vertical;

  bool _onMetrics(ScrollMetrics metrics) {
    final before = metrics.extentBefore > 0;
    final after = metrics.extentAfter > 0;
    if (before != _before || after != _after || metrics.axis != _axis) {
      setState(() {
        _before = before;
        _after = after;
        _axis = metrics.axis;
      });
    }
    return false;
  }

  Widget _shadow(bool atStart) {
    final color = Theme.of(context).colorScheme.shadow;
    final vertical = _axis == Axis.vertical;
    final visible = atStart ? _before : _after;
    final begin = vertical
        ? (atStart ? Alignment.topCenter : Alignment.bottomCenter)
        : (atStart
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd)
              .resolve(Directionality.of(context));
    final shadow = IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: motionDuration(context, const Duration(milliseconds: 150)),
        child: Container(
          width: vertical ? null : widget.extent,
          height: vertical ? widget.extent : null,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: Alignment(-begin.x, -begin.y),
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
    if (vertical) {
      return Positioned(
        left: 0,
        right: 0,
        top: atStart ? 0 : null,
        bottom: atStart ? null : 0,
        child: shadow,
      );
    }
    return PositionedDirectional(
      top: 0,
      bottom: 0,
      start: atStart ? 0 : null,
      end: atStart ? null : 0,
      child: shadow,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only the direct scroll view counts, not scroll views nested in it.
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) =>
          notification.depth == 0 && _onMetrics(notification.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) =>
            notification.depth == 0 && _onMetrics(notification.metrics),
        child: Stack(
          children: [
            widget.child,
            if (widget.start) _shadow(true),
            if (widget.end) _shadow(false),
          ],
        ),
      ),
    );
  }
}

/// The corner cut off by [Oito2DiagonalClip].
enum Oito2DiagonalCorner {
  /// The top-left corner.
  topLeft,

  /// The top-right corner.
  topRight,

  /// The bottom-left corner.
  bottomLeft,

  /// The bottom-right corner.
  bottomRight,
}

/// Clips [child] along a diagonal, keeping the triangle on the side of
/// [corner]. Combine two of them to split an area diagonally, for example
/// to preview light and dark themes in one swatch.
class Oito2DiagonalClip extends StatelessWidget {
  /// Creates a diagonal clip.
  const Oito2DiagonalClip({
    super.key,
    required this.corner,
    required this.child,
  });

  /// The corner whose triangle is kept.
  final Oito2DiagonalCorner corner;

  /// The clipped content.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ClipPath(clipper: _DiagonalClipper(corner), child: child);
}

class _DiagonalClipper extends CustomClipper<Path> {
  const _DiagonalClipper(this.corner);

  final Oito2DiagonalCorner corner;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final points = switch (corner) {
      Oito2DiagonalCorner.topLeft => [Offset.zero, Offset(w, 0), Offset(0, h)],
      Oito2DiagonalCorner.topRight => [Offset.zero, Offset(w, 0), Offset(w, h)],
      Oito2DiagonalCorner.bottomLeft => [
        Offset.zero,
        Offset(w, h),
        Offset(0, h),
      ],
      Oito2DiagonalCorner.bottomRight => [
        Offset(w, 0),
        Offset(w, h),
        Offset(0, h),
      ],
    };
    return Path()..addPolygon(points, true);
  }

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => oldClipper.corner != corner;
}

/// A widget the user can move inside a [Stack], with the pointer or, once
/// focused, with the arrow keys.
///
/// It must be a direct child of a [Stack]. The position is relative to
/// the stack's top-left corner.
class Oito2Draggable extends StatefulWidget {
  /// Creates a draggable widget.
  const Oito2Draggable({
    super.key,
    required this.child,
    this.initialPosition = Offset.zero,
    this.onDragStart,
    this.onDragEnd,
    this.onMoved,
    this.keyboardStep = 8,
  });

  /// The content.
  final Widget child;

  /// The position at start.
  final Offset initialPosition;

  /// Called when a pointer drag starts.
  final VoidCallback? onDragStart;

  /// Called when a pointer drag ends.
  final VoidCallback? onDragEnd;

  /// Called with each new position.
  final ValueChanged<Offset>? onMoved;

  /// How far one arrow key press moves the widget.
  final double keyboardStep;

  @override
  State<Oito2Draggable> createState() => _Oito2DraggableState();
}

class _Oito2DraggableState extends State<Oito2Draggable> {
  late Offset _position = widget.initialPosition;
  bool _dragging = false;

  void _move(Offset delta) {
    setState(() => _position += delta);
    widget.onMoved?.call(_position);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final step = widget.keyboardStep;
    final delta = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => Offset(0, -step),
      LogicalKeyboardKey.arrowDown => Offset(0, step),
      LogicalKeyboardKey.arrowLeft => Offset(-step, 0),
      LogicalKeyboardKey.arrowRight => Offset(step, 0),
      _ => null,
    };
    if (delta == null) return KeyEventResult.ignored;
    _move(delta);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Oito2FocusBorder(
        child: Focus(
          onKeyEvent: _onKey,
          child: MouseRegion(
            cursor: _dragging
                ? SystemMouseCursors.grabbing
                : SystemMouseCursors.grab,
            child: GestureDetector(
              onPanStart: (_) {
                setState(() => _dragging = true);
                widget.onDragStart?.call();
              },
              onPanUpdate: (details) => _move(details.delta),
              onPanEnd: (_) {
                setState(() => _dragging = false);
                widget.onDragEnd?.call();
              },
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
