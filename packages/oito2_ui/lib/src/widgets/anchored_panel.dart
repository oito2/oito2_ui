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

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// The side of its anchor where a popover opens.
///
/// [start] and [end] follow the text direction. The popover moves to the
/// opposite side when the preferred one has too little room.
enum Oito2PopoverPlacement {
  /// Above the anchor.
  top,

  /// Below the anchor.
  bottom,

  /// Before the anchor in the reading order.
  start,

  /// After the anchor in the reading order.
  end,
}

/// How a popover lines up with its anchor along the anchor's edge.
enum Oito2PopoverAlignment {
  /// With the anchor's start (top for side placements).
  start,

  /// Centered on the anchor.
  center,

  /// With the anchor's end (bottom for side placements).
  end,
}

enum _Side { top, bottom, left, right }

/// Lays out [child] next to [anchor], inside its own bounds less
/// [margin], and paints the panel behind it: a rounded rectangle in
/// [color] with a [borderColor] outline, a shadow and, when [arrowSize]
/// is set, an arrow pointing at the anchor.
///
/// It fills the space it is given, which is meant to be an overlay, and
/// lets pointer events outside the panel through.
class AnchoredPanel extends SingleChildRenderObjectWidget {
  /// Creates an anchored panel.
  const AnchoredPanel({
    super.key,
    required this.anchor,
    required this.placement,
    required this.alignment,
    required this.textDirection,
    required this.color,
    required this.borderColor,
    required this.shadowColor,
    this.gap = 4,
    this.margin = 8,
    this.arrowSize,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.matchAnchorWidth = false,
    this.elevation = 4,
    this.radius = 8,
    super.child,
  });

  /// The anchor rectangle in this widget's coordinates.
  final Rect anchor;

  /// The preferred side.
  final Oito2PopoverPlacement placement;

  /// The alignment along the anchor's edge.
  final Oito2PopoverAlignment alignment;

  /// Resolves [Oito2PopoverPlacement.start] and the alignments.
  final TextDirection textDirection;

  /// The panel fill.
  final Color color;

  /// The panel outline.
  final Color borderColor;

  /// The shadow color.
  final Color shadowColor;

  /// The space between the anchor and the panel or its arrow tip.
  final double gap;

  /// The space kept free at the edges of the available area.
  final double margin;

  /// The arrow base width and height, or null for no arrow.
  final Size? arrowSize;

  /// The largest panel width.
  final double maxWidth;

  /// The largest panel height.
  final double maxHeight;

  /// Whether a panel above or below takes the anchor's width.
  final bool matchAnchorWidth;

  /// The shadow elevation.
  final double elevation;

  /// The corner radius.
  final double radius;

  @override
  RenderAnchoredPanel createRenderObject(BuildContext context) =>
      RenderAnchoredPanel()..update(this);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAnchoredPanel renderObject,
  ) => renderObject.update(this);
}

/// The render object of [AnchoredPanel].
class RenderAnchoredPanel extends RenderShiftedBox {
  /// Creates the render object; [update] sets its configuration.
  RenderAnchoredPanel() : super(null);

  late AnchoredPanel _config;
  _Side _side = _Side.bottom;
  double _arrowCenter = 0;

  /// Applies the configuration of [widget].
  void update(AnchoredPanel widget) {
    _config = widget;
    markNeedsLayout();
  }

  _Side get _preferred {
    final ltr = _config.textDirection == TextDirection.ltr;
    return switch (_config.placement) {
      Oito2PopoverPlacement.top => _Side.top,
      Oito2PopoverPlacement.bottom => _Side.bottom,
      Oito2PopoverPlacement.start => ltr ? _Side.left : _Side.right,
      Oito2PopoverPlacement.end => ltr ? _Side.right : _Side.left,
    };
  }

  static _Side _opposite(_Side side) => switch (side) {
    _Side.top => _Side.bottom,
    _Side.bottom => _Side.top,
    _Side.left => _Side.right,
    _Side.right => _Side.left,
  };

  double _space(_Side side) {
    final c = _config;
    final reach = c.gap + (c.arrowSize?.height ?? 0) + c.margin;
    final a = c.anchor;
    return switch (side) {
      _Side.top => a.top - reach,
      _Side.bottom => size.height - a.bottom - reach,
      _Side.left => a.left - reach,
      _Side.right => size.width - a.right - reach,
    }.clamp(0.0, double.infinity);
  }

  BoxConstraints _childConstraints(_Side side, {double? mainLimit}) {
    final c = _config;
    final vertical = side == _Side.top || side == _Side.bottom;
    var maxW = (size.width - 2 * c.margin).clamp(0.0, c.maxWidth);
    var maxH = (size.height - 2 * c.margin).clamp(0.0, c.maxHeight);
    if (mainLimit != null) {
      if (vertical) {
        maxH = maxH.clamp(0.0, mainLimit);
      } else {
        maxW = maxW.clamp(0.0, mainLimit);
      }
    }
    if (vertical && c.matchAnchorWidth) {
      final width = c.anchor.width.clamp(0.0, maxW);
      return BoxConstraints(minWidth: width, maxWidth: width, maxHeight: maxH);
    }
    return BoxConstraints(maxWidth: maxW, maxHeight: maxH);
  }

