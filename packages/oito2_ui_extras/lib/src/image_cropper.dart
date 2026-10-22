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
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

/// The zoom, pan, rotation and flip of an [Oito2ImageCropper], and the
/// crop itself.
///
/// The pan is in the crop box's logical pixels and is kept so the image
/// always covers the box.
class Oito2CropController extends ChangeNotifier {
  /// Creates a crop controller.
  Oito2CropController({this.maxZoom = 5}) : assert(maxZoom >= 1);

  /// The largest zoom, as a multiple of the zoom that just covers the box.
  final double maxZoom;

  ui.Image? _image;
  Size _box = Size.zero;
  double _zoom = 1;
  Offset _offset = Offset.zero;
  int _quarterTurns = 0;
  bool _flipped = false;

  /// The loaded image, or null while it loads.
  ui.Image? get image => _image;

  /// The zoom, from 1 (the image just covers the box) to [maxZoom].
  double get zoom => _zoom;

  /// The pan of the image center from the box center.
  Offset get offset => _offset;

  /// The clockwise quarter turns, from 0 to 3.
  int get quarterTurns => _quarterTurns;

  /// Whether the image is mirrored horizontally.
  bool get flipped => _flipped;

  /// The crop box size in logical pixels, set by the cropper's layout.
  Size get boxSize => _box;

  /// Sets the zoom.
  set zoom(double value) {
    final next = value.clamp(1.0, maxZoom);
    if (next == _zoom) return;
    _zoom = next;
    _clampOffset();
    notifyListeners();
  }

  /// Multiplies the zoom by [factor].
  void zoomBy(double factor) => zoom = _zoom * factor;

  /// Moves the image by [delta].
  void panBy(Offset delta) {
    _offset += delta;
    _clampOffset();
    notifyListeners();
  }

  /// Turns the image a quarter clockwise.
  void rotateRight() => _turn(1);

  /// Turns the image a quarter counterclockwise.
  void rotateLeft() => _turn(3);

  void _turn(int turns) {
    _quarterTurns = (_quarterTurns + turns) % 4;
    _offset = Offset(-_offset.dy, _offset.dx) * (turns == 1 ? 1 : -1);
    _clampOffset();
    notifyListeners();
  }

  /// Mirrors the image horizontally.
  void flipHorizontally() {
    _flipped = !_flipped;
    _offset = Offset(-_offset.dx, _offset.dy);
    notifyListeners();
  }

  /// Restores the zoom, pan, rotation and flip.
  void reset() {
    _resetTransform();
    notifyListeners();
  }

  void _resetTransform() {
    _zoom = 1;
    _offset = Offset.zero;
    _quarterTurns = 0;
    _flipped = false;
  }

  /// Holds a handle of its own to [image], so crops and previews keep
  /// working after the cropper that loaded it is gone. With [reset], the
  /// zoom, pan, rotation and flip start over, as for a new picture.
  void _setImage(ui.Image? image, {bool reset = false}) {
    _image?.dispose();
    _image = image?.clone();
    if (reset) _resetTransform();
    _clampOffset();
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _image?.dispose();
    _image = null;
    super.dispose();
  }

