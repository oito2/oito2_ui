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

const _paneKey = ValueKey('pane');
const _pageKey = ValueKey('page');

Widget _paned({
  Oito2PaneSide side = Oito2PaneSide.start,
  bool resizable = true,
  ValueChanged<double>? onChanged,
}) => Oito2PanedView(
  paneSide: side,
  initialPaneSize: 300,
  minPaneSize: 200,
  minPageSize: 400,
  resizable: resizable,
  onPaneSizeChanged: onChanged,
  pane: const SizedBox.expand(key: _paneKey),
  page: const SizedBox.expand(key: _pageKey),
);

void main() {
  group('Oito2PageController', () {
    test('selects, clears and clamps on length changes', () {
      final controller = Oito2PageController(length: 3);
      var notifications = 0;
      controller.addListener(() => notifications++);
      expect(controller.index, -1);
      expect(controller.hasSelection, isFalse);

      controller.index = 2;
      expect(controller.hasSelection, isTrue);
      controller.index = 2;
      expect(notifications, 1);

      controller.length = 2;
      expect(controller.index, -1);
      expect(notifications, 2);
      expect(() => controller.index = 5, throwsAssertionError);
    });
  });

  group('Oito2PanedView', () {
    testWidgets('starts at the initial size on the start side', (tester) async {
      await pumpOito2(tester, _paned());
      expect(tester.getSize(find.byKey(_paneKey)).width, 300);
      expect(tester.getTopLeft(find.byKey(_paneKey)).dx, 0);
      expect(tester.getTopLeft(find.byKey(_pageKey)).dx, 301);
    });

    testWidgets('dragging resizes within the limits', (tester) async {
      final sizes = <double>[];
      await pumpOito2(tester, _paned(onChanged: sizes.add));
      final handle = find.bySemanticsLabel('Resize pane');
      await tester.drag(handle, const Offset(100, 0));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(_paneKey)).width, 400);

      await tester.drag(handle, const Offset(-1000, 0));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(_paneKey)).width, 200);

      await tester.drag(handle, const Offset(2000, 0));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(_paneKey)).width, 1000 - 400);
      expect(sizes, isNotEmpty);
    });

    testWidgets('arrow keys resize the focused handle', (tester) async {
      await pumpOito2(tester, _paned());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(tester.getSize(find.byKey(_paneKey)).width, 316);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(tester.getSize(find.byKey(_paneKey)).width, 284);
    });

    testWidgets('assistive technologies can adjust it', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(tester, _paned());
      final node = tester.getSemantics(find.bySemanticsLabel('Resize pane'));
      expect(node.value, '300');
      expect(node.increasedValue, '316');
      tester.semantics.increase(find.semantics.byLabel('Resize pane'));
      await tester.pump();
      expect(tester.getSize(find.byKey(_paneKey)).width, 316);
      handle.dispose();
    });

    testWidgets('the end side places the pane after the page', (tester) async {
      await pumpOito2(tester, _paned(side: Oito2PaneSide.end));
      expect(tester.getTopLeft(find.byKey(_paneKey)).dx, 1000 - 300);
      await tester.drag(
        find.bySemanticsLabel('Resize pane'),
        const Offset(-50, 0),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(_paneKey)).width, 350);
    });

    testWidgets('start follows right-to-left text', (tester) async {
      await pumpOito2(tester, _paned(), textDirection: TextDirection.rtl);
      expect(tester.getTopRight(find.byKey(_paneKey)).dx, 1000);
      await tester.drag(
        find.bySemanticsLabel('Resize pane'),
        const Offset(-50, 0),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(_paneKey)).width, 350);
    });

    testWidgets('top and bottom stack vertically', (tester) async {
      await pumpOito2(tester, _paned(side: Oito2PaneSide.top));
      expect(tester.getSize(find.byKey(_paneKey)).height, 300);
      await tester.drag(
        find.bySemanticsLabel('Resize pane'),
        const Offset(0, 40),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(_paneKey)).height, 340);
    });

    testWidgets('a fixed pane has no handle', (tester) async {
      await pumpOito2(tester, _paned(resizable: false));
      expect(find.bySemanticsLabel('Resize pane'), findsNothing);
    });
  });

  group('Oito2MasterDetailPage', () {
    Widget page({Oito2PageController? controller, int? length}) =>
        Oito2MasterDetailPage(
          length: controller == null ? (length ?? 3) : null,
          controller: controller,
          tileBuilder: (context, index, selected, width) =>
              Oito2MasterTile(title: Text('Item $index')),
          pageBuilder: (context, index) => Oito2DetailPage(
            title: Text('Detail $index'),
            body: Text('Body $index'),
          ),
          emptyBuilder: (_) => const Text('empty'),
        );

    testWidgets('wide layouts show the list and the first page', (
      tester,
    ) async {
      await pumpOito2(tester, page(), scaffold: false);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Body 0'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);

      await tester.tap(find.text('Item 2'));
      await tester.pumpAndSettle();
      expect(find.text('Body 2'), findsOneWidget);
      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Item 2'),
      );
      expect(tile.selected, isTrue);
    });

    testWidgets('narrow layouts push the detail and pop back', (tester) async {
      final controller = Oito2PageController(length: 3);
      await pumpOito2(
        tester,
        page(controller: controller),
        size: const Size(400, 700),
        scaffold: false,
      );
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Body 0'), findsNothing);

      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();
      expect(find.text('Body 1'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(controller.index, 1);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Body 1'), findsNothing);
      expect(find.text('Item 1'), findsOneWidget);
      expect(controller.index, -1);
    });

    testWidgets('the selection survives a layout change', (tester) async {
      final controller = Oito2PageController(length: 3, initialIndex: 2);
      await pumpOito2(tester, page(controller: controller), scaffold: false);
      expect(find.text('Body 2'), findsOneWidget);
      await pumpOito2(
        tester,
        page(controller: controller),
        size: const Size(400, 700),
        scaffold: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('Body 2'), findsOneWidget);
    });

    testWidgets('shows the empty builder without items', (tester) async {
      await pumpOito2(tester, page(length: 0), scaffold: false);
      expect(find.text('empty'), findsOneWidget);
    });
  });

  group('Oito2NavigationPage', () {
    const items = [
      Oito2NavigationItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      Oito2NavigationItem(icon: Icon(Icons.search), label: 'Search'),
      Oito2NavigationItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];
    Widget nav({double? extended, ValueChanged<int>? onSelected}) =>
        Oito2NavigationPage(
          items: items,
          extendedBreakpoint: extended,
          onSelected: onSelected,
          pageBuilder: (context, index) => Text('Page ${items[index].label}'),
        );

    testWidgets('wide layouts use a rail', (tester) async {
      final selected = <int>[];
      await pumpOito2(tester, nav(onSelected: selected.add));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Page Home'), findsOneWidget);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Page Settings'), findsOneWidget);
      expect(selected, [2]);
    });

    testWidgets('a rail with more items than fit scrolls', (tester) async {
      final many = [
        for (var i = 0; i < 30; i++)
          Oito2NavigationItem(icon: const Icon(Icons.circle), label: 'Item $i'),
      ];
      await pumpOito2(
        tester,
        Oito2NavigationPage(
          items: many,
          pageBuilder: (context, index) => Text('Page $index'),
        ),
        size: const Size(800, 400),
      );
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Item 29'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(Oito2NavigationPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Item 29'));
      await tester.pumpAndSettle();
      expect(find.text('Page 29'), findsOneWidget);
    });

    testWidgets('narrow layouts use a bottom bar', (tester) async {
      await pumpOito2(tester, nav(), size: const Size(400, 700));
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Page Search'), findsOneWidget);
    });

    testWidgets('the rail extends past the extended breakpoint', (
      tester,
    ) async {
      await pumpOito2(tester, nav(extended: 900));
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
      await pumpOito2(tester, nav(extended: 1200));
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
    });
  });
}
