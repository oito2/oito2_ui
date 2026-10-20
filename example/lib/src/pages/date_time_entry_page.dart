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

/// Shows [Oito2DateEntry], [Oito2TimeEntry] and [Oito2DateTimeEntry].
class DateTimeEntryPage extends StatefulWidget {
  /// Creates the date and time entry page.
  const DateTimeEntryPage({super.key});

  @override
  State<DateTimeEntryPage> createState() => _DateTimeEntryPageState();
}

class _DateTimeEntryPageState extends State<DateTimeEntryPage> {
  String _value = '—';

  @override
  Widget build(BuildContext context) {
    void show(Object? value) =>
        setState(() => _value = value?.toString() ?? '—');
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Date',
          children: [
            SizedBox(
              width: 260,
              child: Oito2DateEntry(
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onChanged: show,
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Time',
          children: [
            SizedBox(width: 200, child: Oito2TimeEntry(onChanged: show)),
          ],
        ),
        ShowcaseSection(
          'Date and time',
          children: [
            SizedBox(
              width: 480,
              child: Oito2DateTimeEntry(
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onChanged: show,
              ),
            ),
          ],
        ),
        Text('Value: $_value', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
