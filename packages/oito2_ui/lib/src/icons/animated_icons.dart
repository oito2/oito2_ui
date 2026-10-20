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
import 'dart:ui' show PathMetric;

import 'package:material_ui/material_ui.dart';

import '../tokens/colors.dart';

/// How an [Oito2AnimatedIcon] plays its animation.
enum Oito2AnimationMode {
  /// Once, when the icon first shows and whenever its data changes.
  once,

  /// Over and over.
  repeat,

  /// Not at all: the icon shows its final frame.
  still,
}

/// Paints one frame of an animated icon in a 24 × 24 box: [progress] runs
/// from 0 to 1, and [paint] carries the icon color.
typedef Oito2AnimatedIconPainter = void Function(
  Canvas canvas,
  double progress,
  Paint paint,
);

/// The drawing and timing of an animated icon, such as
/// [Oito2AnimatedIcons.ok].
@immutable
class Oito2AnimatedIconData {
  /// Creates animated icon data.
  const Oito2AnimatedIconData(
    this.painter, {
    this.duration = const Duration(milliseconds: 700),
  });

  /// Paints a frame.
  final Oito2AnimatedIconPainter painter;

  /// The length of one play.
  final Duration duration;
}

/// The animated icons of oito2_ui, drawn on a 24-pixel grid in the stroke
/// style of the Lucide icons. The `filled` variants cut their inner mark
/// out of the fill, so the background shows through it.
abstract final class Oito2AnimatedIcons {
  /// A circle that draws itself, then a check mark.
  static const ok = Oito2AnimatedIconData(_ok);

  /// A filled circle that pops in, then a check mark cut out of it.
  static const okFilled = Oito2AnimatedIconData(_okFilled);

  /// A heart outline that draws itself, then beats.
  static const heart = Oito2AnimatedIconData(_heart);

  /// A filled heart that pops in.
  static const heartFilled = Oito2AnimatedIconData(_heartFilled);

  /// A star outline that draws itself.
  static const star = Oito2AnimatedIconData(_star);

  /// A filled star that spins and pops in.
  static const starFilled = Oito2AnimatedIconData(_starFilled);

  /// A star outline whose left half fills.
  static const starHalfFilled = Oito2AnimatedIconData(_starHalfFilled);

  /// A compass whose needle, with a filled north half, swings and settles
  /// north.
  static const compass = Oito2AnimatedIconData(
    _compass,
    duration: Duration(milliseconds: 1200),
  );

  /// A filled compass whose cut-out needle swings and settles north.
  static const compassFilled = Oito2AnimatedIconData(
    _compassFilled,
    duration: Duration(milliseconds: 1200),
  );

  /// Wi-Fi waves that appear one by one, then a slash across them.
  static const noNetwork = Oito2AnimatedIconData(
    _noNetwork,
    duration: Duration(milliseconds: 900),
  );
}

// Shared geometry, on the 24 × 24 grid.

const _center = Offset(12, 12);

Paint _stroke(Paint paint) => Paint()
  ..color = paint.color
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// The part of [segment] of the animation that [t] has reached, from 0
/// to 1.
double _phase(double t, double start, double end) =>
    ((t - start) / (end - start)).clamp(0.0, 1.0);

/// The first [fraction] of [path], by length; empty while [fraction] is 0,
/// so round caps draw no dot.
Path _partial(Path path, double fraction) {
  final result = Path();
  if (fraction <= 0) return result;
  for (final PathMetric metric in path.computeMetrics()) {
    result.addPath(
      metric.extractPath(0, metric.length * fraction),
      Offset.zero,
    );
  }
  return result;
}

/// Draws [path] cut out of everything painted after the layer opened.
void _knockOut(Canvas canvas, Path path, {bool stroke = false}) {
  final paint = Paint()..blendMode = BlendMode.clear;
  if (stroke) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }
  canvas.drawPath(path, paint);
}

final Path _circle = Path()
  ..addOval(Rect.fromCircle(center: _center, radius: 10));

final Path _check = Path()
  ..moveTo(7.5, 12.5)
  ..lineTo(10.5, 15.5)
  ..lineTo(16.5, 9);

