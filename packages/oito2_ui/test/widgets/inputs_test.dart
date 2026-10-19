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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'test_app.dart';

void main() {
  group('Oito2SearchField', () {
    testWidgets('clears with the button and with Escape', (tester) async {
      final changes = <String>[];
      var cleared = 0;
      var escaped = 0;
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            child: Oito2SearchField(
              onChanged: changes.add,
              onClear: () => cleared++,
              onEscape: () => escaped++,
            ),
          ),
        ),
      );
      expect(find.text('Search'), findsOneWidget);
      expect(find.byTooltip('Clear text'), findsNothing);

      await tester.enterText(find.byType(TextField), 'files');
      await tester.pump();
      expect(find.byTooltip('Clear text'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear text'));
      await tester.pump();
      expect(find.text('files'), findsNothing);
      expect(cleared, 1);
      expect(changes.last, '');

      await tester.enterText(find.byType(TextField), 'docs');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('docs'), findsNothing);
      expect(cleared, 2);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(escaped, 1);
    });
  });

  testWidgets('Oito2SearchTitleField toggles between title and search', (
    tester,
  ) async {
    var active = false;
    await pumpOito2(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Center(
          child: Oito2SearchTitleField(
            title: const Text('Files'),
            searchActive: active,
            onSearchActiveChanged: (v) => setState(() => active = v),
          ),
        ),
      ),
    );
    expect(find.text('Files'), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.search));
    await tester.pumpAndSettle();
    expect(active, isTrue);
    expect(find.byType(Oito2SearchField), findsOneWidget);
    expect(find.text('Files'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(active, isFalse);
    expect(find.text('Files'), findsOneWidget);
  });

  group('Oito2DateEntry', () {
    Widget entry(List<DateTime?> values, {bool acceptEmpty = true}) => Center(
      child: SizedBox(
        width: 300,
        child: Oito2DateEntry(
          firstDate: DateTime(2020),
          lastDate: DateTime(2030, 12, 31),
          acceptEmpty: acceptEmpty,
          onChanged: values.add,
        ),
      ),
    );

    testWidgets('reports valid dates in the locale format', (tester) async {
      final values = <DateTime?>[];
      await pumpOito2(tester, entry(values));
      expect(find.text('mm/dd/yyyy'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '03/15/2026');
      expect(values.last, DateTime(2026, 3, 15));
    });

    testWidgets('shows format and range errors after submitting', (
      tester,
    ) async {
      final values = <DateTime?>[];
      await pumpOito2(tester, entry(values));
      await tester.enterText(find.byType(TextField), '15/45/2026');
      await tester.pump();
      expect(find.text('Invalid format.'), findsNothing);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('Invalid format.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '01/01/2040');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('Out of range.'), findsOneWidget);
      expect(values, isEmpty);

      await tester.enterText(find.byType(TextField), '01/01/2025');
      await tester.pump();
      expect(find.text('Out of range.'), findsNothing);
      expect(values.last, DateTime(2025));
    });

    testWidgets('an empty field reports null when accepted', (tester) async {
      final values = <DateTime?>[];
      await pumpOito2(tester, entry(values));
      await tester.enterText(find.byType(TextField), '01/01/2025');
      await tester.enterText(find.byType(TextField), '');
      expect(values.last, isNull);
    });

    testWidgets('the calendar button picks a date', (tester) async {
      final values = <DateTime?>[];
      await pumpOito2(tester, entry(values));
      await tester.tap(find.byIcon(LucideIcons.calendar));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(values.single, isNotNull);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('Oito2TimeEntry', () {
    test('parseTime accepts 24-hour and 12-hour input', () {
      expect(
        Oito2TimeEntry.parseTime('9:05'),
        const TimeOfDay(hour: 9, minute: 5),
      );
      expect(
        Oito2TimeEntry.parseTime('21.30'),
        const TimeOfDay(hour: 21, minute: 30),
      );
      expect(
        Oito2TimeEntry.parseTime('7h45'),
        const TimeOfDay(hour: 7, minute: 45),
      );
      expect(
        Oito2TimeEntry.parseTime('12:00 AM'),
        const TimeOfDay(hour: 0, minute: 0),
      );
      expect(
        Oito2TimeEntry.parseTime('1:15 pm'),
        const TimeOfDay(hour: 13, minute: 15),
      );
      expect(
        Oito2TimeEntry.parseTime('3:00 p'),
        const TimeOfDay(hour: 15, minute: 0),
      );
    });

    test('parseTime rejects invalid input', () {
      for (final text in [
        '24:00',
        '9:60',
        '13:00 pm',
        '0:30 am',
        'noon',
        '930',
      ]) {
        expect(Oito2TimeEntry.parseTime(text), isNull, reason: text);
      }
    });

    testWidgets('reports valid times and flags invalid ones', (tester) async {
      final values = <TimeOfDay?>[];
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 220,
            child: Oito2TimeEntry(
              initialTime: const TimeOfDay(hour: 14, minute: 5),
              onChanged: values.add,
            ),
          ),
        ),
      );
      expect(find.text('2:05 PM'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '18:45');
      expect(values.last, const TimeOfDay(hour: 18, minute: 45));

      await tester.enterText(find.byType(TextField), '25:00');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('Enter a valid time'), findsOneWidget);
    });
  });

  testWidgets('Oito2DateTimeEntry combines both fields', (tester) async {
    final values = <DateTime?>[];
    await pumpOito2(
      tester,
      Center(
        child: SizedBox(
          width: 520,
          child: Oito2DateTimeEntry(
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            onChanged: values.add,
          ),
        ),
      ),
    );
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '06/01/2026');
    expect(values.last, DateTime(2026, 6));
    await tester.enterText(fields.last, '08:30');
    expect(values.last, DateTime(2026, 6, 1, 8, 30));
  });

  group('Oito2SegmentedEntry', () {
    Widget entry(List<List<String>> values) => Center(
      child: Oito2SegmentedEntry(
        segments: const [
          Oito2EntrySegment(length: 3, hint: '000'),
          Oito2EntrySegment(length: 3, hint: '000'),
          Oito2EntrySegment(length: 3, hint: '000'),
        ],
        onChanged: values.add,
      ),
    );

    testWidgets('moves to the next segment when one fills up', (tester) async {
      final values = <List<String>>[];
      await pumpOito2(tester, entry(values));
      final fields = find.byType(TextField);
      await tester.tap(fields.first);
      await tester.enterText(fields.first, '192');
      await tester.pump();
      final second = tester.widget<TextField>(fields.at(1));
      expect(second.focusNode!.hasFocus, isTrue);
      expect(values.last, ['192', '', '']);
    });

    testWidgets('keeps only digits up to the segment length', (tester) async {
      final values = <List<String>>[];
      await pumpOito2(tester, entry(values));
      await tester.enterText(find.byType(TextField).first, '1a2b3c4');
      expect(values.last.first, '123');
    });

    testWidgets('Backspace on an empty segment goes back', (tester) async {
      await pumpOito2(tester, entry([]));
      final fields = find.byType(TextField);
      await tester.tap(fields.at(1));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(
        tester.widget<TextField>(fields.first).focusNode!.hasFocus,
        isTrue,
      );
    });

    testWidgets('labels each segment', (tester) async {
      await pumpOito2(tester, entry([]));
      expect(find.bySemanticsLabel(RegExp('Part 2 of 3')), findsOneWidget);
    });
  });
}