  /// Sets the crop box size measured during layout, and tells listeners
  /// such as [Oito2CropPreview] after the frame, outside of the build.
  void _setBox(Size box) {
    if (box == _box) return;
    _box = box;
    _clampOffset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  Size get _turnedImage {
    final image = _image!;
    final w = image.width.toDouble();
    final h = image.height.toDouble();
    return _quarterTurns.isOdd ? Size(h, w) : Size(w, h);
  }

  double get _scale {
    final turned = _turnedImage;
    final cover = math.max(
      _box.width / turned.width,
      _box.height / turned.height,
    );
    return cover * _zoom;
  }

  void _clampOffset() {
    if (_image == null || _box.isEmpty) return;
    final turned = _turnedImage * _scale;
    final maxX = math.max(0.0, (turned.width - _box.width) / 2);
    final maxY = math.max(0.0, (turned.height - _box.height) / 2);
    _offset = Offset(
      _offset.dx.clamp(-maxX, maxX),
      _offset.dy.clamp(-maxY, maxY),
    );
  }

  /// Paints the image as it shows in a crop box of [boxSize] at the
  /// canvas origin.
  void paintCrop(Canvas canvas) {
    final image = _image;
    if (image == null || _box.isEmpty) return;
    canvas
      ..save()
      ..translate(_box.width / 2 + _offset.dx, _box.height / 2 + _offset.dy)
      ..scale(_scale);
    if (_flipped) canvas.scale(-1, 1);
    canvas
      ..rotate(_quarterTurns * math.pi / 2)
      ..drawImage(
        image,
        Offset(-image.width / 2, -image.height / 2),
        Paint()..filterQuality = FilterQuality.medium,
      )
      ..restore();
  }

  /// The cropped image at the image's own resolution, or [width] pixels
  /// wide when given, cut to a circle when [circle] is set; null before
  /// the image loads.
  Future<ui.Image?> crop({double? width, bool circle = false}) async {
    if (_image == null || _box.isEmpty) return null;
    final ratio = width != null ? width / _box.width : 1 / _scale;
    final size = Size(
      math.max(1, (_box.width * ratio).roundToDouble()),
      math.max(1, (_box.height * ratio).roundToDouble()),
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(size.width / _box.width);
    if (circle) canvas.clipPath(Path()..addOval(Offset.zero & _box));
    paintCrop(canvas);
    final picture = recorder.endRecording();
    final result = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    picture.dispose();
    return result;
  }
}

/// Crops [image]: the user zooms and pans it under a crop box of
/// [aspectRatio], rotates it by quarter turns and flips it, and the app
/// reads the result from [controller].
///
/// The image moves by dragging and zooms by pinching, the mouse wheel or
/// the toolbar. With the focus on the crop area the arrow keys pan (more
/// with Shift), plus and minus zoom, R rotates (Shift+R the other way)
/// and H flips. With [circle] the box is a circle. [Oito2CropPreview]
/// shows the result live.
class Oito2ImageCropper extends StatefulWidget {
  /// Creates an image cropper.
  const Oito2ImageCropper({
    super.key,
    required this.image,
    required this.controller,
    this.aspectRatio = 1,
    this.circle = false,
    this.height = 320,
    this.showToolbar = true,
    this.semanticLabel,
    this.maxDecodedDimension = 4096,
    this.onError,
  }) : assert(aspectRatio > 0),
       assert(maxDecodedDimension == null || maxDecodedDimension > 0);

  /// The image to crop.
  final ImageProvider image;

  /// The crop state.
  final Oito2CropController controller;

  /// The crop box width divided by its height; 1 with [circle].
  final double aspectRatio;

  /// Whether the crop box is a circle.
  final bool circle;

  /// The height of the crop area.
  final double height;

  /// Whether the zoom, rotate, flip and reset controls show.
  final bool showToolbar;

  /// The accessibility label; defaults to the localized "Image cropper".
  final String? semanticLabel;

  /// The longest side, in pixels, the image is decoded at; larger images
  /// are scaled down while decoding, keeping their aspect ratio, to bound
  /// the memory they take. Null decodes at full size.
  final int? maxDecodedDimension;

  /// Called when the image fails to load; without it the error is
  /// reported through [FlutterError.reportError].
  final void Function(Object error, StackTrace? stackTrace)? onError;

  @override
  State<Oito2ImageCropper> createState() => _Oito2ImageCropperState();
}

class _Oito2ImageCropperState extends State<Oito2ImageCropper> {
  final _focusNode = FocusNode(debugLabel: 'Oito2ImageCropper');
  ImageStream? _stream;
  ImageInfo? _info;
  late final _listener = ImageStreamListener(_onImage, onError: _onError);
  double _startZoom = 1;

  Oito2CropController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(Oito2ImageCropper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
      oldWidget.controller._setImage(null);
      widget.controller._setImage(_info?.image);
    }
    if (oldWidget.image != widget.image) _newPicture = true;
    if (oldWidget.image != widget.image ||
        oldWidget.maxDecodedDimension != widget.maxDecodedDimension) {
      _resolve();
    }
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _info?.dispose();
    _controller.removeListener(_refresh);
    _focusNode.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _resolve() {
    final max = widget.maxDecodedDimension;
    final provider = max == null
        ? widget.image
        : ResizeImage(
            widget.image,
            width: max,
            height: max,
            policy: ResizeImagePolicy.fit,
          );
    final stream = provider.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  /// Whether the next image loaded is a different picture, which starts
  /// with the transform reset.
  bool _newPicture = false;

  void _onImage(ImageInfo info, bool _) {
    _info?.dispose();
    _info = info;
    _controller._setImage(info.image, reset: _newPicture);
    _newPicture = false;
  }

  void _onError(Object error, StackTrace? stackTrace) {
    final onError = widget.onError;
    if (onError != null) {
      onError(error, stackTrace);
      return;
    }
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'oito2_ui_extras',
        context: ErrorDescription('while loading the image to crop'),
      ),
    );
  }

  double get _aspect => widget.circle ? 1 : widget.aspectRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final area = LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, widget.height);
        final room = Size(
          math.max(1, viewport.width - Oito2Spacing.xl * 2),
          math.max(1, viewport.height - Oito2Spacing.xl * 2),
        );
        final box = room.width / room.height > _aspect
            ? Size(room.height * _aspect, room.height)
            : Size(room.width, room.width / _aspect);
        _controller._setBox(box);
        final boxRect = Alignment.center.inscribe(box, Offset.zero & viewport);
        return Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              GestureBinding.instance.pointerSignalResolver.register(
                event,
                (_) => _controller.zoomBy(
                  math.pow(1.0015, -event.scrollDelta.dy).toDouble(),
                ),
              );
            }
          },
          child: GestureDetector(
            onScaleStart: (_) {
              _focusNode.requestFocus();
              _startZoom = _controller.zoom;
            },
            onScaleUpdate: (details) {
              _controller.panBy(details.focalPointDelta);
              if (details.scale != 1) {
                _controller.zoom = _startZoom * details.scale;
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.move,
              child: ClipRect(
                child: CustomPaint(
                  size: viewport,
                  painter: _CropPainter(
                    controller: _controller,
                    box: boxRect,
                    circle: widget.circle,
                    scrim: scheme.scrim.withValues(alpha: 0.55),
                    border: const Color(0xFFFFFFFF),
                    background: scheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    final keyed = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _controller.panBy(const Offset(8, 0)),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _controller.panBy(const Offset(-8, 0)),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _controller.panBy(const Offset(0, 8)),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _controller.panBy(const Offset(0, -8)),
        const SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true): () =>
            _controller.panBy(const Offset(32, 0)),
        const SingleActivator(LogicalKeyboardKey.arrowRight, shift: true): () =>
            _controller.panBy(const Offset(-32, 0)),
        const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true): () =>
            _controller.panBy(const Offset(0, 32)),
        const SingleActivator(LogicalKeyboardKey.arrowDown, shift: true): () =>
            _controller.panBy(const Offset(0, -32)),
        const CharacterActivator('+'): () => _controller.zoomBy(1.1),
        const CharacterActivator('='): () => _controller.zoomBy(1.1),
        const CharacterActivator('-'): () => _controller.zoomBy(1 / 1.1),
        const CharacterActivator('r'): _controller.rotateRight,
        const CharacterActivator('R'): _controller.rotateLeft,
        const CharacterActivator('h'): _controller.flipHorizontally,
      },
      child: Oito2FocusBorder(
        child: Focus(
          focusNode: _focusNode,
          child: Semantics(
            label: widget.semanticLabel ?? strings.imageCropper,
            value: '${(_controller.zoom * 100).round()}%',
            child: area,
          ),
        ),
      ),
    );
    if (!widget.showToolbar) return keyed;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Oito2Spacing.sm,
      children: [
        keyed,
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Oito2Spacing.xs,
          children: [
            Oito2IconButton(
              tooltip: strings.zoomOut,
              onPressed: () => _controller.zoomBy(1 / 1.2),
              icon: const Icon(LucideIcons.zoom_out),
            ),
            SizedBox(
              width: 140,
              child: Slider(
                value: _controller.zoom,
                min: 1,
                max: _controller.maxZoom,
                label: '${(_controller.zoom * 100).round()}%',
                onChanged: (v) => _controller.zoom = v,
              ),
            ),
            Oito2IconButton(
              tooltip: strings.zoomIn,
              onPressed: () => _controller.zoomBy(1.2),
              icon: const Icon(LucideIcons.zoom_in),
            ),
            Oito2IconButton(
              tooltip: strings.rotateLeft,
              onPressed: _controller.rotateLeft,
              icon: const Icon(LucideIcons.rotate_ccw),
            ),
            Oito2IconButton(
              tooltip: strings.rotateRight,
              onPressed: _controller.rotateRight,
              icon: const Icon(LucideIcons.rotate_cw),
            ),
            Oito2IconButton(
              tooltip: strings.flipHorizontally,
              isSelected: _controller.flipped,
              onPressed: _controller.flipHorizontally,
              icon: const Icon(LucideIcons.arrow_left_right),
            ),
            Oito2IconButton(
              tooltip: strings.reset,
              onPressed: _controller.reset,
              icon: const Icon(LucideIcons.refresh_ccw),
            ),
          ],
        ),
      ],
    );
  }
}

