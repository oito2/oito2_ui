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
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui/src/widgets/options_view.dart';
import 'package:oito2_ui/src/widgets/row_drag.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// A theme for a touch platform, which pads tap targets.
final _touchTheme = Oito2Theme.light(
  platform: const Oito2Platform(
    targetPlatform: TargetPlatform.android,
    isWeb: false,
  ),
);

/// A drag that does nothing.
class _NoDrag implements Drag {
  @override
  void update(DragUpdateDetails details) {}

  @override
  void end(DragEndDetails details) {}

  @override
  void cancel() {}
}

void main() {
  group('RowDragDetector', () {
    /// Pumps a 200 by 40 detector and returns the list of the positions
    /// where a drag started.
    Future<List<Offset>> pumpDetector(
      WidgetTester tester, {
      bool handle = false,
      bool longPress = true,
      bool enabled = true,
    }) async {
      final starts = <Offset>[];
      await tester.pumpWidget(
        Center(
          child: RowDragDetector(
            handle: handle,
            longPress: longPress,
            onStart: enabled
                ? (position) {
                    starts.add(position);
                    return _NoDrag();
                  }
                : null,
            // A tap competes with the drag, as the row's own tap does.
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 200,
                height: 40,
                color: const Color(0xFF000000),
              ),
            ),
          ),
        ),
      );
      return starts;
    }

    /// Presses [kind] at the center of the row, waits [hold], moves by
    /// [by] in small steps and releases.
    Future<void> drag(
      WidgetTester tester,
      Offset by, {
      PointerDeviceKind kind = PointerDeviceKind.mouse,
      int buttons = kPrimaryButton,
      Duration hold = Duration.zero,
    }) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Container)),
        kind: kind,
        buttons: buttons,
      );
      if (hold > Duration.zero) await tester.pump(hold);
      for (var i = 0; i < 4; i++) {
        await gesture.moveBy(by / 4);
        await tester.pump();
      }
      await gesture.up();
      await tester.pump();
    }

    testWidgets('a mouse starts a drag only past the threshold', (
      tester,
    ) async {
      final starts = await pumpDetector(tester);
      await drag(tester, const Offset(0, kRowDragThreshold - 2));
      expect(starts, isEmpty);
      await drag(tester, const Offset(0, kRowDragThreshold * 3));
      expect(starts, hasLength(1));
    });

    testWidgets('only the primary mouse button starts a drag', (tester) async {
      final starts = await pumpDetector(tester);
      await drag(tester, const Offset(0, 40), buttons: kSecondaryMouseButton);
      expect(starts, isEmpty);
    });

    testWidgets('a touch starts a drag after a long press, and never '
        'without longPress', (tester) async {
      var starts = await pumpDetector(tester);
      await drag(tester, const Offset(0, 40), kind: PointerDeviceKind.touch);
      expect(starts, isEmpty);
      await drag(
        tester,
        const Offset(0, 40),
        kind: PointerDeviceKind.touch,
        hold: kLongPressTimeout + const Duration(milliseconds: 50),
      );
      expect(starts, hasLength(1));

      starts = await pumpDetector(tester, longPress: false);
      await drag(
        tester,
        const Offset(0, 40),
        kind: PointerDeviceKind.touch,
        hold: kLongPressTimeout + const Duration(milliseconds: 50),
      );
      expect(starts, isEmpty);
    });

    testWidgets('a handle starts a touch drag at once', (tester) async {
      final starts = await pumpDetector(tester, handle: true);
      await drag(tester, const Offset(0, 40), kind: PointerDeviceKind.touch);
      expect(starts, hasLength(1));
    });

    testWidgets('recognizes nothing without onStart', (tester) async {
      await pumpDetector(tester, enabled: false);
      expect(
        find.descendant(
          of: find.byType(RowDragDetector),
          matching: find.byType(RawGestureDetector),
        ),
        findsOneWidget,
      );
    });
  });

  group('DragAutoScroller', () {
    /// Pumps a 300-pixel-tall list of 50 rows of 40 pixels and returns its
    /// controller.
    Future<ScrollController> pumpList(
      WidgetTester tester, {
      bool reverse = false,
    }) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: ListView.builder(
                controller: controller,
                reverse: reverse,
                itemCount: 50,
                itemExtent: 40,
                itemBuilder: (context, index) => Text('$index'),
              ),
            ),
          ),
        ),
      );
      return controller;
    }

    RenderBox viewportOf(WidgetTester tester) =>
        tester.renderObject<RenderBox>(find.byType(Scrollable));

    testWidgets('scrolls toward the edge the pointer is near, faster '
        'closer to it, and stops in the middle', (tester) async {
      final controller = await pumpList(tester);
      var scrolled = 0;
      final scroller = DragAutoScroller(() => scrolled++);
      addTearDown(scroller.stop);
      final viewport = viewportOf(tester);
      final bottom = viewport.localToGlobal(const Offset(100, 295));
      scroller.update(bottom, viewport, controller.position);
      expect(scroller.isScrolling, isTrue);
      await tester.pump(DragAutoScroller.interval);
      final fast = controller.offset;
      expect(fast, greaterThan(0));
      expect(scrolled, 1);

      scroller.update(
        viewport.localToGlobal(const Offset(100, 272)),
        viewport,
        controller.position,
      );
      await tester.pump(DragAutoScroller.interval);
      expect(controller.offset - fast, lessThan(fast));

      scroller.update(
        viewport.localToGlobal(const Offset(100, 150)),
        viewport,
        controller.position,
      );
      expect(scroller.isScrolling, isFalse);

      scroller.update(
        viewport.localToGlobal(const Offset(100, 5)),
        viewport,
        controller.position,
      );
      final before = controller.offset;
      await tester.pump(DragAutoScroller.interval);
      expect(controller.offset, lessThan(before));
    });

    testWidgets('ignores a pointer beside the viewport and stops at the '
        'end of the list', (tester) async {
      final controller = await pumpList(tester);
      final scroller = DragAutoScroller(() {});
      addTearDown(scroller.stop);
      final viewport = viewportOf(tester);
      scroller.update(
        viewport.localToGlobal(const Offset(-10, 295)),
        viewport,
        controller.position,
      );
      expect(scroller.isScrolling, isFalse);

      scroller.update(
        viewport.localToGlobal(const Offset(100, 5)),
        viewport,
        controller.position,
      );
      await tester.pump(DragAutoScroller.interval * 3);
      expect(controller.offset, 0);

      controller.jumpTo(controller.position.maxScrollExtent);
      scroller.update(
        viewport.localToGlobal(const Offset(100, 295)),
        viewport,
        controller.position,
      );
      await tester.pump(DragAutoScroller.interval * 3);
      expect(controller.offset, controller.position.maxScrollExtent);

      scroller.update(Offset.zero, null, controller.position);
      expect(scroller.isScrolling, isFalse);
    });

    testWidgets('follows a reversed list', (tester) async {
      final controller = await pumpList(tester, reverse: true);
      final scroller = DragAutoScroller(() {});
      addTearDown(scroller.stop);
      final viewport = viewportOf(tester);
      // In a reversed list, the top edge leads to larger offsets.
      scroller.update(
        viewport.localToGlobal(const Offset(100, 5)),
        viewport,
        controller.position,
      );
      await tester.pump(DragAutoScroller.interval);
      expect(controller.offset, greaterThan(0));
    });
  });

  group('Oito2TableColumn.resolveWidths', () {
    Oito2TableColumn<int> column(String id, Oito2ColumnWidth width) =>
        Oito2TableColumn(id: id, label: id, width: width);

    test('fixed columns keep their width and flexible ones share the '
        'rest by flex', () {
      final widths = Oito2TableColumn.resolveWidths([
        column('a', const Oito2ColumnWidth.fixed(100)),
        column('b', const Oito2ColumnWidth.flex(1)),
        column('c', const Oito2ColumnWidth.flex(3)),
      ], 500);
      expect(widths, [100, 100, 300]);
    });

    test('a flexible column keeps its minimum, and nothing goes below '
        'zero when the fixed columns overflow', () {
      expect(
        Oito2TableColumn.resolveWidths([
          column('a', const Oito2ColumnWidth.fixed(300)),
          column('b', const Oito2ColumnWidth.flex(1, min: 80)),
          column('c', const Oito2ColumnWidth.flex(1)),
        ], 200),
        [300, 80, 0],
      );
    });

    test('an override replaces the width of any column and counts as '
        'fixed', () {
      final widths = Oito2TableColumn.resolveWidths(
        [
          column('a', const Oito2ColumnWidth.fixed(100)),
          column('b', const Oito2ColumnWidth.flex(1)),
          column('c', const Oito2ColumnWidth.flex(1)),
        ],
        400,
        overrides: const {'a': 50, 'b': 150},
      );
      expect(widths, [50, 150, 200]);
    });
  });

  group('AutocompleteOptionsView', () {
    /// Pumps the view of three fruits with [highlighted] as the keyboard
    /// highlight and returns the list of chosen options.
    Future<List<String>> pumpView(
      WidgetTester tester, {
      int highlighted = 0,
      double maxHeight = 300,
      ThemeData? theme,
      int count = 3,
      ValueNotifier<int>? highlight,
    }) async {
      final chosen = <String>[];
      final notifier = highlight ?? ValueNotifier(highlighted);
      if (highlight == null) addTearDown(notifier.dispose);
      final fruits = [
        'Apple',
        'Apricot',
        'Banana',
        for (var i = 3; i < count; i++) 'Fruit $i',
      ];
      await pumpOito2(
        tester,
        AutocompleteHighlightedOption(
          highlightIndexNotifier: notifier,
          child: AutocompleteOptionsView<String>(
            options: fruits,
            collection: Oito2ListCollection(fruits),
            query: 'ap',
            onSelected: chosen.add,
            maxHeight: maxHeight,
            width: 240,
          ),
        ),
        theme: theme,
      );
      await tester.pump();
      return chosen;
    }

    testWidgets('highlights the query and chooses the tapped option', (
      tester,
    ) async {
      final chosen = await pumpView(tester);
      final labels = tester
          .widgetList<Oito2HighlightedText>(find.byType(Oito2HighlightedText))
          .map((text) => (text.text, text.query));
      expect(labels, [('Apple', 'ap'), ('Apricot', 'ap'), ('Banana', 'ap')]);
      expect(
        tester.getSize(find.byType(ListView)).width,
        lessThanOrEqualTo(240),
      );
      await tester.tap(find.byType(Oito2HighlightedText).at(1));
      expect(chosen, ['Apricot']);
    });

    testWidgets('marks the highlighted option as selected', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpView(tester, highlighted: 2);
      bool selected(String label) =>
          tester
              .getSemantics(
                find
                    .ancestor(
                      of: find
                          .byType(Oito2HighlightedText)
                          .at(['Apple', 'Apricot', 'Banana'].indexOf(label)),
                      matching: find.byType(Semantics),
                    )
                    .first,
              )
              .flagsCollection
              .isSelected
              .toBoolOrNull() ??
          false;
      expect(selected('Banana'), isTrue);
      expect(selected('Apple'), isFalse);
      handle.dispose();
    });

    testWidgets('keeps the highlighted option in view as the highlight '
        'moves', (tester) async {
      final highlight = ValueNotifier(0);
      addTearDown(highlight.dispose);
      await pumpView(tester, maxHeight: 100, count: 12, highlight: highlight);
      for (var index = 1; index < 12; index++) {
        highlight.value = index;
        await tester.pumpAndSettle();
        final list = tester.getRect(find.byType(ListView));
        final row = tester.getRect(
          find.ancestor(
            of: find.byWidgetPredicate(
              (widget) =>
                  widget is Oito2HighlightedText &&
                  widget.text ==
                      (['Apple', 'Apricot', 'Banana'].elementAtOrNull(index) ??
                          'Fruit $index'),
            ),
            matching: find.byType(InkWell),
          ),
        );
        expect(
          list.top <= row.top + 0.5 && row.bottom <= list.bottom + 0.5,
          isTrue,
          reason: 'option $index at $row, list at $list',
        );
      }
    });

    testWidgets('rows reach 48 pixels on touch', (tester) async {
      await pumpView(tester, theme: _touchTheme);
      for (final element in find.byType(InkWell).evaluate()) {
        expect(
          tester.getSize(find.byWidget(element.widget)).height,
          greaterThanOrEqualTo(48),
        );
      }
      expect(find.byType(InkWell), findsNWidgets(3));
    });
  });
}
