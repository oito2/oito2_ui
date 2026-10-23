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

// #region countries
final _countries = Oito2ListCollection(
  const [
    ('ar', 'Argentina'),
    ('bo', 'Bolívia'),
    ('br', 'Brasil'),
    ('cl', 'Chile'),
    ('co', 'Colômbia'),
    ('ec', 'Equador'),
    ('py', 'Paraguai'),
    ('pe', 'Peru'),
    ('uy', 'Uruguai'),
    ('ve', 'Venezuela'),
  ],
  valueOf: (country) => country.$1,
  labelOf: (country) => country.$2,
);
// #endregion

/// Documents [Oito2Autocomplete] suggesting items of a collection.
class AutocompletePage extends StatefulWidget {
  /// Creates the autocomplete page.
  const AutocompletePage({super.key});

  @override
  State<AutocompletePage> createState() => _AutocompletePageState();
}

class _AutocompletePageState extends State<AutocompletePage> {
  String _picked = '—';
  String _browsed = '—';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DocPage(
      title: 'Autocomplete',
      description:
          'A text field that suggests items of a collection as you type, '
          'and fills in the one you pick.',
      source: 'lib/src/pages/autocomplete_page.dart',
      children: [
        ExamplePanel(
          regions: const ['countries', 'preview'],
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.md,
              children: [
                // #region preview
                Oito2Autocomplete(
                  collection: _countries,
                  hintText: 'Country',
                  onSelected: (country) => setState(() => _picked = country.$2),
                ),
                Text('Picked: $_picked', style: textTheme.bodySmall),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give the field an `Oito2ListCollection` of the items to suggest. '
          'The suggestions are the enabled items whose label contains the '
          'typed text, ignoring case and accents, with the match '
          'highlighted: typing "colo" finds "Colômbia". Picking one fills '
          'the field with its label and calls `onSelected` with the item.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The list grows up to `optionsMaxHeight`, 240 by default, before '
          'it scrolls, and is as wide as the field unless `optionsWidth` '
          'is set. To read or change the text, pass a `controller` '
          'together with a `focusNode`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Every option while empty', level: 3),
        const DocText(
          'With `showAllWhenEmpty`, every enabled item shows while the '
          'field is empty, so the list can be browsed before typing.',
        ),
        ExamplePanel(
          region: 'show-all',
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.md,
              children: [
                // #region show-all
                Oito2Autocomplete(
                  collection: _countries,
                  hintText: 'Country',
                  showAllWhenEmpty: true,
                  onSelected: (country) =>
                      setState(() => _browsed = country.$2),
                ),
                Text('Picked: $_browsed', style: textTheme.bodySmall),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Initial value', level: 3),
        const DocText(
          '`initialValue` is the value of the item whose label fills the '
          'field at start. It is used only without a `controller`.',
        ),
        ExamplePanel(
          region: 'initial',
          child: SizedBox(
            width: 300,
            // #region initial
            child: Oito2Autocomplete(
              collection: _countries,
              initialValue: 'br',
              hintText: 'Country',
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'While the field has the focus, a live region announces the '
          'number of suggestions, such as "3 results", or "No results" '
          'when nothing matches.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Up arrow` / `Down arrow`',
              'Moves the highlight through the suggestions.',
            ],
            ['`Enter`', 'Picks the highlighted suggestion.'],
            ['`Escape`', 'Closes the suggestions.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2Autocomplete', 'Oito2ListCollection']),
      ],
    );
  }
}
