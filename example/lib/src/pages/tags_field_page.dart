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

/// Documents [Oito2TagsField]: suggestions, limits, validation and the
/// subtle style.
class TagsFieldPage extends StatefulWidget {
  /// Creates the tags field page.
  const TagsFieldPage({super.key});

  @override
  State<TagsFieldPage> createState() => _TagsFieldPageState();
}

class _TagsFieldPageState extends State<TagsFieldPage> {
  List<String> _fruits = ['Apple', 'Mango'];
  List<String> _tags = ['Dart'];
  List<String> _emails = [];
  List<String> _topics = ['React', 'Solid', 'Vue'];

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Tags Field',
      description:
          'Collects a list of short values as chips, typed, pasted or '
          'picked from suggestions.',
      source: 'lib/src/pages/tags_field_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 420,
            // #region preview
            child: Oito2TagsField(
              tags: _fruits,
              labelText: 'Fruits',
              hintText: 'Add a fruit',
              onChanged: (tags) => setState(() => _fruits = tags),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'The field is controlled: pass the `tags` and replace them in '
          '`onChanged`, which receives the whole new list. Enter or a '
          'comma adds the typed text as a tag, and a pasted list is split '
          'on the commas. A null `onChanged` makes the field read-only.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Suggestions', level: 3),
        const DocText(
          'With `suggestions`, an `Oito2ListCollection`, the items that '
          'match the typed text and aren\'t tags yet show below the input.',
        ),
        ExamplePanel(
          region: 'suggestions',
          child: SizedBox(
            width: 420,
            // #region suggestions
            child: Oito2TagsField(
              tags: _tags,
              labelText: 'Languages',
              hintText: 'Add a language',
              suggestions: _languages,
              onChanged: (tags) => setState(() => _tags = tags),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Limits and validation', level: 3),
        const DocText(
          '`maxTags` caps the list, `delimiters` sets the characters that '
          'end a tag, and `validator` refuses tags that don\'t fit. A typed '
          'tag that is refused stays in the input to be fixed; repeated '
          'tags are refused unless `allowDuplicates` is set.',
        ),
        ExamplePanel(
          region: 'limits',
          child: SizedBox(
            width: 420,
            // #region limits
            child: Oito2TagsField(
              tags: _emails,
              maxTags: 3,
              delimiters: const [',', ' ', ';'],
              hintText: 'name@example.com',
              validator: (tag) => tag.contains('@'),
              onChanged: (tags) => setState(() => _emails = tags),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Subtle style and clear button', level: 3),
        const DocText(
          '`Oito2TagsFieldStyle.subtle` draws neutral tags that take the '
          'accent when focused. `clearable` adds a button that removes '
          'every tag at once.',
        ),
        ExamplePanel(
          region: 'subtle',
          child: SizedBox(
            width: 420,
            // #region subtle
            child: Oito2TagsField(
              tags: _topics,
              labelText: 'Frameworks',
              style: Oito2TagsFieldStyle.subtle,
              clearable: true,
              onChanged: (tags) => setState(() => _topics = tags),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each tag is focusable and announces its text with a hint to '
          'remove it; its remove button is labeled "Remove <tag>". The '
          'field label names the input.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Enter` / a delimiter', 'Adds the typed text as a tag.'],
            [
              '`Backspace` in the empty input',
              'Moves the focus to the last tag.',
            ],
            [
              '`Left arrow` at the start of the input',
              'Moves the focus to the last tag (the right arrow in '
                  'right-to-left layouts).',
            ],
            [
              '`Left arrow` / `Right arrow` on a tag',
              'Moves to the previous or next tag; past the last one, back '
                  'to the input.',
            ],
            ['`Backspace` / `Delete` on a tag', 'Removes the focused tag.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2TagsField', 'Oito2TagsFieldStyle']),
      ],
    );
  }
}
