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
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

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

/// The pointer of the last mouse drag.
var _mouse = 100;

/// Drags with a mouse from [from] to [to], in steps, pumping between
/// them; releases the button unless [release] is false and returns the
/// gesture.
Future<TestGesture> _drag(
  WidgetTester tester,
  Offset from,
  Offset to, {
  bool release = true,
  PointerDeviceKind kind = PointerDeviceKind.mouse,
}) async {
  final TestGesture gesture;
  if (kind == PointerDeviceKind.mouse) {
    gesture = await tester.createGesture(kind: kind, pointer: ++_mouse);
    await gesture.addPointer(location: from);
    await gesture.down(from);
  } else {
    gesture = await tester.startGesture(from, kind: kind);
  }
  await tester.pump();
  if (kind != PointerDeviceKind.mouse) {
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  }
  await gesture.moveBy(const Offset(0, 10));
  await tester.pump();
  await gesture.moveTo(to);
  await tester.pump();
  if (release) await _release(tester, gesture);
  return gesture;
}

/// Releases [gesture] and removes its pointer, then pumps a frame.
Future<void> _release(WidgetTester tester, TestGesture gesture) async {
  await gesture.up();
  await gesture.removePointer();
  await tester.pump();
}

/// The global position [dy] pixels below the vertical center of the row
/// that shows [label], 40 pixels tall, at the horizontal center of the
/// tree or list.
Offset _at(WidgetTester tester, String label, [double dy = 0]) {
  final text = tester.getCenter(find.text(label).first);
  return Offset(text.dx, text.dy + dy);
}

/// The test tree: a projects branch with an app branch and a readme, a
/// docs branch with a guide, an empty archive branch and a notes leaf.
final _tree = Oito2TreeCollection<void>([
  const Oito2TreeNode(
    value: 'projects',
    children: [
      Oito2TreeNode(
        value: 'app',
        children: [Oito2TreeNode(value: 'main.dart')],
      ),
      Oito2TreeNode(value: 'readme.md'),
    ],
  ),
  const Oito2TreeNode(
    value: 'docs',
    children: [Oito2TreeNode(value: 'guide.md')],
  ),
  const Oito2TreeNode(value: 'archive', children: []),
  const Oito2TreeNode(value: 'notes.txt'),
]);

/// A recorded call of `onMove`.
typedef _Move = (String nodes, String? parent, int index);

