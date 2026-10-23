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
  valueOf: (c) => c.$1,
  labelOf: (c) => c.$2,
);

/// Shows [Oito2Autocomplete] suggesting items of a collection.
class AutocompletePage extends StatefulWidget {
  /// Creates the autocomplete page.
  const AutocompletePage({super.key});

  @override
  State<AutocompletePage> createState() => _AutocompletePageState();
}

class _AutocompletePageState extends State<AutocompletePage> {
  String _picked = '—';

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Type to filter; accents are ignored',
          children: [
            SizedBox(
              width: 300,
              child: Oito2Autocomplete(
                collection: _countries,
                hintText: 'Country',
                onSelected: (c) => setState(() => _picked = c.$2),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Every option while empty',
          children: [
            SizedBox(
              width: 300,
              child: Oito2Autocomplete(
                collection: _countries,
                hintText: 'Country',
                showAllWhenEmpty: true,
                onSelected: (c) => setState(() => _picked = c.$2),
              ),
            ),
          ],
        ),
        Text('Picked: $_picked', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
