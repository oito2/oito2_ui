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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

void main() {
  group('Oito2ScrollArea', () {
    testWidgets('scrolls vertically with a single scroll bar', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          width: 200,
          height: 200,
          child: Oito2ScrollArea(
            verticalController: controller,
            child: const SizedBox(width: 100, height: 1000),
          ),
        ),
        size: const Size(400, 400),
      );
      expect(find.byType(Scrollbar), findsOneWidget);
      await tester.drag(find.byType(Oito2ScrollArea), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(0));
    });

    testWidgets('scrolls both ways with a scroll bar on each axis', (
      tester,
    ) async {
      final vertical = ScrollController();
      final horizontal = ScrollController();
      addTearDown(vertical.dispose);
      addTearDown(horizontal.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          width: 200,
          height: 200,
          child: Oito2ScrollArea(
            direction: Oito2ScrollDirection.both,
            verticalController: vertical,
            horizontalController: horizontal,
            thumbVisibility: true,
            child: const SizedBox(width: 1000, height: 1000),
          ),
        ),
        size: const Size(400, 400),
      );
      expect(find.byType(Scrollbar), findsNWidgets(2));
      await tester.drag(find.byType(Oito2ScrollArea), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(horizontal.offset, greaterThan(0));
      expect(vertical.offset, 0);
      await tester.drag(find.byType(Oito2ScrollArea), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(vertical.offset, greaterThan(0));
    });

    testWidgets('adds the undershoot shadow when asked', (tester) async {
      await pumpOito2(
        tester,
        const SizedBox(
          width: 200,
          height: 200,
          child: Oito2ScrollArea(
            direction: Oito2ScrollDirection.horizontal,
            undershoot: true,
            child: SizedBox(width: 1000, height: 100),
          ),
        ),
        size: const Size(400, 400),
      );
      expect(find.byType(Oito2ScrollViewUndershoot), findsOneWidget);
      expect(find.byType(Scrollbar), findsOneWidget);
    });
  });
}
