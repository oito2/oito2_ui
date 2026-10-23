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
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

const _fruits = [
  Oito2Segment(value: 'apple', label: Text('Apple')),
  Oito2Segment(value: 'banana', label: Text('Banana')),
  Oito2Segment(value: 'cherry', label: Text('Cherry'), enabled: false),
  Oito2Segment(value: 'date', label: Text('Date')),
];

const _styles = [
  Oito2ToggleItem(value: 'b', child: Icon(LucideIcons.bold), tooltip: 'Bold'),
  Oito2ToggleItem(
    value: 'i',
    child: Icon(LucideIcons.italic),
    tooltip: 'Italic',
  ),
  Oito2ToggleItem(
    value: 'u',
    child: Icon(LucideIcons.underline),
    tooltip: 'Underline',
  ),
];

void main() {
  group('Oito2SegmentGroup', () {
    Future<List<String>> pumpGroup(WidgetTester tester) async {
      final changes = <String>[];
      var selected = 'apple';
      await pumpOito2(
        tester,
        Center(
          child: StatefulBuilder(
            builder: (context, setState) => Oito2SegmentGroup<String>(
              segments: _fruits,
              selected: selected,
              onChanged: (v) => setState(() {
                changes.add(v);
                selected = v;
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return changes;
    }

    Rect markerRect(WidgetTester tester) => tester.getRect(
      find.descendant(
        of: find.byType(AnimatedPositioned),
        matching: find.byType(DecoratedBox),
      ),
    );

    testWidgets('selects by tap and slides the marker there', (tester) async {
      final changes = await pumpGroup(tester);
      expect(
        markerRect(tester).center.dx,
        moreOrLessEquals(tester.getCenter(find.text('Apple')).dx, epsilon: 1),
      );
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(changes, ['banana']);
      expect(
        markerRect(tester).center.dx,
        moreOrLessEquals(tester.getCenter(find.text('Banana')).dx, epsilon: 1),
      );
      await tester.tap(find.text('Cherry'));
      await tester.pumpAndSettle();
      expect(changes, ['banana']);
    });

    testWidgets('arrow keys select the next enabled segment', (tester) async {
      final changes = await pumpGroup(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(changes, ['banana', 'date']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(changes.last, 'apple');
    });

    testWidgets('reads as a group of checked choices', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpGroup(tester);
      expect(
        tester.getSemantics(find.text('Apple')),
        isSemantics(
          label: 'Apple',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('Oito2ToggleGroup', () {
    Future<List<Set<String>>> pumpGroup(
      WidgetTester tester, {
      bool multiple = false,
      bool deselectable = true,
      Set<String> initial = const {},
    }) async {
      final changes = <Set<String>>[];
      var selected = initial;
      await pumpOito2(
        tester,
        Center(
          child: StatefulBuilder(
            builder: (context, setState) => Oito2ToggleGroup<String>(
              items: _styles,
              selected: selected,
              multiple: multiple,
              deselectable: deselectable,
              onChanged: (v) => setState(() {
                changes.add(v);
                selected = v;
              }),
            ),
          ),
        ),
      );
      return changes;
    }

    testWidgets('single mode keeps one item on and can turn it off', (
      tester,
    ) async {
      final changes = await pumpGroup(tester);
      await tester.tap(find.byIcon(LucideIcons.bold));
      await tester.pump();
      await tester.tap(find.byIcon(LucideIcons.italic));
      await tester.pump();
      await tester.tap(find.byIcon(LucideIcons.italic));
      await tester.pump();
      expect(changes, [
        {'b'},
        {'i'},
        <String>{},
      ]);
    });

    testWidgets('a non-deselectable single group keeps its item on', (
      tester,
    ) async {
      final changes = await pumpGroup(
        tester,
        deselectable: false,
        initial: {'b'},
      );
      await tester.tap(find.byIcon(LucideIcons.bold));
      await tester.pump();
      expect(changes, isEmpty);
    });

    testWidgets('multiple mode toggles items on their own', (tester) async {
      final changes = await pumpGroup(tester, multiple: true);
      await tester.tap(find.byIcon(LucideIcons.bold));
      await tester.pump();
      await tester.tap(find.byIcon(LucideIcons.underline));
      await tester.pump();
      await tester.tap(find.byIcon(LucideIcons.bold));
      await tester.pump();
      expect(changes, [
        {'b'},
        {'b', 'u'},
        {'u'},
      ]);
    });

    testWidgets('arrows move focus and Space toggles', (tester) async {
      final handle = tester.ensureSemantics();
      final changes = await pumpGroup(tester, multiple: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(changes, [
        {'i'},
      ]);
      expect(
        tester.getSemantics(find.byIcon(LucideIcons.italic)),
        isSemantics(
          label: 'Italic',
          isButton: true,
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          isFocused: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });
}
