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

import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

enum _Speed { full, limited, paused }

const _values = [
  Oito2ScheduleValue(
    value: _Speed.full,
    label: 'Unlimited',
    type: Oito2InfoType.success,
  ),
  Oito2ScheduleValue(
    value: _Speed.limited,
    label: 'Limited',
    type: Oito2InfoType.warning,
  ),
  Oito2ScheduleValue(
    value: _Speed.paused,
    label: 'Paused',
    type: Oito2InfoType.danger,
  ),
];

/// A schedule of [slots] slots a day at full speed.
List<_Speed> _full([int slots = 24]) => List.filled(7 * slots, _Speed.full);

/// Holds a schedule and repaints the grid with each change.
class _Host extends StatefulWidget {
  const _Host({this.onChanged, this.autofocus = false, this.editable = true});

  final ValueChanged<List<_Speed>>? onChanged;
  final bool autofocus;
  final bool editable;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  List<_Speed> schedule = _full();

  @override
  Widget build(BuildContext context) {
    return Oito2WeekScheduleGrid<_Speed>(
      values: _values,
      schedule: schedule,
      paintValue: null,
      autofocus: widget.autofocus,
      onChanged: widget.editable
          ? (next) {
              setState(() => schedule = next);
              widget.onChanged?.call(next);
            }
          : null,
    );
  }
}