final Path _heartPath = Path()
  ..moveTo(12, 20.5)
  ..cubicTo(6, 16, 2, 12.5, 2, 8.5)
  ..cubicTo(2, 5.5, 4.5, 3.5, 7.2, 3.5)
  ..cubicTo(9.2, 3.5, 10.9, 4.6, 12, 6.3)
  ..cubicTo(13.1, 4.6, 14.8, 3.5, 16.8, 3.5)
  ..cubicTo(19.5, 3.5, 22, 5.5, 22, 8.5)
  ..cubicTo(22, 12.5, 18, 16, 12, 20.5)
  ..close();

final Path _starPath = () {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final radius = i.isEven ? 10.0 : 4.4;
    final angle = -math.pi / 2 + i * math.pi / 5;
    final point = Offset(12, 12.8) + Offset.fromDirection(angle, radius);
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}();

Path _needle(double angle) {
  final matrix = Matrix4.identity()
    ..translateByDouble(12, 12, 0, 1)
    ..rotateZ(angle)
    ..translateByDouble(-12, -12, 0, 1);
  return (Path()
        ..moveTo(12, 5.5)
        ..lineTo(14.5, 12)
        ..lineTo(12, 18.5)
        ..lineTo(9.5, 12)
        ..close())
      .transform(matrix.storage);
}

/// The half of the grid on the north side of a needle turned by [angle].
Path _northHalf(double angle) {
  final matrix = Matrix4.identity()
    ..translateByDouble(12, 12, 0, 1)
    ..rotateZ(angle)
    ..translateByDouble(-12, -12, 0, 1);
  return (Path()..addRect(const Rect.fromLTRB(-12, -12, 36, 12))).transform(
    matrix.storage,
  );
}

/// A swing that starts at 50 degrees and settles at 0.
double _swing(double t) =>
    (1 - t) * (1 - t) * math.sin(t * 3.5 * math.pi) * 50 * math.pi / 180;

/// Scales the canvas by [scale] around the grid center.
void _scaleAround(Canvas canvas, double scale) {
  canvas
    ..translate(12, 12)
    ..scale(scale)
    ..translate(-12, -12);
}

// The painters.

void _ok(Canvas canvas, double t, Paint paint) {
  final stroke = _stroke(paint);
  canvas.drawPath(_partial(_circle, _phase(t, 0, 0.6)), stroke);
  canvas.drawPath(_partial(_check, _phase(t, 0.45, 1)), stroke);
}

void _okFilled(Canvas canvas, double t, Paint paint) {
  final pop = Curves.easeOutBack.transform(_phase(t, 0, 0.5));
  canvas.saveLayer(const Rect.fromLTWH(0, 0, 24, 24), Paint());
  canvas.save();
  _scaleAround(canvas, pop);
  canvas.drawPath(_circle, paint);
  canvas.restore();
  _knockOut(canvas, _partial(_check, _phase(t, 0.4, 1)), stroke: true);
  canvas.restore();
}

void _heart(Canvas canvas, double t, Paint paint) {
  final beat = 1 + 0.15 * math.sin(math.pi * _phase(t, 0.7, 1));
  canvas.save();
  _scaleAround(canvas, beat);
  canvas.drawPath(_partial(_heartPath, _phase(t, 0, 0.7)), _stroke(paint));
  canvas.restore();
}

void _heartFilled(Canvas canvas, double t, Paint paint) {
  canvas.save();
  _scaleAround(canvas, Curves.easeOutBack.transform(t));
  canvas.drawPath(_heartPath, paint);
  canvas.restore();
}

void _star(Canvas canvas, double t, Paint paint) {
  canvas.drawPath(_partial(_starPath, t), _stroke(paint));
}

void _starFilled(Canvas canvas, double t, Paint paint) {
  canvas.save();
  canvas
    ..translate(12, 12.8)
    ..rotate((1 - Curves.easeOut.transform(t)) * -2 * math.pi / 5)
    ..translate(-12, -12.8);
  _scaleAround(canvas, Curves.easeOutBack.transform(t));
  canvas.drawPath(_starPath, paint);
  canvas.restore();
}

void _starHalfFilled(Canvas canvas, double t, Paint paint) {
  canvas.drawPath(_starPath, _stroke(paint));
  canvas.save();
  canvas.clipRect(Rect.fromLTWH(0, 0, 12 * Curves.easeOut.transform(t), 24));
  canvas.drawPath(_starPath, paint);
  canvas.restore();
}

