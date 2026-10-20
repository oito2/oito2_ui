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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../widgets/showcase_widgets.dart';

final _fonts = Oito2ListCollection(
  const [
    'Inter',
    'Noto Sans',
    'Outfit',
    'Ubuntu',
    'JetBrains Mono',
    'Fira Code',
    'Noto Serif',
    'Merriweather',
  ],
  groupOf: (font) => switch (font) {
    'JetBrains Mono' || 'Fira Code' => 'Monospace',
    'Noto Serif' || 'Merriweather' => 'Serif',
    _ => 'Sans serif',
  },
  isDisabled: (font) => font == 'Ubuntu',
);

/// Shows [Oito2ListBox] with single and multiple selection.
class ListBoxPage extends StatefulWidget {
  /// Creates the list box page.
  const ListBoxPage({super.key});

  @override
  State<ListBoxPage> createState() => _ListBoxPageState();
}

class _ListBoxPageState extends State<ListBoxPage> {
  late final _single = Oito2SelectionController(
    collection: _fonts,
    initialValues: const ['Inter'],
  );
  late final _multiple = Oito2SelectionController(
    collection: _fonts,
    mode: Oito2SelectionMode.multiple,
  );
  String _activated = 'None';

  @override
  void dispose() {
    _single.dispose();
    _multiple.dispose();
    super.dispose();
  }

  Widget _box(Oito2SelectionController controller, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 240,
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: Oito2Radius.mediumAll,
      ),
      child: Oito2ListBox(
        collection: _fonts,
        controller: controller,
        maxHeight: 300,
        semanticLabel: label,
        onActivate: (font) => setState(() => _activated = font),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Single: arrows, Home/End, type to jump, Enter activates',
          children: [
            _box(_single, 'Font'),
            ListenableBuilder(
              listenable: _single,
              builder: (context, _) =>
                  Text('Selected: ${_single.selectedValues.join(', ')}'),
            ),
          ],
        ),
        ShowcaseSection(
          'Multiple: Space, Shift+arrows, Ctrl+A, Ctrl/Shift+click',
          children: [
            _box(_multiple, 'Fonts'),
            ListenableBuilder(
              listenable: _multiple,
              builder: (context, _) =>
                  Text('Selected: ${_multiple.selectedValues.join(', ')}'),
            ),
          ],
        ),
        ShowcaseSection('Last activated', children: [Text(_activated)]),
      ],
    );
  }
}