void main() {
  group('Oito2TreeView moves', () {
    /// Pumps the test tree, 40-pixel rows, recording `onMove` calls into
    /// [moves] and applying them to the collection when [apply] is true.
    Future<Oito2TreeController> pumpTree(
      WidgetTester tester,
      List<_Move> moves, {
      bool apply = false,
      bool enabled = true,
      Iterable<String> expanded = const ['projects', 'docs'],
      Oito2SelectionMode mode = Oito2SelectionMode.single,
      bool Function(List<Oito2TreeNode<void>>, String?, int)? canDrop,
      Future<void> Function(Oito2TreeNode<void>)? onLoadChildren,
      Oito2TreeCollection<void>? collection,
      String query = '',
      double height = 400,
    }) async {
      final controller = Oito2TreeController(
        selectionMode: mode,
        expanded: expanded,
      );
      addTearDown(controller.dispose);
      var tree = collection ?? _tree;
      await pumpOito2(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: height,
            child: StatefulBuilder(
              builder: (context, setState) => Oito2TreeView(
                collection: tree,
                controller: controller,
                rowHeight: 40,
                query: query,
                canDrop: canDrop,
                onLoadChildren: onLoadChildren,
                semanticLabel: 'Files',
                onMove: !enabled
                    ? null
                    : (nodes, parent, index) {
                        moves.add((
                          [for (final n in nodes) n.value].join(','),
                          parent,
                          index,
                        ));
                        if (apply) {
                          setState(
                            () => tree = tree.move(
                              [for (final n in nodes) n.value],
                              parent,
                              index: index,
                            ),
                          );
                        }
                      },
              ),
            ),
          ),
        ),
      );
      return controller;
    }

    testWidgets('a leaf drops before or after a row by the half it is over', (
      tester,
    ) async {
      final moves = <_Move>[];
      await pumpTree(tester, moves);
      await _drag(tester, _at(tester, 'notes.txt'), _at(tester, 'docs', -15));
      expect(moves.last, ('notes.txt', null, 1));
      await _drag(
        tester,
        _at(tester, 'guide.md'),
        _at(tester, 'readme.md', 10),
      );
      expect(moves.last, ('guide.md', 'projects', 2));
      await _drag(
        tester,
        _at(tester, 'notes.txt'),
        _at(tester, 'readme.md', -10),
      );
      expect(moves.last, ('notes.txt', 'projects', 1));
      expect(moves, hasLength(3));
    });

    testWidgets('the middle of a branch drops into it, as its last child', (
      tester,
    ) async {
      final moves = <_Move>[];
      await pumpTree(tester, moves);
      await _drag(tester, _at(tester, 'notes.txt'), _at(tester, 'docs'));
      expect(moves.last, ('notes.txt', 'docs', 1));
      // After an open branch with shown children: its first child.
      await _drag(tester, _at(tester, 'notes.txt'), _at(tester, 'docs', 16));
      expect(moves.last, ('notes.txt', 'docs', 0));
    });

    testWidgets('a line or a frame marks the drop while dragging', (
      tester,
    ) async {
      final moves = <_Move>[];
      await pumpTree(tester, moves);
      final gesture = await _drag(
        tester,
        _at(tester, 'notes.txt'),
        _at(tester, 'docs', -15),
        release: false,
      );
      expect(find.byKey(const ValueKey('oito2-drop-line')), findsOneWidget);
      expect(find.byKey(const ValueKey('oito2-drop-inside')), findsNothing);
      await gesture.moveTo(_at(tester, 'docs'));
      await tester.pump();
      expect(find.byKey(const ValueKey('oito2-drop-line')), findsNothing);
      expect(find.byKey(const ValueKey('oito2-drop-inside')), findsOneWidget);
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        isNot(SystemMouseCursors.noDrop),
      );
      await _release(tester, gesture);
      expect(find.byKey(const ValueKey('oito2-drop-inside')), findsNothing);
      expect(find.text('notes.txt'), findsOneWidget);
    });

    testWidgets('a node never drops into itself or its descendants', (
      tester,
    ) async {
      final moves = <_Move>[];
      await pumpTree(tester, moves);
      final gesture = await _drag(
        tester,
        _at(tester, 'projects'),
        _at(tester, 'app'),
        release: false,
      );
      expect(find.byKey(const ValueKey('oito2-drag-no-drop')), findsOneWidget);
      expect(find.byKey(const ValueKey('oito2-drop-inside')), findsNothing);
      await _release(tester, gesture);
      await _drag(tester, _at(tester, 'projects'), _at(tester, 'readme.md'));
      expect(moves, isEmpty);
      expect(find.byKey(const ValueKey('oito2-drag-no-drop')), findsNothing);
    });

    testWidgets('canDrop refuses a drop, which calls nothing', (tester) async {
      final moves = <_Move>[];
      final asked = <(String?, int)>[];
      await pumpTree(
        tester,
        moves,
        canDrop: (nodes, parent, index) {
          asked.add((parent, index));
          return parent != 'archive';
        },
      );
      final gesture = await _drag(
        tester,
        _at(tester, 'notes.txt'),
        _at(tester, 'archive'),
        release: false,
      );
      expect(asked.last, ('archive', 0));
      expect(find.byKey(const ValueKey('oito2-drag-no-drop')), findsOneWidget);
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.noDrop,
      );
      await _release(tester, gesture);
      expect(moves, isEmpty);
      await _drag(tester, _at(tester, 'notes.txt'), _at(tester, 'docs'));
      expect(moves, [('notes.txt', 'docs', 1)]);
    });

    testWidgets('a drop that changes nothing calls nothing', (tester) async {
      final moves = <_Move>[];
      await pumpTree(tester, moves);
      await _drag(
        tester,
        _at(tester, 'readme.md'),
        _at(tester, 'readme.md', 15),
      );
      await _drag(tester, _at(tester, 'readme.md'), _at(tester, 'app', 16));
      expect(moves, isEmpty);
    });

    testWidgets('a closed branch held under the pointer opens and loads', (
      tester,
    ) async {
      final moves = <_Move>[];
      final loads = <String>[];
      final controller = await pumpTree(
        tester,
        moves,
        expanded: const ['projects'],
        onLoadChildren: (node) async => loads.add(node.value),
      );
      final gesture = await _drag(
        tester,
        _at(tester, 'notes.txt'),
        _at(tester, 'docs'),
        release: false,
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(controller.isExpanded('docs'), isFalse);
      await tester.pump(const Duration(milliseconds: 150));
      expect(controller.isExpanded('docs'), isTrue);
      expect(find.text('guide.md'), findsOneWidget);
      // Leaving a branch before the delay keeps it closed.
      await gesture.moveTo(_at(tester, 'archive'));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.moveTo(_at(tester, 'notes.txt'));
      await tester.pump(const Duration(milliseconds: 800));
      expect(controller.isExpanded('archive'), isFalse);
      // An empty branch loads its children as it opens.
      await gesture.moveTo(_at(tester, 'archive'));
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump();
      expect(controller.isExpanded('archive'), isTrue);
      expect(loads, ['archive']);
      await _release(tester, gesture);
      expect(moves, [('notes.txt', 'archive', 0)]);
    });

    testWidgets('the tree scrolls while the pointer is near an edge', (
      tester,
    ) async {
      final moves = <_Move>[];
      await pumpTree(
        tester,
        moves,
        height: 200,
        collection: Oito2TreeCollection([
          for (var i = 0; i < 40; i++) Oito2TreeNode(value: 'item $i'),
        ]),
      );
      final scroll = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      final box = tester.getRect(find.byType(Oito2TreeView<void>));
      final gesture = await _drag(
        tester,
        _at(tester, 'item 0'),
        Offset(box.center.dx, box.bottom - 4),
        release: false,
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(scroll.pixels, greaterThan(50));
      // Back in the middle, it stops.
      await gesture.moveTo(box.center);
      await tester.pump();
      final stopped = scroll.pixels;
      await tester.pump(const Duration(milliseconds: 200));
      expect(scroll.pixels, stopped);
      await _release(tester, gesture);
      expect(moves.single.$1, 'item 0');
      expect(moves.single.$3, greaterThan(3));
    });

    testWidgets('a drag carries the multiple selection that holds its row', (
      tester,
    ) async {
      final moves = <_Move>[];
      final controller = await pumpTree(
        tester,
        moves,
        mode: Oito2SelectionMode.multiple,
      );
      controller.setSelected(['notes.txt', 'docs', 'guide.md']);
      await tester.pump();
      await _drag(tester, _at(tester, 'notes.txt'), _at(tester, 'app', -15));
      expect(moves.last, ('docs,notes.txt', 'projects', 0));
      // A row outside the selection moves alone.
      await _drag(tester, _at(tester, 'readme.md'), _at(tester, 'app', -15));
      expect(moves.last, ('readme.md', 'projects', 0));
    });

    testWidgets('Escape cancels a drag', (tester) async {
      final moves = <_Move>[];
      await pumpTree(tester, moves);
      final gesture = await _drag(
        tester,
        _at(tester, 'notes.txt'),
        _at(tester, 'docs'),
        release: false,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byKey(const ValueKey('oito2-drop-inside')), findsNothing);
      await _release(tester, gesture);
      expect(moves, isEmpty);
    });

    testWidgets('a touch drags after a long press', (tester) async {
      final moves = <_Move>[];
      await pumpTree(tester, moves);
      await _drag(
        tester,
        _at(tester, 'notes.txt'),
        _at(tester, 'docs'),
        kind: PointerDeviceKind.touch,
      );
      expect(moves, [('notes.txt', 'docs', 1)]);
    });

    testWidgets('nothing drags without onMove or while filtering', (
      tester,
    ) async {
      final moves = <_Move>[];
      final controller = await pumpTree(tester, moves, enabled: false);
      await _drag(tester, _at(tester, 'notes.txt'), _at(tester, 'docs'));
      expect(find.byKey(const ValueKey('oito2-drop-inside')), findsNothing);
      // A plain click still selects.
      await tester.tap(find.text('readme.md'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.selected, {'readme.md'});
      // Alt+Down moves the active row as Down does.
      await _alt(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selected, {'docs'});

      await pumpTree(tester, moves, query: 'md');
      await _drag(
        tester,
        _at(tester, 'readme.md'),
        _at(tester, 'guide.md', 15),
      );
      expect(moves, isEmpty);
    });

    testWidgets('Alt with the arrows moves the active node and announces it', (
      tester,
    ) async {
      final moves = <_Move>[];
      final controller = await pumpTree(tester, moves, apply: true);
      await tester.tap(find.text('readme.md'));
      await tester.pump(const Duration(milliseconds: 400));
      _announced(tester);

      await _alt(tester, LogicalKeyboardKey.arrowUp);
      expect(moves.last, ('readme.md', 'projects', 0));
      expect(_announced(tester), ['Moved readme.md into projects, position 1']);
      // Already first: nothing happens.
      await _alt(tester, LogicalKeyboardKey.arrowUp);
      expect(moves, hasLength(1));
      expect(_announced(tester), isEmpty);

      await _alt(tester, LogicalKeyboardKey.arrowDown);
      expect(moves.last, ('readme.md', 'projects', 1));

      // Outdent: after the parent, at the top level.
      await _alt(tester, LogicalKeyboardKey.arrowLeft);
      expect(moves.last, ('readme.md', null, 1));
      expect(
        _announced(tester).last,
        'Moved readme.md to the top level, position 2',
      );
      // Already at the top level: nothing happens.
      await _alt(tester, LogicalKeyboardKey.arrowLeft);
      expect(moves, hasLength(3));

      // Indent: into the branch above, as its last child.
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(moves.last, ('readme.md', 'projects', 1));

      // Indent into a closed, empty branch opens it.
      await tester.tap(find.text('notes.txt'));
      await tester.pump(const Duration(milliseconds: 400));
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(moves.last, ('notes.txt', 'archive', 0));
      expect(controller.isExpanded('archive'), isTrue);
      expect(find.text('notes.txt'), findsOneWidget);
      // The first child has no sibling above to go into.
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(moves, hasLength(5));
      // The moved node stays active: Down goes on from it.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(controller.selected, {'archive'});
    });

    testWidgets('the keyboard follows canDrop and announces a refusal', (
      tester,
    ) async {
      final moves = <_Move>[];
      await pumpTree(
        tester,
        moves,
        canDrop: (nodes, parent, index) => parent != 'archive',
      );
      await tester.tap(find.text('notes.txt'));
      await tester.pump(const Duration(milliseconds: 400));
      _announced(tester);
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(moves, isEmpty);
      expect(_announced(tester), ["Can't drop here"]);
    });

    testWidgets('rows offer the move actions to assistive technologies', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final moves = <_Move>[];
      await pumpTree(tester, moves);
      List<String> actions(String label) {
        final data = tester
            .getSemantics(find.bySemanticsLabel(label))
            .getSemanticsData();
        return [
          for (final id in data.customSemanticsActionIds ?? const <int>[])
            CustomSemanticsAction.getAction(id)!.label!,
        ];
      }

      expect(actions('projects'), unorderedEquals(['Move down']));
      expect(
        actions('readme.md'),
        unorderedEquals(['Move up', 'Indent', 'Outdent']),
      );
      expect(actions('notes.txt'), unorderedEquals(['Move up', 'Indent']));
      final node = tester.getSemantics(find.bySemanticsLabel('readme.md'));
      node.owner!.performAction(
        node.id,
        SemanticsAction.customAction,
        CustomSemanticsAction.getIdentifier(
          const CustomSemanticsAction(label: 'Outdent'),
        ),
      );
      await tester.pump();
      expect(moves, [('readme.md', null, 1)]);
      semantics.dispose();
    });

    /// Pumps the test tree with drag handles, a context menu that records
    /// its nodes into [menus], and the given [columns].
    Future<void> pumpHandles(
      WidgetTester tester,
      List<_Move> moves,
      List<String> menus, {
      List<Oito2TableColumn<Oito2TreeNode<void>>>? columns,
    }) async {
      final controller = Oito2TreeController(
        expanded: const ['projects', 'docs'],
      );
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 400,
            child: Oito2TreeView(
              collection: _tree,
              controller: controller,
              rowHeight: 40,
              dragHandle: true,
              columns: columns,
              onContextMenu: (node, position, byKeyboard) =>
                  menus.add(node.value),
              onMove: (nodes, parent, index) => moves.add((
                [for (final n in nodes) n.value].join(','),
                parent,
                index,
              )),
            ),
          ),
        ),
      );
    }

    /// The grip of the row that shows [label].
    Finder grip(String label) => find.descendant(
      of: find
          .ancestor(of: find.text(label).first, matching: find.byType(Row))
          .first,
      matching: find.byKey(const ValueKey('oito2-drag-handle')),
    );

    testWidgets('with dragHandle, only the grip drags, by mouse or touch', (
      tester,
    ) async {
      final moves = <_Move>[];
      final menus = <String>[];
      await pumpHandles(tester, moves, menus);
      expect(find.byKey(const ValueKey('oito2-drag-handle')), findsNWidgets(7));
      // The row itself no longer drags.
      await _drag(tester, _at(tester, 'notes.txt'), _at(tester, 'docs'));
      expect(moves, isEmpty);
      // A mouse on the grip, with the grab cursor.
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(grip('notes.txt')));
      await tester.pump();
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.grab,
      );
      await mouse.removePointer();
      await _drag(
        tester,
        tester.getCenter(grip('notes.txt')),
        _at(tester, 'docs'),
      );
      expect(moves, [('notes.txt', 'docs', 1)]);
      // A touch on the grip drags at once, without a long press.
      final touch = await tester.startGesture(
        tester.getCenter(grip('notes.txt')),
      );
      await touch.moveBy(const Offset(0, 20));
      await tester.pump();
      await touch.moveTo(_at(tester, 'docs', -15));
      await tester.pump();
      await _release(tester, touch);
      expect(moves.last, ('notes.txt', null, 1));
      expect(menus, isEmpty);
    });

    testWidgets('with dragHandle, a long press still opens the menu', (
      tester,
    ) async {
      final moves = <_Move>[];
      final menus = <String>[];
      await pumpHandles(tester, moves, menus);
      await tester.longPress(find.text('readme.md'));
      await tester.pump();
      expect(menus, ['readme.md']);
      expect(moves, isEmpty);
    });

    testWidgets('with dragHandle and columns, the cells stay aligned', (
      tester,
    ) async {
      final moves = <_Move>[];
      final menus = <String>[];
      await pumpHandles(
        tester,
        moves,
        menus,
        columns: [
          const Oito2TableColumn(
            id: 'name',
            label: 'Name',
            width: Oito2ColumnWidth.flex(1, min: 160),
          ),
          Oito2TableColumn(
            id: 'kind',
            label: 'Kind',
            width: const Oito2ColumnWidth.fixed(80),
            cellBuilder: (context, node) => Text(
              node.isBranch ? 'Folder ${node.value}' : 'File ${node.value}',
            ),
          ),
        ],
      );
      final header = tester.getRect(find.text('Kind')).left;
      for (final value in ['projects', 'readme.md', 'notes.txt']) {
        final cell = find.textContaining(' $value');
        final left = tester.getRect(cell).left;
        expect((left - header).abs(), lessThan(1), reason: value);
        // The grip sits in the first column, before the cell.
        expect(
          tester.getRect(grip(value)).right,
          lessThanOrEqualTo(left),
          reason: value,
        );
      }
      await _drag(
        tester,
        tester.getCenter(grip('notes.txt')),
        _at(tester, 'docs'),
      );
      expect(moves, [('notes.txt', 'docs', 1)]);
    });

    testWidgets('rowDropTargetBuilder wraps rows and dropHighlight marks one', (
      tester,
    ) async {
      final dropped = <(String, Object)>[];
      String? hovered;
      final controller = Oito2TreeController(expanded: const ['projects']);
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Column(
          children: [
            const Draggable<String>(
              data: 'photo.png',
              feedback: SizedBox(width: 10, height: 10),
              child: Text('photo.png'),
            ),
            SizedBox(
              width: 300,
              height: 300,
              child: StatefulBuilder(
                builder: (context, setState) => Oito2TreeView(
                  collection: _tree,
                  controller: controller,
                  rowHeight: 40,
                  dropHighlight: hovered,
                  rowDropTargetBuilder: (context, node, row) =>
                      DragTarget<String>(
                        onWillAcceptWithDetails: (details) {
                          if (!node.isBranch) return false;
                          setState(() => hovered = node.value);
                          return true;
                        },
                        onLeave: (_) => setState(() => hovered = null),
                        onAcceptWithDetails: (details) {
                          setState(() => hovered = null);
                          dropped.add((node.value, details.data));
                        },
                        builder: (context, candidates, rejected) => row,
                      ),
                ),
              ),
            ),
          ],
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('photo.png')),
      );
      await gesture.moveTo(tester.getCenter(find.text('docs')));
      await tester.pump();
      expect(find.byKey(const ValueKey('oito2-drop-inside')), findsOneWidget);
      await _release(tester, gesture);
      expect(dropped, [('docs', 'photo.png')]);
      expect(find.byKey(const ValueKey('oito2-drop-inside')), findsNothing);
    });
  });

  group('Oito2TreeView lazy branches', () {
    /// Pumps a tree with an empty `archive` branch that loads
    /// `archive/old.txt` after 200 milliseconds, followed by `notes.txt`,
    /// applying `onMove` to the tree; returns the controller, the moves
    /// and the loaded branches.
    Future<
      (
        Oito2TreeController,
        List<_Move>,
        List<String>,
        ValueGetter<Oito2TreeCollection<void>>,
        ValueSetter<Oito2TreeCollection<void>>,
      )
    >
    pumpLazy(
      WidgetTester tester, {
      Oito2SelectionMode mode = Oito2SelectionMode.single,
      List<Oito2TreeNode<void>>? roots,
    }) async {
      final controller = Oito2TreeController(selectionMode: mode);
      addTearDown(controller.dispose);
      final moves = <_Move>[];
      final loads = <String>[];
      var tree = Oito2TreeCollection<void>(
        roots ??
            const [
              Oito2TreeNode(value: 'archive', children: []),
              Oito2TreeNode(value: 'notes.txt'),
            ],
      );
      late StateSetter update;
      await pumpOito2(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 400,
            child: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return Oito2TreeView(
                  collection: tree,
                  controller: controller,
                  rowHeight: 40,
                  semanticLabel: 'Files',
                  onLoadChildren: (node) async {
                    loads.add(node.value);
                    await Future<void>.delayed(
                      const Duration(milliseconds: 200),
                    );
                    setState(
                      () => tree = tree.insert(node.value, [
                        Oito2TreeNode(value: '${node.value}/old.txt'),
                      ]),
                    );
                  },
                  onMove: (nodes, parent, index) {
                    final values = [for (final n in nodes) n.value];
                    moves.add((values.join(','), parent, index));
                    setState(
                      () => tree = tree.move(values, parent, index: index),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
      return (
        controller,
        moves,
        loads,
        () => tree,
        (Oito2TreeCollection<void> next) => update(() => tree = next),
      );
    }

    testWidgets('a quick drop into an unloaded branch loads it first', (
      tester,
    ) async {
      final (controller, moves, loads, tree, _) = await pumpLazy(tester);
      await _drag(tester, _at(tester, 'notes.txt'), _at(tester, 'archive'));
      expect(moves, isEmpty);
      expect(controller.isExpanded('archive'), isTrue);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      await tester.pump();
      expect(loads, ['archive']);
      expect(moves, [('notes.txt', 'archive', 1)]);
      expect(tree().childrenOf('archive').map((n) => n.value), [
        'archive/old.txt',
        'notes.txt',
      ]);
    });

    testWidgets('Alt+Right into an unloaded branch loads it first', (
      tester,
    ) async {
      final (_, moves, loads, tree, _) = await pumpLazy(tester);
      await tester.tap(find.text('notes.txt'));
      await tester.pump();
      await _alt(tester, LogicalKeyboardKey.arrowRight);
      expect(moves, isEmpty);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      await tester.pump();
      expect(loads, ['archive']);
      expect(moves, [('notes.txt', 'archive', 1)]);
      expect(tree().childrenOf('archive').map((n) => n.value), [
        'archive/old.txt',
        'notes.txt',
      ]);
    });

    testWidgets('reloadChildren loads a loaded branch again', (tester) async {
      final (controller, _, loads, tree, setTree) = await pumpLazy(tester);
      controller.setExpanded('archive', true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(loads, ['archive']);
      expect(find.text('archive/old.txt'), findsOneWidget);
      // Emptying the branch alone doesn't load it again.
      setTree(tree().remove(['archive/old.txt']));
      await tester.pump();
      await tester.pump();
      expect(loads, ['archive']);
      controller.reloadChildren('archive');
      await tester.pump();
      await tester.pump();
      expect(loads, ['archive', 'archive']);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(find.text('archive/old.txt'), findsOneWidget);
    });

    testWidgets('a drag leaves out disabled selected nodes', (tester) async {
      final (controller, moves, _, _, _) = await pumpLazy(
        tester,
        mode: Oito2SelectionMode.multiple,
        roots: const [
          Oito2TreeNode(
            value: 'locked',
            disabled: true,
            children: [Oito2TreeNode(value: 'draft.txt')],
          ),
          Oito2TreeNode(
            value: 'inbox',
            children: [Oito2TreeNode(value: 'a')],
          ),
          Oito2TreeNode(value: 'notes.txt'),
        ],
      );
      controller.setExpanded('locked', true);
      controller.setSelected(['locked', 'draft.txt', 'notes.txt']);
      await tester.pump();
      await _drag(tester, _at(tester, 'draft.txt'), _at(tester, 'inbox'));
      expect(moves, [('draft.txt,notes.txt', 'inbox', 1)]);
      // The emptied branch loads its children again.
      await tester.pump(const Duration(milliseconds: 200));
    });
  });

  for (final virtual in [false, true]) {
    group(virtual ? 'Oito2VirtualList reorder' : 'Oito2ListBox reorder', () {
      final fruits = Oito2ListCollection(const [
        'Apple',
        'Banana',
        'Cherry',
        'Date',
        'Elder',
      ], isDisabled: (f) => f == 'Cherry');

      Future<Oito2SelectionController> pumpList(
        WidgetTester tester,
        List<(int, int)> moves, {
        bool enabled = true,
        bool dragHandle = false,
      }) async {
        final controller = Oito2SelectionController(collection: fruits);
        addTearDown(controller.dispose);
        void onReorder(int from, int to) => moves.add((from, to));
        await pumpOito2(
          tester,
          Center(
            child: SizedBox(
              width: 240,
              height: 300,
              child: virtual
                  ? Oito2VirtualList(
                      collection: fruits,
                      controller: controller,
                      dragHandle: dragHandle,
                      onReorder: enabled ? onReorder : null,
                    )
                  : Oito2ListBox(
                      collection: fruits,
                      controller: controller,
                      dragHandle: dragHandle,
                      onReorder: enabled ? onReorder : null,
                    ),
            ),
          ),
        );
        return controller;
      }

      testWidgets('to is the index after the item is taken out', (
        tester,
      ) async {
        final moves = <(int, int)>[];
        await pumpList(tester, moves);
        await _drag(tester, _at(tester, 'Apple'), _at(tester, 'Date', 6));
        expect(moves.last, (0, 3));
        await _drag(tester, _at(tester, 'Elder'), _at(tester, 'Banana', -6));
        expect(moves.last, (4, 1));
        await _drag(tester, _at(tester, 'Apple'), _at(tester, 'Elder', 6));
        expect(moves.last, (0, 4));
        // Next to itself, nothing moves.
        await _drag(tester, _at(tester, 'Banana'), _at(tester, 'Apple', 6));
        // A disabled item doesn't drag.
        await _drag(tester, _at(tester, 'Cherry'), _at(tester, 'Apple', -6));
        expect(moves, hasLength(3));
      });

      testWidgets('a line marks the drop while dragging', (tester) async {
        final moves = <(int, int)>[];
        await pumpList(tester, moves);
        final gesture = await _drag(
          tester,
          _at(tester, 'Apple'),
          _at(tester, 'Apple', 6),
          release: false,
        );
        // Over its own place: no line, but no "no drop" sign either.
        expect(find.byKey(const ValueKey('oito2-drop-line')), findsNothing);
        expect(find.byKey(const ValueKey('oito2-drag-no-drop')), findsNothing);
        await gesture.moveTo(_at(tester, 'Date', 6));
        await tester.pump();
        expect(find.byKey(const ValueKey('oito2-drop-line')), findsOneWidget);
        expect(
          RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
          SystemMouseCursors.grabbing,
        );
        await gesture.moveTo(const Offset(5, 5));
        await tester.pump();
        expect(find.byKey(const ValueKey('oito2-drop-line')), findsNothing);
        expect(
          find.byKey(const ValueKey('oito2-drag-no-drop')),
          findsOneWidget,
        );
        await _release(tester, gesture);
        expect(moves, isEmpty);
      });

      testWidgets('with dragHandle, only the grip drags, with any pointer', (
        tester,
      ) async {
        final moves = <(int, int)>[];
        await pumpList(tester, moves, dragHandle: true);
        await _drag(tester, _at(tester, 'Apple'), _at(tester, 'Date', 6));
        expect(moves, isEmpty);
        final grip = find.byKey(const ValueKey('oito2-drag-handle'));
        expect(grip, findsNWidgets(5));
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: tester.getCenter(grip.first));
        addTearDown(mouse.removePointer);
        await tester.pump();
        expect(
          RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
          SystemMouseCursors.grab,
        );
        final touch = await tester.startGesture(tester.getCenter(grip.first));
        await touch.moveBy(const Offset(0, 20));
        await tester.pump();
        await touch.moveTo(_at(tester, 'Date', 6));
        await tester.pump();
        await touch.up();
        await tester.pump();
        expect(moves, [(0, 3)]);
      });

      testWidgets('Alt with Up or Down moves the active row', (tester) async {
        final moves = <(int, int)>[];
        await pumpList(tester, moves);
        await tester.tap(find.text('Banana'));
        await tester.pump(const Duration(milliseconds: 400));
        _announced(tester);
        await _alt(tester, LogicalKeyboardKey.arrowDown);
        expect(moves, [(1, 2)]);
        expect(_announced(tester), ['Moved Banana to position 3 of 5']);
        await _alt(tester, LogicalKeyboardKey.arrowUp);
        expect(moves.last, (1, 0));
        await tester.tap(find.text('Elder'));
        await tester.pump(const Duration(milliseconds: 400));
        await _alt(tester, LogicalKeyboardKey.arrowDown);
        expect(moves, hasLength(2));
      });

      testWidgets('rows offer Move up and Move down', (tester) async {
        final semantics = tester.ensureSemantics();
        final moves = <(int, int)>[];
        await pumpList(tester, moves);
        final node = tester.getSemantics(find.text('Apple'));
        final labels = [
          for (final id
              in node.getSemanticsData().customSemanticsActionIds ??
                  const <int>[])
            CustomSemanticsAction.getAction(id)!.label!,
        ];
        expect(labels, ['Move down']);
        node.owner!.performAction(
          node.id,
          SemanticsAction.customAction,
          CustomSemanticsAction.getIdentifier(
            const CustomSemanticsAction(label: 'Move down'),
          ),
        );
        await tester.pump();
        expect(moves, [(0, 1)]);
        semantics.dispose();
      });

      testWidgets('disabled rows offer no move actions', (tester) async {
        final semantics = tester.ensureSemantics();
        final moves = <(int, int)>[];
        await pumpList(tester, moves);
        final ids =
            tester
                .getSemantics(find.text('Cherry'))
                .getSemanticsData()
                .customSemanticsActionIds ??
            const <int>[];
        expect(ids, isEmpty);
        semantics.dispose();
      });

      testWidgets('without onReorder nothing drags and Alt+Down moves on', (
        tester,
      ) async {
        final moves = <(int, int)>[];
        final controller = await pumpList(tester, moves, enabled: false);
        await _drag(tester, _at(tester, 'Apple'), _at(tester, 'Date', 6));
        expect(find.byKey(const ValueKey('oito2-drop-line')), findsNothing);
        expect(find.byKey(const ValueKey('oito2-drag-handle')), findsNothing);
        await tester.tap(find.text('Banana'));
        await tester.pump(const Duration(milliseconds: 400));
        await _alt(tester, LogicalKeyboardKey.arrowDown);
        expect(controller.selectedValues, ['Date']);
        expect(moves, isEmpty);
      });
    });
  }

  testWidgets('Oito2VirtualList scrolls while dragging near an edge', (
    tester,
  ) async {
    final items = Oito2ListCollection([for (var i = 0; i < 100; i++) 'Row $i']);
    final controller = Oito2SelectionController(collection: items);
    addTearDown(controller.dispose);
    final moves = <(int, int)>[];
    await pumpOito2(
      tester,
      Center(
        child: SizedBox(
          width: 240,
          height: 300,
          child: Oito2VirtualList(
            collection: items,
            controller: controller,
            onReorder: (from, to) => moves.add((from, to)),
          ),
        ),
      ),
    );
    final box = tester.getRect(find.byType(Oito2VirtualList<String>));
    final gesture = await _drag(
      tester,
      _at(tester, 'Row 0'),
      Offset(box.center.dx, box.bottom - 3),
      release: false,
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final scroll = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    expect(scroll.pixels, greaterThan(100));
    await _release(tester, gesture);
    expect(moves.single.$1, 0);
    expect(moves.single.$2, greaterThan(8));
  });

  testWidgets('Oito2DataTable passes onReorder to its rows', (tester) async {
    final items = Oito2ListCollection(const ['a', 'b', 'c']);
    final controller = Oito2SelectionController(collection: items);
    addTearDown(controller.dispose);
    final moves = <(int, int)>[];
    await pumpOito2(
      tester,
      SizedBox(
        width: 400,
        height: 300,
        child: Oito2DataTable<String>(
          collection: items,
          controller: controller,
          columns: [
            Oito2TableColumn(
              id: 'name',
              label: 'Name',
              cellBuilder: (context, item) => Text(item),
            ),
          ],
          onReorder: (from, to) => moves.add((from, to)),
        ),
      ),
    );
    await tester.tap(find.text('a'));
    await tester.pump(const Duration(milliseconds: 400));
    await _alt(tester, LogicalKeyboardKey.arrowDown);
    expect(moves, [(0, 1)]);
  });
}
