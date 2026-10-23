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

/// Documents [Oito2ChoiceChipBar] as a scrolling row and as a wrap, with
/// single and multiple selection.
class ChoiceChipBarPage extends StatefulWidget {
  /// Creates the choice chip bar page.
  const ChoiceChipBarPage({super.key});

  @override
  State<ChoiceChipBarPage> createState() => _ChoiceChipBarPageState();
}

class _ChoiceChipBarPageState extends State<ChoiceChipBarPage> {
  // #region state
  final Set<int> _selected = {0};

  void _toggle(int i) => setState(
    () => _selected.contains(i) ? _selected.remove(i) : _selected.add(i),
  );
  // #endregion
  int _sort = 0;
  final Set<int> _plain = {0};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DocPage(
      title: 'Choice Chip Bar',
      description:
          'A bar of pill-shaped chips for picking one or more filters, in a '
          'scrolling row or wrapped over several rows.',
      source: 'lib/src/pages/choice_chip_bar_page.dart',
      children: [
        ExamplePanel(
          regions: const ['state', 'preview'],
          child: SizedBox(
            width: 420,
            // #region preview
            child: Oito2ChoiceChipBar(
              labels: [for (final name in _categories) Text(name)],
              isSelected: [
                for (var i = 0; i < _categories.length; i++)
                  _selected.contains(i),
              ],
              onSelected: _toggle,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2ChoiceChipBar` is controlled: `labels` are the chips, '
          '`isSelected` says which are selected, in the same order, and '
          '`onSelected` receives the index of the chip the user activated. '
          'The bar doesn\'t change the selection itself, so the same widget '
          'serves single and multiple choice. A null `onSelected` disables '
          'every chip.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          '`labels` and `isSelected` must have the same length; debug '
          'builds assert it.',
          type: Oito2InfoType.warning,
        ),
        const DocHeading('Examples'),
        const DocHeading('Row with scroll arrows', level: 3),
        const DocText(
          'The default `Oito2ChoiceChipBarStyle.row` keeps the chips on one '
          'line that scrolls sideways. An arrow button and a soft edge '
          'shadow appear only on a side that hides chips; each press '
          'scrolls `scrollStep` pixels, 200 by default.',
        ),
        ExamplePanel(
          region: 'row',
          child: SizedBox(
            width: 420,
            // #region row
            child: Oito2ChoiceChipBar(
              style: Oito2ChoiceChipBarStyle.row,
              scrollStep: 160,
              labels: [for (final name in _categories) Text(name)],
              isSelected: [
                for (var i = 0; i < _categories.length; i++)
                  _selected.contains(i),
              ],
              onSelected: _toggle,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Wrap', level: 3),
        const DocText(
          '`Oito2ChoiceChipBarStyle.wrap` lays the chips over as many rows '
          'as they need, `spacing` apart in both directions.',
        ),
        ExamplePanel(
          region: 'wrap',
          child: SizedBox(
            width: 420,
            // #region wrap
            child: Oito2ChoiceChipBar(
              style: Oito2ChoiceChipBarStyle.wrap,
              labels: [for (final name in _categories) Text(name)],
              isSelected: [
                for (var i = 0; i < _categories.length; i++)
                  _selected.contains(i),
              ],
              onSelected: _toggle,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Single choice', level: 3),
        const DocText(
          'For one choice at a time, keep a single index and select only '
          'the chip that matches it.',
        ),
        ExamplePanel(
          region: 'single',
          child: SizedBox(
            width: 420,
            // #region single
            child: Oito2ChoiceChipBar(
              style: Oito2ChoiceChipBarStyle.wrap,
              labels: const [Text('Name'), Text('Date'), Text('Size')],
              isSelected: [for (var i = 0; i < 3; i++) i == _sort],
              onSelected: (i) => setState(() => _sort = i),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Fill only', level: 3),
        const DocText(
          'With `showCheckmark: false` a selected chip shows only the '
          'secondary container fill, without the check mark before its '
          'label. Here the selection is also listed below the bar.',
        ),
        ExamplePanel(
          region: 'fill',
          child: SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.md,
              children: [
                // #region fill
                Oito2ChoiceChipBar(
                  showCheckmark: false,
                  labels: [for (final name in _categories) Text(name)],
                  isSelected: [
                    for (var i = 0; i < _categories.length; i++)
                      _plain.contains(i),
                  ],
                  onSelected: (i) => setState(
                    () => _plain.contains(i) ? _plain.remove(i) : _plain.add(i),
                  ),
                ),
                // #endregion
                Oito2BorderContainer(
                  padding: const EdgeInsets.all(Oito2Spacing.md),
                  child: _plain.isEmpty
                      ? const Text('Nothing selected')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Oito2Spacing.xs,
                          children: [
                            for (var i = 0; i < _categories.length; i++)
                              if (_plain.contains(i))
                                Text(
                                  _categories[i],
                                  style: textTheme.titleMedium,
                                ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'A null `onSelected` disables the whole bar: the chips keep '
          'showing their selection but ignore input.',
        ),
        ExamplePanel(
          region: 'disabled',
          child: SizedBox(
            width: 420,
            // #region disabled
            child: Oito2ChoiceChipBar(
              style: Oito2ChoiceChipBarStyle.wrap,
              labels: const [Text('Audio'), Text('Games'), Text('Office')],
              isSelected: const [false, true, false],
              onSelected: null,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each chip is a Material `ChoiceChip`, which assistive '
          'technologies report as a button with its selected '
          'state. The scroll arrows of the row style use `previousLabel` '
          'and `nextLabel` as their tooltip and label, by default the '
          'localized "Scroll back" and "Scroll forward".',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next chip or arrow button.'],
            ['`Space` / `Enter`', 'Activates the focused chip or arrow.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2ChoiceChipBar',
          'Oito2ChoiceChipBarStyle',
        ]),
      ],
    );
  }
}
