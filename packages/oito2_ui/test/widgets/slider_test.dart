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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

const _marks = [
  Oito2SliderMark(0, label: '0%'),
  Oito2SliderMark(50, label: '50%'),
  Oito2SliderMark(100, label: '100%'),
];

void main() {
  group('Oito2Slider', () {
    testWidgets('shows the label and value and changes with the keyboard', (
      tester,
    ) async {
      var value = 40.0;
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 300,
            child: Oito2Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 10,
              label: const Text('Volume'),
              valueText: (v) => '${v.round()}%',
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      // A tap at the middle of the track picks 50; once focused, an arrow
      // key adds one of the ten divisions.
      await tester.tap(find.byType(Slider));
      await tester.pump();
      expect(value, 50);
      expect(find.text('50%'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 60);
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('marks sit under their values on the track', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            child: Oito2Slider(
              value: 50,
              min: 0,
              max: 100,
              marks: _marks,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      final track = tester.getRect(find.byType(Slider));
      // The track runs from one thumb radius inside each end.
      expect(
        tester.getCenter(find.text('0%')).dx,
        moreOrLessEquals(track.left + 10, epsilon: 0.5),
      );
      expect(
        tester.getCenter(find.text('50%')).dx,
        moreOrLessEquals(track.center.dx, epsilon: 0.5),
      );
      expect(
        tester.getCenter(find.text('100%')).dx,
        moreOrLessEquals(track.right - 10, epsilon: 0.5),
      );
    });

    testWidgets('a vertical slider stands at its length with side marks', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        Center(
          child: Oito2Slider(
            value: 30,
            min: 0,
            max: 100,
            orientation: Axis.vertical,
            length: 200,
            marks: _marks,
            onChanged: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final track = tester.getRect(find.byType(RotatedBox));
      expect(track.height, 200);
      expect(tester.getCenter(find.text('100%')).dy, track.top + 10);
      expect(tester.getCenter(find.text('0%')).dy, track.bottom - 10);
      expect(tester.getTopLeft(find.text('50%')).dx, greaterThan(track.right));
    });
  });

  group('Oito2Slider vertical', () {
    for (final direction in TextDirection.values) {
      testWidgets('keeps its minimum at the bottom in ${direction.name}', (
        tester,
      ) async {
        double? value;
        await pumpOito2(
          tester,
          Center(
            child: Oito2Slider(
              value: 50,
              max: 100,
              orientation: Axis.vertical,
              length: 200,
              onChanged: (v) => value = v,
            ),
          ),
          textDirection: direction,
        );
        final track = tester.getRect(find.byType(RotatedBox));
        await tester.tapAt(Offset(track.center.dx, track.bottom - 12));
        expect(value, lessThan(10));
      });
    }
  });

  group('Oito2RangeSlider', () {
    testWidgets('shows the range and lines its track up with the marks', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            child: Oito2RangeSlider(
              values: const RangeValues(20, 70),
              min: 0,
              max: 100,
              valueText: (v) => '${v.round()}',
              marks: _marks,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('20 – 70'), findsOneWidget);
      final slider = tester.getRect(find.byType(RangeSlider));
      expect(
        tester.getCenter(find.text('0%')).dx,
        moreOrLessEquals(slider.left + 10, epsilon: 0.5),
      );
      expect(
        tester.getCenter(find.text('100%')).dx,
        moreOrLessEquals(slider.right - 10, epsilon: 0.5),
      );
    });
  });
}
