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

import '../theme/extensions/progress_theme.dart';
import 'widget_helpers.dart';

/// The resolved colors and sizes of a progress indicator: the widget's
/// own values, then the [Oito2ProgressIndicatorThemeData] of the theme,
/// then the selected fill color over the highest surface container track,
/// a 4-pixel stroke and a 6-pixel height.
({Color color, Color track, double stroke, double height}) _resolve(
  BuildContext context, {
  Color? color,
  Color? trackColor,
  double? strokeWidth,
  double? height,
}) {
  final theme = Oito2ProgressIndicatorThemeData.maybeOf(context);
  return (
    color: color ?? theme?.color ?? selectedFillOf(context).fill,
    track:
        trackColor ??
        theme?.trackColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest,
    stroke: strokeWidth ?? theme?.strokeWidth ?? 4,
    height: height ?? theme?.linearHeight ?? 6,
  );
}

/// The accessibility value of determinate progress, as a percentage.
String? _percent(double? value) =>
    value == null ? null : '${(value.clamp(0, 1) * 100).round()}%';

/// Runs the indeterminate animation of a progress indicator while it has
/// no value and animations are enabled.
mixin _IndeterminateAnimation<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  /// The controller that drives the indeterminate animation.
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: period,
  );

  /// The duration of one animation cycle.
  Duration get period;

  /// Whether the animation runs back and forth instead of in loops.
  bool get reverses => false;

  /// The current value, or null for indeterminate progress.
  double? get value;

  /// Starts the animation while the progress is indeterminate and
  /// animations are enabled, and stops it otherwise.
  void _sync() {
    final animate =
        value == null &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    if (animate && !animation.isAnimating) {
      animation.repeat(reverse: reverses);
    } else if (!animate && animation.isAnimating) {
      animation.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }
}

/// Paints the arc from [start] spanning [sweep] radians of a ring of
/// [radius] and [stroke] width as one filled shape with round ends.
void _paintArc(
  Canvas canvas,
  Offset center,
  double radius,
  double stroke,
  double start,
  double sweep,
  Paint paint,
) {
  if (sweep <= 0) return;
  if (sweep >= 2 * math.pi) {
    final outer = RRect.fromRectAndRadius(
      Rect.fromCircle(center: center, radius: radius + stroke / 2),
      Radius.circular(radius + stroke / 2),
    );
    canvas.drawDRRect(outer, outer.deflate(stroke), paint);
    return;
  }
  final path = Path()
    ..arcTo(
      Rect.fromCircle(center: center, radius: radius + stroke / 2),
      start,
      sweep,
      true,
    )
    ..arcTo(
      Rect.fromCircle(center: center, radius: radius - stroke / 2),
      start + sweep,
      -sweep,
      false,
    )
    ..close();
  canvas.drawPath(path, paint);
  for (final angle in [start, start + sweep]) {
    canvas.drawCircle(
      center + Offset(math.cos(angle), math.sin(angle)) * radius,
      stroke / 2,
      paint,
    );
  }
}

/// A circular progress indicator painted in the oito2 style.
///
/// With a [value] from 0 to 1, a ring fills clockwise from the top over
/// the track. Without one, an arc of changing length spins without a
/// track; when animations are disabled it stays still. The ring and its
/// round ends are filled shapes, so they render smoothly with every
/// Flutter renderer.
///
/// Colors and thickness default to the theme's
/// [Oito2ProgressIndicatorThemeData].
class Oito2CircularProgressIndicator extends StatefulWidget {
  /// Creates a circular progress indicator.
  const Oito2CircularProgressIndicator({
    super.key,
    this.value,
    this.size = 32,
    this.strokeWidth,
    this.color,
    this.trackColor,
    this.semanticsLabel,
    this.semanticsValue,
  });

  /// The progress from 0 to 1, or null for indeterminate progress.
  final double? value;

  /// The diameter.
  final double size;

  /// The ring thickness.
  final double? strokeWidth;

  /// The progress color.
  final Color? color;

  /// The track color of determinate progress.
  final Color? trackColor;

  /// The accessibility label, such as what is loading.
  final String? semanticsLabel;

  /// The accessibility value; defaults to the percentage of [value].
  final String? semanticsValue;

  @override
  State<Oito2CircularProgressIndicator> createState() =>
      _Oito2CircularProgressIndicatorState();
}

class _Oito2CircularProgressIndicatorState
    extends State<Oito2CircularProgressIndicator>
    with
        SingleTickerProviderStateMixin,
        _IndeterminateAnimation<Oito2CircularProgressIndicator> {
  @override
  Duration get period => const Duration(milliseconds: 1500);

  @override
  double? get value => widget.value;

  @override
  Widget build(BuildContext context) {
    final style = _resolve(
      context,
      color: widget.color,
      trackColor: widget.trackColor,
      strokeWidth: widget.strokeWidth,
    );
    return Semantics(
      label: widget.semanticsLabel,
      value: widget.semanticsValue ?? _percent(widget.value),
      // The painter repaints with the animation, without rebuilding.
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _CircularPainter(
          value: widget.value,
          animation: animation,
          color: style.color,
          track: style.track,
          stroke: style.stroke,
        ),
      ),
    );
  }
}

