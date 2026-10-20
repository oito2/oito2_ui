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

/// A decorative square that stands in for a missing picture, such as an
/// album cover or an app icon that has not loaded.
///
/// It fills a rounded square with a container tone of the color scheme
/// and draws a picture outline in its center. It is hidden from assistive
/// technologies.
class Oito2PlaceholderIcon extends StatelessWidget {
  /// Creates a placeholder icon.
  const Oito2PlaceholderIcon({
    super.key,
    this.size = 48,
    this.borderRadius = Oito2Radius.mediumAll,
  });

  /// The width and height.
  final double size;

  /// The corner rounding.
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _PlaceholderPainter(
          fill: scheme.surfaceContainerHighest,
          ink: scheme.onSurfaceVariant.withValues(alpha: 0.55),
          borderRadius: borderRadius,
          textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
        ),
      ),
    );
  }
}

class _PlaceholderPainter extends CustomPainter {
  _PlaceholderPainter({
    required this.fill,
    required this.ink,
    required this.borderRadius,
    required this.textDirection,
  });

  final Color fill;
  final Color ink;
  final BorderRadius borderRadius;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRRect(
      borderRadius.resolve(textDirection).toRRect(bounds),
      Paint()..color = fill,
    );

    // A picture outline: a frame, a sun and two hills, on a 24-unit grid
    // that covers the middle half of the square.
    final unit = size.shortestSide / 48;
    canvas.save();
    canvas.translate(size.width / 2 - 12 * unit, size.height / 2 - 12 * unit);
    canvas.scale(unit);
    final ink = Paint()..color = this.ink;
    final frame = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(RRect.fromLTRBR(2, 3, 22, 21, const Radius.circular(3)))
      ..addRRect(RRect.fromLTRBR(4, 5, 20, 19, const Radius.circular(1.5)));
    canvas.drawPath(frame, ink);
    canvas.drawCircle(const Offset(8.5, 9.5), 1.75, ink);
    final hills = Path()
      ..moveTo(4, 19)
      ..lineTo(10, 12.5)
      ..lineTo(13.5, 16)
      ..lineTo(16, 13.5)
      ..lineTo(20, 17.5)
      ..lineTo(20, 19)
      ..close();
    canvas.drawPath(hills, ink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlaceholderPainter old) =>
      old.fill != fill ||
      old.ink != ink ||
      old.borderRadius != borderRadius ||
      old.textDirection != textDirection;
}
