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

/// Documents [Oito2SegmentedEntry]: an IPv4 address and a license key.
class SegmentedEntryPage extends StatefulWidget {
  /// Creates the segmented entry page.
  const SegmentedEntryPage({super.key});

  @override
  State<SegmentedEntryPage> createState() => _SegmentedEntryPageState();
}

class _SegmentedEntryPageState extends State<SegmentedEntryPage> {
  String _address = '';
  String _key = 'ABCD-1234--';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DocPage(
      title: 'Segmented Entry',
      description:
          'Enters a value made of short fixed parts, such as an IP address '
          'or a license key, in a row of small fields.',
      source: 'lib/src/pages/segmented_entry_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.md,
            children: [
              // #region preview
              Oito2SegmentedEntry(
                segments: const [
                  Oito2EntrySegment(length: 3, hint: '192'),
                  Oito2EntrySegment(length: 3, hint: '168'),
                  Oito2EntrySegment(length: 3, hint: '0'),
                  Oito2EntrySegment(length: 3, hint: '1'),
                ],
                onChanged: (parts) =>
                    setState(() => _address = parts.join('.')),
              ),
              Text('Address: $_address', style: textTheme.bodySmall),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Describe each part with an `Oito2EntrySegment`: its `length` in '
          'characters, an optional `hint` placeholder and whether it is '
          '`numeric`, the default, which accepts digits only. The entry '
          'keeps the text of every segment and calls `onChanged` with the '
          'whole list whenever one changes; `initialValues` fills them at '
          'start.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The focus moves to the next segment when one fills up or when '
          'the delimiter is typed, so a value can be typed in one go. Each '
          'field is as wide as its number of digits.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Delimiter and letters', level: 3),
        const DocText(
          '`delimiter` is the text drawn between the segments, `.` by '
          'default. Typing its first visible character, `-` for `\' - \'`, '
          'moves to the next segment, and a segment that isn\'t `numeric` '
          'refuses that character but accepts any other.',
        ),
        ExamplePanel(
          region: 'license',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.md,
            children: [
              // #region license
              Oito2SegmentedEntry(
                delimiter: ' - ',
                initialValues: const ['ABCD', '1234'],
                segments: const [
                  Oito2EntrySegment(length: 4, numeric: false),
                  Oito2EntrySegment(length: 4, numeric: false),
                  Oito2EntrySegment(length: 4, numeric: false),
                  Oito2EntrySegment(length: 4, numeric: false),
                ],
                onChanged: (parts) => setState(() => _key = parts.join('-')),
              ),
              Text('Key: $_key', style: textTheme.bodySmall),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each segment is a text field labeled "Part <n> of <count>", or '
          'with the segment `label` when set. The delimiters are hidden '
          'from assistive technologies.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['The delimiter', 'Moves the focus to the next segment.'],
            [
              '`Backspace` in an empty segment',
              'Moves the focus to the end of the previous segment.',
            ],
            [
              '`Left arrow` at the start of a segment',
              'Moves the focus to the end of the previous segment (the '
                  'right arrow in right-to-left layouts).',
            ],
            [
              '`Right arrow` at the end of a segment',
              'Moves the focus to the start of the next segment (the left '
                  'arrow in right-to-left layouts).',
            ],
          ],
        ),
        ...apiReferenceWidgets(['Oito2SegmentedEntry', 'Oito2EntrySegment']),
      ],
    );
  }
}
