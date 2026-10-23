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
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2ImageCropper], [Oito2CropController] and
/// [Oito2CropPreview]: zoom, pan, rotation, a circle crop, a live preview
/// and the cropped result.
class ImageCropperPage extends StatefulWidget {
  /// Creates the image cropper page.
  const ImageCropperPage({super.key});

  @override
  State<ImageCropperPage> createState() => _ImageCropperPageState();
}

class _ImageCropperPageState extends State<ImageCropperPage> {
  final _previewController = Oito2CropController();
  final _controller = Oito2CropController();
  final _plainController = Oito2CropController(maxZoom: 3);
  ImageProvider? _image;
  bool _circle = false;
  ui.Image? _result;

  @override
  void initState() {
    super.initState();
    _paintSample().then((image) {
      if (mounted) setState(() => _image = image);
    });
  }

  @override
  void dispose() {
    _previewController.dispose();
    _controller.dispose();
    _plainController.dispose();
    _result?.dispose();
    super.dispose();
  }

  /// Paints a landscape picture to crop, so the page needs no asset.
  static Future<ImageProvider> _paintSample() async {
    const size = Size(960, 640);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final sky = Offset.zero & size;
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C71D8), Color(0xFFF6D32D)],
        ).createShader(sky),
    );
    canvas.drawCircle(
      const Offset(700, 220),
      90,
      Paint()..color = const Color(0xFFFFF5C0),
    );
    for (var i = 0; i < 3; i++) {
      final path = Path()..moveTo(0, size.height);
      for (var x = 0.0; x <= size.width; x += 20) {
        path.lineTo(x, 420 + i * 70 + math.sin(x / (90 + i * 40)) * 60);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = const [
            Color(0xFF26A269),
            Color(0xFF2EC27E),
            Color(0xFF1A5FB4),
          ][i],
      );
    }
    final image = await recorder.endRecording().toImage(960, 640);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return MemoryImage(bytes!.buffer.asUint8List());
  }

  // #region crop-method
  /// Crops the image to a 240-pixel-wide result, replacing and disposing
  /// the previous one.
  Future<void> _crop() async {
    final image = await _controller.crop(width: 240, circle: _circle);
    if (!mounted) return;
    setState(() {
      _result?.dispose();
      _result = image;
    });
  }
  // #endregion

  /// Shows a spinner of the cropper's default height while the sample
  /// image is painted, and [builder] with the image once it is ready.
  Widget _whenLoaded(Widget Function(ImageProvider image) builder) {
    final image = _image;
    if (image == null) {
      return const SizedBox(
        height: 320,
        child: Center(child: Oito2CircularProgressIndicator()),
      );
    }
    return builder(image);
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Image Cropper',
      description:
          'Zooms, pans, rotates and flips an image under a crop box, and '
          'returns the cropped part as an image.',
      source: 'lib/src/pages/image_cropper_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 400,
            child: _whenLoaded(
              (image) =>
                  // #region preview
                  Oito2ImageCropper(
                    image: image,
                    controller: _previewController,
                    aspectRatio: 4 / 3,
                  ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give the cropper an `ImageProvider` and an `Oito2CropController`, '
          'and dispose the controller with its owner. The controller holds '
          'the `zoom`, from 1, where the image just covers the box, to '
          '`maxZoom` (5 by default), the pan, the quarter turns and the '
          'flip; the image always covers the box. Call `crop` on it to get '
          'the result.',
        ),
        const DocCode("import 'package:oito2_ui_extras/oito2_ui_extras.dart';"),
        const DocText(
          'The crop box has the `aspectRatio` (width over height, 1 by '
          'default) and fits the crop area, which takes the available width '
          'and `height` pixels, 320 by default. Drag to move the image, and '
          'pinch or scroll the mouse wheel to zoom. A new picture starts '
          'with the transform reset. Images are decoded at most '
          '`maxDecodedDimension` pixels on their longest side, 4096 by '
          'default, and a load failure goes to `onError`, or to '
          '`FlutterError.reportError` without it.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Circle, live preview and crop', level: 3),
        const DocText(
          'With `circle` the crop box is a circle and `aspectRatio` is '
          'ignored. `Oito2CropPreview` shows the crop of a controller at '
          '`width`, updated as the user moves the image. `crop` returns the '
          'cropped image at the decoded resolution, or `width` pixels wide, '
          'cut to a circle with `circle`; it returns null before the image '
          'loads, and the caller must dispose the image.',
        ),
        ExamplePanel(
          regions: const ['circle', 'crop-method'],
          child: SizedBox(
            width: 400,
            // #region circle
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                Oito2CheckButton(
                  value: _circle,
                  onChanged: (v) => setState(() => _circle = v ?? false),
                  title: const Text('Circle'),
                ),
                _whenLoaded(
                  (image) => Oito2ImageCropper(
                    image: image,
                    controller: _controller,
                    circle: _circle,
                    aspectRatio: 4 / 3,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: Oito2Spacing.md,
                  runSpacing: Oito2Spacing.sm,
                  children: [
                    Oito2CropPreview(
                      controller: _controller,
                      width: 120,
                      circle: _circle,
                    ),
                    FilledButton(onPressed: _crop, child: const Text('Crop')),
                    if (_result != null)
                      RawImage(image: _result, width: 120, fit: BoxFit.contain),
                  ],
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Without the toolbar', level: 3),
        const DocText(
          'The toolbar under the crop area zooms, rotates, flips and resets. '
          'With `showToolbar: false` only the crop area shows, and the app '
          'drives the controller itself: `zoomBy`, `panBy`, `rotateLeft`, '
          '`rotateRight`, `flipHorizontally` and `reset`. Here `maxZoom` '
          'is 3.',
        ),
        ExamplePanel(
          region: 'plain',
          child: SizedBox(
            width: 400,
            // #region plain
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                _whenLoaded(
                  (image) => Oito2ImageCropper(
                    image: image,
                    controller: _plainController,
                    height: 240,
                    showToolbar: false,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: Oito2Spacing.sm,
                  runSpacing: Oito2Spacing.sm,
                  children: [
                    OutlinedButton(
                      onPressed: () => _plainController.zoomBy(1.5),
                      child: const Text('Zoom in'),
                    ),
                    OutlinedButton(
                      onPressed: _plainController.rotateRight,
                      child: const Text('Rotate'),
                    ),
                    OutlinedButton(
                      onPressed: _plainController.reset,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The crop area takes the keyboard focus, showing the focus ring, '
          'and is labeled by `semanticLabel` ("Image cropper" by default) '
          'with the zoom percentage as its value. The toolbar buttons are '
          'labeled by their tooltips. `Oito2CropPreview` is hidden from '
          'assistive technologies.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the crop area.'],
            ['Arrow keys', 'Move the image by 8 pixels.'],
            ['`Shift` + arrow keys', 'Move the image by 32 pixels.'],
            ['`+` / `=`', 'Zooms in by 10%.'],
            ['`-`', 'Zooms out by 10%.'],
            ['`R`', 'Turns the image a quarter clockwise.'],
            ['`Shift` + `R`', 'Turns the image a quarter counterclockwise.'],
            ['`H`', 'Flips the image horizontally.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2ImageCropper',
          'Oito2CropController',
          'Oito2CropPreview',
        ]),
      ],
    );
  }
}
