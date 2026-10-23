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
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2SignaturePad] and [Oito2SignatureController]: drawing,
/// ink options, outside actions and the SVG export.
class SignaturePadPage extends StatefulWidget {
  /// Creates the signature pad page.
  const SignaturePadPage({super.key});

  @override
  State<SignaturePadPage> createState() => _SignaturePadPageState();
}

class _SignaturePadPageState extends State<SignaturePadPage> {
  final _controller = Oito2SignatureController();
  final _inkController = Oito2SignatureController();
  final _actionsController = Oito2SignatureController();
  final _exportController = Oito2SignatureController();
  String? _svg;

  @override
  void dispose() {
    _controller.dispose();
    _inkController.dispose();
    _actionsController.dispose();
    _exportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return DocPage(
      title: 'Signature Pad',
      description:
          'An area to sign with a mouse, a finger or a pen, with undo, clear '
          'and export to SVG or PNG.',
      source: 'lib/src/pages/signature_pad_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 400,
            // #region preview
            child: Oito2SignaturePad(controller: _controller),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Create an `Oito2SignatureController`, give it to the pad and '
          'dispose it with its owner. The controller holds the strokes: '
          '`isEmpty` says whether anything was drawn, `undo` removes the '
          'last stroke, `clear` removes them all, and `addStroke` puts back '
          'a saved one. It notifies its listeners on every change.',
        ),
        const DocCode("import 'package:oito2_ui_extras/oito2_ui_extras.dart';"),
        const DocText(
          'The pad takes the available width and `height` pixels, 180 by '
          'default. Only the first pointer down draws, and a mouse draws '
          'with its primary button only. The pad wins the pointer at once, '
          'so a scroll view around it doesn\'t take the stroke.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Ink and stroke width', level: 3),
        const DocText(
          'Strokes get thinner as the pointer moves faster, between '
          '`minWidth` and `maxWidth`, and a stylus that reports pressure '
          'draws wider when pressed harder. `color` sets the ink, the '
          'theme\'s text color by default, and `placeholder` replaces the '
          '"Sign here" text of the empty pad.',
        ),
        ExamplePanel(
          region: 'ink',
          child: SizedBox(
            width: 400,
            // #region ink
            child: Oito2SignaturePad(
              controller: _inkController,
              height: 140,
              color: scheme.primary,
              minWidth: 2,
              maxWidth: 6,
              placeholder: 'Draw here',
            ),
            // #endregion
          ),
        ),
        const DocHeading('Own actions', level: 3),
        const DocText(
          'With `showActions: false` the undo and clear buttons in the '
          'corner go away, and the app calls the controller instead. Listen '
          'to the controller to enable them only when there are strokes.',
        ),
        ExamplePanel(
          region: 'actions',
          child: SizedBox(
            width: 400,
            // #region actions
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                Oito2SignaturePad(
                  controller: _actionsController,
                  showActions: false,
                ),
                ListenableBuilder(
                  listenable: _actionsController,
                  builder: (context, _) => Wrap(
                    alignment: WrapAlignment.end,
                    spacing: Oito2Spacing.sm,
                    children: [
                      OutlinedButton(
                        onPressed: _actionsController.isEmpty
                            ? null
                            : _actionsController.undo,
                        child: const Text('Undo'),
                      ),
                      OutlinedButton(
                        onPressed: _actionsController.isEmpty
                            ? null
                            : _actionsController.clear,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Export', level: 3),
        const DocText(
          '`toSvg` returns an SVG document of the pad size, one path per '
          'stroke segment so the width can vary, in the opaque RGB value of '
          'its `color`. `toImage` renders a transparent image at '
          '`pixelRatio`, which the caller must dispose, and `toPngBytes` '
          'encodes it as PNG, returning null when encoding fails.',
        ),
        ExamplePanel(
          region: 'export',
          child: SizedBox(
            width: 400,
            // #region export
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                Oito2SignaturePad(controller: _exportController),
                FilledButton(
                  onPressed: () =>
                      setState(() => _svg = _exportController.toSvg()),
                  child: const Text('Show as SVG'),
                ),
                if (_svg case final svg?)
                  Text(
                    '${svg.length} characters: '
                    '${svg.substring(0, svg.length.clamp(0, 160))}…',
                    style: textTheme.bodySmall,
                  ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The pad is one node for assistive technologies, labeled by '
          '`semanticLabel` ("Signature" by default), whose value says '
          'whether it is "Empty" or "Signed". The undo and clear buttons are '
          'labeled by their tooltips and are disabled while the pad is '
          'empty. Drawing needs a pointer, so offer another way to sign, '
          'such as typing the name, where that matters.',
        ),
        ...apiReferenceWidgets([
          'Oito2SignaturePad',
          'Oito2SignatureController',
          'Oito2SignaturePoint',
        ]),
      ],
    );
  }
}
