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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2SignaturePad] with its SVG export.
class SignaturePadPage extends StatefulWidget {
  /// Creates the signature pad page.
  const SignaturePadPage({super.key});

  @override
  State<SignaturePadPage> createState() => _SignaturePadPageState();
}

class _SignaturePadPageState extends State<SignaturePadPage> {
  final _controller = Oito2SignatureController();
  String? _svg;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Sign with the mouse, a finger or a pen',
          children: [
            SizedBox(
              width: 480,
              child: Oito2SignaturePad(controller: _controller),
            ),
          ],
        ),
        ShowcaseSection(
          'Export',
          children: [
            FilledButton(
              onPressed: () => setState(() => _svg = _controller.toSvg()),
              child: const Text('Show as SVG'),
            ),
            if (_svg != null)
              SizedBox(
                width: 480,
                child: Text(
                  '${_svg!.length} characters: '
                  '${_svg!.substring(0, _svg!.length.clamp(0, 160))}…',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
