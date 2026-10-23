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

import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2QrCode]: typed content, error levels, module styles,
/// colors and a center image.
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
    return DocPage(
      title: 'QR Code',
      description:
          'Draws a QR code of a text or link, with a choice of error '
          'correction, module shape, colors and a center logo.',
      source: 'lib/src/pages/qr_code_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2QrCode(data: 'https://oito2.github.io/oito2_ui/'),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2QrCode` the `data` to encode. It paints a square of '
          '`size` pixels, 160 by default, with the standard four-module '
          'quiet zone included. The code is encoded again only when the '
          'data or the error level changes.',
        ),
        const DocCode("import 'package:oito2_ui_extras/oito2_ui_extras.dart';"),
        const DocNote(
          'The default black on white is what every scanner reads. Custom '
          'colors need strong contrast, with `color` darker than '
          '`backgroundColor`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Content, level and modules', level: 3),
        const DocText(
          '`errorLevel` sets how much of the code can be damaged or covered '
          'and still read: `low` about 7%, `medium` (the default) about '
          '15%, `quartile` about 25% and `high` about 30%. Higher levels '
          'take more modules. `roundedModules` draws the dark modules as '
          'rounded squares.',
        ),
        ExamplePanel(
          region: 'options',
          child: SizedBox(
            width: 360,
            child: Column(
              spacing: Oito2Spacing.md,
              children: [
                TextField(
                  controller: _text,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Text or link'),
                ),
                Oito2ChoiceChipBar(
                  style: Oito2ChoiceChipBarStyle.wrap,
                  labels: [
                    for (final level in Oito2QrErrorLevel.values)
                      Text(level.name),
                  ],
                  isSelected: [
                    for (final level in Oito2QrErrorLevel.values)
                      level == _level,
                  ],
                  onSelected: (i) =>
                      setState(() => _level = Oito2QrErrorLevel.values[i]),
                ),
                Oito2CheckButton(
                  value: _rounded,
                  onChanged: (v) => setState(() => _rounded = v ?? false),
                  title: const Text('Rounded modules'),
                ),
                // #region options
                Oito2QrCode(
                  data: _text.text,
                  errorLevel: _level,
                  roundedModules: _rounded,
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Colors', level: 3),
        const DocText(
          '`color` paints the dark modules and `backgroundColor` the light '
          'modules and the quiet zone.',
        ),
        ExamplePanel(
          region: 'colors',
          // #region colors
          child: Oito2QrCode(
            data: _text.text,
            errorLevel: _level,
            roundedModules: _rounded,
            color: const Color(0xFF1A3A6B),
            backgroundColor: const Color(0xFFF1F5FB),
          ),
          // #endregion
        ),
        const DocHeading('Center image', level: 3),
        const DocText(
          'A `centerImage`, such as a logo, covers the middle of the '
          'modules, a `centerImageFraction` of their width (0.22 by '
          'default, at most 0.3). The error level is then always `high`, '
          'which recovers the most covered modules, so the code still '
          'reads.',
        ),
        ExamplePanel(
          region: 'image',
          // #region image
          child: Oito2QrCode(
            data: _text.text,
            roundedModules: _rounded,
            centerImage: _logo,
          ),
          // #endregion
        ),
        const DocHeading('Data that doesn\'t fit', level: 3),
        const DocText(
          'When the data is too long for a QR code at the chosen level, a '
          'localized message shows in its place, or what `errorBuilder` '
          'builds.',
        ),
        ExamplePanel(
          region: 'error',
          // #region error
          child: Oito2QrCode(
            data: 'oito2 ' * 600,
            errorBuilder: (context) => const SizedBox.square(
              dimension: 160,
              child: Center(child: Text('Too long to encode')),
            ),
          ),
          // #endregion
        ),
        const DocHeading('Modules only', level: 3),
        const DocText(
          '`oito2QrModules` returns the module grid of a text without '
          'painting it, for exporting a code or drawing it another way. '
          'It throws an `ArgumentError` when the data doesn\'t fit.',
        ),
        const DocCode('''
final qr = oito2QrModules('oito2', errorLevel: Oito2QrErrorLevel.high);
for (final row in qr.modules) {
  print(row.map((dark) => dark ? '#' : ' ').join());
}'''),
        const DocHeading('Accessibility'),
        const DocText(
          'The code is a single image for assistive technologies, labeled '
          'with `semanticLabel`, by default the localized "QR code". Name '
          'what it leads to when the data isn\'t shown next to it.',
        ),
        ...apiReferenceWidgets([
          'Oito2QrCode',
          'Oito2QrErrorLevel',
          'oito2QrModules',
        ]),
      ],
    );
  }
}
