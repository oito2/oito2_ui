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

/// Documents [Oito2Calendar] and [Oito2DatePicker] for dates and ranges,
/// and an [Oito2DateEntry].
class CalendarPage extends StatefulWidget {
  /// Creates the calendar page.
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _first = DateTime(2020);
  final _last = DateTime(2030, 12, 31);
  DateTime? _day;
  DateTime? _date;
  DateTimeRange? _range;
  DateTime? _picked;
  DateTimeRange? _pickedRange;

  @override
  Widget build(BuildContext context) {
    final l10n = MaterialLocalizations.of(context);
    return DocPage(
      title: 'Calendar',
      description:
          'A month grid that picks a date or a range of dates, inline or '
          'from a field that opens it in a popover.',
      source: 'lib/src/pages/calendar_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2Calendar(
            firstDate: _first,
            lastDate: _last,
            selectedDate: _day,
            onDateSelected: (day) => setState(() => _day = day),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2Calendar` is controlled: give it the `selectedDate` and '
          'update it in `onDateSelected`. Days outside `firstDate` and '
          '`lastDate` can\'t be picked, and the header changes the month '
          'within those limits. It opens on the month of the selection, or '
          'of today; `initialMonth` chooses another, and `currentDate` sets '
          'the day marked as today.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Allowed days', level: 3),
        const DocText(
          '`selectableDayPredicate` decides which days can be picked; here '
          'weekends are refused and show dimmed.',
        ),
        ExamplePanel(
          region: 'allowed-days',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.md,
            children: [
              // #region allowed-days
              Oito2Calendar(
                firstDate: _first,
                lastDate: _last,
                selectedDate: _date,
                selectableDayPredicate: (day) => day.weekday < 6,
                onDateSelected: (day) => setState(() => _date = day),
              ),
              Text(_date == null ? 'No date' : l10n.formatFullDate(_date!)),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Range and week numbers', level: 3),
        const DocText(
          'Setting `onRangeSelected` turns on range mode, with the range in '
          '`selectedRange`. A range takes two picks, and the second may come '
          'before the first; between them the band previews the range up '
          'to the hovered or focused day. `showWeekNumbers` adds a column '
          'of ISO 8601 week numbers.',
        ),
        ExamplePanel(
          region: 'range',
          // #region range
          child: Oito2Calendar(
            firstDate: _first,
            lastDate: _last,
            selectedRange: _range,
            showWeekNumbers: true,
            onRangeSelected: (range) => setState(() => _range = range),
          ),
          // #endregion
        ),
        const DocHeading('Date picker', level: 3),
        const DocText(
          '`Oito2DatePicker` is a field-like button that shows the date and '
          'opens the calendar in a popover; a pick closes it. Like the '
          'calendar, it picks a range when `onRangeChanged` is set. It is '
          'disabled when neither `onChanged` nor `onRangeChanged` is set.',
        ),
        ExamplePanel(
          region: 'picker',
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: Oito2Spacing.md,
            runSpacing: Oito2Spacing.md,
            children: [
              // #region picker
              SizedBox(
                width: 220,
                child: Oito2DatePicker(
                  firstDate: _first,
                  lastDate: _last,
                  value: _picked,
                  labelText: 'Due date',
                  onChanged: (day) => setState(() => _picked = day),
                ),
              ),
              SizedBox(
                width: 280,
                child: Oito2DatePicker(
                  firstDate: _first,
                  lastDate: _last,
                  range: _pickedRange,
                  labelText: 'Trip',
                  onRangeChanged: (range) =>
                      setState(() => _pickedRange = range),
                ),
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Typed date', level: 3),
        const DocText(
          'To let people type the date as well, use `Oito2DateEntry`: a '
          'text field with a button that opens the same calendar.',
        ),
        ExamplePanel(
          region: 'entry',
          child: SizedBox(
            width: 260,
            // #region entry
            child: Oito2DateEntry(firstDate: _first, lastDate: _last),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each day is a button named by its full date, marked selected '
          'when picked and disabled when it can\'t be picked; today carries '
          'a hint. The month title is a live region, so the new month is '
          'announced, and the week numbers read as "Week <n>". The month '
          'buttons are named by their localized tooltips.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocText(
          'The grid takes the focus as a whole and moves a focused day:',
        ),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Left arrow` / `Right arrow`',
              'Moves to the previous or next day (mirrored in right-to-left '
                  'layouts).',
            ],
            [
              '`Up arrow` / `Down arrow`',
              'Moves to the same day a week before or after.',
            ],
            ['`Home` / `End`', 'Moves to the start or end of the week.'],
            [
              '`Page Up` / `Page Down`',
              'Moves to the same day a month before or after.',
            ],
            [
              '`Shift` + `Page Up` / `Page Down`',
              'Moves to the same day a year before or after.',
            ],
            ['`Enter` / `Space`', 'Picks the focused day.'],
            [
              '`Enter` / `Space` / `Alt` + `Down arrow` on a date picker',
              'Opens the calendar.',
            ],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2Calendar',
          'Oito2DatePicker',
          'Oito2DateEntry',
        ]),
      ],
    );
  }
}