void _compass(Canvas canvas, double t, Paint paint) {
  final stroke = _stroke(paint);
  canvas.drawPath(_circle, stroke);
  final angle = _swing(t);
  canvas.drawPath(_needle(angle), stroke);
  canvas.drawPath(
    Path.combine(PathOperation.intersect, _needle(angle), _northHalf(angle)),
    paint,
  );
}

void _compassFilled(Canvas canvas, double t, Paint paint) {
  canvas.saveLayer(const Rect.fromLTWH(0, 0, 24, 24), Paint());
  canvas.drawPath(_circle, paint);
  _knockOut(canvas, _needle(_swing(t)));
  canvas.restore();
}

void _noNetwork(Canvas canvas, double t, Paint paint) {
  final stroke = _stroke(paint);
  const base = Offset(12, 19);
  final dot = _phase(t, 0, 0.15);
  if (dot > 0) {
    canvas.drawCircle(
      base,
      1.2,
      Paint()..color = paint.color.withValues(alpha: paint.color.a * dot),
    );
  }
  for (var i = 0; i < 3; i++) {
    final appear = _phase(t, 0.1 + i * 0.15, 0.25 + i * 0.15);
    if (appear == 0) continue;
    final radius = 4.5 + i * 4.5;
    canvas.drawArc(
      Rect.fromCircle(center: base, radius: radius),
      -math.pi * 3 / 4,
      math.pi / 2,
      false,
      stroke..color = paint.color.withValues(alpha: paint.color.a * appear),
    );
  }
  final slash = Path()
    ..moveTo(3, 3)
    ..lineTo(21, 21);
  canvas.drawPath(_partial(slash, _phase(t, 0.65, 1)), _stroke(paint));
}

/// An animated icon, such as [Oito2AnimatedIcons.ok].
///
/// It plays according to [mode], at [size] (the icon theme size by
/// default) in [color] (the icon theme color by default). When animations
/// are disabled it shows the final frame. Without a [semanticLabel] it is
/// hidden from assistive technologies, as a decorative icon.
class Oito2AnimatedIcon extends StatefulWidget {
  /// Creates an animated icon.
  const Oito2AnimatedIcon(
    this.data, {
    super.key,
    this.size,
    this.color,
    this.mode = Oito2AnimationMode.once,
    this.duration,
    this.semanticLabel,
  });

  /// The icon drawing and timing.
  final Oito2AnimatedIconData data;

  /// The width and height; defaults to the icon theme size.
  final double? size;

  /// The color; defaults to the icon theme color.
  final Color? color;

  /// How the animation plays.
  final Oito2AnimationMode mode;

  /// Overrides [Oito2AnimatedIconData.duration].
  final Duration? duration;

  /// The accessibility label.
  final String? semanticLabel;

  @override
  State<Oito2AnimatedIcon> createState() => _Oito2AnimatedIconState();
}

class _Oito2AnimatedIconState extends State<Oito2AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration ?? widget.data.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _play(restart: false);
  }

  @override
  void didUpdateWidget(Oito2AnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration ?? widget.data.duration;
    if (oldWidget.data != widget.data || oldWidget.mode != widget.mode) {
      _play(restart: true);
    }
  }

  void _play({required bool restart}) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced || widget.mode == Oito2AnimationMode.still) {
      _controller.value = 1;
      return;
    }
    if (widget.mode == Oito2AnimationMode.repeat) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (restart || _controller.value == 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final size = widget.size ?? iconTheme.size ?? 24;
    final color =
        widget.color ?? iconTheme.color ?? Oito2NeutralPalette.light.onSurface;
    final icon = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size.square(size),
        painter: _AnimatedIconPainter(
          widget.data.painter,
          _controller.value,
          color,
        ),
      ),
    );
    final label = widget.semanticLabel;
    return label == null
        ? ExcludeSemantics(child: icon)
        : Semantics(label: label, image: true, child: icon);
  }
}

class _AnimatedIconPainter extends CustomPainter {
  _AnimatedIconPainter(this.draw, this.progress, this.color);

  final Oito2AnimatedIconPainter draw;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    draw(canvas, progress, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AnimatedIconPainter old) =>
      old.progress != progress || old.color != color || old.draw != draw;
}
