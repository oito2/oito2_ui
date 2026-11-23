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

/// The bandwidth of a sync schedule slot.
enum Bandwidth {
  /// Syncs at full speed.
  unlimited,

  /// Syncs at a limited speed.
  limited,

  /// Doesn't sync.
  paused,
}

/// Documents [Oito2WeekScheduleGrid]: a bandwidth schedule, half-hour
/// slots and a read-only grid.
class WeekScheduleGridPage extends StatefulWidget {
  /// Creates the week schedule grid page.
  const WeekScheduleGridPage({super.key});

  @override
  State<WeekScheduleGridPage> createState() => _WeekScheduleGridPageState();
}

class _WeekScheduleGridPageState extends State<WeekScheduleGridPage> {
  // #region values
  static const _bandwidth = [
    Oito2ScheduleValue(
      value: Bandwidth.unlimited,
      label: 'Unlimited',
      type: Oito2InfoType.success,
    ),
    Oito2ScheduleValue(
      value: Bandwidth.limited,
      label: 'Limited',
      type: Oito2InfoType.warning,
    ),
    Oito2ScheduleValue(
      value: Bandwidth.paused,
      label: 'Paused',
      type: Oito2InfoType.danger,
    ),
  ];

  // Monday is day 0; working hours are limited.
  List<Bandwidth> _schedule = [
    for (var day = 0; day < 7; day++)
      for (var hour = 0; hour < 24; hour++)
        day < 5 && hour >= 9 && hour < 18
            ? Bandwidth.limited
            : Bandwidth.unlimited,
  ];
  // #endregion

  List<Bandwidth> _halfHours = List.filled(7 * 48, Bandwidth.unlimited);

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Week Schedule Grid',
      description:
          'A week of time slots, one row per day, painted with values the '
          'app defines, such as when a sync runs at full speed, limited or '
          'paused.',
      source: 'lib/src/pages/week_schedule_grid_page.dart',
      children: [
        ExamplePanel(
          region: 'values',
          regions: const ['preview'],
          // #region preview
          child: Oito2WeekScheduleGrid<Bandwidth>(
            values: _bandwidth,
            schedule: _schedule,
            onChanged: (schedule) => setState(() => _schedule = schedule),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give the grid its `values`, each an `Oito2ScheduleValue` with the '
          'app value, a legend `label` and a `color` or a semantic `type`, '
          'and the current `schedule`. The schedule is a flat list of '
          '`7 × slotsPerDay` values, day after day from Monday (day 0, as '
          '`DateTime.weekday - 1`) to Sunday; '
          '`Oito2WeekScheduleGrid.indexOf(day, slot)` finds a cell. Rows '
          'start at the first day of the week of the locale.',
        ),
        const DocText(
          'The legend picks the value to paint. A click paints a cell and a '
          'drag paints the rectangle from the first cell to the current one, '
          'previewed while dragging. `onChanged` receives the whole new '
          'schedule; without it the grid is read-only. `paintValue` and '
          '`onPaintValueChanged` control the brush from outside.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Half-hour slots', level: 3),
        const DocText(
          '`slotsPerDay` divides the day into other slots, 48 half hours '
          'here. Cells shrink with the width down to `minCellWidth`, 16 '
          'pixels by default, and then the grid scrolls sideways; hour '
          'labels skip slots when they don\'t fit. `slotLabel` replaces '
          'the hour labels.',
        ),
        ExamplePanel(
          region: 'half-hours',
          // #region half-hours
          child: Oito2WeekScheduleGrid<Bandwidth>(
            values: _bandwidth,
            schedule: _halfHours,
            slotsPerDay: 48,
            paintValue: Bandwidth.paused,
            onChanged: (schedule) => setState(() => _halfHours = schedule),
          ),
          // #endregion
        ),
        const DocHeading('Read-only', level: 3),
        const DocText(
          'Without `onChanged`, the grid only shows the schedule and its '
          'legend.',
        ),
        ExamplePanel(
          region: 'read-only',
          // #region read-only
          child: Oito2WeekScheduleGrid<Bandwidth>(
            values: _bandwidth,
            schedule: _schedule,
            cellHeight: 20,
          ),
          // #endregion
        ),
        const DocHeading('Keyboard'),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['Arrows', 'Move the active cell'],
            ['Home / End', 'Go to the start or end of the day'],
            ['Shift + arrows, Home, End', 'Extend a rectangular selection'],
            ['Space / Enter', 'Paint the selection or the active cell'],
            ['Escape', 'Clear the selection'],
            ['1 to 9', 'Pick a value of the legend'],
          ],
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The grid is one focus stop, labelled "Weekly schedule" or '
          '`semanticsLabel`. Each cell reads its day, time range and value, '
          'such as "Monday 2:00 PM–3:00 PM, Limited", in the locale\'s '
          'names and time format, and its tap action paints it. The legend '
          'entries are buttons with a selected state; colors are never the '
          'only cue, as every cell reads its value.',
        ),
        ...apiReferenceWidgets(['Oito2WeekScheduleGrid', 'Oito2ScheduleValue']),
      ],
    );
  }
}
