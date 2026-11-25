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

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui/src/widgets/resize_handle.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

typedef _File = (String, int, String, String);

final _files = Oito2ListCollection(const [
  ('a.txt', 120, 'Text', 'Mon'),
  ('b.png', 4096, 'Image', 'Tue'),
  ('c.zip', 1 << 20, 'Archive', 'Wed'),
], valueOf: (f) => f.$1);

/// The columns: a resizable, sortable name, a size, a kind that can't be
/// hidden and a date.
final _columns = <Oito2TableColumn<_File>>[
  const Oito2TableColumn(
    id: 'name',
    label: 'Name',
    width: Oito2ColumnWidth.fixed(150),
    sortable: true,
    resizable: true,
  ),
  Oito2TableColumn(
    id: 'size',
    label: 'Size',
    width: const Oito2ColumnWidth.fixed(100),
    cellBuilder: (context, f) => Text('${f.$2} B'),
  ),
  Oito2TableColumn(
    id: 'kind',
    label: 'Kind',
    width: const Oito2ColumnWidth.fixed(100),
    hideable: false,
    cellBuilder: (context, f) => Text(f.$3),
  ),
  Oito2TableColumn(
    id: 'date',
    label: 'Date',
    width: const Oito2ColumnWidth.fixed(100),
    cellBuilder: (context, f) => Text(f.$4),
  ),
];

/// What the app saw: the hidden columns, the orders and the sorts it was
/// given.
class _Log {
  final hidden = <Set<String>>[];
  final orders = <List<String>>[];
  final sorts = <Oito2SortDescriptor?>[];
  final resized = <(String, double)>[];
  var resets = 0;
}

/// A data table whose app keeps the hidden columns and the order it is
/// told, logging them in [log].
class _Harness extends StatefulWidget {
  const _Harness({
    required this.log,
    required this.controller,
    this.hide = true,
    this.reorder = true,
    this.pinned = 0,
    this.initialHidden = const {},
    this.reset = false,
  });

  final _Log log;
  final bool reset;
  final Oito2SelectionController controller;
  final bool hide;
  final bool reorder;
  final int pinned;
  final Set<String> initialHidden;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late var _hidden = widget.initialHidden;
  List<String>? _order;

  @override
  Widget build(BuildContext context) => Oito2DataTable<_File>(
    collection: _files,
    controller: widget.controller,
    columns: _columns,
    semanticLabel: 'Files',
    pinnedColumns: widget.pinned,
    onSortChanged: widget.log.sorts.add,
    onColumnResized: (id, w) => widget.log.resized.add((id, w)),
    hiddenColumns: _hidden,
    onHiddenColumnsChanged: !widget.hide
        ? null
        : (hidden) => setState(() {
            widget.log.hidden.add(hidden);
            _hidden = hidden;
          }),
    columnOrder: _order,
    onColumnsReordered: !widget.reorder
        ? null
        : (order) => setState(() {
            widget.log.orders.add(order);
            _order = order;
          }),
    onResetColumns: !widget.reset
        ? null
        : () => setState(() {
            widget.log.resets++;
            _hidden = const {};
            _order = null;
          }),
  );
}

/// Pumps the harness [width] pixels wide and returns its log.
Future<(_Log, Oito2SelectionController)> _pump(
  WidgetTester tester, {
  bool hide = true,
  bool reorder = true,
  int pinned = 0,
  double width = 600,
  Set<String> hidden = const {},
  TextDirection textDirection = TextDirection.ltr,
  bool reset = false,
}) async {
  final log = _Log();
  final controller = Oito2SelectionController(collection: _files);
  addTearDown(controller.dispose);
  await pumpOito2(
    tester,
    Center(
      child: SizedBox(
        width: width,
        height: 300,
        child: _Harness(
          log: log,
          controller: controller,
          hide: hide,
          reorder: reorder,
          pinned: pinned,
          initialHidden: hidden,
          reset: reset,
        ),
      ),
    ),
    textDirection: textDirection,
  );
  return (log, controller);
}

/// Presses [key] with Alt held, then pumps a frame.
Future<void> _alt(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
  await tester.pump();
}

/// The messages announced to assistive technologies since the last call.
List<String> _announced(WidgetTester tester) => [
  for (final a in tester.takeAnnouncements()) a.message,
];

