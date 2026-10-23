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

/// Documents [Oito2SearchField] and [Oito2SearchTitleField].
class SearchFieldPage extends StatefulWidget {
  /// Creates the search field page.
  const SearchFieldPage({super.key});

  @override
  State<SearchFieldPage> createState() => _SearchFieldPageState();
}

class _SearchFieldPageState extends State<SearchFieldPage> {
  bool _searching = false;
  String _query = '';
  String _fileQuery = '';
  String _submitted = '';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DocPage(
      title: 'Search Field',
      description:
          'A text field for a search, with a search icon and a clear '
          'button, and a title that turns into one.',
      source: 'lib/src/pages/search_field_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.md,
              children: [
                // #region preview
                Oito2SearchField(
                  onChanged: (text) => setState(() => _query = text),
                ),
                Text('Query: "$_query"', style: textTheme.bodySmall),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2SearchField` reports the text through `onChanged` and '
          '`onSubmitted`, or keeps it in your own `controller`. The clear '
          'button shows while there is text; it empties the field, reports '
          'the empty text to `onChanged` and then calls `onClear`. The hint '
          'defaults to the localized "Search".',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Hint and submit', level: 3),
        const DocText(
          '`hintText` replaces the default hint, and `onSubmitted` receives '
          'the text when Enter or the keyboard search action is pressed.',
        ),
        ExamplePanel(
          region: 'submit',
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.md,
              children: [
                // #region submit
                Oito2SearchField(
                  hintText: 'Search messages',
                  onSubmitted: (text) => setState(() => _submitted = text),
                ),
                Text('Submitted: "$_submitted"', style: textTheme.bodySmall),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Search in a title', level: 3),
        const DocText(
          '`Oito2SearchTitleField` switches between a `title` and a search '
          'field with a toggle button, as in a title bar. It is '
          'controlled: `searchActive` says whether the field shows, and '
          '`onSearchActiveChanged` asks to open or close it. It keeps the '
          'same size in both states, `fieldWidth` wide, so the layout '
          'around it doesn\'t move.',
        ),
        ExamplePanel(
          region: 'title',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.md,
            children: [
              // #region title
              Oito2SearchTitleField(
                title: Text('Files', style: textTheme.titleMedium),
                searchActive: _searching,
                onSearchActiveChanged: (active) =>
                    setState(() => _searching = active),
                onChanged: (text) => setState(() => _fileQuery = text),
              ),
              Text('Query: "$_fileQuery"', style: textTheme.bodySmall),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The clear button has the localized tooltip "Clear", which also '
          'names it. The toggle button of `Oito2SearchTitleField` is named '
          'by `toggleLabel`, "Search" by default, and reports its pressed '
          'state to assistive technologies. Closing the search returns the '
          'focus to the toggle button.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Escape` with text', 'Clears the field.'],
            [
              '`Escape` in the empty field',
              'Calls `onEscape`; in `Oito2SearchTitleField`, closes the '
                  'search.',
            ],
            ['`Enter`', 'Calls `onSubmitted` with the text.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2SearchField', 'Oito2SearchTitleField']),
      ],
    );
  }
}
