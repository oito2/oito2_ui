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
import 'package:oito2_ui/oito2_ui.dart';
import 'package:qr/qr.dart';

/// How much of an [Oito2QrCode] can be damaged or covered and still
/// read, as error correction data takes more room.
enum Oito2QrErrorLevel {
  /// About 7%.
  low(QrErrorCorrectLevel.low),

  /// About 15%.
  medium(QrErrorCorrectLevel.medium),

  /// About 25%.
  quartile(QrErrorCorrectLevel.quartile),

  /// About 30%.
  high(QrErrorCorrectLevel.high);

  const Oito2QrErrorLevel(this._level);

  final QrErrorCorrectLevel _level;
}

/// The dark modules of the QR code of [data], as a square grid of
/// [moduleCount] rows: `modules[row][column]` is true for a dark module.
///
/// Throws an [ArgumentError] when [data] doesn't fit in a QR code at
/// [errorLevel].
({int moduleCount, List<List<bool>> modules}) oito2QrModules(
  String data, {
  Oito2QrErrorLevel errorLevel = Oito2QrErrorLevel.medium,
}) {
  final QrCode code;
  try {
    code = QrCode(
      payload: QrPayload.fromString(data),
      errorCorrectLevel: errorLevel._level,
    );
  } on InputTooLongException catch (e) {
    throw ArgumentError.value(data, 'data', '$e');
  }
  final image = QrImage(code);
  final count = image.moduleCount;
  return (
    moduleCount: count,
    modules: [
      for (var row = 0; row < count; row++)
        [for (var col = 0; col < count; col++) image.isDark(row, col)],
    ],
  );
}

/// A QR code of [data], painted in [color] on [backgroundColor] with the
/// standard four-module quiet zone.
///
/// The defaults are black on white, which every scanner reads; custom
/// colors need strong contrast with the dark color darker. A
/// [centerImage], such as a logo, covers the middle of the modules; the
/// error level is then [Oito2QrErrorLevel.high], which recovers the most
/// covered modules, so the code still reads. When [data] doesn't fit, [errorBuilder] or a
/// message shows instead.
class Oito2QrCode extends StatelessWidget {
  /// Creates a QR code.
  const Oito2QrCode({
    super.key,
    required this.data,
    this.size = 160,
    this.errorLevel = Oito2QrErrorLevel.medium,
    this.color = const Color(0xFF000000),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.roundedModules = false,
    this.centerImage,
    this.centerImageFraction = 0.22,
    this.semanticLabel,
    this.errorBuilder,
  }) : assert(centerImageFraction > 0 && centerImageFraction <= 0.3);

  /// The encoded text, such as a link.
  final String data;

  /// The width and height, quiet zone included.
  final double size;

  /// The error correction level.
  final Oito2QrErrorLevel errorLevel;

  /// The dark module color.
  final Color color;

  /// The light module and quiet zone color.
  final Color backgroundColor;

  /// Whether dark modules are drawn as rounded squares.
  final bool roundedModules;

  /// An image drawn in the middle, such as a logo.
  final ImageProvider? centerImage;

  /// The share of the code width the center image takes.
  final double centerImageFraction;

  /// The accessibility label; defaults to the localized "QR code".
  final String? semanticLabel;

  /// Builds what shows when [data] doesn't fit in a QR code.
  final WidgetBuilder? errorBuilder;

  /// The recently encoded codes, by data and level; null marks data that
  /// doesn't fit. Reusing them skips the encoding on rebuilds and keeps
  /// the module list identical, so the code isn't repainted.
  static final _cache =
      <
        (String, Oito2QrErrorLevel),
        ({int moduleCount, List<List<bool>> modules})?
      >{};

  static ({int moduleCount, List<List<bool>> modules})? _encode(
    String data,
    Oito2QrErrorLevel level,
  ) {
    final key = (data, level);
    if (_cache.containsKey(key)) return _cache[key];
    if (_cache.length >= 32) _cache.remove(_cache.keys.first);
    try {
      return _cache[key] = oito2QrModules(data, errorLevel: level);
    } on ArgumentError {
      return _cache[key] = null;
    }
  }

  /// The width of the modules, without the quiet zone, for [count]
  /// modules a side.
  double _moduleExtent(int count) =>
      size * count / (count + _QrPainter._quietZone * 2);

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final image = centerImage;
    final level = image != null ? Oito2QrErrorLevel.high : errorLevel;
    final qr = _encode(data, level);
    if (qr == null) {
      return errorBuilder?.call(context) ??
          SizedBox.square(
            dimension: size,
            child: Center(
              child: Text(strings.qrTooLong, textAlign: TextAlign.center),
            ),
          );
    }
    final code = CustomPaint(
      size: Size.square(size),
      painter: _QrPainter(
        modules: qr.modules,
        color: color,
        background: backgroundColor,
        rounded: roundedModules,
        hole: image == null ? 0 : centerImageFraction,
      ),
    );
    return Semantics(
      image: true,
      label: semanticLabel ?? strings.qrCode,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: image == null
            ? code
            : Stack(
                alignment: Alignment.center,
                children: [
                  code,
                  SizedBox.square(
                    dimension:
                        _moduleExtent(qr.moduleCount) *
                        centerImageFraction *
                        0.86,
                    child: Image(image: image, fit: BoxFit.contain),
                  ),
                ],
              ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter({
    required this.modules,
    required this.color,
    required this.background,
    required this.rounded,
    required this.hole,
  });

  final List<List<bool>> modules;
  final Color color;
  final Color background;
  final bool rounded;

  /// The share of the module area cleared in the middle for an image, or
  /// 0.
  final double hole;

  static const int _quietZone = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final count = modules.length;
    final unit = size.width / (count + _quietZone * 2);
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final center = size.center(Offset.zero);
    // The hole is a share of the modules, without the quiet zone around.
    final clear = hole == 0
        ? Rect.zero
        : Rect.fromCenter(
            center: center,
            width: unit * count * hole,
            height: unit * count * hole,
          );
    final path = Path();
    for (var row = 0; row < count; row++) {
      for (var col = 0; col < count; col++) {
        if (!modules[row][col]) continue;
        final rect = Rect.fromLTWH(
          (col + _quietZone) * unit,
          (row + _quietZone) * unit,
          unit,
          unit,
        );
        if (hole != 0 && clear.overlaps(rect.deflate(unit * 0.1))) continue;
        if (rounded) {
          path.addRRect(
            RRect.fromRectAndRadius(
              rect.deflate(unit * 0.06),
              Radius.circular(unit * 0.32),
            ),
          );
        } else {
          // Slightly larger squares hide hairline seams between modules.
          path.addRect(rect.inflate(0.25));
        }
      }
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_QrPainter old) =>
      old.modules != modules ||
      old.color != color ||
      old.background != background ||
      old.rounded != rounded ||
      old.hole != hole;
}