/// Opens the header menu of the column labeled [label] with a secondary
/// click.
Future<void> _openMenu(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first, buttons: kSecondaryButton);
  await tester.pumpAndSettle();
}

/// The check box item of the column [id] in the open header menu.
Finder _toggle(String id) => find.byKey(ValueKey('oito2-column-toggle-$id'));

/// Whether the menu item [item] is enabled.
bool _enabled(WidgetTester tester, Finder item) => tester
    .widget<MenuItemButton>(
      find.descendant(
        of: item,
        matching: find.byType(MenuItemButton),
        matchRoot: true,
      ),
    )
    .enabled;

/// The sideways scroll position of the table.
ScrollPosition _sideways(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.byWidgetPredicate(
        (w) =>
            w is Scrollable &&
            (w.axisDirection == AxisDirection.right ||
                w.axisDirection == AxisDirection.left),
      ),
    )
    .position;

/// The pointer of the last mouse drag.
var _mousePointer = 100;

/// Starts a mouse drag at [from], moves it past the drag threshold and on
/// to [to], and returns the gesture with the button still down.
Future<TestGesture> _mouseDrag(
  WidgetTester tester,
  Offset from,
  Offset to,
) async {
  final gesture = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
    pointer: ++_mousePointer,
  );
  await gesture.addPointer(location: from);
  await gesture.down(from);
  await tester.pump();
  await gesture.moveBy(const Offset(10, 0));
  await tester.pump();
  await gesture.moveTo(to);
  await tester.pump();
  return gesture;
}

/// The labels of the header cells, from the start.
List<String> _headerOrder(WidgetTester tester) {
  final labels = [
    'Name',
    'Size',
    'Kind',
    'Date',
  ].where((l) => find.text(l).evaluate().isNotEmpty).toList();
  labels.sort(
    (a, b) => tester
        .getTopLeft(find.text(a).first)
        .dx
        .compareTo(tester.getTopLeft(find.text(b).first).dx),
  );
  return labels;
}

/// The tree of the tree grid tests: a docs branch with a readme.
final _tree = Oito2TreeCollection<(int, String, String)>(const [
  Oito2TreeNode(
    value: 'docs',
    data: (0, 'Synced', 'Folder'),
    children: [Oito2TreeNode(value: 'readme.md', data: (12, 'Local', 'Text'))],
  ),
]);

typedef _TreeColumn = Oito2TableColumn<Oito2TreeNode<(int, String, String)>>;

/// The tree grid columns: the structural name, a size, a status and a
/// kind.
final _treeColumns = <_TreeColumn>[
  const Oito2TableColumn(
    id: 'name',
    label: 'Name',
    width: Oito2ColumnWidth.fixed(160),
  ),
  Oito2TableColumn(
    id: 'size',
    label: 'Size',
    width: const Oito2ColumnWidth.fixed(90),
    cellBuilder: (context, node) => Text('${node.data!.$1} B'),
  ),
  Oito2TableColumn(
    id: 'status',
    label: 'Status',
    width: const Oito2ColumnWidth.fixed(90),
    cellBuilder: (context, node) => Text(node.data!.$2),
  ),
  Oito2TableColumn(
    id: 'kind',
    label: 'Kind',
    width: const Oito2ColumnWidth.fixed(90),
    cellBuilder: (context, node) => Text(node.data!.$3),
  ),
];

/// A tree grid whose app keeps the hidden columns and the order it is
/// told, logging them in [log].
class _TreeHarness extends StatefulWidget {
  const _TreeHarness({
    required this.log,
    required this.controller,
    this.pinned = 0,
    this.initialHidden = const {},
    this.initialOrder,
  });

  final _Log log;
  final Oito2TreeController controller;
  final int pinned;
  final Set<String> initialHidden;
  final List<String>? initialOrder;

  @override
  State<_TreeHarness> createState() => _TreeHarnessState();
}

class _TreeHarnessState extends State<_TreeHarness> {
  late var _hidden = widget.initialHidden;
  late var _order = widget.initialOrder;

