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

import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// A labeled point on the track of an [Oito2Slider] or [Oito2RangeSlider].
@immutable
class Oito2SliderMark {
  /// Creates a mark at [value].
  const Oito2SliderMark(this.value, {this.label});

  /// The value the mark points at.
  final double value;

  /// The text under the mark (beside it on a vertical slider).
  final String? label;
}

/// The radius of the slider thumb, which is also the inset of the track
/// from the slider ends.
const double _thumbRadius = 10;

/// The thickness of the slider track.
const double _trackHeight = 6;

/// The default length of a vertical slider.
const double _verticalLength = 192;

/// A slider for one value, with an optional [label] and value text above
/// the track and [marks] along it.
///
/// It is a Material `Slider` drawn with a thick rounded track and a ring
/// thumb, so it keeps the keyboard, pointer and accessibility behavior of
/// `Slider`. [valueText] formats the value for the text above the track,
/// the indicator shown while dragging (with [showValueIndicator]) and
/// assistive technologies. A [Axis.vertical] slider is [length] pixels
/// tall, with its minimum at the bottom.
class Oito2Slider extends StatelessWidget {
  /// Creates a slider.
  const Oito2Slider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.valueText,
    this.showValueIndicator = false,
    this.marks = const [],
    this.orientation = Axis.horizontal,
    this.length = _verticalLength,
    this.focusNode,
  });

  /// The selected value, between [min] and [max].
  final double value;

  /// Called with the new value while it changes; null disables the slider.
  final ValueChanged<double>? onChanged;

  /// Called with the value when a change starts.
  final ValueChanged<double>? onChangeStart;

  /// Called with the value when a change ends.
  final ValueChanged<double>? onChangeEnd;

  /// The smallest value.
  final double min;

  /// The largest value.
  final double max;

  /// The number of equal steps between [min] and [max]; null for a
  /// continuous slider.
  final int? divisions;

  /// The name shown above the track.
  final Widget? label;

  /// Formats the value; when given, the value shows above the track.
  final String Function(double value)? valueText;

  /// Whether the formatted value shows above the thumb while dragging.
  final bool showValueIndicator;

  /// The labeled points along the track.
  final List<Oito2SliderMark> marks;

  /// Whether the track runs across or up.
  final Axis orientation;

  /// The height of a vertical slider.
  final double length;

  /// The focus node of the slider.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final valueText = this.valueText;
    return _SliderFrame(
      min: min,
      max: max,
      reached: (mark) => mark <= value,
      label: label,
      valueText: valueText?.call(value),
      showValueIndicator: showValueIndicator,
      marks: marks,
      orientation: orientation,
      length: length,
      slider: Slider(
        value: value,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        min: min,
        max: max,
        divisions: divisions,
        label: valueText?.call(value),
        semanticFormatterCallback: valueText,
        focusNode: focusNode,
      ),
    );
  }
}

