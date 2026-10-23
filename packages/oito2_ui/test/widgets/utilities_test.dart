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

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

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

  for (final (name, axis, direction, before) in [
    ('a reversed list', Axis.vertical, TextDirection.ltr, 1.0),
    ('a right-to-left row', Axis.horizontal, TextDirection.rtl, 0.0),
    ('a reversed right-to-left row', Axis.horizontal, TextDirection.rtl, 1.0),
  ]) {
    testWidgets('Oito2ScrollViewUndershoot shades the right edges of $name', (
      tester,
    ) async {
      final reverse = name.contains('reversed');
      await pumpOito2(
        tester,
        SizedBox(
          height: 300,
          width: 300,
          child: Oito2ScrollViewUndershoot(
            child: ListView(
              scrollDirection: axis,
              reverse: reverse,
              children: [
                for (var i = 0; i < 40; i++)
                  SizedBox.square(dimension: 40, child: Text('$i')),
              ],
            ),
          ),
        ),
        textDirection: direction,
      );
      await tester.pumpAndSettle();
      // At the scroll start, only the edge where the content continues is
      // shaded: the start shadow comes first.
      expect(
        tester
            .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
            .map((o) => o.opacity)
            .toList(),
        [before, 1 - before],
      );
    });
  }

  testWidgets('Oito2ScrollViewUndershoot follows a scroll view that shrinks '
      'while scrolled', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var count = 40;
    late StateSetter setCount;
    await pumpOito2(
      tester,
      SizedBox(
        height: 300,
        child: StatefulBuilder(
          builder: (context, setState) {
            setCount = setState;
            // Laid out inside a LayoutBuilder, the list settles while the
            // tree is still being built.
            return LayoutBuilder(
              builder: (context, _) => Oito2ScrollViewUndershoot(
                child: ListView(
                  controller: controller,
                  children: [
                    for (var i = 0; i < count; i++)
                      SizedBox(height: 40, child: Text('$i')),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pumpAndSettle();
    // Fewer items leave the position past the end, so the list settles
    // back while it lays out.
    setCount(() => count = 10);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester
          .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
          .map((o) => o.opacity)
          .toList(),
      [1, 0],
    );
  });

  testWidgets('Oito2ScrollViewUndershoot ignores nested scroll views', (
    tester,
  ) async {
    await pumpOito2(
      tester,
      SizedBox(
        height: 300,
        child: Oito2ScrollViewUndershoot(
          child: ListView(
            children: [
              SizedBox(
                height: 60,
                child: ListView(
                  key: const Key('inner'),
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var i = 0; i < 40; i++)
                      SizedBox(width: 80, child: Text('h$i')),
                  ],
                ),
              ),
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
    await tester.drag(find.byKey(const Key('inner')), const Offset(-5000, 0));
    await tester.pumpAndSettle();
    expect(opacities(), [0, 1]);
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

  testWidgets('Oito2Draggable ends a cancelled drag', (tester) async {
    final events = <String>[];
    await pumpOito2(
      tester,
      Stack(
        children: [
          Oito2Draggable(
            onDragStart: () => events.add('start'),
            onDragEnd: () => events.add('end'),
            child: const SizedBox.square(
              dimension: 40,
              child: ColoredBox(color: Color(0xFF3584E4)),
            ),
          ),
        ],
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ColoredBox)),
    );
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();
    await gesture.cancel();
    await tester.pump();
    expect(events, ['start', 'end']);
  });

  testWidgets('Oito2Draggable is named and movable for assistive '
      'technologies', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpOito2(
      tester,
      const Stack(
        children: [
          Oito2Draggable(
            semanticLabel: 'Sticky note',
            initialPosition: Offset(20, 20),
            child: SizedBox.square(
              dimension: 40,
              child: ColoredBox(color: Color(0xFF3584E4)),
            ),
          ),
        ],
      ),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Sticky note'));
    expect(node.hint, 'Use the arrow keys to move it');
    final action = node.getSemanticsData().customSemanticsActionIds!;
    expect(action, hasLength(4));
    tester
        .renderObject(find.byType(ColoredBox))
        .owner!
        .semanticsOwner!
        .performAction(node.id, SemanticsAction.customAction, action.first);
    await tester.pump();
    expect(tester.getTopLeft(find.byType(ColoredBox)), const Offset(20, 12));
    handle.dispose();
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
