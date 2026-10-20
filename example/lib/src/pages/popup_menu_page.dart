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

/// Shows [Oito2PopupMenuButton] with single and multiple choices, and
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
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Single choice',
          children: [
            Oito2PopupMenuButton(
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
          ],
        ),
        ShowcaseSection(
          'Multiple choices: the menu stays open',
          children: [
            Oito2PopupMenuButton(
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
          ],
        ),
        ShowcaseSection(
          'Select over a grouped collection',
          children: [
            Oito2Select(
              collection: _desktops,
              value: _desktop,
              placeholder: const Text('Desktop'),
              onChanged: (v) => setState(() => _desktop = v),
            ),
            const Oito2PopupMenuButton(
              enabled: false,
              menuChildren: [],
              child: Text('Disabled'),
            ),
          ],
        ),
      ],
    );
  }
}
