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

final _languages = Oito2ListCollection(const [
  'Dart',
  'Go',
  'Kotlin',
  'PHP',
  'Python',
  'Rust',
  'Svelte',
  'Swift',
  'TypeScript',
]);

/// Shows [Oito2TagsField] with suggestions and a tag limit.
class TagsFieldPage extends StatefulWidget {
  /// Creates the tags field page.
  const TagsFieldPage({super.key});

  @override
  State<TagsFieldPage> createState() => _TagsFieldPageState();
}

class _TagsFieldPageState extends State<TagsFieldPage> {
  List<String> _tags = ['Dart'];
  List<String> _emails = [];

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Suggestions; Enter or comma adds, Backspace reaches the tags',
          children: [
            SizedBox(
              width: 420,
              child: Oito2TagsField(
                tags: _tags,
                labelText: 'Languages',
                hintText: 'Add a language',
                suggestions: _languages,
                onChanged: (v) => setState(() => _tags = v),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Up to 3 e-mail addresses; space or comma separates',
          children: [
            SizedBox(
              width: 420,
              child: Oito2TagsField(
                tags: _emails,
                maxTags: 3,
                delimiters: const [',', ' ', ';'],
                hintText: 'name@example.com',
                validator: (tag) => tag.contains('@'),
                onChanged: (v) => setState(() => _emails = v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
