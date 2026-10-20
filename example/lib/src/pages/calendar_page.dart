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

/// Shows [Oito2Calendar] and [Oito2DatePicker] for dates and ranges.
class CalendarPage extends StatefulWidget {
  /// Creates the calendar page.
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _first = DateTime(2020);
  final _last = DateTime(2030, 12, 31);
  DateTime? _date;
  DateTimeRange? _range;
  DateTime? _picked;
  DateTimeRange? _pickedRange;

  @override
  Widget build(BuildContext context) {
    final l10n = MaterialLocalizations.of(context);
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Single date, weekends refused; arrows, Page Up/Down, Enter',
          children: [
            Oito2Calendar(
              firstDate: _first,
              lastDate: _last,
              selectedDate: _date,
              selectableDayPredicate: (d) => d.weekday < 6,
              onDateSelected: (d) => setState(() => _date = d),
            ),
            Text(_date == null ? 'No date' : l10n.formatFullDate(_date!)),
          ],
        ),
        ShowcaseSection(
          'Range with week numbers',
          children: [
            Oito2Calendar(
              firstDate: _first,
              lastDate: _last,
              selectedRange: _range,
              showWeekNumbers: true,
              onRangeSelected: (r) => setState(() => _range = r),
            ),
          ],
        ),
        ShowcaseSection(
          'Oito2DatePicker and Oito2DateEntry',
          children: [
            SizedBox(
              width: 220,
              child: Oito2DatePicker(
                firstDate: _first,
                lastDate: _last,
                value: _picked,
                labelText: 'Due date',
                onChanged: (d) => setState(() => _picked = d),
              ),
            ),
            SizedBox(
              width: 280,
              child: Oito2DatePicker(
                firstDate: _first,
                lastDate: _last,
                range: _pickedRange,
                labelText: 'Trip',
                onRangeChanged: (r) => setState(() => _pickedRange = r),
              ),
            ),
            SizedBox(
              width: 220,
              child: Oito2DateEntry(firstDate: _first, lastDate: _last),
            ),
          ],
        ),
      ],
    );
  }
}
