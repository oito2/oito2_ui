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

// #region select-data
final _desktops = Oito2ListCollection(
  const [
    ('gnome', 'GNOME', 'GTK'),
    ('cinnamon', 'Cinnamon', 'GTK'),
    ('xfce', 'Xfce', 'GTK'),
    ('kde', 'KDE Plasma', 'Qt'),
    ('lxqt', 'LXQt (unavailable)', 'Qt'),
  ],
  valueOf: (d) => d.$1,
  labelOf: (d) => d.$2,
  groupOf: (d) => d.$3,
  isDisabled: (d) => d.$1 == 'lxqt',
);
// #endregion

/// Documents [Oito2PopupMenuButton] with single and multiple choices, and
/// [Oito2Select] over a grouped collection.
class PopupMenuPage extends StatefulWidget {
  /// Creates the popup menu page.
  const PopupMenuPage({super.key});

  @override
  State<PopupMenuPage> createState() => _PopupMenuPageState();
}

class _PopupMenuPageState extends State<PopupMenuPage> {
  String _sort = 'Name';
  final Set<String> _columns = {'Size', 'Modified'};
  String? _desktop = 'gnome';

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Popup Menu',
      description:
          'A button that looks like a field and opens a menu of choices '
          'below it.',
      source: 'lib/src/pages/popup_menu_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2PopupMenuButton(
            leading: const Icon(LucideIcons.arrow_down_up, size: 18),
            menuChildren: [
              for (final option in ['Name', 'Size', 'Modified'])
                Oito2CheckedMenuItem(
                  checked: _sort == option,
                  onPressed: () => setState(() => _sort = option),
                  child: Text(option),
                ),
            ],
            child: Text('Sort by: $_sort'),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2PopupMenuButton` shows its `child`, usually the current '
          'choice, with a chevron, and opens `menuChildren` below it. The '
          'menu is a `MenuAnchor`: use `Oito2CheckedMenuItem` for a single '
          'choice, `Oito2MultiSelectMenuItem` for several, or any '
          '`MenuItemButton`. The button is as tall as the text fields, and '
          'long labels end with an ellipsis.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For a few short choices that fit side by side, a segmented button '
          'is quicker to use. To pick a value of a collection, use '
          '`Oito2Select`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Multiple choices', level: 3),
        const DocText(
          '`Oito2MultiSelectMenuItem` shows a check box and calls '
          '`onChanged` with the new state. The menu stays open, so several '
          'items can be toggled in a row.',
        ),
        ExamplePanel(
          region: 'multiple',
          // #region multiple
          child: Oito2PopupMenuButton(
            menuChildren: [
              for (final column in ['Size', 'Type', 'Modified', 'Owner'])
                Oito2MultiSelectMenuItem(
                  checked: _columns.contains(column),
                  onChanged: (on) => setState(
                    () => on ? _columns.add(column) : _columns.remove(column),
                  ),
                  child: Text(column),
                ),
            ],
            child: Text('Columns (${_columns.length})'),
          ),
          // #endregion
        ),
        const DocHeading('Select', level: 3),
        const DocText(
          '`Oito2Select` picks one value of an `Oito2ListCollection`. The '
          'button shows the selected item\'s label, or `placeholder` when '
          'nothing is selected; the menu lists the items under their group '
          'names, with a check mark on the selected one and disabled items '
          'greyed out. A null `onChanged` disables it.',
        ),
        ExamplePanel(
          region: 'select-data',
          regions: const ['select'],
          // #region select
          child: Oito2Select(
            collection: _desktops,
            value: _desktop,
            placeholder: const Text('Desktop'),
            onChanged: (v) => setState(() => _desktop = v),
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'With `enabled: false` the button greys out and does not open its '
          'menu.',
        ),
        const ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2PopupMenuButton(
            enabled: false,
            menuChildren: [],
            child: Text('Disabled'),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The button reports whether its menu is expanded, and is labeled '
          'by the text of its child unless `semanticLabel` is given. '
          '`Oito2CheckedMenuItem` reports its checked state as one of a '
          'group of exclusive choices, and `Oito2MultiSelectMenuItem` as a '
          'checked item.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Enter` / `Space`', 'Opens or closes the menu from the button.'],
            ['`Down arrow`', 'Opens the menu from the button.'],
            ['Arrow keys', 'Move between the menu entries.'],
            ['`Escape`', 'Closes the menu.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2PopupMenuButton',
          'Oito2CheckedMenuItem',
          'Oito2MultiSelectMenuItem',
          'Oito2Select',
        ]),
      ],
    );
  }
}
