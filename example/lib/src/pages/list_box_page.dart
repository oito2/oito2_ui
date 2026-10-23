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

// #region data
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
// #endregion

/// Documents [Oito2ListBox] with single and multiple selection, custom
/// rows and activation.
class ListBoxPage extends StatefulWidget {
  /// Creates the list box page.
  const ListBoxPage({super.key});

  @override
  State<ListBoxPage> createState() => _ListBoxPageState();
}

class _ListBoxPageState extends State<ListBoxPage> {
  // #region single-data
  late final _single = Oito2SelectionController(
    collection: _fonts,
    initialValues: const ['Inter'],
  );
  // #endregion
  // #region multiple-data
  late final _multiple = Oito2SelectionController(
    collection: _fonts,
    mode: Oito2SelectionMode.multiple,
  );
  // #endregion
  late final _custom = Oito2SelectionController(
    collection: _fonts,
    initialValues: const ['Outfit'],
  );
  String _activated = 'None';

  @override
  void dispose() {
    _single.dispose();
    _multiple.dispose();
    _custom.dispose();
    super.dispose();
  }

  /// A bordered box of 240 pixels wide around [child].
  Widget _border(Widget child) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 240,
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: Oito2Radius.mediumAll,
      ),
      child: child,
    );
  }

  /// The selected values of [controller], updated as they change.
  Widget _selected(Oito2SelectionController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) =>
          Text('Selected: ${controller.selectedValues.join(', ')}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'List Box',
      description:
          'A list of items that the user selects from, one or several, with '
          'the mouse or the keyboard.',
      source: 'lib/src/pages/list_box_page.dart',
      children: [
        ExamplePanel(
          regions: const ['data', 'single-data', 'preview'],
          child: Column(
            spacing: Oito2Spacing.sm,
            children: [
              _border(
                // #region preview
                Oito2ListBox(
                  collection: _fonts,
                  controller: _single,
                  maxHeight: 300,
                  semanticLabel: 'Font',
                  onActivate: (font) => setState(() => _activated = font),
                ),
                // #endregion
              ),
              _selected(_single),
            ],
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2ListBox` an `Oito2ListCollection` of the items and an '
          '`Oito2SelectionController` over it, which keeps the selection; '
          'listen to the controller to react to changes, and dispose of it '
          'with the state that owns it. Grouped items show under their group '
          'headings, and disabled items cannot be selected or activated.',
        ),
        const DocText(
          'The list takes the focus as a whole and marks its active row. '
          '`maxHeight` bounds it, and it scrolls beyond. Every row is built, '
          'so it suits lists of up to a few hundred items.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'To pick one value from a menu that takes less room, use '
          '`Oito2Select` over the same collection.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Multiple selection', level: 3),
        const DocText(
          'With `mode: Oito2SelectionMode.multiple`, clicks follow the '
          'desktop conventions: Shift+click selects the range from the '
          'anchor, Control or Command+click toggles an item, and a plain '
          'click selects only it.',
        ),
        ExamplePanel(
          regions: const ['multiple-data', 'multiple'],
          child: Column(
            spacing: Oito2Spacing.sm,
            children: [
              _border(
                // #region multiple
                Oito2ListBox(
                  collection: _fonts,
                  controller: _multiple,
                  maxHeight: 300,
                  semanticLabel: 'Fonts',
                  onActivate: (font) => setState(() => _activated = font),
                ),
                // #endregion
              ),
              _selected(_multiple),
            ],
          ),
        ),
        const DocHeading('Custom rows', level: 3),
        const DocText(
          '`itemBuilder` builds the content of each row from the item and '
          'whether it is selected; without it, the row shows the item label.',
        ),
        ExamplePanel(
          region: 'custom',
          child: _border(
            // #region custom
            Oito2ListBox(
              collection: _fonts,
              controller: _custom,
              maxHeight: 240,
              semanticLabel: 'Font',
              itemBuilder: (context, font, selected) => Row(
                spacing: Oito2Spacing.sm,
                children: [
                  Icon(
                    selected ? LucideIcons.circle_check : LucideIcons.type,
                    size: 16,
                  ),
                  Expanded(child: Text(font, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Activation', level: 3),
        const DocText(
          '`onActivate` runs on Enter or a double click on an enabled item, '
          'for example to open it. The two lists at the top report here.',
        ),
        ExamplePanel(
          region: 'activated',
          minHeight: 60,
          // #region activated
          child: Text('Last activated: $_activated'),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The list is a semantics container labeled by `semanticLabel`. '
          'Each row reports whether it is selected, enabled and active, and '
          'group names are marked as headers. Set `autofocus` to give the '
          'list the focus when it shows.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Down arrow` / `Up arrow`',
              'Moves the active row; a single-selection list also selects it.',
            ],
            ['`Home` / `End`', 'Moves to the first or the last row.'],
            [
              '`Shift` + arrows, `Home`, `End`',
              'Extends the selection, in a multiple-selection list.',
            ],
            [
              '`Space`',
              'Toggles the active row, in a multiple-selection list.',
            ],
            [
              '`Ctrl+A` / `Cmd+A`',
              'Selects all, in a multiple-selection list.',
            ],
            ['`Enter`', 'Activates the active row.'],
            ['Letters', 'Jump to the next row whose label matches.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2ListBox',
          'Oito2ListBoxItemBuilder',
          'Oito2ListCollection',
          'Oito2SelectionController',
          'Oito2SelectionMode',
        ]),
      ],
    );
  }
}