  double _align(double start, double end, double extent, bool flip) {
    final alignment = switch (_config.alignment) {
      Oito2PopoverAlignment.start when flip => Oito2PopoverAlignment.end,
      Oito2PopoverAlignment.end when flip => Oito2PopoverAlignment.start,
      final other => other,
    };
    return switch (alignment) {
      Oito2PopoverAlignment.start => start,
      Oito2PopoverAlignment.center => (start + end - extent) / 2,
      Oito2PopoverAlignment.end => end - extent,
    };
  }

  static double _clampInto(double value, double min, double max) =>
      max < min ? min : value.clamp(min, max);

  @override
  void performLayout() {
    size = constraints.biggest;
    final child = this.child;
    if (child == null) return;
    final c = _config;

    var side = _preferred;
    child.layout(_childConstraints(side), parentUsesSize: true);
    double extentOf(_Side s) => s == _Side.top || s == _Side.bottom
        ? child.size.height
        : child.size.width;
    if (extentOf(side) > _space(side) &&
        _space(_opposite(side)) > _space(side)) {
      side = _opposite(side);
    }
    if (extentOf(side) > _space(side)) {
      child.layout(
        _childConstraints(side, mainLimit: _space(side)),
        parentUsesSize: true,
      );
    }
    _side = side;

    final a = c.anchor;
    final w = child.size.width;
    final h = child.size.height;
    final reach = c.gap + (c.arrowSize?.height ?? 0);
    final rtl = c.textDirection == TextDirection.rtl;
    final double x;
    final double y;
    switch (side) {
      case _Side.top || _Side.bottom:
        y = side == _Side.bottom ? a.bottom + reach : a.top - reach - h;
        x = _clampInto(
          _align(a.left, a.right, w, rtl),
          c.margin,
          size.width - c.margin - w,
        );
        _arrowCenter = a.center.dx - x;
        _arrowCenter = _clampInto(
          _arrowCenter,
          c.radius + (c.arrowSize?.width ?? 0) / 2,
          w - c.radius - (c.arrowSize?.width ?? 0) / 2,
        );
      case _Side.left || _Side.right:
        x = side == _Side.right ? a.right + reach : a.left - reach - w;
        y = _clampInto(
          _align(a.top, a.bottom, h, false),
          c.margin,
          size.height - c.margin - h,
        );
        _arrowCenter = _clampInto(
          a.center.dy - y,
          c.radius + (c.arrowSize?.width ?? 0) / 2,
          h - c.radius - (c.arrowSize?.width ?? 0) / 2,
        );
    }
    (child.parentData! as BoxParentData).offset = Offset(x, y);
  }

  Path _shape(Rect rect) {
    final c = _config;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(c.radius)));
    final arrow = c.arrowSize;
    if (arrow == null) return path;
    final half = arrow.width / 2;
    final triangle = Path();
    switch (_side) {
      case _Side.bottom:
        final cx = rect.left + _arrowCenter;
        triangle
          ..moveTo(cx - half, rect.top + 1)
          ..lineTo(cx, rect.top - arrow.height)
          ..lineTo(cx + half, rect.top + 1);
      case _Side.top:
        final cx = rect.left + _arrowCenter;
        triangle
          ..moveTo(cx - half, rect.bottom - 1)
          ..lineTo(cx, rect.bottom + arrow.height)
          ..lineTo(cx + half, rect.bottom - 1);
      case _Side.right:
        final cy = rect.top + _arrowCenter;
        triangle
          ..moveTo(rect.left + 1, cy - half)
          ..lineTo(rect.left - arrow.height, cy)
          ..lineTo(rect.left + 1, cy + half);
      case _Side.left:
        final cy = rect.top + _arrowCenter;
        triangle
          ..moveTo(rect.right - 1, cy - half)
          ..lineTo(rect.right + arrow.height, cy)
          ..lineTo(rect.right - 1, cy + half);
    }
    return Path.combine(PathOperation.union, path, triangle..close());
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    final c = _config;
    final childOffset = (child.parentData! as BoxParentData).offset;
    final shape = _shape(offset + childOffset & child.size);
    final canvas = context.canvas;
    if (c.elevation > 0) {
      canvas.drawShadow(shape, c.shadowColor, c.elevation, false);
    }
    canvas
      ..drawPath(shape, Paint()..color = c.color)
      ..drawPath(
        shape,
        Paint()
          ..color = c.borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    super.paint(context, offset);
  }
}
