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

/// Shows [Oito2SelectableContainer] as a style picker.
class SelectableContainerPage extends StatefulWidget {
  /// Creates the selectable container page.
  const SelectableContainerPage({super.key});

  @override
  State<SelectableContainerPage> createState() =>
      _SelectableContainerPageState();
}

class _SelectableContainerPageState extends State<SelectableContainerPage> {
  int _style = 0;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Style picker',
          children: [
            for (final (index, name) in const [
              'Light',
              'Dark',
              'System',
            ].indexed)
              SizedBox(
                width: 150,
                child: Oito2SelectableContainer(
                  selected: _style == index,
                  onTap: () => setState(() => _style = index),
                  child: Column(
                    children: [
                      Oito2BorderContainer(
                        height: 72,
                        color: switch (index) {
                          0 => const Color(0xFFFAFAFA),
                          1 => const Color(0xFF242424),
                          _ => Theme.of(context).colorScheme.surfaceContainer,
                        },
                      ),
                      const SizedBox(height: Oito2Spacing.sm),
                      Text(name),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
