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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2ImageCropper] with a live preview and the cropped result.
class ImageCropperPage extends StatefulWidget {
  /// Creates the image cropper page.
  const ImageCropperPage({super.key});

  @override
  State<ImageCropperPage> createState() => _ImageCropperPageState();
}

class _ImageCropperPageState extends State<ImageCropperPage> {
  final _controller = Oito2CropController();
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
    _controller.dispose();
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

  Future<void> _crop() async {
    final image = await _controller.crop(width: 240, circle: _circle);
    if (!mounted) return;
    setState(() {
      _result?.dispose();
      _result = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Drag to move, wheel or pinch to zoom; focus it for the keys',
          children: [
            Oito2CheckButton(
              value: _circle,
              onChanged: (v) => setState(() => _circle = v ?? false),
              title: const Text('Circle'),
            ),
            SizedBox(
              width: 520,
              child: image == null
                  ? const SizedBox(
                      height: 320,
                      child: Center(child: Oito2CircularProgressIndicator()),
                    )
                  : Oito2ImageCropper(
                      image: image,
                      controller: _controller,
                      circle: _circle,
                      aspectRatio: 4 / 3,
                    ),
            ),
          ],
        ),
        ShowcaseSection(
          'Live preview and crop',
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
    );
  }
}
