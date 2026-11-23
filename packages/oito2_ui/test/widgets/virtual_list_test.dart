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

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui/src/widgets/resize_handle.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// Presses and releases [key], holding Shift when [shift] is true and
/// Control when [control] is true, then pumps a frame.
Future<void> _key(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
  bool control = false,
}) async {
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  if (control) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  if (control) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.pump();
}

/// The labels of the rows 0 to [count] - 1: "Row 0", "Row 1"...
List<String> _rows(int count) => [for (var i = 0; i < count; i++) 'Row $i'];

void main() {
  group('Oito2VirtualList', () {
    final fruits = Oito2ListCollection(const [
      'Apple',
      'Banana',
      'Blueberry',
      'Cherry',
      'Date',
    ], isDisabled: (f) => f == 'Cherry');

    Future<Oito2SelectionController> pumpList(
      WidgetTester tester,
      Oito2SelectionMode mode, {
      ValueChanged<String>? onActivate,
      Oito2ListCollection<String>? collection,
    }) async {
      final items = collection ?? fruits;
      final controller = Oito2SelectionController(
        collection: items,
        mode: mode,
      );
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 240,
            height: 300,
            child: Oito2VirtualList(
              collection: items,
              controller: controller,
              onActivate: onActivate,
              semanticLabel: 'Fruits',
            ),
          ),
        ),
      );
      return controller;
    }

    testWidgets('single: the arrows select, skipping disabled items', (
      tester,
    ) async {
      final activated = <String>[];
      final controller = await pumpList(
        tester,
        Oito2SelectionMode.single,
        onActivate: activated.add,
      );
      await _key(tester, LogicalKeyboardKey.tab);
      expect(controller.selectedValues, isEmpty);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selectedValues, ['Banana']);
      await _key(tester, LogicalKeyboardKey.end);
      expect(controller.selectedValues, ['Date']);
      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(controller.selectedValues, ['Blueberry']);
      await _key(tester, LogicalKeyboardKey.home);
      expect(controller.selectedValues, ['Apple']);
      await _key(tester, LogicalKeyboardKey.enter);
      expect(activated, ['Apple']);
    });

    testWidgets('a double click activates; two slow clicks do not', (
      tester,
    ) async {
      final activated = <String>[];
      await pumpList(
        tester,
        Oito2SelectionMode.single,
        onActivate: activated.add,
      );
      await tester.tap(find.text('Date'));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Date'));
      await tester.pump();
      expect(activated, isEmpty);
      await tester.tap(find.text('Date'));
      await tester.pump(const Duration(milliseconds: 80));
      expect(activated, ['Date']);
    });

    testWidgets('typeahead jumps to matching labels', (tester) async {
      final controller = await pumpList(tester, Oito2SelectionMode.single);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.keyB);
      expect(controller.selectedValues, ['Banana']);
      await _key(tester, LogicalKeyboardKey.keyL);
      expect(controller.selectedValues, ['Blueberry']);
    });

    testWidgets('multiple: Space, Shift+arrows, Control+A and clicks', (
      tester,
    ) async {
      final controller = await pumpList(tester, Oito2SelectionMode.multiple);
      await tester.tap(find.text('Apple'));
      await tester.pump();
      expect(controller.selectedValues, ['Apple']);
      await _key(tester, LogicalKeyboardKey.arrowDown, shift: true);
      expect(controller.selectedValues, ['Apple', 'Banana']);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _key(tester, LogicalKeyboardKey.space);
      expect(controller.selectedValues, ['Apple', 'Banana', 'Blueberry']);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(find.text('Banana'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(controller.selectedValues, ['Apple', 'Blueberry']);
      await _key(tester, LogicalKeyboardKey.keyA, control: true);
      expect(controller.selectedValues, [
        'Apple',
        'Banana',
        'Blueberry',
        'Date',
      ]);
    });

    testWidgets('rows report selection to assistive technologies', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final controller = await pumpList(tester, Oito2SelectionMode.single);
      controller.replace('Banana');
      await tester.pump();
      expect(
        tester.getSemantics(find.text('Banana')),
        isSemantics(
          label: 'Banana',
          isSelected: true,
          hasSelectedState: true,
          isEnabled: true,
          hasEnabledState: true,
          isButton: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('Page Down, End and Shift+Page Up in 10,000 rows', (
      tester,
    ) async {
      final rows = Oito2ListCollection(_rows(10000));
      final controller = await pumpList(
        tester,
        Oito2SelectionMode.multiple,
        collection: rows,
      );
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.pageDown);
      // The 300-pixel list shows 8 rows of 34 pixels; a page moves 7.
      await _key(tester, LogicalKeyboardKey.space);
      expect(controller.selectedValues, ['Row 7']);
      await _key(tester, LogicalKeyboardKey.end);
      expect(find.text('Row 9999'), findsOneWidget);
      expect(find.text('Row 0'), findsNothing);
      await _key(tester, LogicalKeyboardKey.space);
      await _key(tester, LogicalKeyboardKey.pageUp, shift: true);
      expect(controller.selectedValues, [
        for (var i = 9992; i < 10000; i++) 'Row $i',
      ]);
      expect(find.text('Row 9992'), findsOneWidget);
    });

    testWidgets('builds only the rows in view of 10,000', (tester) async {
      final rows = Oito2ListCollection(_rows(10000));
      final controller = Oito2SelectionController(collection: rows);
      addTearDown(controller.dispose);
      final built = <String>[];
      await pumpOito2(
        tester,
        SizedBox(
          height: 400,
          child: Oito2VirtualList(
            collection: rows,
            controller: controller,
            cacheExtent: 0,
            itemBuilder: (context, item, selected) {
              built.add(item);
              return Text(item);
            },
          ),
        ),
      );
      // 400 pixels of 34-pixel rows.
      expect(built.length, lessThanOrEqualTo(13));
      expect(built.first, 'Row 0');
      built.clear();
      await tester.drag(
        find.byType(Oito2VirtualList<String>),
        const Offset(0, -3400),
      );
      await tester.pump();
      expect(built.length, lessThanOrEqualTo(26));
      expect(find.text('Row 100'), findsOneWidget);
    });

    testWidgets('a per-row listenable rebuilds only its row, also at '
        '50 updates per frame', (tester) async {
      final rows = Oito2ListCollection(_rows(10000));
      final progress = {for (final row in rows.items) row: ValueNotifier(0)};
      addTearDown(() {
        for (final notifier in progress.values) {
          notifier.dispose();
        }
      });
      final controller = Oito2SelectionController(collection: rows);
      addTearDown(controller.dispose);
      final builds = <String, int>{};
      var rowBuilds = 0;
      await pumpOito2(
        tester,
        SizedBox(
          height: 600,
          child: Oito2VirtualList(
            collection: rows,
            controller: controller,
            itemBuilder: (context, item, selected) {
              rowBuilds++;
              return ValueListenableBuilder(
                valueListenable: progress[item]!,
                builder: (context, value, _) {
                  builds[item] = (builds[item] ?? 0) + 1;
                  return Text('$item $value%');
                },
              );
            },
          ),
        ),
      );
      final visible = builds.length;
      expect(visible, lessThan(40));
      builds.clear();
      rowBuilds = 0;

      progress['Row 3']!.value = 50;
      await tester.pump();
      expect(builds, {'Row 3': 1});
      expect(rowBuilds, 0);
      expect(find.text('Row 3 50%'), findsOneWidget);

      // 50 updates per frame over the 10,000 rows, 20 frames: a second.
      var tick = 0;
      for (var frame = 0; frame < 20; frame++) {
        builds.clear();
        for (var i = 0; i < 50; i++) {
          final row = 'Row ${(tick * 7919) % 10000}';
          tick++;
          progress[row]!.value++;
        }
        await tester.pump(const Duration(milliseconds: 50));
        final total = builds.values.fold(0, (a, b) => a + b);
        expect(total, lessThanOrEqualTo(visible + 50));
        expect(rowBuilds, 0);
      }
    });

    testWidgets('a selection change rebuilds only the rows in view', (
      tester,
    ) async {
      final rows = Oito2ListCollection(_rows(10000));
      final controller = Oito2SelectionController(collection: rows);
      addTearDown(controller.dispose);
      var built = 0;
      await pumpOito2(
        tester,
        SizedBox(
          height: 400,
          child: Oito2VirtualList(
            collection: rows,
            controller: controller,
            itemBuilder: (context, item, selected) {
              built++;
              return Text(item);
            },
          ),
        ),
      );
      final visible = built;
      built = 0;
      controller.replace('Row 2');
      await tester.pump();
      expect(built, visible);
    });

    testWidgets('rows keep their state when items move', (tester) async {
      var items = ['a', 'b', 'c'];
      late StateSetter setOuter;
      final controller = Oito2SelectionController(
        collection: Oito2ListCollection(items),
      );
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          height: 300,
          child: StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return Oito2VirtualList(
                collection: Oito2ListCollection(items),
                controller: controller,
                itemBuilder: (context, item, selected) =>
                    _Counter(key: ValueKey('counter $item'), label: item),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('b 0'));
      await tester.pump();
      expect(find.text('b 1'), findsOneWidget);
      setOuter(() => items = ['b', 'c', 'a']);
      await tester.pump();
      expect(find.text('b 1'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('b 1')).dy,
        lessThan(tester.getTopLeft(find.text('a 0')).dy),
      );
    });

    testWidgets('onReachEnd fires once per approach of the end', (
      tester,
    ) async {
      var count = 50;
      var reached = 0;
      late StateSetter setOuter;
      final controller = Oito2SelectionController(
        collection: Oito2ListCollection(_rows(count)),
      );
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          height: 340,
          child: StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return Oito2VirtualList(
                collection: Oito2ListCollection(_rows(count)),
                controller: controller,
                reachEndThreshold: 100,
                onReachEnd: () => reached++,
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(reached, 0);
      final list = find.byType(Oito2VirtualList<String>);
      // 50 rows of 34 pixels, 8 of padding, minus the 340-pixel view.
      await tester.drag(list, const Offset(0, -1300));
      await tester.pump();
      expect(reached, 1);
      await tester.drag(list, const Offset(0, -20));
      await tester.pump();
      expect(reached, 1);
      await tester.drag(list, const Offset(0, 400));
      await tester.pump();
      await tester.drag(list, const Offset(0, -400));
      await tester.pump();
      expect(reached, 2);
      // More items arm it again; the end is then far.
      setOuter(() => count = 100);
      await tester.pump();
      await tester.pump();
      expect(reached, 2);
      await tester.drag(list, const Offset(0, -2000));
      await tester.pump();
      expect(reached, 3);
    });

    testWidgets('a list shorter than its view reaches the end at once', (
      tester,
    ) async {
      var reached = 0;
      final rows = Oito2ListCollection(_rows(3));
      final controller = Oito2SelectionController(collection: rows);
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          height: 300,
          child: Oito2VirtualList(
            collection: rows,
            controller: controller,
            onReachEnd: () => reached++,
          ),
        ),
      );
      await tester.pump();
      expect(reached, 1);
      await tester.pump();
      expect(reached, 1);
    });

    testWidgets('an async controller loads pages, shows loading and error '
        'rows, and retries', (tester) async {
      final requests = <Completer<Oito2AsyncListPage<String, int>>>[];
      final async = Oito2AsyncListController<String, int>(
        load: (request) {
          final completer = Completer<Oito2AsyncListPage<String, int>>();
          requests.add(completer);
          return completer.future;
        },
      );
      addTearDown(async.dispose);
      final controller = Oito2SelectionController(
        collection: Oito2ListCollection(const <String>[]),
      );
      addTearDown(controller.dispose);
      Widget list() => ListenableBuilder(
        listenable: async,
        builder: (context, _) => Oito2VirtualList(
          collection: Oito2ListCollection(async.items),
          controller: controller,
          asyncController: async,
          cacheExtent: 0,
        ),
      );
      await pumpOito2(tester, SizedBox(height: 340, child: list()));
      expect(find.text('No items'), findsOneWidget);
      unawaited(async.reload());
      await tester.pump();
      expect(find.text('Loading'), findsOneWidget);
      expect(find.text('No items'), findsNothing);
      requests.last.complete(Oito2AsyncListPage(_rows(20), cursor: 20));
      await tester.pump();
      await tester.pump();
      expect(find.text('Row 0'), findsOneWidget);
      // The end is far from the view: nothing more loads.
      expect(requests, hasLength(1));

      await tester.drag(
        find.byType(Oito2VirtualList<String>),
        const Offset(0, -400),
      );
      await tester.pump();
      expect(requests, hasLength(2));
      await tester.pump();
      await tester.drag(
        find.byType(Oito2VirtualList<String>),
        const Offset(0, -100),
      );
      await tester.pump();
      expect(find.text('Loading more…'), findsOneWidget);
      requests.last.completeError(StateError('offline'));
      await tester.pump();
      await tester.pump();
      expect(find.text("Couldn't load the items"), findsOneWidget);
      // A failed page doesn't load again by itself.
      await tester.drag(
        find.byType(Oito2VirtualList<String>),
        const Offset(0, -50),
      );
      await tester.pump();
      await tester.pump();
      expect(requests, hasLength(2));

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(requests, hasLength(3));
      requests.last.complete(
        Oito2AsyncListPage([for (var i = 20; i < 40; i++) 'Row $i']),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text("Couldn't load the items"), findsNothing);
      expect(async.items, hasLength(40));
      await tester.drag(
        find.byType(Oito2VirtualList<String>),
        const Offset(0, -2000),
      );
      await tester.pump();
      expect(find.text('Row 39'), findsOneWidget);
      // The last page had no cursor.
      expect(requests, hasLength(3));
    });

    testWidgets('variable heights, header and footer', (tester) async {
      final rows = Oito2ListCollection(_rows(500));
      final controller = Oito2SelectionController(collection: rows);
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          height: 300,
          child: Oito2VirtualList(
            collection: rows,
            controller: controller,
            variableHeight: true,
            header: const Text('Header'),
            footer: const Text('Footer'),
            itemBuilder: (context, item, selected) => SizedBox(
              height: item.endsWith('0') ? 60 : 20,
              child: Text(item),
            ),
          ),
        ),
      );
      expect(find.text('Header'), findsOneWidget);
      expect(tester.getSize(find.text('Row 0')).height, lessThanOrEqualTo(60));
      expect(
        tester.getTopLeft(find.text('Row 1')).dy -
            tester.getTopLeft(find.text('Row 0')).dy,
        greaterThan(60),
      );
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.end);
      for (var i = 0; i < 8; i++) {
        await tester.pump();
      }
      expect(controller.selectedValues, ['Row 499']);
      expect(find.text('Row 499'), findsOneWidget);
      await tester.drag(
        find.byType(Oito2VirtualList<String>),
        const Offset(0, -500),
      );
      await tester.pump();
      expect(find.text('Footer'), findsOneWidget);
    });
  });

  group('Oito2DataTable', () {
    final files = Oito2ListCollection(const [
      ('a.txt', 120),
      ('b.png', 4096),
      ('c.zip', 1 << 20),
    ], valueOf: (f) => f.$1);

    List<Oito2TableColumn<(String, int)>> columns({
      Oito2ColumnWidth nameWidth = const Oito2ColumnWidth.flex(1),
    }) => [
      Oito2TableColumn(
        id: 'name',
        label: 'Name',
        width: nameWidth,
        sortable: true,
        resizable: true,
      ),
      Oito2TableColumn(
        id: 'size',
        label: 'Size',
        width: const Oito2ColumnWidth.fixed(100),
        alignment: AlignmentDirectional.centerEnd,
        sortable: true,
        cellBuilder: (context, file) => Text('${file.$2} B'),
      ),
      const Oito2TableColumn(id: 'kind', label: 'Kind'),
    ];

    Future<Oito2SelectionController> pumpTable(
      WidgetTester tester, {
      Oito2SortDescriptor? sort,
      ValueChanged<Oito2SortDescriptor?>? onSortChanged,
      void Function(String, double)? onColumnResized,
      List<Oito2TableColumn<(String, int)>>? tableColumns,
      double width = 500,
      TextDirection textDirection = TextDirection.ltr,
    }) async {
      final controller = Oito2SelectionController(collection: files);
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: width,
            height: 300,
            child: Oito2DataTable(
              collection: files,
              controller: controller,
              columns: tableColumns ?? columns(),
              sort: sort,
              onSortChanged: onSortChanged,
              onColumnResized: onColumnResized,
              semanticLabel: 'Files',
            ),
          ),
        ),
        textDirection: textDirection,
      );
      return controller;
    }

    test('nextSort cycles ascending, descending, none', () {
      expect(
        Oito2DataTable.nextSort(null, 'size'),
        const Oito2SortDescriptor('size'),
      );
      expect(
        Oito2DataTable.nextSort(const Oito2SortDescriptor('size'), 'size'),
        const Oito2SortDescriptor('size', Oito2SortDirection.descending),
      );
      expect(
        Oito2DataTable.nextSort(
          const Oito2SortDescriptor('size', Oito2SortDirection.descending),
          'size',
        ),
        isNull,
      );
      expect(
        Oito2DataTable.nextSort(const Oito2SortDescriptor('name'), 'size'),
        const Oito2SortDescriptor('size'),
      );
    });

    testWidgets('a header click reports the next sort and shows the arrow', (
      tester,
    ) async {
      final sorts = <Oito2SortDescriptor?>[];
      await pumpTable(
        tester,
        sort: const Oito2SortDescriptor('size'),
        onSortChanged: sorts.add,
      );
      expect(find.byIcon(LucideIcons.arrow_up), findsOneWidget);
      await tester.tap(find.text('Size'));
      await tester.tap(find.text('Name'));
      await tester.tap(find.text('Kind'));
      expect(sorts, [
        const Oito2SortDescriptor('size', Oito2SortDirection.descending),
        const Oito2SortDescriptor('name'),
      ]);
    });

    testWidgets('headers are headers, with the sort state as value', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final sorts = <Oito2SortDescriptor?>[];
      await pumpTable(
        tester,
        sort: const Oito2SortDescriptor('size', Oito2SortDirection.descending),
        onSortChanged: sorts.add,
      );
      expect(
        tester.getSemantics(find.text('Size')),
        isSemantics(
          label: 'Size',
          value: 'Sorted descending',
          isHeader: true,
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Name')),
        isSemantics(value: 'Not sorted', isHeader: true),
      );
      expect(
        tester.getSemantics(find.text('Kind')),
        isSemantics(label: 'Kind', isHeader: true, isButton: false),
      );
      // Rows read their cells in order.
      expect(find.semantics.byLabel(RegExp(r'^b\.png\n4096 B$')), findsOne);
      final node = tester.getSemantics(find.text('Size'));
      tester
          .renderObject(find.text('Size'))
          .owner!
          .semanticsOwner!
          .performAction(node.id, SemanticsAction.tap);
      expect(sorts, [null]);
      semantics.dispose();
    });

    testWidgets('Enter on a focused sortable header sorts', (tester) async {
      final sorts = <Oito2SortDescriptor?>[];
      await pumpTable(tester, onSortChanged: sorts.add);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.enter);
      expect(sorts, [const Oito2SortDescriptor('name')]);
    });

    testWidgets('cells line up with their headers', (tester) async {
      await pumpTable(tester);
      final header = tester.getTopRight(find.text('Size'));
      final cell = tester.getTopRight(find.text('4096 B'));
      expect(cell.dx, moreOrLessEquals(header.dx));
      expect(
        tester.getTopLeft(find.text('a.txt')).dx,
        moreOrLessEquals(tester.getTopLeft(find.text('Name')).dx),
      );
    });

    testWidgets('cells line up with their headers right to left', (
      tester,
    ) async {
      await pumpTable(tester, textDirection: TextDirection.rtl);
      expect(
        tester.getTopLeft(find.text('4096 B')).dx,
        moreOrLessEquals(tester.getTopLeft(find.text('Size')).dx),
      );
      expect(
        tester.getTopRight(find.text('a.txt')).dx,
        moreOrLessEquals(tester.getTopRight(find.text('Name')).dx),
      );
    });

    testWidgets('a resize moves the cells and reports the width', (
      tester,
    ) async {
      final resized = <(String, double)>[];
      await pumpTable(
        tester,
        tableColumns: columns(nameWidth: const Oito2ColumnWidth.fixed(150)),
        onColumnResized: (id, width) => resized.add((id, width)),
      );
      final before = tester.getTopLeft(find.text('4096 B')).dx;
      await tester.drag(find.byType(ResizeHandle), const Offset(40, 0));
      await tester.pump();
      expect(resized, [('name', 190.0)]);
      expect(
        tester.getTopLeft(find.text('4096 B')).dx,
        moreOrLessEquals(before + 40),
      );
    });

    testWidgets('columns wider than the table scroll sideways', (tester) async {
      await pumpTable(
        tester,
        width: 300,
        tableColumns: columns(nameWidth: const Oito2ColumnWidth.fixed(400)),
      );
      final scrollable = find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
      );
      final position = tester.state<ScrollableState>(scrollable).position;
      expect(position.maxScrollExtent, greaterThan(0));
      final header = tester.getTopLeft(find.text('Size')).dx;
      final cell = tester.getTopLeft(find.text('4096 B')).dx;
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      expect(
        tester.getTopLeft(find.text('Size')).dx,
        moreOrLessEquals(header - position.maxScrollExtent),
      );
      expect(
        tester.getTopLeft(find.text('4096 B')).dx,
        moreOrLessEquals(cell - position.maxScrollExtent),
      );
    });

    testWidgets('rows select with the keyboard as the list', (tester) async {
      final controller = await pumpTable(tester);
      await tester.tap(find.text('a.txt'));
      await tester.pump();
      expect(controller.selectedValues, ['a.txt']);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selectedValues, ['b.png']);
      await _key(tester, LogicalKeyboardKey.end);
      expect(controller.selectedValues, ['c.zip']);
    });
  });
}

/// A label with a counter that a tap increments, to check that a row
/// keeps its state.
class _Counter extends StatefulWidget {
  const _Counter({super.key, required this.label});

  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _count++),
    child: Text('${widget.label} $_count'),
  );
}