  @override
  Widget build(BuildContext context) => Oito2TreeView<(int, String, String)>(
    collection: _tree,
    controller: widget.controller,
    columns: _treeColumns,
    pinnedColumns: widget.pinned,
    hiddenColumns: _hidden,
    onHiddenColumnsChanged: (hidden) => setState(() {
      widget.log.hidden.add(hidden);
      _hidden = hidden;
    }),
    columnOrder: _order,
    onColumnsReordered: (order) => setState(() {
      widget.log.orders.add(order);
      _order = order;
    }),
    onResetColumns: () => setState(() {
      widget.log.resets++;
      _hidden = const {};
      _order = null;
    }),
  );
}

/// Pumps the tree harness [width] pixels wide and returns its log.
Future<_Log> _pumpTree(
  WidgetTester tester, {
  int pinned = 0,
  double width = 600,
  Set<String> hidden = const {},
  List<String>? order,
}) async {
  final log = _Log();
  final controller = Oito2TreeController(expanded: const {'docs'});
  addTearDown(controller.dispose);
  await pumpOito2(
    tester,
    Center(
      child: SizedBox(
        width: width,
        height: 300,
        child: _TreeHarness(
          log: log,
          controller: controller,
          pinned: pinned,
          initialHidden: hidden,
          initialOrder: order,
        ),
      ),
    ),
  );
  return log;
}

/// The labels of the tree grid header cells, from the start.
List<String> _treeHeaderOrder(WidgetTester tester) {
  final labels = [
    'Name',
    'Size',
    'Status',
    'Kind',
  ].where((l) => find.text(l).evaluate().isNotEmpty).toList();
  labels.sort(
    (a, b) => tester
        .getTopLeft(find.text(a).first)
        .dx
        .compareTo(tester.getTopLeft(find.text(b).first).dx),
  );
  return labels;
}

/// The custom accessibility actions of the node of the text [label].
List<String> _actions(WidgetTester tester, String label) {
  final data = tester.getSemantics(find.text(label)).getSemanticsData();
  return [
    for (final id in data.customSemanticsActionIds ?? const <int>[])
      CustomSemanticsAction.getAction(id)!.label!,
  ];
}

