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
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

/// A point of a signature stroke with the stroke width there.
typedef Oito2SignaturePoint = ({Offset position, double width});

/// The strokes of an [Oito2SignaturePad], with undo, clear and export.
///
/// Positions are in the pad's logical pixels; [size] is the pad size the
/// strokes were drawn in, which the exports use.
class Oito2SignatureController extends ChangeNotifier {
  final List<List<Oito2SignaturePoint>> _strokes = [];

  /// The size of the pad, updated as it lays out.
  Size size = Size.zero;

  /// The strokes, in drawing order; neither the list nor its strokes can
  /// be changed.
  List<List<Oito2SignaturePoint>> get strokes =>
      List.unmodifiable(_strokes.map(List<Oito2SignaturePoint>.unmodifiable));

  /// Whether nothing has been drawn.
  bool get isEmpty => _strokes.isEmpty;

  /// Removes the last stroke.
  void undo() {
    if (_strokes.isEmpty) return;
    _strokes.removeLast();
    notifyListeners();
  }

  /// Removes every stroke.
  void clear() {
    if (_strokes.isEmpty) return;
    _strokes.clear();
    notifyListeners();
  }

  /// Adds a whole [stroke], such as one of a saved signature.
  void addStroke(List<Oito2SignaturePoint> stroke) {
    if (stroke.isEmpty) return;
    _strokes.add(List.of(stroke));
    notifyListeners();
  }

  void _begin(Oito2SignaturePoint point) {
    _strokes.add([point]);
    notifyListeners();
  }

  void _extend(Oito2SignaturePoint point) {
    if (_strokes.isEmpty) return;
    _strokes.last.add(point);
    notifyListeners();
  }

