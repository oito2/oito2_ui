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

import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2QrCode] for typed text, levels and styles.
class QrCodePage extends StatefulWidget {
  /// Creates the QR code page.
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  final _text = TextEditingController(
    text: 'https://oito2.github.io/oito2_ui/',
  );
  Oito2QrErrorLevel _level = Oito2QrErrorLevel.medium;
  bool _rounded = false;
  ImageProvider? _logo;

  @override
  void initState() {
    super.initState();
    _paintLogo().then((logo) {
      if (mounted) setState(() => _logo = logo);
    });
  }

  /// Paints a small round mark to place in the middle of a code.
  static Future<ImageProvider> _paintLogo() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..drawCircle(
        const Offset(48, 48),
        48,
        Paint()..color = const Color(0xFF3584E4),
      )
      ..drawCircle(
        const Offset(48, 32),
        14,
        Paint()..color = const Color(0xFFFFFFFF),
      )
      ..drawCircle(
        const Offset(48, 62),
        18,
        Paint()..color = const Color(0xFFFFFFFF),
      );
    final image = await recorder.endRecording().toImage(96, 96);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return MemoryImage(bytes!.buffer.asUint8List());
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Content and options',
          children: [
            SizedBox(
              width: 360,
              child: TextField(
                controller: _text,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Text or link'),
              ),
            ),
            SizedBox(
              width: 360,
              child: Oito2ChoiceChipBar(
                style: Oito2ChoiceChipBarStyle.wrap,
                labels: [
                  for (final level in Oito2QrErrorLevel.values)
                    Text(level.name),
                ],
                isSelected: [
                  for (final level in Oito2QrErrorLevel.values) level == _level,
                ],
                onSelected: (i) =>
                    setState(() => _level = Oito2QrErrorLevel.values[i]),
              ),
            ),
            Oito2CheckButton(
              value: _rounded,
              onChanged: (v) => setState(() => _rounded = v ?? false),
              title: const Text('Rounded modules'),
            ),
          ],
        ),
        ShowcaseSection(
          'Standard, themed and with a center icon',
          children: [
            Oito2QrCode(
              data: _text.text,
              errorLevel: _level,
              roundedModules: _rounded,
            ),
            Oito2QrCode(
              data: _text.text,
              errorLevel: _level,
              roundedModules: _rounded,
              color: scheme.onSurface,
              backgroundColor: scheme.surface,
            ),
            Oito2QrCode(
              data: _text.text,
              errorLevel: _level,
              roundedModules: _rounded,
              centerImage: _logo,
            ),
          ],
        ),
      ],
    );
  }
}
