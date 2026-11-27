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

import 'package:flutter/foundation.dart' show listEquals;
import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_ui/material_ui.dart';

import '../foundation/contrast.dart';
import '../format/format.dart';
import '../l10n/oito2_localizations.dart';
import 'info.dart';
import 'widget_helpers.dart';

/// How an [Oito2Sparkline] draws its values.
enum Oito2SparklineType {
  /// A line through the values.
  line,

  /// A line through the values with the area down to the baseline filled.
  area,

  /// One bar per value from the baseline.
  bars,
}

/// The direction of a series from its first to its last value.
enum Oito2SparklineTrend {
  /// The last value is higher than the first by more than the threshold.
  rising,

  /// The first and last values are within the threshold of each other.
  steady,

  /// The last value is lower than the first by more than the threshold.
  falling,
}

/// The minimum, maximum, first and last finite values of a series and its
/// trend, as an [Oito2Sparkline] summarizes them.
///
/// Values that aren't finite (NaN and the infinities) are skipped: they
/// count for nothing here and an [Oito2Sparkline] draws nothing for them.
@immutable
class Oito2SparklineStats {
  /// Creates the statistics of a series; [of] computes them from values.
  const Oito2SparklineStats({
    required this.count,
    required this.min,
    required this.max,
    required this.first,
    required this.last,
    required this.minIndex,
    required this.maxIndex,
    required this.lastIndex,
    required this.trend,
  });

  /// The default trend threshold: a tenth of the range of the values.
  static const double defaultTrendThreshold = 0.1;