/// Paints the track and progress ring, or the spinning arc of
/// indeterminate progress.
class _CircularPainter extends CustomPainter {
  _CircularPainter({
    required this.value,
    required this.animation,
    required this.color,
    required this.track,
    required this.stroke,
  }) : super(repaint: animation);

  final double? value;
  final Animation<double> animation;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    const top = -math.pi / 2;
    final value = this.value;
    if (value != null) {
      _paintArc(
        canvas,
        center,
        radius,
        stroke,
        0,
        2 * math.pi,
        Paint()..color = track,
      );
      _paintArc(
        canvas,
        center,
        radius,
        stroke,
        top,
        2 * math.pi * value.clamp(0, 1),
        Paint()..color = color,
      );
      return;
    }
    // The arc turns once per cycle while its length grows and shrinks
    // between a quarter and three quarters of a turn.
    final phase = animation.value;
    final sweep =
        math.pi * (0.5 + 1.0 * (0.5 - 0.5 * math.cos(2 * math.pi * phase)));
    final start = top + 2 * math.pi * phase;
    _paintArc(
      canvas,
      center,
      radius,
      stroke,
      start,
      sweep,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CircularPainter old) =>
      old.value != value ||
      old.animation != animation ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}

/// A linear progress indicator painted in the oito2 style.
///
/// With a [value] from 0 to 1, a bar fills the track from the start side.
/// Without one, a short segment glides back and forth along the track, as
/// GNOME's pulse; when animations are disabled it stays still. The bar
/// and the track have round ends and fill the available width, or 160
/// pixels when the width is unbounded.
///
/// Colors and height default to the theme's
/// [Oito2ProgressIndicatorThemeData].
class Oito2LinearProgressIndicator extends StatefulWidget {
  /// Creates a linear progress indicator.
  const Oito2LinearProgressIndicator({
    super.key,
    this.value,
    this.height,
    this.color,
    this.trackColor,
    this.semanticsLabel,
    this.semanticsValue,
  });

  /// The progress from 0 to 1, or null for indeterminate progress.
  final double? value;

  /// The bar height.
  final double? height;

  /// The progress color.
  final Color? color;

  /// The track color.
  final Color? trackColor;

  /// The accessibility label, such as what is loading.
  final String? semanticsLabel;

  /// The accessibility value; defaults to the percentage of [value].
  final String? semanticsValue;

  @override
  State<Oito2LinearProgressIndicator> createState() =>
      _Oito2LinearProgressIndicatorState();
}

class _Oito2LinearProgressIndicatorState
    extends State<Oito2LinearProgressIndicator>
    with
        SingleTickerProviderStateMixin,
        _IndeterminateAnimation<Oito2LinearProgressIndicator> {
  @override
  Duration get period => const Duration(milliseconds: 1100);

  @override
  bool get reverses => true;

  @override
  double? get value => widget.value;

  @override
  Widget build(BuildContext context) {
    final style = _resolve(
      context,
      color: widget.color,
      trackColor: widget.trackColor,
      height: widget.height,
    );
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      label: widget.semanticsLabel,
      value: widget.semanticsValue ?? _percent(widget.value),
      child: LayoutBuilder(
        // The painter repaints with the animation, without rebuilding.
        builder: (context, constraints) => CustomPaint(
          size: Size(
            constraints.hasBoundedWidth ? constraints.maxWidth : 160,
            style.height,
          ),
          painter: _LinearPainter(
            value: widget.value,
            animation: animation,
            color: style.color,
            track: style.track,
            rtl: rtl,
          ),
        ),
      ),
    );
  }
}

/// Paints the track and the progress bar, or the gliding segment of
/// indeterminate progress, mirrored in right-to-left text.
class _LinearPainter extends CustomPainter {
  _LinearPainter({
    required this.value,
    required this.animation,
    required this.color,
    required this.track,
    required this.rtl,
  }) : super(repaint: animation);

  final double? value;
  final Animation<double> animation;
  final Color color;
  final Color track;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = track,
    );
    final value = this.value;
    final double start;
    final double width;
    if (value != null) {
      if (value <= 0) return;
      width = math.max(size.height, size.width * value.clamp(0, 1));
      start = 0;
    } else {
      width = size.width * 0.25;
      start =
          (size.width - width) * Curves.easeInOut.transform(animation.value);
    }
    final left = rtl ? size.width - start - width : start;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 0, width, size.height),
        radius,
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_LinearPainter old) =>
      old.value != value ||
      old.animation != animation ||
      old.color != color ||
      old.track != track ||
      old.rtl != rtl;
}