/// A slider for a range between two values, with an optional [label] and
/// value text above the track and [marks] along it.
///
/// It is a Material `RangeSlider` drawn like [Oito2Slider]. [valueText]
/// formats each end for the text above the track (as "start – end") and
/// the indicators shown while dragging (with [showValueIndicator]).
class Oito2RangeSlider extends StatelessWidget {
  /// Creates a range slider.
  const Oito2RangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.valueText,
    this.showValueIndicator = false,
    this.marks = const [],
    this.orientation = Axis.horizontal,
    this.length = _verticalLength,
  });

  /// The selected range, between [min] and [max].
  final RangeValues values;

  /// Called with the new range while it changes; null disables the slider.
  final ValueChanged<RangeValues>? onChanged;

  /// Called with the range when a change starts.
  final ValueChanged<RangeValues>? onChangeStart;

  /// Called with the range when a change ends.
  final ValueChanged<RangeValues>? onChangeEnd;

  /// The smallest value.
  final double min;

  /// The largest value.
  final double max;

  /// The number of equal steps between [min] and [max]; null for a
  /// continuous slider.
  final int? divisions;

  /// The name shown above the track.
  final Widget? label;

  /// Formats a value; when given, the range shows above the track.
  final String Function(double value)? valueText;

  /// Whether the formatted values show above the thumbs while dragging.
  final bool showValueIndicator;

  /// The labeled points along the track.
  final List<Oito2SliderMark> marks;

  /// Whether the track runs across or up.
  final Axis orientation;

  /// The height of a vertical slider.
  final double length;

  @override
  Widget build(BuildContext context) {
    final valueText = this.valueText;
    return _SliderFrame(
      min: min,
      max: max,
      reached: (mark) => mark >= values.start && mark <= values.end,
      label: label,
      valueText: valueText == null
          ? null
          : '${valueText(values.start)} – ${valueText(values.end)}',
      showValueIndicator: showValueIndicator,
      marks: marks,
      orientation: orientation,
      length: length,
      slider: RangeSlider(
        values: values,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        min: min,
        max: max,
        divisions: divisions,
        labels: valueText == null
            ? null
            : RangeLabels(valueText(values.start), valueText(values.end)),
        semanticFormatterCallback: valueText,
        // The range track is already inset by half a thumb, the same as the
        // padding of the single-value slider.
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// The header, the restyled Material slider and the marks shared by
/// [Oito2Slider] and [Oito2RangeSlider].
class _SliderFrame extends StatelessWidget {
  const _SliderFrame({
    required this.slider,
    required this.min,
    required this.max,
    required this.reached,
    required this.label,
    required this.valueText,
    required this.showValueIndicator,
    required this.marks,
    required this.orientation,
    required this.length,
  });

  final Widget slider;
  final double min;
  final double max;
  final bool Function(double mark) reached;
  final Widget? label;
  final String? valueText;
  final bool showValueIndicator;
  final List<Oito2SliderMark> marks;
  final Axis orientation;
  final double length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final vertical = orientation == Axis.vertical;
    final thumb = _RingThumbShape(fill: scheme.surface);
    final themed = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: _trackHeight,
        trackShape: const RoundedRectSliderTrackShape(),
        rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
        thumbShape: thumb,
        rangeThumbShape: thumb,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        rangeTickMarkShape: const RoundRangeSliderTickMarkShape(
          tickMarkRadius: 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: _thumbRadius),
        showValueIndicator: showValueIndicator
            ? ShowValueIndicator.onDrag
            : ShowValueIndicator.never,
      ),
      child: slider,
    );
    final track = vertical
        ? SizedBox(
            height: length,
            child: RotatedBox(quarterTurns: 3, child: themed),
          )
        : themed;
    final body = marks.isEmpty
        ? track
        : vertical
        ? Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.xs,
            children: [
              track,
              SizedBox(height: length, child: _marks(context, vertical)),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Oito2Spacing.xs,
            children: [track, _marks(context, vertical)],
          );
    final valueText = this.valueText;
    if (label == null && valueText == null) return body;
    final headerStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.stretch,
      spacing: Oito2Spacing.xs,
      children: [
        DefaultTextStyle.merge(
          style: headerStyle,
          child: Row(
            mainAxisSize: vertical ? MainAxisSize.min : MainAxisSize.max,
            spacing: Oito2Spacing.sm,
            children: [
              if (label case final label?)
                vertical ? label : Expanded(child: label),
              if (valueText != null) ExcludeSemantics(child: Text(valueText)),
            ],
          ),
        ),
        body,
      ],
    );
  }

  /// The marks: a dot at each value, filled with the accent once the value
  /// reaches it, with its label under it (beside it when [vertical]).
  Widget _marks(BuildContext context, bool vertical) {
    final theme = Theme.of(context);
    final accent = semanticColorsOf(context).primaryText;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent =
            (vertical ? constraints.maxHeight : constraints.maxWidth) -
            2 * _thumbRadius;
        final children = <Widget>[];
        for (final mark in marks) {
          final t = max == min ? 0.0 : (mark.value - min) / (max - min);
          final along = _thumbRadius + extent * t.clamp(0.0, 1.0);
          final dot = Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reached(mark.value)
                  ? accent
                  : theme.colorScheme.outlineVariant,
            ),
          );
          final text = mark.label == null
              ? null
              : Text(mark.label!, style: labelStyle);
          final content = vertical
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Oito2Spacing.xs,
                  children: [dot, ?text],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Oito2Spacing.xxs,
                  children: [dot, ?text],
                );
          children.add(
            vertical
                ? Positioned(
                    left: 0,
                    top: constraints.maxHeight - along,
                    child: FractionalTranslation(
                      translation: const Offset(0, -0.5),
                      child: content,
                    ),
                  )
                : Positioned(
                    top: 0,
                    left: rtl ? constraints.maxWidth - along : along,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, 0),
                      child: content,
                    ),
                  ),
          );
        }
        final labeled = marks.any((mark) => mark.label != null);
        return SizedBox(
          width: vertical ? _verticalMarksWidth(context, labelStyle) : null,
          height: vertical ? null : (labeled ? 24 : 4),
          child: Stack(clipBehavior: Clip.none, children: children),
        );
      },
    );
  }

  /// The width of the marks beside a vertical slider: the dot, and the
  /// widest label after it.
  double _verticalMarksWidth(BuildContext context, TextStyle? style) {
    var widest = 0.0;
    for (final mark in marks) {
      final label = mark.label;
      if (label == null) continue;
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      if (painter.width > widest) widest = painter.width;
      painter.dispose();
    }
    return widest == 0 ? 4 : 4 + Oito2Spacing.xs + widest.ceilToDouble();
  }
}

/// A thumb drawn as a ring in the slider's thumb color around a [fill]
/// disk, with a faint shadow.
class _RingThumbShape extends SliderComponentShape
    implements RangeSliderThumbShape {
  const _RingThumbShape({required this.fill});

  final Color fill;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_thumbRadius);

  void _paintRing(
    Canvas canvas,
    Offset center,
    SliderThemeData theme,
    Animation<double> enableAnimation,
  ) {
    final ring = ColorTween(
      begin: theme.disabledThumbColor,
      end: theme.thumbColor,
    ).evaluate(enableAnimation)!;
    final circle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: _thumbRadius));
    canvas
      ..drawShadow(circle, const Color(0xFF000000), 1, true)
      ..drawCircle(center, _thumbRadius, Paint()..color = fill)
      ..drawCircle(
        center,
        _thumbRadius - 1,
        Paint()
          ..color = ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = true,
    bool isOnTop = false,
    TextDirection textDirection = TextDirection.ltr,
    required SliderThemeData sliderTheme,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    double value = 0,
    double textScaleFactor = 1,
    Size sizeWithOverflow = Size.zero,
  }) {
    _paintRing(context.canvas, center, sliderTheme, enableAnimation);
  }
}