/// Pumps [child] in an app for [locale] with the oito2 and Material
/// localizations.
Future<void> _pumpLocalized(
  WidgetTester tester,
  Widget child, {
  required Locale locale,
}) async {
  tester.view.physicalSize = const Size(1000, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('en', 'GB'),
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        Oito2Localizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      theme: Oito2Theme.fromColors(
        Oito2ColorTheme.light(),
        platform: testPlatform,
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

/// Returns the fill color of the cell read as [label].
Color? _cellColor(WidgetTester tester, String label) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.bySemanticsLabel(label),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (box.decoration as BoxDecoration).color;
}

/// The index of [day] (Monday 0) at [hour] in a 24-slot schedule.
int _at(int day, int hour) => Oito2WeekScheduleGrid.indexOf(day, hour);

void main() {
  group('Oito2WeekScheduleGrid', () {
    testWidgets('reads each cell as its day, time range and value', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(tester, const _Host());
      expect(
        find.bySemanticsLabel('Monday 2:00 PM–3:00 PM, Unlimited'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Weekly schedule'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a click paints a cell with the brush', (tester) async {
      final changes = <List<_Speed>>[];
      await pumpOito2(tester, _Host(onChanged: changes.add));
      await tester.tap(find.bySemanticsLabel(RegExp('^Tuesday 3:00 AM')));
      await tester.pump();
      // The first legend value is the default brush, so painting it over
      // itself reports nothing.
      expect(changes, isEmpty);
      await tester.tap(find.text('Paused'));
      await tester.tap(find.bySemanticsLabel(RegExp('^Tuesday 3:00 AM')));
      await tester.pump();
      expect(changes, hasLength(1));
      expect(changes.last[_at(1, 3)], _Speed.paused);
      expect(changes.last.where((v) => v == _Speed.paused), hasLength(1));
    });

    testWidgets('a drag previews then paints a rectangle', (tester) async {
      final changes = <List<_Speed>>[];
      await pumpOito2(tester, _Host(onChanged: changes.add));
      await tester.tap(find.text('Limited'));
      await tester.pump();
      final from = tester.getCenter(
        find.bySemanticsLabel(RegExp('^Monday 1:00 AM')),
      );
      final to = tester.getCenter(
        find.bySemanticsLabel(RegExp('^Wednesday 4:00 AM')),
      );
      final full = _cellColor(tester, 'Monday 9:00 AM–10:00 AM, Unlimited');
      final gesture = await tester.startGesture(from);
      await gesture.moveBy(const Offset(0, 20));
      await gesture.moveTo(to);
      await tester.pump();
      expect(changes, isEmpty);
      final previewed = _cellColor(
        tester,
        'Tuesday 2:00 AM–3:00 AM, Unlimited',
      );
      expect(previewed, isNot(full));
      expect(_cellColor(tester, 'Thursday 2:00 AM–3:00 AM, Unlimited'), full);
      await gesture.up();
      await tester.pump();
      expect(changes, hasLength(1));
      final painted = [
        for (var i = 0; i < changes.single.length; i++)
          if (changes.single[i] == _Speed.limited) i,
      ];
      expect(painted, [
        for (final day in [0, 1, 2])
          for (var hour = 1; hour <= 4; hour++) _at(day, hour),
      ]);
      expect(_cellColor(tester, 'Tuesday 2:00 AM–3:00 AM, Limited'), previewed);
    });

    testWidgets('the keyboard moves, selects and paints', (tester) async {
      final changes = <List<_Speed>>[];
      await pumpOito2(tester, _Host(onChanged: changes.add, autofocus: true));
      await tester.pump();
      // Picks the third value with its digit.
      await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
      // The first row is Sunday in English; moves to Monday 1:00.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(changes.last[_at(0, 1)], _Speed.paused);
      expect(changes.last.where((v) => v == _Speed.paused), hasLength(1));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(
        [
          for (var i = 0; i < changes.last.length; i++)
            if (changes.last[i] == _Speed.paused) i,
        ],
        [_at(0, 1), _at(0, 2), _at(1, 1), _at(1, 2)],
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(changes.last[_at(1, 23)], _Speed.limited);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(changes.last[_at(1, 0)], _Speed.limited);
    });

    testWidgets('keeps the active cell inside fewer slots a day', (
      tester,
    ) async {
      final changes = <List<_Speed>>[];
      var slots = 48;
      late StateSetter setSlots;
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setSlots = setState;
            return Oito2WeekScheduleGrid<_Speed>(
              values: _values,
              schedule: _full(slots),
              slotsPerDay: slots,
              paintValue: _Speed.paused,
              autofocus: true,
              onChanged: changes.add,
            );
          },
        ),
      );
      await tester.pump();
      // The first row is Sunday in English, the last day of the schedule.
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      setSlots(() => slots = 24);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        [
          for (var i = 0; i < changes.last.length; i++)
            if (changes.last[i] == _Speed.paused) i,
        ],
        [_at(6, 23)],
      );
    });

    testWidgets('the legend marks the brush as selected', (tester) async {
      final handle = tester.ensureSemantics();
      var picked = <_Speed>[];
      await pumpOito2(
        tester,
        Oito2WeekScheduleGrid<_Speed>(
          values: _values,
          schedule: _full(),
          onChanged: (_) {},
          onPaintValueChanged: (value) => picked = [...picked, value],
        ),
      );
      final unlimited = tester
          .getSemantics(find.bySemanticsLabel('Unlimited'))
          .flagsCollection;
      expect(unlimited.isButton, isTrue);
      expect(unlimited.isSelected, Tristate.isTrue);
      expect(unlimited.isInMutuallyExclusiveGroup, isTrue);
      await tester.tap(find.text('Paused'));
      await tester.pump();
      expect(picked, [_Speed.paused]);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Paused'))
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      handle.dispose();
    });

    testWidgets('rows start at the first day of the locale', (tester) async {
      Future<List<String>> rows(Locale locale, List<String> names) async {
        await _pumpLocalized(
          tester,
          Oito2WeekScheduleGrid<_Speed>(values: _values, schedule: _full()),
          locale: locale,
        );
        return [...names]..sort(
          (a, b) => tester
              .getTopLeft(find.text(a))
              .dy
              .compareTo(tester.getTopLeft(find.text(b)).dy),
        );
      }

      expect((await rows(const Locale('en'), ['Mon', 'Sun'])).first, 'Sun');
      expect(
        (await rows(const Locale('en', 'GB'), ['Mon', 'Sun'])).first,
        'Mon',
      );
      expect(
        (await rows(const Locale('pt', 'BR'), ['seg.', 'dom.'])).first,
        'dom.',
      );
    });

    testWidgets('reads cells in Portuguese', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpLocalized(
        tester,
        Oito2WeekScheduleGrid<_Speed>(values: _values, schedule: _full()),
        locale: const Locale('pt', 'BR'),
      );
      expect(
        find.bySemanticsLabel('segunda-feira 14:00–15:00, Unlimited'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Agenda semanal'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('is read-only without onChanged', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(tester, const _Host(editable: false));
      await tester.tap(find.bySemanticsLabel(RegExp('^Monday 3:00 AM')));
      await tester.pump();
      final cell = tester.getSemantics(
        find.bySemanticsLabel(RegExp('^Monday 3:00 AM')),
      );
      expect(cell.flagsCollection.isButton, isFalse);
      expect(cell.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Paused'))
            .flagsCollection
            .isButton,
        isFalse,
      );
      handle.dispose();
    });

    testWidgets('the tap action of a cell paints it', (tester) async {
      final handle = tester.ensureSemantics();
      final changes = <List<_Speed>>[];
      await pumpOito2(tester, _Host(onChanged: changes.add));
      await tester.tap(find.text('Limited'));
      await tester.pump();
      tester.semantics.tap(
        find.semantics.byLabel('Friday 8:00 PM–9:00 PM, Unlimited'),
      );
      await tester.pump();
      expect(changes.last[_at(4, 20)], _Speed.limited);
      handle.dispose();
    });

    testWidgets('scrolls sideways below the narrowest cells', (tester) async {
      await pumpOito2(
        tester,
        SizedBox(
          width: 300,
          child: Oito2WeekScheduleGrid<_Speed>(
            values: _values,
            schedule: _full(48),
            slotsPerDay: 48,
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
      final cell = find.bySemanticsLabel(RegExp('^Monday 2:30 PM–3:00 PM'));
      expect(tester.getSize(cell).width, 16);
    });

    testWidgets('fills the width and skips hour labels that do not fit', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        SizedBox(
          width: 500,
          child: Oito2WeekScheduleGrid<_Speed>(
            values: _values,
            schedule: _full(),
          ),
        ),
      );
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.text('12 AM'), findsOneWidget);
      expect(find.text('1 AM'), findsNothing);
    });

    test('dayOfRow starts the rows at the first day of the week', () {
      List<int> days(int first) => [
        for (var row = 0; row < 7; row++)
          Oito2WeekScheduleGrid.dayOfRow(row, firstDayOfWeekIndex: first),
      ];
      expect(days(0), [6, 0, 1, 2, 3, 4, 5]);
      expect(days(1), [0, 1, 2, 3, 4, 5, 6]);
      expect(days(6), [5, 6, 0, 1, 2, 3, 4]);
    });
  });
}