class _CropPainter extends CustomPainter {
  _CropPainter({
    required this.controller,
    required this.box,
    required this.circle,
    required this.scrim,
    required this.border,
    required this.background,
  }) : super(repaint: controller);

  final Oito2CropController controller;
  final Rect box;
  final bool circle;
  final Color scrim;
  final Color border;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = Offset.zero & size;
    canvas.drawRect(viewport, Paint()..color = background);
    canvas
      ..save()
      ..translate(box.left, box.top);
    controller.paintCrop(canvas);
    canvas.restore();
    final hole = Path();
    circle ? hole.addOval(box) : hole.addRect(box);
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(viewport), hole),
      Paint()..color = scrim,
    );
    final line = Paint()
      ..color = border.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    if (!circle) {
      for (var i = 1; i < 3; i++) {
        final x = box.left + box.width * i / 3;
        final y = box.top + box.height * i / 3;
        canvas
          ..drawLine(Offset(x, box.top), Offset(x, box.bottom), line)
          ..drawLine(Offset(box.left, y), Offset(box.right, y), line);
      }
    }
    canvas.drawPath(
      hole,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.box != box ||
      old.circle != circle ||
      old.scrim != scrim ||
      old.border != border ||
      old.background != background ||
      old.controller != controller;
}

/// The current crop of an [Oito2CropController] at [width], updated as
/// the user zooms, pans, rotates and flips.
class Oito2CropPreview extends StatelessWidget {
  /// Creates a crop preview.
  const Oito2CropPreview({
    super.key,
    required this.controller,
    this.width = 96,
    this.circle = false,
  });

  /// The crop state.
  final Oito2CropController controller;

  /// The preview width; the height follows the crop box.
  final double width;

  /// Whether the preview is cut to a circle.
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final box = controller.boxSize;
        final height = box.isEmpty ? width : width * box.height / box.width;
        final preview = CustomPaint(
          size: Size(width, height),
          painter: _PreviewPainter(controller),
        );
        return ExcludeSemantics(
          child: circle
              ? ClipOval(child: preview)
              : ClipRRect(borderRadius: Oito2Radius.mediumAll, child: preview),
        );
      },
    );
  }
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.controller) : super(repaint: controller);

  final Oito2CropController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final box = controller.boxSize;
    if (box.isEmpty) return;
    canvas.scale(size.width / box.width);
    controller.paintCrop(canvas);
  }

  @override
  bool shouldRepaint(_PreviewPainter old) => old.controller != controller;
}
