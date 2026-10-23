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

import '../docs/doc_widgets.dart';

/// Documents [Oito2FloatingPanel]: panels over an area, a fixed size, a
/// control style and the reported rectangle.
class FloatingPanelPage extends StatefulWidget {
  /// Creates the floating panel page.
  const FloatingPanelPage({super.key});

  @override
  State<FloatingPanelPage> createState() => _FloatingPanelPageState();
}

class _FloatingPanelPageState extends State<FloatingPanelPage> {
  bool _inspector = true;
  bool _layers = true;
  Rect _rect = const Rect.fromLTWH(24, 24, 240, 150);

  /// The bordered area of [width] by [height] the panels of an example
  /// float over.
  Widget _area({
    required double width,
    required double height,
    required List<Widget> children,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Stack(children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Floating Panel',
      description:
          'A non-modal window inside the app, such as an inspector or a tool '
          'palette, that the user moves, resizes, minimizes and maximizes.',
      source: 'lib/src/pages/floating_panel_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          padding: const EdgeInsets.all(Oito2Spacing.md),
          child: _area(
            width: 680,
            height: 420,
            children: [
              Center(
                child: Wrap(
                  spacing: Oito2Spacing.sm,
                  runSpacing: Oito2Spacing.sm,
                  children: [
                    if (!_inspector)
                      OutlinedButton(
                        onPressed: () => setState(() => _inspector = true),
                        child: const Text('Open Inspector'),
                      ),
                    if (!_layers)
                      OutlinedButton(
                        onPressed: () => setState(() => _layers = true),
                        child: const Text('Open Layers'),
                      ),
                  ],
                ),
              ),
              // #region preview
              if (_layers)
                Oito2FloatingPanel(
                  title: 'Layers',
                  initialRect: const Rect.fromLTWH(400, 120, 240, 240),
                  onClose: () => setState(() => _layers = false),
                  child: ListView(
                    children: [
                      for (final layer in ['Text', 'Shape', 'Background'])
                        Oito2ListTile(title: Text(layer)),
                    ],
                  ),
                ),
              if (_inspector)
                Oito2FloatingPanel(
                  title: 'Inspector',
                  initialRect: const Rect.fromLTWH(30, 30, 320, 220),
                  onClose: () => setState(() => _inspector = false),
                  child: const Padding(
                    padding: EdgeInsets.all(Oito2Spacing.md),
                    child: Text('Width: 320\nHeight: 240\nOpacity: 100%'),
                  ),
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Place `Oito2FloatingPanel`s in a `Stack`: a panel covers the '
          'stack to know its bounds, but only takes pointer events on '
          'itself. `initialRect` sets its position and size at start, in the '
          'stack\'s coordinates, and `minSize` the smallest size it can be '
          'resized to, 220 by 140 by default.',
        ),
        const DocText(
          'Dragging the title bar moves the panel, which keeps its title bar '
          'inside the stack, and a double click maximizes or restores it. '
          'Its right and bottom edges and corner resize it. Minimizing '
          'leaves only the title bar, and the content keeps its state. The '
          'close button shows only when `onClose` is set.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'Panels keep the stacking order of the stack\'s children: clicking '
          'a panel does not bring it to the front, so reorder the children '
          'when you want that.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Fixed size and control style', level: 3),
        const DocText(
          'With `resizable: false` the edges no longer resize the panel. '
          '`controlStyle` draws the title bar buttons in the look of a '
          'desktop, GNOME by default.',
        ),
        ExamplePanel(
          region: 'fixed',
          padding: const EdgeInsets.all(Oito2Spacing.md),
          child: _area(
            width: 420,
            height: 240,
            children: const [
              // #region fixed
              Oito2FloatingPanel(
                title: 'Palette',
                initialRect: Rect.fromLTWH(24, 24, 260, 150),
                resizable: false,
                controlStyle: Oito2WindowControlStyle.breeze,
                child: Center(child: Text('Fixed size')),
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Tracking the rectangle', level: 3),
        const DocText(
          '`onRectChanged` reports the new rectangle on every move or resize '
          'step, including each step of a drag, for example to save the '
          'layout.',
        ),
        ExamplePanel(
          region: 'rect',
          padding: const EdgeInsets.all(Oito2Spacing.md),
          child: _area(
            width: 420,
            height: 240,
            children: [
              // #region rect
              Oito2FloatingPanel(
                title: 'Position',
                initialRect: const Rect.fromLTWH(24, 24, 240, 150),
                onRectChanged: (rect) => setState(() => _rect = rect),
                child: Center(
                  child: Text(
                    '${_rect.left.round()}, ${_rect.top.round()}\n'
                    '${_rect.width.round()} × ${_rect.height.round()}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each panel is a semantics container labeled by its `title`. The '
          'title bar takes the focus, and from there the keyboard moves and '
          'resizes the panel by `keyboardStep` pixels, 16 by default.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['Arrow keys', 'Move the panel, while the title bar has focus.'],
            [
              '`Shift` + arrow keys',
              'Resize the panel, while the title bar has focus.',
            ],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2FloatingPanel',
          'Oito2WindowControlStyle',
        ]),
      ],
    );
  }
}
