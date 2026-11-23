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

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

/// The colors of a highlighted code line: a light tint of the scheme's
/// primary color across the line and a bar in the text-safe primary tone
/// along its leading edge.
@immutable
class LineHighlightColors {
  /// Creates line highlight colors.
  const LineHighlightColors({required this.tint, required this.bar});

  /// Returns the colors for the closest theme.
  factory LineHighlightColors.of(BuildContext context) {
    final theme = Theme.of(context);
    return LineHighlightColors(
      tint: theme.colorScheme.primary.withValues(alpha: 0.14),
      bar:
          Oito2SemanticColors.maybeOf(context)?.primaryText ??
          theme.colorScheme.primary,
    );
  }

  /// The fill across the line.
  final Color tint;

  /// The bar along the leading edge.
  final Color bar;

  /// The width of [bar].
  static const double barWidth = 3;

  @override
  bool operator ==(Object other) =>
      other is LineHighlightColors && other.tint == tint && other.bar == bar;

  @override
  int get hashCode => Object.hash(tint, bar);
}

/// Paints [rect] as a highlighted line in [colors]: the tint over the
/// whole rectangle and the bar on its leading side for [direction].
void paintLineHighlight(
  Canvas canvas,
  Rect rect,
  LineHighlightColors colors,
  TextDirection direction,
) {
  canvas.drawRect(rect, Paint()..color = colors.tint);
  final bar = direction == TextDirection.ltr
      ? Rect.fromLTWH(
          rect.left,
          rect.top,
          LineHighlightColors.barWidth,
          rect.height,
        )
      : Rect.fromLTWH(
          rect.right - LineHighlightColors.barWidth,
          rect.top,
          LineHighlightColors.barWidth,
          rect.height,
        );
  canvas.drawRect(bar, Paint()..color = colors.bar);
}

/// Paints the lines of a code block with fixed-height lines: line [n]
/// (counted from 1) of [lines] spans from [top] plus n - 1 times
/// [lineHeight], across the whole width.
class FixedLineHighlightPainter extends CustomPainter {
  /// Creates the painter.
  FixedLineHighlightPainter({
    required this.lines,
    required this.top,
    required this.lineHeight,
    required this.colors,
    required this.direction,
  });

  /// The highlighted line numbers, counted from 1.
  final Set<int> lines;

  /// The offset of the first line from the top.
  final double top;

  /// The height of every line.
  final double lineHeight;

  /// The highlight colors.
  final LineHighlightColors colors;

  /// The text direction, which sets the side of the bar.
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      if (line < 1) continue;
      final y = top + (line - 1) * lineHeight;
      if (y >= size.height) continue;
      paintLineHighlight(
        canvas,
        Rect.fromLTWH(0, y, size.width, lineHeight),
        colors,
        direction,
      );
    }
  }

  @override
  bool shouldRepaint(FixedLineHighlightPainter oldDelegate) =>
      !setEquals(oldDelegate.lines, lines) ||
      oldDelegate.top != top ||
      oldDelegate.lineHeight != lineHeight ||
      oldDelegate.colors != colors ||
      oldDelegate.direction != direction;
}