  /// The strokes as an SVG document of [size] (the pad size by default),
  /// one path per stroke segment so the width can vary.
  String toSvg({Size? size, Color color = const Color(0xFF000000)}) {
    final s = size ?? this.size;
    String n(double v) => v.toStringAsFixed(1);
    final hex =
        '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final buffer = StringBuffer(
      '<svg xmlns="http://www.w3.org/2000/svg" width="${n(s.width)}" '
      'height="${n(s.height)}" viewBox="0 0 ${n(s.width)} ${n(s.height)}">',
    );
    buffer.write(
      '<g fill="none" stroke="$hex" stroke-linecap="round" '
      'stroke-linejoin="round">',
    );
    for (final stroke in _strokes) {
      if (stroke.length == 1) {
        final p = stroke.first;
        buffer.write(
          '<circle cx="${n(p.position.dx)}" cy="${n(p.position.dy)}" '
          'r="${n(p.width / 2)}" fill="$hex" stroke="none"/>',
        );
        continue;
      }
      for (var i = 1; i < stroke.length; i++) {
        final a = stroke[i - 1];
        final b = stroke[i];
        buffer.write(
          '<path d="M${n(a.position.dx)} ${n(a.position.dy)}'
          'L${n(b.position.dx)} ${n(b.position.dy)}" '
          'stroke-width="${n((a.width + b.width) / 2)}"/>',
        );
      }
    }
    buffer.write('</g></svg>');
    return buffer.toString();
  }

  /// Renders the strokes in [color] on a transparent background, at
  /// [pixelRatio] physical pixels per logical pixel.
  Future<ui.Image> toImage({
    Color color = const Color(0xFF000000),
    double pixelRatio = 2,
  }) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    _paintStrokes(canvas, _strokes, color);
    final picture = recorder.endRecording();
    final image = picture.toImage(
      math.max(1, (size.width * pixelRatio).ceil()),
      math.max(1, (size.height * pixelRatio).ceil()),
    );
    picture.dispose();
    return image;
  }

  /// The strokes as PNG bytes; see [toImage].
  Future<Uint8List?> toPngBytes({
    Color color = const Color(0xFF000000),
    double pixelRatio = 2,
  }) async {
    final image = await toImage(color: color, pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}

/// Paints [strokes] in [color]: round dots joined by segments whose width
/// moves from one point's width to the next.
void _paintStrokes(
  Canvas canvas,
  List<List<Oito2SignaturePoint>> strokes,
  Color color,
) {
  final fill = Paint()..color = color;
  final line = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  for (final stroke in strokes) {
    if (stroke.length == 1) {
      canvas.drawCircle(stroke.first.position, stroke.first.width / 2, fill);
      continue;
    }
    for (var i = 1; i < stroke.length; i++) {
      final a = stroke[i - 1];
      final b = stroke[i];
      canvas.drawLine(
        a.position,
        b.position,
        line..strokeWidth = (a.width + b.width) / 2,
      );
    }
  }
}

/// An area to sign with a pointer, finger or pen.
///
/// Strokes get thinner as the pointer moves faster, between [minWidth]
/// and [maxWidth], like ink. A stylus' pressure, when reported, makes
/// them wider. With [showActions] undo and clear buttons sit in a corner.
/// Assistive technologies hear whether the pad is empty or signed.
class Oito2SignaturePad extends StatefulWidget {
  /// Creates a signature pad.
  const Oito2SignaturePad({
    super.key,
    required this.controller,
    this.height = 180,
    this.color,
    this.minWidth = 1.2,
    this.maxWidth = 3.6,
    this.showActions = true,
    this.placeholder,
    this.semanticLabel,
  }) : assert(minWidth > 0 && maxWidth >= minWidth);

  /// The strokes.
  final Oito2SignatureController controller;

  /// The pad height; it takes the available width.
  final double height;

  /// The ink color; defaults to the theme's text color.
  final Color? color;

  /// The thinnest stroke.
  final double minWidth;

  /// The thickest stroke.
  final double maxWidth;

  /// Whether undo and clear buttons show.
  final bool showActions;

  /// The text shown on the empty pad; defaults to the localized "Sign
  /// here".
  final String? placeholder;

  /// The accessibility label; defaults to the localized "Signature".
  final String? semanticLabel;

  @override
  State<Oito2SignaturePad> createState() => _Oito2SignaturePadState();
}

class _Oito2SignaturePadState extends State<Oito2SignaturePad> {
  Offset? _last;
  Duration? _lastTime;
  double _width = 0;

  Oito2SignatureController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _wasEmpty = _controller.isEmpty;
    _controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(Oito2SignaturePad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
      _wasEmpty = widget.controller.isEmpty;
      _pointer = null;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    super.dispose();
  }

  late bool _wasEmpty;

  /// Rebuilds only when the pad turns empty or signed; the painter
  /// repaints the strokes by itself.
  void _refresh() {
    if (mounted && _controller.isEmpty != _wasEmpty) {
      setState(() => _wasEmpty = _controller.isEmpty);
    }
  }

  /// The pointer drawing the current stroke; others are ignored until it
  /// lifts.
  int? _pointer;

  double _pressureWidth(PointerEvent event) {
    final range = event.pressureMax - event.pressureMin;
    if (range <= 0 || event.kind != ui.PointerDeviceKind.stylus) return 1;
    return 0.6 + 0.8 * ((event.pressure - event.pressureMin) / range);
  }

  void _down(PointerDownEvent event) {
    if (_pointer != null) return;
    if (event.kind == ui.PointerDeviceKind.mouse &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    _pointer = event.pointer;
    _last = event.localPosition;
    _lastTime = event.timeStamp;
    _width = (widget.minWidth + widget.maxWidth) / 2;
    _controller._begin((
      position: event.localPosition,
      width: _width * _pressureWidth(event),
    ));
  }

  void _move(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    final last = _last;
    final lastTime = _lastTime;
    if (last == null || lastTime == null) return;
    final distance = (event.localPosition - last).distance;
    if (distance < 1) return;
    final ms = math.max(1, (event.timeStamp - lastTime).inMilliseconds);
    final speed = distance / ms;
    // Faster strokes are thinner; the width eases toward its target so it
    // doesn't jump between points.
    final target = (widget.maxWidth - speed * 1.2).clamp(
      widget.minWidth,
      widget.maxWidth,
    );
    _width = _width * 0.6 + target * 0.4;
    _last = event.localPosition;
    _lastTime = event.timeStamp;
    _controller._extend((
      position: event.localPosition,
      width: _width * _pressureWidth(event),
    ));
  }

  void _up(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    _last = null;
    _lastTime = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final ink = widget.color ?? scheme.onSurface;
    final empty = _controller.isEmpty;
    return Semantics(
      container: true,
      label: widget.semanticLabel ?? strings.signature,
      value: empty ? strings.empty : strings.signed,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color:
              theme.inputDecorationTheme.fillColor ??
              scheme.surfaceContainerHigh,
          borderRadius: Oito2Radius.mediumAll,
          border: Border.all(color: scheme.outline),
        ),
        child: ClipRRect(
          borderRadius: Oito2Radius.mediumAll,
          child: Stack(
            children: [
              if (empty)
                Center(
                  child: ExcludeSemantics(
                    child: Text(
                      widget.placeholder ?? strings.signHere,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              PositionedDirectional(
                start: Oito2Spacing.lg,
                end: Oito2Spacing.lg,
                bottom: Oito2Spacing.xl,
                child: Container(height: 1, color: scheme.outlineVariant),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _controller.size = constraints.biggest;
                    return Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: _down,
                      onPointerMove: _move,
                      onPointerUp: _up,
                      onPointerCancel: _up,
                      // Wins the gesture arena at once, so a scroll view
                      // around the pad doesn't take the stroke.
                      child: RawGestureDetector(
                        behavior: HitTestBehavior.opaque,
                        gestures: {
                          _ClaimRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                _ClaimRecognizer
                              >(_ClaimRecognizer.new, (_) {}),
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.precise,
                          child: CustomPaint(
                            painter: _SignaturePainter(_controller, ink),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (widget.showActions)
                PositionedDirectional(
                  top: Oito2Spacing.xs,
                  end: Oito2Spacing.xs,
                  child: Row(
                    children: [
                      Oito2IconButton(
                        tooltip: strings.undo,
                        onPressed: empty ? null : _controller.undo,
                        icon: const Icon(LucideIcons.undo_2),
                      ),
                      Oito2IconButton(
                        tooltip: strings.clear,
                        onPressed: empty ? null : _controller.clear,
                        icon: const Icon(LucideIcons.eraser),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the strokes of [controller], repainting whenever it changes.
class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.controller, this.color) : super(repaint: controller);

  final Oito2SignatureController controller;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) =>
      _paintStrokes(canvas, controller._strokes, color);

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.controller != controller || old.color != color;
}

/// Joins the gesture arena on pointer down and wins it at once, so no
/// other recognizer, such as a scroll view's, takes the pointer.
class _ClaimRecognizer extends OneSequenceGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'signature claim';
}