void main() {
  group('Oito2DataTable columns', () {
    testWidgets('defaults add no menu, focus or pinning', (tester) async {
      final controller = Oito2SelectionController(collection: _files);
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          width: 300,
          height: 300,
          child: Oito2DataTable<_File>(
            collection: _files,
            controller: controller,
            columns: _columns,
          ),
        ),
      );
      expect(find.byType(Oito2ContextMenuRegion), findsNothing);
      expect(find.byType(Oito2FocusBorder), findsNothing);
      await tester.tap(find.text('Size'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNothing);
      final position = _sideways(tester);
      final name = tester.getTopLeft(find.text('Name')).dx;
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      expect(
        tester.getTopLeft(find.text('Name')).dx,
        moreOrLessEquals(name - position.maxScrollExtent),
      );
    });

    testWidgets('the header menu hides and shows columns', (tester) async {
      final (log, _) = await _pump(tester, reorder: false);
      await _openMenu(tester, 'Size');
      expect(_toggle('name'), findsOne);
      expect(_toggle('date'), findsOne);
      // Kind can't be hidden.
      expect(_enabled(tester, _toggle('kind')), isFalse);
      expect(
        find.byKey(const ValueKey('oito2-column-move-left')),
        findsNothing,
      );
      await tester.tap(_toggle('date'));
      await tester.pumpAndSettle();
      expect(log.hidden.last, {'date'});
      expect(find.text('Tue'), findsNothing);
      // The menu stays open to toggle more.
      await tester.tap(_toggle('date'));
      await tester.pumpAndSettle();
      expect(log.hidden.last, <String>{});
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_headerOrder(tester), ['Name', 'Size', 'Kind', 'Date']);
    });

    testWidgets('the last shown column can not be hidden', (tester) async {
      final (log, _) = await _pump(
        tester,
        reorder: false,
        hidden: const {'name', 'size', 'kind'},
      );
      expect(_headerOrder(tester), ['Date']);
      await _openMenu(tester, 'Date');
      expect(_enabled(tester, _toggle('date')), isFalse);
      // A hidden column that can't be hidden by the user can be shown.
      expect(_enabled(tester, _toggle('kind')), isTrue);
      await tester.tap(_toggle('kind'));
      await tester.pumpAndSettle();
      expect(log.hidden.last, {'name', 'size'});
      expect(_enabled(tester, _toggle('date')), isTrue);
      expect(_enabled(tester, _toggle('kind')), isFalse);
    });

    testWidgets('Shift+F10 and the menu key open the header menu', (
      tester,
    ) async {
      await _pump(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.f10);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(_toggle('name'), findsOne);
      expect(
        _enabled(tester, find.byKey(const ValueKey('oito2-column-move-left'))),
        isFalse,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_toggle('name'), findsNothing);
      // A header that doesn't sort takes the focus too.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
      await tester.pumpAndSettle();
      expect(_toggle('name'), findsOne);
    });

    testWidgets('a header drag moves the column with a drop line', (
      tester,
    ) async {
      final (log, _) = await _pump(tester);
      _announced(tester);
      final gesture = await _mouseDrag(
        tester,
        tester.getCenter(find.text('Kind')),
        tester.getTopLeft(find.text('Name')) + const Offset(2, 4),
      );
      expect(
        find.byKey(const ValueKey('oito2-column-drop-line')),
        findsOneWidget,
      );
      expect(
        tester
            .getTopLeft(find.byKey(const ValueKey('oito2-column-drop-line')))
            .dx,
        lessThanOrEqualTo(tester.getTopLeft(find.text('Name')).dx),
      );
      expect(log.orders, isEmpty);
      await gesture.up();
      await tester.pump();
      expect(log.orders, [
        ['kind', 'name', 'size', 'date'],
      ]);
      expect(_headerOrder(tester), ['Kind', 'Name', 'Size', 'Date']);
      expect(
        find.byKey(const ValueKey('oito2-column-drop-line')),
        findsNothing,
      );
      expect(_announced(tester), ['Moved column Kind to position 1 of 4']);
      // Cells follow their header.
      expect(
        tester.getTopLeft(find.text('Image')).dx,
        lessThan(tester.getTopLeft(find.text('b.png')).dx),
      );
    });

    testWidgets('Escape cancels a column drag', (tester) async {
      final (log, _) = await _pump(tester);
      final gesture = await _mouseDrag(
        tester,
        tester.getCenter(find.text('Kind')),
        tester.getTopLeft(find.text('Name')) + const Offset(2, 4),
      );
      expect(
        find.byKey(const ValueKey('oito2-column-drop-line')),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(
        find.byKey(const ValueKey('oito2-column-drop-line')),
        findsNothing,
      );
      await gesture.moveBy(const Offset(4, 0));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(log.orders, isEmpty);
      expect(_headerOrder(tester), ['Name', 'Size', 'Kind', 'Date']);
    });

    testWidgets('Reset columns shows only with onResetColumns', (tester) async {
      final (log, _) = await _pump(tester, hidden: const {'date'});
      await _openMenu(tester, 'Size');
      expect(find.byKey(const ValueKey('oito2-column-reset')), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(log.resets, 0);
    });

    testWidgets('Reset columns calls onResetColumns', (tester) async {
      final (log, _) = await _pump(tester, hidden: const {'date'}, reset: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(_headerOrder(tester), ['Size', 'Name', 'Kind']);
      await _openMenu(tester, 'Kind');
      expect(find.text('Reset columns'), findsOne);
      await tester.tap(find.byKey(const ValueKey('oito2-column-reset')));
      await tester.pumpAndSettle();
      expect(log.resets, 1);
      expect(_headerOrder(tester), ['Name', 'Size', 'Kind', 'Date']);
    });

    testWidgets('a drop that leaves the column in place moves nothing', (
      tester,
    ) async {
      final (log, _) = await _pump(tester);
      final gesture = await _mouseDrag(
        tester,
        tester.getCenter(find.text('Size')),
        tester.getCenter(find.text('Size')) + const Offset(20, 0),
      );
      expect(
        find.byKey(const ValueKey('oito2-column-drop-line')),
        findsNothing,
      );
      await gesture.up();
      await tester.pump();
      expect(log.orders, isEmpty);
    });

    testWidgets('the resize handle resizes without moving the column', (
      tester,
    ) async {
      final (log, _) = await _pump(tester);
      await tester.drag(find.byType(ResizeHandle), const Offset(60, 0));
      await tester.pump();
      expect(log.orders, isEmpty);
      expect(log.resized, [('name', 210.0)]);
    });

    testWidgets('a header drag near the edge scrolls sideways', (tester) async {
      final (log, _) = await _pump(tester, width: 300);
      final position = _sideways(tester);
      expect(position.pixels, 0);
      final table = tester.getRect(find.byType(Oito2DataTable<_File>));
      final gesture = await _mouseDrag(
        tester,
        tester.getCenter(find.text('Name')),
        Offset(table.right - 4, tester.getCenter(find.text('Name')).dy),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(position.pixels, greaterThan(0));
      await gesture.up();
      await tester.pump();
      expect(log.orders.single.first, isNot('name'));
    });

    testWidgets('Alt with the arrows moves the focused header column', (
      tester,
    ) async {
      final (log, _) = await _pump(tester);
      _announced(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(log.orders.last, ['size', 'name', 'kind', 'date']);
      expect(_announced(tester), ['Moved column Name to position 2 of 4']);
      // The focus stays on the moved header.
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(log.orders.last, ['size', 'kind', 'name', 'date']);
      await _alt(tester, LogicalKeyboardKey.arrowLeft);
      expect(log.orders.last, ['size', 'name', 'kind', 'date']);
      expect(_headerOrder(tester), ['Size', 'Name', 'Kind', 'Date']);
    });

    testWidgets('Alt with the arrows follows the screen right to left', (
      tester,
    ) async {
      final (log, _) = await _pump(tester, textDirection: TextDirection.rtl);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(log.orders, isEmpty);
      await _alt(tester, LogicalKeyboardKey.arrowLeft);
      expect(log.orders.last, ['size', 'name', 'kind', 'date']);
    });

    testWidgets('header actions move the column', (tester) async {
      final semantics = tester.ensureSemantics();
      final (log, _) = await _pump(tester);
      List<String> actions(String label) {
        final data = tester.getSemantics(find.text(label)).getSemanticsData();
        return [
          for (final id in data.customSemanticsActionIds ?? const <int>[])
            CustomSemanticsAction.getAction(id)!.label!,
        ];
      }

      expect(actions('Name'), ['Move column right']);
      expect(
        actions('Kind'),
        unorderedEquals(['Move column left', 'Move column right']),
      );
      expect(actions('Date'), ['Move column left']);
      final node = tester.getSemantics(find.text('Kind'));
      node.owner!.performAction(
        node.id,
        SemanticsAction.customAction,
        CustomSemanticsAction.getIdentifier(
          const CustomSemanticsAction(label: 'Move column left'),
        ),
      );
      await tester.pump();
      expect(log.orders.last, ['name', 'kind', 'size', 'date']);
      semantics.dispose();
    });

    testWidgets('the header menu moves the column', (tester) async {
      final (log, _) = await _pump(tester, hide: false);
      await _openMenu(tester, 'Size');
      expect(_toggle('name'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('oito2-column-move-right')));
      await tester.pumpAndSettle();
      expect(log.orders.last, ['name', 'kind', 'size', 'date']);
    });

    testWidgets('pinned columns stay while the others scroll', (tester) async {
      final semantics = tester.ensureSemantics();
      final (log, controller) = await _pump(tester, pinned: 1, width: 300);
      final position = _sideways(tester);
      final name = tester.getTopLeft(find.text('Name')).dx;
      final cell = tester.getTopLeft(find.text('a.txt')).dx;
      final size = tester.getTopLeft(find.text('Size')).dx;
      final sizeCell = tester.getTopRight(find.text('4096 B')).dx;
      Finder divider() => find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).border is BorderDirectional,
      );
      expect(divider(), findsNothing);
      position.jumpTo(100);
      await tester.pump();
      expect(tester.getTopLeft(find.text('Name')).dx, moreOrLessEquals(name));
      expect(tester.getTopLeft(find.text('a.txt')).dx, moreOrLessEquals(cell));
      expect(
        tester.getTopLeft(find.text('Size')).dx,
        moreOrLessEquals(size - 100),
      );
      expect(
        tester.getTopRight(find.text('4096 B')).dx,
        moreOrLessEquals(sizeCell - 100),
      );
      // The header and each row show the divider.
      expect(divider(), findsAtLeast(4));
      // Rows still read as one item, in column order.
      expect(
        find.semantics.byLabel(RegExp(r'^b\.png\n4096 B\nImage\nTue$')),
        findsOne,
      );
      // Rows select, headers sort and resize through the pinned cells.
      await tester.tap(find.text('b.png'));
      await tester.pump();
      expect(controller.selectedValues, ['b.png']);
      await tester.tap(find.text('Name'));
      await tester.pump();
      expect(log.sorts, [const Oito2SortDescriptor('name')]);
      await tester.drag(
        find.byType(ResizeHandle),
        const Offset(20, 0),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      expect(log.resized, [('name', 170.0)]);
      semantics.dispose();
    });

    testWidgets('pinned columns stay right to left', (tester) async {
      await _pump(
        tester,
        pinned: 1,
        width: 300,
        textDirection: TextDirection.rtl,
      );
      final position = _sideways(tester);
      final name = tester.getTopRight(find.text('Name')).dx;
      final size = tester.getTopRight(find.text('Size')).dx;
      position.jumpTo(100);
      await tester.pump();
      expect(tester.getTopRight(find.text('Name')).dx, moreOrLessEquals(name));
      expect(
        tester.getTopRight(find.text('Size')).dx,
        moreOrLessEquals(size + 100),
      );
    });

    testWidgets('scrolling cells under the pinned ones take no taps', (
      tester,
    ) async {
      final (log, _) = await _pump(tester, pinned: 1, width: 300);
      final position = _sideways(tester);
      final name = tester.getCenter(find.text('Name'));
      position.jumpTo(150);
      await tester.pump();
      // Size now sits under Name; the pointer reaches Name only.
      final hits = [
        for (final entry in tester.hitTestOnBinding(name).path) entry.target,
      ];
      expect(hits, contains(tester.renderObject(find.text('Name'))));
      expect(hits, isNot(contains(tester.renderObject(find.text('Size')))));
      await tester.tapAt(name);
      await tester.pump();
      expect(log.sorts, [const Oito2SortDescriptor('name')]);
    });

    testWidgets('pinned columns move only among themselves', (tester) async {
      final (log, _) = await _pump(tester, pinned: 2);
      // Tab past Name and its resize handle to Size, the second pinned
      // header.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(log.orders, isEmpty);
      await _alt(tester, LogicalKeyboardKey.arrowLeft);
      expect(log.orders.last, ['size', 'name', 'kind', 'date']);
      // Kind, the first scrolling column, can't move before Size.
      final gesture = await _mouseDrag(
        tester,
        tester.getCenter(find.text('Kind')),
        tester.getTopLeft(find.text('Size')),
      );
      await gesture.up();
      await tester.pump();
      expect(log.orders, hasLength(1));
    });

    testWidgets('hidden columns take no width and keep their place in the '
        'order', (tester) async {
      final (log, _) = await _pump(tester, hidden: const {'size'});
      expect(find.text('Size'), findsNothing);
      expect(find.text('4096 B'), findsNothing);
      // Kind starts where Size would.
      expect(
        tester.getTopLeft(find.text('Kind')).dx -
            tester.getTopLeft(find.text('Name')).dx,
        moreOrLessEquals(150 - 0 + 4, epsilon: 8),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(log.orders.last, ['size', 'kind', 'name', 'date']);
    });
  });

  group('Oito2TreeView columns', () {
    testWidgets('the first column stays while the others scroll', (
      tester,
    ) async {
      final tree = Oito2TreeCollection<String>(const [
        Oito2TreeNode(value: 'docs', data: 'folder'),
      ]);
      final controller = Oito2TreeController();
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: Oito2TreeView<String>(
              collection: tree,
              controller: controller,
              pinnedColumns: 1,
              columns: [
                const Oito2TableColumn(
                  id: 'name',
                  label: 'Name',
                  width: Oito2ColumnWidth.fixed(160),
                ),
                Oito2TableColumn(
                  id: 'kind',
                  label: 'Kind',
                  width: const Oito2ColumnWidth.fixed(200),
                  cellBuilder: (context, node) => Text(node.data ?? ''),
                ),
              ],
            ),
          ),
        ),
      );
      final position = _sideways(tester);
      final name = tester.getTopLeft(find.text('Name')).dx;
      final docs = tester.getTopLeft(find.text('docs')).dx;
      final kind = tester.getTopLeft(find.text('folder')).dx;
      position.jumpTo(60);
      await tester.pump();
      expect(tester.getTopLeft(find.text('Name')).dx, moreOrLessEquals(name));
      expect(tester.getTopLeft(find.text('docs')).dx, moreOrLessEquals(docs));
      expect(
        tester.getTopLeft(find.text('folder')).dx,
        moreOrLessEquals(kind - 60),
      );
    });
    testWidgets('the first column always shows and the others hide', (
      tester,
    ) async {
      final log = await _pumpTree(tester, hidden: const {'name', 'kind'});
      // The first column's id is ignored.
      expect(_treeHeaderOrder(tester), ['Name', 'Size', 'Status']);
      await _openMenu(tester, 'Size');
      expect(_enabled(tester, _toggle('name')), isFalse);
      expect(
        tester.widget<Oito2MultiSelectMenuItem>(_toggle('name')).checked,
        isTrue,
      );
      await tester.tap(_toggle('status'));
      await tester.pumpAndSettle();
      expect(log.hidden.last, {'name', 'kind', 'status'});
      expect(find.text('Synced'), findsNothing);
      // Size, the last column besides the first, can be hidden too: the
      // first column stays.
      expect(_enabled(tester, _toggle('size')), isTrue);
      await tester.tap(_toggle('size'));
      await tester.pumpAndSettle();
      expect(log.hidden.last, {'name', 'kind', 'status', 'size'});
      expect(find.text('docs'), findsOne);
    });

    testWidgets('the first column stays first; the others move', (
      tester,
    ) async {
      final log = await _pumpTree(tester, order: const ['kind', 'name']);
      expect(_treeHeaderOrder(tester), ['Name', 'Kind', 'Size', 'Status']);
      _announced(tester);
      expect(_actions(tester, 'Name'), isEmpty);
      expect(_actions(tester, 'Kind'), ['Move column right']);
      // Alt with the arrows on the focused Kind header.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(log.orders, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await _alt(tester, LogicalKeyboardKey.arrowLeft);
      expect(log.orders, isEmpty);
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(log.orders.last, ['name', 'size', 'kind', 'status']);
      expect(_announced(tester), ['Moved column Kind to position 3 of 4']);
      // A drag before Name drops after it; Name itself doesn't drag.
      var gesture = await _mouseDrag(
        tester,
        tester.getCenter(find.text('Status')),
        tester.getTopLeft(find.text('Name')),
      );
      await gesture.up();
      await gesture.removePointer();
      await tester.pump();
      expect(log.orders.last, ['name', 'status', 'size', 'kind']);
      gesture = await _mouseDrag(
        tester,
        tester.getCenter(find.text('Name')),
        tester.getCenter(find.text('Kind')),
      );
      expect(
        find.byKey(const ValueKey('oito2-column-drop-line')),
        findsNothing,
      );
      await gesture.up();
      await tester.pump();
      expect(log.orders, hasLength(2));
    });

    testWidgets('pinned tree columns move only among themselves', (
      tester,
    ) async {
      final log = await _pumpTree(tester, pinned: 2, width: 300);
      expect(_actions(tester, 'Size'), isEmpty);
      expect(_actions(tester, 'Status'), ['Move column right']);
      final position = _sideways(tester);
      final size = tester.getTopLeft(find.text('Size')).dx;
      position.jumpTo(40);
      await tester.pump();
      expect(tester.getTopLeft(find.text('Size')).dx, moreOrLessEquals(size));
      final node = tester.getSemantics(find.text('Status'));
      node.owner!.performAction(
        node.id,
        SemanticsAction.customAction,
        CustomSemanticsAction.getIdentifier(
          const CustomSemanticsAction(label: 'Move column right'),
        ),
      );
      await tester.pump();
      expect(log.orders.last, ['name', 'size', 'kind', 'status']);
    });

    testWidgets('Reset columns calls onResetColumns', (tester) async {
      final log = await _pumpTree(tester, hidden: const {'kind'});
      await _openMenu(tester, 'Size');
      await tester.tap(find.byKey(const ValueKey('oito2-column-reset')));
      await tester.pumpAndSettle();
      expect(log.resets, 1);
      expect(_treeHeaderOrder(tester), ['Name', 'Size', 'Status', 'Kind']);
    });
  });
}
