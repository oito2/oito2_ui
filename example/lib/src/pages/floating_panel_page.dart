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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2FloatingPanel]s over an area.
class FloatingPanelPage extends StatefulWidget {
  /// Creates the floating panel page.
  const FloatingPanelPage({super.key});

  @override
  State<FloatingPanelPage> createState() => _FloatingPanelPageState();
}

class _FloatingPanelPageState extends State<FloatingPanelPage> {
  bool _inspector = true;
  bool _layers = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Drag the titles, resize from the edges, focus a title and use the '
          'arrows (Shift resizes)',
          children: [
            Container(
              width: 680,
              height: 420,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Oito2Spacing.sm,
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
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
