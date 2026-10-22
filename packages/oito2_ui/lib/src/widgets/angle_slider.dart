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
import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_ui/material_ui.dart';

import 'utilities.dart';
import 'widget_helpers.dart';

/// A round dial that picks an angle in degrees, from 0 at the top
/// clockwise to just under 360, such as a rotation or a gradient
/// direction.
///
/// Dragging or tapping points the dial at the pointer, in [step]
/// increments. The arrow keys turn it by [step], Page Up and Page Down by
/// [pageStep], and Home goes back to 0; the value wraps around.
/// [markers] draws ticks at those angles. Assistive technologies see it
/// as a slider.
class Oito2AngleSlider extends StatefulWidget {
  /// Creates an angle slider.
  const Oito2AngleSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.step = 1,
    this.pageStep = 15,
    this.markers = const [0, 90, 180, 270],
    this.size = 96,
    this.showValue = true,
    this.semanticLabel,
  }) : assert(step > 0);

  /// The angle in degrees, from 0 to under 360.
  final double value;

  /// Called with each new angle; the dial is read-only when null.
  final ValueChanged<double>? onChanged;

  /// Called with the final angle when a drag or a tap ends, and after
  /// each key press or assistive-technology adjustment.
  final ValueChanged<double>? onChangeEnd;

  /// The smallest change.
  final double step;

  /// The change of Page Up and Page Down.
  final double pageStep;

  /// The angles that get a tick.
  final List<double> markers;

  /// The dial diameter.
  final double size;

  /// Whether the angle shows in the middle of the dial.
  final bool showValue;

  /// The accessibility label.
  final String? semanticLabel;

  @override
  State<Oito2AngleSlider> createState() => _Oito2AngleSliderState();
}

class _Oito2AngleSliderState extends State<Oito2AngleSlider> {
  final _focusNode = FocusNode(debugLabel: 'Oito2AngleSlider');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onChanged != null;

  static double _wrap(double degrees) => (degrees % 360 + 360) % 360;

  double _snap(double degrees) =>
      _wrap((degrees / widget.step).round() * widget.step);

  /// The last value reported, which the parent may not have shown yet.
  double? _pending;

  void _set(double degrees) {
    final next = _snap(degrees);
    if (next != (_pending ?? widget.value)) {
      _pending = next;
      widget.onChanged?.call(next);
    }
  }

  /// Ends a change: a drag, a tap or a key press.
  void _end() {
    widget.onChangeEnd?.call(_pending ?? widget.value);
    _pending = null;
  }

  /// Sets [degrees] and ends the change at once, for keys and assistive
  /// technologies.
  void _setAndEnd(double degrees) {
    _set(degrees);
    _end();
  }

  NumberFormat? _wholeFormat;
  NumberFormat? _tenthFormat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    _wholeFormat = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 0,
    );
    _tenthFormat = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 1,
    );
  }

  void _pointAt(Offset local) {
    _focusNode.requestFocus();
    final center = Offset(widget.size / 2, widget.size / 2);
    final d = local - center;
    if (d.distance < 2) return;
    _set(math.atan2(d.dx, -d.dy) * 180 / math.pi);
  }

  /// [degrees] in the locale's number format, with a tenth when it has one.
  String _label(double degrees) =>
      '${(degrees % 1 == 0 ? _wholeFormat : _tenthFormat)!.format(degrees)}°';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fill = selectedFillOf(context).fill;
    final dial = CustomPaint(
      size: Size.square(widget.size),
      painter: _DialPainter(
        angle: widget.value,
        markers: widget.markers,
        track:
            theme.inputDecorationTheme.fillColor ?? scheme.surfaceContainerHigh,
        border: scheme.outline,
        tick: scheme.onSurfaceVariant,
        thumb: _enabled ? fill : scheme.onSurface.withValues(alpha: 0.38),
        hollow: widget.showValue,
      ),
      child: SizedBox.square(
        dimension: widget.size,
        child: widget.showValue
            ? Center(
                child: Text(
                  _label(widget.value),
                  style: theme.textTheme.labelLarge,
                ),
              )
            : null,
      ),
    );
    final value = _label(widget.value);
    if (!_enabled) {
      return Semantics(
        label: widget.semanticLabel,
        value: value,
        child: ExcludeSemantics(child: dial),
      );
    }
    void by(double delta) => _setAndEnd(widget.value + delta);
    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: value,
      increasedValue: _label(_snap(widget.value + widget.step)),
      decreasedValue: _label(_snap(widget.value - widget.step)),
      onIncrease: () => by(widget.step),
      onDecrease: () => by(-widget.step),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
              by(widget.step),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              by(widget.step),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
              by(-widget.step),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              by(-widget.step),
          const SingleActivator(LogicalKeyboardKey.pageUp): () =>
              by(widget.pageStep),
          const SingleActivator(LogicalKeyboardKey.pageDown): () =>
              by(-widget.pageStep),
          const SingleActivator(LogicalKeyboardKey.home): () => _setAndEnd(0),
        },
        child: Oito2FocusBorder(
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: Focus(
            focusNode: _focusNode,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: GestureDetector(
                onTapDown: (d) => _pointAt(d.localPosition),
                onTapUp: (_) => _end(),
                onPanStart: (d) => _pointAt(d.localPosition),
                onPanUpdate: (d) => _pointAt(d.localPosition),
                onPanEnd: (_) => _end(),
                child: ExcludeSemantics(child: dial),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.angle,
    required this.markers,
    required this.track,
    required this.border,
    required this.tick,
    required this.thumb,
    required this.hollow,
  });

  final double angle;
  final List<double> markers;
  final Color track;
  final Color border;
  final Color tick;
  final Color thumb;

  /// Whether the middle stays free for the value text.
  final bool hollow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas
      ..drawCircle(center, radius, Paint()..color = border)
      ..drawCircle(center, radius - 1, Paint()..color = track);
    Offset at(double degrees, double distance) =>
        center + Offset.fromDirection((degrees - 90) * math.pi / 180, distance);
    final tickPaint = Paint()..color = tick;
    for (final marker in markers) {
      canvas.drawCircle(at(marker, radius - 7), 1.5, tickPaint);
    }
    // The hand: a filled bar toward a knob near the edge, starting at the
    // center or, when the middle shows the value, past it.
    final knob = at(angle, radius - 12);
    final hand = Paint()..color = thumb;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle * math.pi / 180);
    canvas.drawRRect(
      RRect.fromLTRBR(
        -1,
        -(radius - 12),
        1,
        hollow ? -radius * 0.45 : 0,
        const Radius.circular(1),
      ),
      hand,
    );
    canvas.restore();
    if (!hollow) canvas.drawCircle(center, 3, hand);
    canvas.drawCircle(knob, 6, hand);
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.angle != angle ||
      old.track != track ||
      old.border != border ||
      old.tick != tick ||
      old.thumb != thumb ||
      old.hollow != hollow ||
      old.markers != markers;
}
