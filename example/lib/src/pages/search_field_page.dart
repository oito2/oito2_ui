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

/// Shows [Oito2SearchField] and [Oito2SearchTitleField].
class SearchFieldPage extends StatefulWidget {
  /// Creates the search field page.
  const SearchFieldPage({super.key});

  @override
  State<SearchFieldPage> createState() => _SearchFieldPageState();
}

class _SearchFieldPageState extends State<SearchFieldPage> {
  bool _searching = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Search field',
          children: [
            SizedBox(
              width: 300,
              child: Oito2SearchField(
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Search title field',
          children: [
            Oito2SearchTitleField(
              title: Text('Files', style: textTheme.titleMedium),
              searchActive: _searching,
              onSearchActiveChanged: (v) => setState(() => _searching = v),
              onChanged: (v) => setState(() => _query = v),
            ),
          ],
        ),
        Text('Query: "$_query"', style: textTheme.bodySmall),
      ],
    );
  }
}
