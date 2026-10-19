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

import 'test_app.dart';

void main() {
  testWidgets('Oito2FocusBorder shows a ring on keyboard focus only', (
    tester,
  ) async {
    await pumpOito2(
      tester,
      Center(
        child: Oito2FocusBorder(
          child: TextButton(onPressed: () {}, child: const Text('Go')),
        ),
      ),
    );
    Border? ring() {
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(Oito2FocusBorder),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return (box.decoration as BoxDecoration).border as Border?;
    }

    expect(ring(), isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(ring()!.top.color, Oito2ColorTheme.light().semantic.primaryText);
    expect(ring()!.top.width, Oito2Sizes.focusBorderWidth);
  });

  testWidgets('Oito2EdgeFocusInterceptor keeps arrow focus inside', (
    tester,
  ) async {
    final inside = [FocusNode(), FocusNode()];
    final outside = FocusNode();
    addTearDown(() {
      for (final node in [...inside, outside]) {
        node.dispose();
      }
    });
    await pumpOito2(
      tester,
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Oito2EdgeFocusInterceptor(
              child: Row(
                children: [
                  TextButton(
                    focusNode: inside[0],
                    onPressed: () {},
                    child: const Text('A'),
                  ),
                  TextButton(
                    focusNode: inside[1],
                    onPressed: () {},
                    child: const Text('B'),
                  ),
                ],
              ),
            ),
            TextButton(
              focusNode: outside,
              onPressed: () {},
              child: const Text('C'),
            ),
          ],
        ),
      ),
    );
    inside[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(inside[1].hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(inside[1].hasFocus, isTrue);
    expect(outside.hasFocus, isFalse);
  });

  testWidgets('Oito2ScrollViewUndershoot follows the scroll position', (
    tester,
  ) async {
    await pumpOito2(
      tester,
      SizedBox(
        height: 300,
        child: Oito2ScrollViewUndershoot(
          child: ListView(
            children: [
              for (var i = 0; i < 40; i++)
                SizedBox(height: 40, child: Text('$i')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    List<double> opacities() => tester
        .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
        .map((o) => o.opacity)
        .toList();
    expect(opacities(), [0, 1]);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(opacities(), [1, 1]);

    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(opacities(), [1, 0]);
  });

  testWidgets('Oito2DiagonalClip keeps the triangle of its corner', (
    tester,
  ) async {
    var taps = 0;
    await pumpOito2(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox.square(
          dimension: 100,
          child: Oito2DiagonalClip(
            corner: Oito2DiagonalCorner.topLeft,
            child: GestureDetector(
              onTap: () => taps++,
              child: const ColoredBox(color: Color(0xFF000000)),
            ),
          ),
        ),
      ),
    );
    await tester.tapAt(const Offset(10, 10));
    expect(taps, 1);
    await tester.tapAt(const Offset(90, 90));
    expect(taps, 1);
  });

  testWidgets('Oito2Draggable moves with the pointer and the keyboard', (
    tester,
  ) async {
    final positions = <Offset>[];
    await pumpOito2(
      tester,
      Stack(
        children: [
          Oito2Draggable(
            initialPosition: const Offset(20, 20),
            onMoved: positions.add,
            child: const SizedBox.square(
              dimension: 40,
              child: ColoredBox(color: Color(0xFF3584E4)),
            ),
          ),
        ],
      ),
    );
    await tester.drag(find.byType(ColoredBox), const Offset(30, 10));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(ColoredBox)), const Offset(50, 30));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(tester.getTopLeft(find.byType(ColoredBox)), const Offset(50, 38));
    expect(positions.last, const Offset(50, 38));
  });

  testWidgets('Oito2EdgeFocusInterceptor lets Tab leave the group', (
    tester,
  ) async {
    final last = FocusNode();
    final outside = FocusNode();
    addTearDown(last.dispose);
    addTearDown(outside.dispose);
    await pumpOito2(
      tester,
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Oito2EdgeFocusInterceptor(
              child: TextButton(
                focusNode: last,
                onPressed: () {},
                child: const Text('A'),
              ),
            ),
            TextButton(
              focusNode: outside,
              onPressed: () {},
              child: const Text('B'),
            ),
          ],
        ),
      ),
    );
    last.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(outside.hasFocus, isTrue);
  });
}
