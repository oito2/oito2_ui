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

const _categories = [
  'All',
  'Audio',
  'Development',
  'Education',
  'Games',
  'Graphics',
  'Internet',
  'Office',
  'Science',
  'Utilities',
];

/// Shows [Oito2ChoiceChipBar] as a scrolling row and as a wrap.
class ChoiceChipBarPage extends StatefulWidget {
  /// Creates the choice chip bar page.
  const ChoiceChipBarPage({super.key});

  @override
  State<ChoiceChipBarPage> createState() => _ChoiceChipBarPageState();
}

class _ChoiceChipBarPageState extends State<ChoiceChipBarPage> {
  final Set<int> _selected = {0};

  @override
  Widget build(BuildContext context) {
    Widget bar(Oito2ChoiceChipBarStyle style, {bool check = true}) =>
        Oito2ChoiceChipBar(
          style: style,
          showCheckmark: check,
          labels: [for (final name in _categories) Text(name)],
          isSelected: [
            for (var i = 0; i < _categories.length; i++) _selected.contains(i),
          ],
          onSelected: (i) => setState(
            () =>
                _selected.contains(i) ? _selected.remove(i) : _selected.add(i),
          ),
        );
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Row with scroll arrows',
          children: [
            SizedBox(width: 520, child: bar(Oito2ChoiceChipBarStyle.row)),
          ],
        ),
        ShowcaseSection(
          'Wrap',
          children: [
            SizedBox(width: 520, child: bar(Oito2ChoiceChipBarStyle.wrap)),
          ],
        ),
        ShowcaseSection(
          'Fill only, with the selection listed below',
          children: [
            SizedBox(
              width: 520,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Oito2Spacing.md,
                children: [
                  bar(Oito2ChoiceChipBarStyle.row, check: false),
                  Oito2BorderContainer(
                    padding: const EdgeInsets.all(Oito2Spacing.md),
                    child: _selected.isEmpty
                        ? const Text('Nothing selected')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Oito2Spacing.xs,
                            children: [
                              for (var i = 0; i < _categories.length; i++)
                                if (_selected.contains(i))
                                  Text(
                                    _categories[i],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                            ],
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
