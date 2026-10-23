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

/// Documents [Oito2DateEntry], [Oito2TimeEntry] and [Oito2DateTimeEntry].
class DateTimeEntryPage extends StatefulWidget {
  /// Creates the date and time entry page.
  const DateTimeEntryPage({super.key});

  @override
  State<DateTimeEntryPage> createState() => _DateTimeEntryPageState();
}

class _DateTimeEntryPageState extends State<DateTimeEntryPage> {
  DateTime? _date;
  TimeOfDay? _time;
  DateTime? _dateTime;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DocPage(
      title: 'Date and Time Entry',
      description:
          'Text fields that read a typed date, time or both, with a '
          'calendar or clock picker button.',
      source: 'lib/src/pages/date_time_entry_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.md,
              children: [
                // #region preview
                Oito2DateEntry(
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onChanged: (date) => setState(() => _date = date),
                ),
                Text('Value: ${_date ?? '—'}', style: textTheme.bodySmall),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2DateEntry` reads the locale\'s compact date format, such '
          'as mm/dd/yyyy in American English, and accepts dates from '
          '`firstDate` to `lastDate`. `onChanged` receives each valid date, '
          'or null when the field is emptied; text that doesn\'t parse '
          'doesn\'t call it, so the last valid date stays reported. '
          '`initialDate` fills the field at start.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The format, the hint, the labels and the error messages come '
          'from `MaterialLocalizations`, so they follow the app language. '
          'An error shows only after the field loses the focus or is '
          'submitted, so partial input isn\'t flagged while typing. The '
          'calendar button opens an `Oito2Calendar` in a popover; '
          '`showPickerButton` hides it.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Time', level: 3),
        const DocText(
          '`Oito2TimeEntry` accepts `H:MM` and `HH:MM`, also with `.` or '
          '`h` as the separator, and an AM/PM marker in 12-hour form. It '
          'shows the time in the locale\'s format, following the platform '
          '24-hour setting, and its clock button opens the time picker '
          'dialog.',
        ),
        ExamplePanel(
          region: 'time',
          child: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.md,
              children: [
                // #region time
                Oito2TimeEntry(
                  onChanged: (time) => setState(() => _time = time),
                ),
                Text(
                  'Value: ${_time?.format(context) ?? '—'}',
                  style: textTheme.bodySmall,
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Date and time', level: 3),
        const DocText(
          '`Oito2DateTimeEntry` puts a date entry and a time entry side by '
          'side and reports one `DateTime`; an empty time means midnight, '
          'and without a date the value is null. `onChanged` waits while '
          'either field holds invalid text.',
        ),
        ExamplePanel(
          region: 'date-time',
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.md,
              children: [
                // #region date-time
                Oito2DateTimeEntry(
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onChanged: (value) => setState(() => _dateTime = value),
                ),
                Text('Value: ${_dateTime ?? '—'}', style: textTheme.bodySmall),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Required date and allowed days', level: 3),
        const DocText(
          'With `acceptEmpty` set to false an empty field is an error. '
          '`selectableDayPredicate` refuses days, here weekends, both typed '
          'and in the calendar. `onErrorChanged` receives the error message '
          'when the text stops being valid, and null when it is valid '
          'again.',
        ),
        ExamplePanel(
          region: 'errors',
          child: SizedBox(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.md,
              children: [
                // #region errors
                Oito2DateEntry(
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  labelText: 'Meeting day',
                  acceptEmpty: false,
                  selectableDayPredicate: (day) => day.weekday < 6,
                  onErrorChanged: (error) => setState(() => _error = error),
                ),
                Text('Error: ${_error ?? '—'}', style: textTheme.bodySmall),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each field has a visible label, the localized "Enter Date" or '
          '"Enter time" by default, and its error shows below it. The '
          'picker buttons are named by their localized tooltips.',
        ),
        ...apiReferenceWidgets([
          'Oito2DateEntry',
          'Oito2TimeEntry',
          'Oito2DateTimeEntry',
        ]),
      ],
    );
  }
}
