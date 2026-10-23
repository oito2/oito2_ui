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

/// Shows [Oito2IconButton] as a plain button and as a toggle, and the
/// [Oito2BackButton] and [Oito2CloseButton].
class IconButtonPage extends StatefulWidget {
  /// Creates the icon button page.
  const IconButtonPage({super.key});

  @override
  State<IconButtonPage> createState() => _IconButtonPageState();
}

class _IconButtonPageState extends State<IconButtonPage> {
  final Set<String> _styles = {'bold'};

  @override
  Widget build(BuildContext context) {
    Widget toggle(String name, IconData icon) => Oito2IconButton(
      icon: Icon(icon),
      tooltip: name,
      isSelected: _styles.contains(name),
      onPressed: () => setState(
        () => _styles.contains(name) ? _styles.remove(name) : _styles.add(name),
      ),
    );
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Buttons',
          children: [
            Oito2IconButton(
              icon: const Icon(LucideIcons.settings),
              tooltip: 'Settings',
              onPressed: () {},
            ),
            Oito2IconButton(
              icon: const Icon(LucideIcons.search),
              tooltip: 'Search',
              onPressed: () {},
            ),
            const Oito2IconButton(
              icon: Icon(LucideIcons.trash),
              tooltip: 'Delete',
              onPressed: null,
            ),
          ],
        ),
        ShowcaseSection(
          'Toggles',
          children: [
            toggle('bold', LucideIcons.bold),
            toggle('italic', LucideIcons.italic),
            toggle('underline', LucideIcons.underline),
          ],
        ),
        ShowcaseSection(
          'Back and close',
          children: [
            Oito2BackButton(onPressed: () {}),
            Oito2CloseButton(onPressed: () {}),
          ],
        ),
      ],
    );
  }
}
