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

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// Pads the touch target of a control to [Oito2Sizes.minTouchTarget] on
/// each axis when the closest theme pads tap targets, as `Oito2Theme` does
/// on touch platforms, the way Material buttons do with
/// [MaterialTapTargetSize.padded].
///
/// While padding, the box is at least 48 pixels wide and tall, with
/// [child] centered and drawn at its own size; a touch in the transparent
/// margin around [child] goes to the nearest point of [child], and the box
/// forms the semantics node of the control, so assistive technologies
/// report the padded size. With [mergeSemantics], the semantics of all
/// descendants, such as a button that forms its own node, merge into that
/// node; otherwise only the descendants that form no node of their own,
/// such as a text field, join it, and a button inside the field keeps its
/// own node.
///
/// When the theme doesn't pad tap targets, as on pointer platforms, the
/// box takes the size of [child] and adds nothing to its layout, hit
/// testing or semantics.
///
/// The widgets of this library already pad their touch targets; wrap
/// other controls with it, such as a plain [TextField], which the theme
/// keeps 40 pixels tall on touch platforms.
class Oito2TouchTarget extends StatelessWidget {
  /// Creates a touch target around [child].
  const Oito2TouchTarget({
    super.key,
    this.mergeSemantics = false,
    required this.child,
  });

  /// Whether the semantics of all descendants merge into the node of the
  /// padded box.
  final bool mergeSemantics;

  /// The control.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _TouchTargetBox(
      minSize: padsTapTargets(context)
          ? const Size.square(Oito2Sizes.minTouchTarget)
          : null,
      mergeSemantics: mergeSemantics,
      child: child,
    );
  }
}

class _TouchTargetBox extends SingleChildRenderObjectWidget {
  const _TouchTargetBox({
    required this.minSize,
    required this.mergeSemantics,
    super.child,
  });

  final Size? minSize;
  final bool mergeSemantics;

  @override
  _RenderTouchTargetBox createRenderObject(BuildContext context) =>
      _RenderTouchTargetBox(minSize: minSize, mergeSemantics: mergeSemantics);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTouchTargetBox renderObject,
  ) {
    renderObject
      ..minSize = minSize
      ..mergeSemantics = mergeSemantics;
  }
}

/// The render object of [Oito2TouchTarget].
///
/// With a [minSize], it is at least that size, centers its child, sends
/// touches in its margin to the nearest point of the child and forms a
/// semantics node; with none, it is the size of its child and adds
/// nothing.
class _RenderTouchTargetBox extends RenderShiftedBox {
  /// Creates the render object.
  _RenderTouchTargetBox({
    Size? minSize,
    bool mergeSemantics = false,
    RenderBox? child,
  }) : _min = minSize,
       _merge = mergeSemantics,
       super(child);

  /// The minimum size while padding, or null when not padding.
  Size? get minSize => _min;
  Size? _min;
  set minSize(Size? value) {
    if (value == _min) return;
    final semanticsChanged = (value == null) != (_min == null);
    _min = value;
    markNeedsLayout();
    if (semanticsChanged) markNeedsSemanticsUpdate();
  }

  /// Whether the semantics of all descendants merge into this node.
  bool get mergeSemantics => _merge;
  bool _merge;
  set mergeSemantics(bool value) {
    if (value == _merge) return;
    _merge = value;
    markNeedsSemanticsUpdate();
  }

  Size _padded(Size childSize) {
    final min = _min;
    if (min == null) return childSize;
    return Size(
      math.max(childSize.width, min.width),
      math.max(childSize.height, min.height),
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(super.computeMinIntrinsicWidth(height), _min?.width ?? 0);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(super.computeMaxIntrinsicWidth(height), _min?.width ?? 0);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(super.computeMinIntrinsicHeight(width), _min?.height ?? 0);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(super.computeMaxIntrinsicHeight(width), _min?.height ?? 0);

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.constrain(_min ?? Size.zero);
    return constraints.constrain(_padded(child.getDryLayout(constraints)));
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final child = this.child;
    if (child == null) return null;
    final result = child.getDryBaseline(constraints, baseline);
    if (result == null) return null;
    final childSize = child.getDryLayout(constraints);
    final size = constraints.constrain(_padded(childSize));
    return result + (size.height - childSize.height) / 2;
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.constrain(_min ?? Size.zero);
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(_padded(child.size));
    final parentData = child.parentData! as BoxParentData;
    parentData.offset = Alignment.center.alongOffset(
      size - child.size as Offset,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) return true;
    final child = this.child;
    if (_min == null || child == null || !size.contains(position)) {
      return false;
    }
    final offset = (child.parentData! as BoxParentData).offset;
    final local = position - offset;
    // The nearest point inside the child, half a pixel in from its edge.
    final target = Offset(
      _clampInside(local.dx, child.size.width),
      _clampInside(local.dy, child.size.height),
    );
    if (target == local) return false;
    return result.addWithRawTransform(
      transform: Matrix4.translationValues(
        target.dx - position.dx,
        target.dy - position.dy,
        0,
      ),
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
  }

  static double _clampInside(double value, double extent) {
    final inset = math.min(0.5, extent / 2);
    return value.clamp(inset, extent - inset);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    if (_min == null) return;
    config
      ..isSemanticBoundary = true
      ..isMergingSemanticsOfDescendants = _merge;
  }
}