  /// Returns the statistics of the finite [values], or null when none is
  /// finite, with the trend from [trendOf] at [trendThreshold].
  ///
  /// The indexes are positions in [values]; [minIndex] and [maxIndex] are
  /// the first occurrences of the minimum and maximum.
  static Oito2SparklineStats? of(
    List<double> values, {
    double trendThreshold = defaultTrendThreshold,
  }) {
    var count = 0;
    var min = 0.0;
    var max = 0.0;
    var first = 0.0;
    var last = 0.0;
    var minIndex = -1;
    var maxIndex = -1;
    var lastIndex = -1;
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (!value.isFinite) continue;
      if (count == 0) {
        first = min = max = value;
        minIndex = maxIndex = i;
      } else {
        if (value < min) {
          min = value;
          minIndex = i;
        }
        if (value > max) {
          max = value;
          maxIndex = i;
        }
      }
      last = value;
      lastIndex = i;
      count++;
    }
    if (count == 0) return null;
    return Oito2SparklineStats(
      count: count,
      min: min,
      max: max,
      first: first,
      last: last,
      minIndex: minIndex,
      maxIndex: maxIndex,
      lastIndex: lastIndex,
      trend: trendOf(first, last, min, max, threshold: trendThreshold),
    );
  }

  /// Returns the trend of a series from its [first] to its [last] value,
  /// measured against its range from [min] to [max].
  ///
  /// The series is [Oito2SparklineTrend.rising] when the last value
  /// exceeds the first by more than [threshold] times the range,
  /// [Oito2SparklineTrend.falling] when it is below the first by more
  /// than that, and [Oito2SparklineTrend.steady] otherwise, which
  /// includes a range of zero (one value, or all values equal). Being
  /// relative to the range, the trend doesn't depend on the unit or the
  /// sign of the values.
  static Oito2SparklineTrend trendOf(
    double first,
    double last,
    double min,
    double max, {
    double threshold = defaultTrendThreshold,
  }) {
    final range = max - min;
    if (!(range > 0)) return Oito2SparklineTrend.steady;
    final change = last - first;
    final limit = threshold * range;
    if (change > limit) return Oito2SparklineTrend.rising;
    if (change < -limit) return Oito2SparklineTrend.falling;
    return Oito2SparklineTrend.steady;
  }

  /// The number of finite values.
  final int count;

  /// The lowest finite value.
  final double min;

  /// The highest finite value.
  final double max;

  /// The first finite value.
  final double first;

  /// The last finite value.
  final double last;

  /// The position of the first [min] in the values.
  final int minIndex;

  /// The position of the first [max] in the values.
  final int maxIndex;

  /// The position of [last] in the values.
  final int lastIndex;

  /// The direction from [first] to [last].
  final Oito2SparklineTrend trend;

  /// Returns the text summary of the series in [strings], with each value
  /// passed through [format]: "Value 5" for one value, otherwise the
  /// minimum, maximum, last value and trend, such as "Minimum 3,
  /// maximum 12, last 8, rising".
  ///
  /// Without [format], values are decimal numbers of the locale of
  /// [strings].
  String describe(
    Oito2Localizations strings, [
    String Function(double value)? format,
  ]) {
    format ??= NumberFormat.decimalPattern(
      NumberFormat.localeExists(strings.localeName) ? strings.localeName : 'en',
    ).format;
    if (count == 1) return strings.sparklineValue(format(last));
    return strings.sparklineSummary(
      format(min),
      format(max),
      format(last),
      switch (trend) {
        Oito2SparklineTrend.rising => strings.trendRising,
        Oito2SparklineTrend.steady => strings.trendSteady,
        Oito2SparklineTrend.falling => strings.trendFalling,
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2SparklineStats &&
      other.count == count &&
      other.min == min &&
      other.max == max &&
      other.first == first &&
      other.last == last &&
      other.minIndex == minIndex &&
      other.maxIndex == maxIndex &&
      other.lastIndex == lastIndex &&
      other.trend == trend;

  @override
  int get hashCode => Object.hash(
    count,
    min,
    max,
    first,
    last,
    minIndex,
    maxIndex,
    lastIndex,
    trend,
  );
}

/// A small, static chart of a series of values, such as a transfer speed
/// over the last minute or the usage of a resource over time.
///
/// The values are drawn evenly spaced from the start to the end edge
/// (right to left in right-to-left text) as a [Oito2SparklineType.line],
/// an [Oito2SparklineType.area] or [Oito2SparklineType.bars]. The vertical
/// range runs from [min] to [max], which default to the lowest and highest
/// values; bars default to a range that also includes zero. The area and
/// the bars start from zero, or from the range edge closest to zero when
/// zero is outside the range. Values outside an explicit range are drawn
/// at its edge.
///
/// Values that aren't finite (NaN and the infinities) are skipped: the
/// line joins the finite values around them and their bar is left empty.
/// Without finite values nothing is drawn. One value draws a dot or a
/// single bar, and equal values a flat line across the middle.
///
/// [showMin], [showMax] and [showLast] mark the first lowest, the first
/// highest and the last finite value with a dot.
///
/// The color is [color], or else the [tone] color of the theme raised to
/// 3:1 against the surface, or else the primary fill of selected controls.
///
/// The sparkline isn't interactive and doesn't take focus. Assistive
/// technologies read one label with a summary of the values (minimum,
/// maximum, last value and trend, from [Oito2SparklineStats]), each
/// formatted by [formatValue], after [semanticsLabel] when it is set, such
/// as "Download speed, minimum 1.2 MB/s, maximum 8 MB/s, last 6.5 MB/s,
/// rising". It doesn't animate value changes.
class Oito2Sparkline extends StatelessWidget {
  /// Creates a sparkline of [values].
  ///
  /// Throws an [AssertionError] in debug mode when [min] or [max] is NaN
  /// or infinite, when [strokeWidth] isn't positive, or when [height] or
  /// [trendThreshold] is negative.
  const Oito2Sparkline({
    super.key,
    required this.values,
    this.type = Oito2SparklineType.line,
    this.tone,
    this.color,
    this.min,
    this.max,
    this.showMin = false,
    this.showMax = false,
    this.showLast = false,
    this.strokeWidth = 2,
    this.width,
    this.height = 32,
    this.formatValue,
    this.semanticsLabel,
    this.trendThreshold = Oito2SparklineStats.defaultTrendThreshold,
  }) : assert(strokeWidth > 0),
       assert(height >= 0),
       assert(trendThreshold >= 0),
       // A NaN is the only value that differs from itself.
       assert(
         min == null ||
             (min == min &&
                 min != double.infinity &&
                 min != double.negativeInfinity),
         'The min of Oito2Sparkline must be a finite number.',
       ),
       assert(
         max == null ||
             (max == max &&
                 max != double.infinity &&
                 max != double.negativeInfinity),
         'The max of Oito2Sparkline must be a finite number.',
       );

  /// The width used when the parent doesn't bound it and [width] is null.
  static const double defaultWidth = 120;

  /// The values, oldest first.
  final List<double> values;

  /// How the values are drawn.
  final Oito2SparklineType type;

  /// The semantic tone of the color, or null for the primary color.
  final Oito2InfoType? tone;

  /// The color, used as is; overrides [tone].
  final Color? color;

  /// The value drawn at the bottom edge; defaults to the lowest value, or
  /// to zero for bars when it is lower.
  final double? min;

  /// The value drawn at the top edge; defaults to the highest value, or
  /// to zero for bars when it is higher.
  final double? max;

  /// Whether a dot marks the first lowest value.
  final bool showMin;

  /// Whether a dot marks the first highest value.
  final bool showMax;

  /// Whether a dot marks the last finite value.
  final bool showLast;

  /// The thickness of the line.
  final double strokeWidth;

  /// The width; when null, the sparkline fills the width the parent
  /// allows, or [defaultWidth] when the parent doesn't bound it.
  final double? width;

  /// The height.
  final double height;

  /// Formats each value in the accessibility summary, such as
  /// "12 MB/s"; when null, values are numbers of the locale.
  final String Function(BuildContext context, double value)? formatValue;

  /// What the values measure, read before the summary, such as
  /// "Download speed".
  final String? semanticsLabel;

  /// The trend threshold, as a fraction of the range of the values; see
  /// [Oito2SparklineStats.trendOf].
  final double trendThreshold;

  /// Returns the color of the line, area and bars in [context].
  Color _colorOf(BuildContext context) {
    final color = this.color;
    if (color != null) return color;
    final tone = this.tone;
    if (tone == null) return selectedFillOf(context).fill;
    return Oito2Contrast.ensure(tone.colorIn(semanticColorsOf(context)), [
      Theme.of(context).colorScheme.surface,
    ], Oito2Contrast.nonTextAA);
  }

  /// Returns the accessibility summary of [stats] in [context].
  String _summary(BuildContext context, Oito2SparklineStats? stats) {
    final strings = Oito2Localizations.of(context);
    final formatValue = this.formatValue;
    final number = NumberFormat.decimalPattern(Oito2Format.of(context).locale);
    final text = stats == null
        ? strings.noData
        : stats.describe(
            strings,
            formatValue == null
                ? number.format
                : (value) => formatValue(context, value),
          );
    final label = semanticsLabel;
    return label == null || label.isEmpty ? text : '$label, $text';
  }

  @override
  Widget build(BuildContext context) {
    final stats = Oito2SparklineStats.of(
      values,
      trendThreshold: trendThreshold,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final painter = _SparklinePainter(
      // A copy, so a list changed in place still repaints.
      values: List.of(values),
      stats: stats,
      type: type,
      color: _colorOf(context),
      ring: colorScheme.surface,
      min: min,
      max: max,
      showMin: showMin,
      showMax: showMax,
      showLast: showLast,
      strokeWidth: strokeWidth,
      rtl: Directionality.of(context) == TextDirection.rtl,
    );
    return Semantics(
      container: true,
      image: true,
      label: _summary(context, stats),
      child: LimitedBox(
        maxWidth: defaultWidth,
        child: SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: CustomPaint(painter: painter),
        ),
      ),
    );
  }
}

/// Paints the values of an [Oito2Sparkline].
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.stats,
    required this.type,
    required this.color,
    required this.ring,
    required this.min,
    required this.max,
    required this.showMin,
    required this.showMax,
    required this.showLast,
    required this.strokeWidth,
    required this.rtl,
  });

  final List<double> values;
  final Oito2SparklineStats? stats;
  final Oito2SparklineType type;
  final Color color;
  final Color ring;
  final double? min;
  final double? max;
  final bool showMin;
  final bool showMax;
  final bool showLast;
  final double strokeWidth;
  final bool rtl;

  /// The radius of the marker dots.
  double get _markerRadius => strokeWidth + 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final stats = this.stats;
    if (stats == null || size.isEmpty) return;
    final bars = type == Oito2SparklineType.bars;
    final markers = showMin || showMax || showLast;
    // The drawing keeps the line ends and the marker dots inside the box.
    final inset = markers ? _markerRadius + 1 : strokeWidth / 2;
    final rect = Rect.fromLTRB(
      bars ? 0 : inset,
      inset,
      size.width - (bars ? 0 : inset),
      size.height - inset,
    );
    if (rect.width <= 0 || rect.height <= 0) return;

    var lo = min ?? (bars ? math.min(stats.min, 0.0) : stats.min);
    var hi = max ?? (bars ? math.max(stats.max, 0.0) : stats.max);
    if (hi < lo) (lo, hi) = (hi, lo);
    final span = hi - lo;

    // Returns the vertical position of [value], clamped to the range; the
    // middle when the range is empty.
    double yOf(double value) {
      if (span <= 0) return rect.center.dy;
      final t = ((value - lo) / span).clamp(0.0, 1.0);
      return rect.bottom - t * rect.height;
    }

    final baseline = span <= 0 ? rect.bottom : yOf(0.0.clamp(lo, hi));
    final n = values.length;
    final slot = rect.width / n;

    // Returns the horizontal center of the value at [index].
    double xOf(int index) {
      final double offset;
      if (bars) {
        offset = (index + 0.5) * slot;
      } else {
        offset = n == 1 ? rect.width / 2 : index * rect.width / (n - 1);
      }
      return rtl ? rect.right - offset : rect.left + offset;
    }

    final fill = Paint()..color = color;
    if (bars) {
      final gap = math.min(2.0, slot * 0.25);
      final barWidth = math.max(slot - gap, 1.0);
      for (var i = 0; i < n; i++) {
        final value = values[i];
        if (!value.isFinite) continue;
        final x = xOf(i);
        final y = yOf(value);
        // An empty range draws equal bars across the whole height.
        final top = span <= 0 ? rect.top : math.min(y, baseline);
        final bottom = span <= 0 ? rect.bottom : math.max(y, baseline);
        canvas.drawRect(
          Rect.fromLTRB(
            x - barWidth / 2,
            top,
            x + barWidth / 2,
            math.max(bottom, top + 1),
          ),
          fill,
        );
      }
    } else if (stats.count == 1) {
      canvas.drawCircle(
        Offset(xOf(stats.lastIndex), yOf(stats.last)),
        strokeWidth,
        fill,
      );
    } else {
      final line = Path();
      Offset? start;
      Offset? end;
      for (var i = 0; i < n; i++) {
        final value = values[i];
        if (!value.isFinite) continue;
        final point = Offset(xOf(i), yOf(value));
        if (start == null) {
          start = point;
          line.moveTo(point.dx, point.dy);
        } else {
          line.lineTo(point.dx, point.dy);
        }
        end = point;
      }
      if (type == Oito2SparklineType.area && start != null && end != null) {
        final area = Path.from(line)
          ..lineTo(end.dx, baseline)
          ..lineTo(start.dx, baseline)
          ..close();
        canvas.drawPath(
          area,
          Paint()..color = color.withValues(alpha: color.a * 0.2),
        );
      }
      canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    final ringPaint = Paint()..color = ring;
    void marker(int index, double value) {
      final x = xOf(index);
      final center = Offset(
        x,
        bars ? math.min(yOf(value), baseline) : yOf(value),
      );
      canvas
        ..drawCircle(center, _markerRadius + 1, ringPaint)
        ..drawCircle(center, _markerRadius, fill);
    }

    if (showMin) marker(stats.minIndex, stats.min);
    if (showMax) marker(stats.maxIndex, stats.max);
    if (showLast) marker(stats.lastIndex, stats.last);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      !listEquals(oldDelegate.values, values) ||
      oldDelegate.type != type ||
      oldDelegate.color != color ||
      oldDelegate.ring != ring ||
      oldDelegate.min != min ||
      oldDelegate.max != max ||
      oldDelegate.showMin != showMin ||
      oldDelegate.showMax != showMax ||
      oldDelegate.showLast != showLast ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.rtl != rtl;
}
