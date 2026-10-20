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

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'test_app.dart';

Widget _popover({
  Oito2PopoverPlacement placement = Oito2PopoverPlacement.bottom,
  bool closeOnTapOutside = true,
  bool matchAnchorWidth = false,
  Widget? content,
}) {
  return Oito2Popover(
    placement: placement,
    closeOnTapOutside: closeOnTapOutside,
    matchAnchorWidth: matchAnchorWidth,
    semanticLabel: 'Panel',
    builder: (context, controller) => SizedBox(
      width: 200,
      child: OutlinedButton(
        onPressed: controller.toggle,
        child: const Text('Anchor'),
      ),
    ),
    popoverBuilder: (context, controller) =>
        content ??
        TextButton(onPressed: controller.close, child: const Text('Inside')),
  );
}

void main() {
  group('Oito2Popover', () {
    testWidgets('opens below, takes the focus and closes on Escape', (
      tester,
    ) async {
      await pumpOito2(tester, Center(child: _popover()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Inside'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Inside')).dy,
        greaterThan(tester.getBottomLeft(find.text('Anchor')).dy),
      );
      final inside = Focus.of(tester.element(find.text('Inside')));
      expect(inside.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Inside'), findsNothing);
      expect(Focus.of(tester.element(find.text('Anchor'))).hasFocus, isTrue);
    });

    testWidgets('a tap outside closes it unless disabled', (tester) async {
      await pumpOito2(tester, Center(child: _popover()));
      await tester.tap(find.text('Anchor'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Inside'), findsNothing);

      await pumpOito2(
        tester,
        Center(child: _popover(closeOnTapOutside: false)),
      );
      await tester.tap(find.text('Anchor'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Inside'), findsOneWidget);
    });

    testWidgets('moves above when there is no room below', (tester) async {
      await pumpOito2(
        tester,
        Align(alignment: Alignment.bottomCenter, child: _popover()),
      );
      await tester.tap(find.text('Anchor'));
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(find.text('Inside')).dy,
        lessThan(tester.getTopLeft(find.text('Anchor')).dy),
      );
    });

    testWidgets('can take the anchor width', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: _popover(
            matchAnchorWidth: true,
            content: const SizedBox(key: Key('content'), height: 20),
          ),
        ),
      );
      await tester.tap(find.text('Anchor'));
      await tester.pumpAndSettle();
      // The content is the anchor width less the panel padding.
      expect(tester.getSize(find.byKey(const Key('content'))).width, 200 - 24);
    });

    testWidgets('a nested popover keeps the outer one open', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: _popover(
            content: Oito2Popover(
              placement: Oito2PopoverPlacement.end,
              builder: (context, controller) => TextButton(
                onPressed: controller.open,
                child: const Text('Open inner'),
              ),
              popoverBuilder: (context, _) => const Text('Inner'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Anchor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open inner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inner'));
      await tester.pumpAndSettle();
      expect(find.text('Inner'), findsOneWidget);
      expect(find.text('Open inner'), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Open inner'), findsNothing);
    });

    testWidgets('the panel has its label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(tester, Center(child: _popover()));
      await tester.tap(find.text('Anchor'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Panel'), findsOneWidget);
      handle.dispose();
    });
  });

  group('Oito2HoverCard', () {
    Widget card() => Center(
      child: Oito2HoverCard(
        cardBuilder: (_) => const Text('Card'),
        child: TextButton(onPressed: () {}, child: const Text('Name')),
      ),
    );

    testWidgets('opens after a hover delay and closes after leaving', (
      tester,
    ) async {
      await pumpOito2(tester, card());
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Card'), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Card'), findsOneWidget);
      await mouse.moveTo(const Offset(2, 2));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Card'), findsNothing);
    });

    testWidgets('opens on keyboard focus', (tester) async {
      await pumpOito2(tester, card());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Card'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('Card'), findsNothing);
    });
  });

  group('showOito2Sheet', () {
    Future<Future<Object?>> open(
      WidgetTester tester, {
      Oito2SheetSide side = Oito2SheetSide.end,
      bool modal = true,
      bool dismissible = true,
      List<double>? snapPoints,
    }) async {
      late Future<Object?> result;
      await pumpOito2(
        tester,
        Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => result = showOito2Sheet<Object?>(
                context,
                side: side,
                modal: modal,
                dismissible: dismissible,
                snapPoints: snapPoints,
                builder: (context) => Oito2Sheet(
                  title: const Text('Sheet'),
                  child: TextButton(
                    onPressed: () => Oito2Sheet.close(context, 'saved'),
                    child: const Text('Save'),
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('an end sheet sits at the right and returns a value', (
      tester,
    ) async {
      final result = await open(tester);
      expect(tester.getTopRight(find.byType(Oito2Sheet)).dx, 1000);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(await result, 'saved');
      expect(find.text('Sheet'), findsNothing);
    });

    testWidgets('a start sheet sits at the left in LTR', (tester) async {
      await open(tester, side: Oito2SheetSide.start);
      expect(tester.getTopLeft(find.byType(Oito2Sheet)).dx, 0);
    });

    testWidgets('Escape, the close button and the scrim close it', (
      tester,
    ) async {
      await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsNothing);

      await open(tester);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsNothing);

      await open(tester);
      await tester.tapAt(const Offset(10, 400));
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsNothing);

      await open(tester, dismissible: false);
      await tester.tapAt(const Offset(10, 400));
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsOneWidget);
    });

    testWidgets('dragging toward the edge dismisses it', (tester) async {
      await open(tester);
      await tester.drag(find.text('Sheet'), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsNothing);
    });

    testWidgets('a short drag springs back', (tester) async {
      await open(tester);
      await tester.timedDrag(
        find.text('Sheet'),
        const Offset(40, 0),
        const Duration(milliseconds: 500),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopRight(find.byType(Oito2Sheet)).dx, 1000);
    });

    testWidgets('a non-modal sheet leaves the page usable', (tester) async {
      var taps = 0;
      await pumpOito2(
        tester,
        Builder(
          builder: (context) => Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: () => taps++, child: const Text('Page')),
                TextButton(
                  onPressed: () => showOito2Sheet<void>(
                    context,
                    modal: false,
                    builder: (_) => const Oito2Sheet(child: Text('Side')),
                  ),
                  child: const Text('Open'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Page'));
      expect(taps, 1);
      expect(find.text('Side'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Side'), findsNothing);
    });

    testWidgets('bottom snap points move by keyboard and semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(
        tester,
        side: Oito2SheetSide.bottom,
        snapPoints: const [0.3, 0.8],
      );
      final top = tester.getTopLeft(find.byType(Oito2Sheet)).dy;
      final resize = find.bySemanticsLabel('Resize sheet');
      expect(tester.getSemantics(resize).value, '30%');
      tester.semantics.increase(find.semantics.byLabel('Resize sheet'));
      await tester.pumpAndSettle();
      expect(tester.getSemantics(resize).value, '80%');
      expect(tester.getTopLeft(find.byType(Oito2Sheet)).dy, lessThan(top));
      handle.dispose();
    });
  });

  group('Oito2Toaster', () {
    Future<Oito2ToasterState> pumpToaster(
      WidgetTester tester, {
      int maxVisible = 3,
    }) async {
      await pumpOito2(
        tester,
        Oito2Toaster(maxVisible: maxVisible, child: const SizedBox.expand()),
      );
      return tester.state<Oito2ToasterState>(find.byType(Oito2Toaster));
    }

    testWidgets('shows a toast and dismisses it after its time', (
      tester,
    ) async {
      final toaster = await pumpToaster(tester);
      toaster.show(const Oito2Toast(title: 'Saved'));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('the time stops while hovered', (tester) async {
      final toaster = await pumpToaster(tester);
      toaster.show(const Oito2Toast(title: 'Saved'));
      await tester.pumpAndSettle();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: tester.getCenter(find.text('Saved')));
      await tester.pump(const Duration(seconds: 6));
      expect(find.text('Saved'), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('extra toasts wait for room', (tester) async {
      final toaster = await pumpToaster(tester, maxVisible: 1);
      final first = toaster.show(
        const Oito2Toast(title: 'One', duration: null),
      );
      toaster.show(const Oito2Toast(title: 'Two', duration: null));
      await tester.pumpAndSettle();
      expect(find.text('Two'), findsNothing);
      first.dismiss();
      await tester.pumpAndSettle();
      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('the action runs and dismisses the toast', (tester) async {
      final toaster = await pumpToaster(tester);
      var undone = false;
      toaster.show(
        Oito2Toast(
          title: 'Deleted',
          actionLabel: 'Undo',
          onAction: () => undone = true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(undone, isTrue);
      expect(find.text('Deleted'), findsNothing);
    });

    testWidgets('a promise replaces the loading toast', (tester) async {
      final toaster = await pumpToaster(tester);
      final done = toaster.promise<int>(
        Future.delayed(const Duration(seconds: 1), () => 3),
        loading: const Oito2Toast(title: 'Uploading', loading: true),
        success: (n) =>
            Oito2Toast(title: '$n files uploaded', type: Oito2InfoType.success),
        error: (_) => const Oito2Toast(title: 'Failed'),
      );
      await tester.pump();
      expect(find.text('Uploading'), findsOneWidget);
      expect(find.byType(Oito2CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(await done, 3);
      expect(find.text('3 files uploaded'), findsOneWidget);
    });

    testWidgets('toasts are live regions in a labelled area', (tester) async {
      final handle = tester.ensureSemantics();
      final toaster = await pumpToaster(tester);
      toaster.show(const Oito2Toast(title: 'Saved'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Saved'),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && (w.properties.liveRegion ?? false),
          ),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('Oito2ContextMenuRegion', () {
    Widget region(ValueChanged<String> picked) => Center(
      child: Oito2ContextMenuRegion(
        menuChildren: [
          MenuItemButton(
            onPressed: () => picked('copy'),
            child: const Text('Copy'),
          ),
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                onPressed: () => picked('pdf'),
                child: const Text('PDF'),
              ),
            ],
            child: const Text('Export'),
          ),
        ],
        child: TextButton(onPressed: () {}, child: const Text('Target')),
      ),
    );

    testWidgets('a secondary click opens the menu', (tester) async {
      final picked = <String>[];
      await pumpOito2(tester, region(picked.add));
      await tester.tap(find.text('Target'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(picked, ['copy']);
      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('a long press and Shift+F10 open it', (tester) async {
      final picked = <String>[];
      await pumpOito2(tester, region(picked.add));
      await tester.longPress(find.text('Target'));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.f10);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);
    });
  });

  group('Oito2Tour', () {
    final first = GlobalKey();
    final second = GlobalKey();

    Future<(Oito2TourController, List<bool>, List<String>)> pumpTour(
      WidgetTester tester, {
      bool waitForTap = false,
    }) async {
      final controller = Oito2TourController(
        steps: [
          Oito2TourStep(target: first, title: 'First', description: 'One'),
          Oito2TourStep(
            target: second,
            title: 'Second',
            waitForTap: waitForTap,
          ),
          const Oito2TourStep(title: 'Last'),
        ],
      );
      addTearDown(controller.dispose);
      final finished = <bool>[];
      final taps = <String>[];
      await pumpOito2(
        tester,
        Oito2Tour(
          controller: controller,
          onFinished: finished.add,
          child: Column(
            children: [
              TextButton(
                key: first,
                onPressed: () => taps.add('first'),
                child: const Text('A'),
              ),
              const SizedBox(height: 200),
              TextButton(
                key: second,
                onPressed: () => taps.add('second'),
                child: const Text('B'),
              ),
            ],
          ),
        ),
      );
      controller.start();
      await tester.pumpAndSettle();
      return (controller, finished, taps);
    }

    testWidgets('steps forward, back and finishes', (tester) async {
      final (controller, finished, _) = await pumpTour(tester);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 3'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(controller.index, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Last'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Last'), findsNothing);
      expect(finished, [true]);
    });

    testWidgets('Escape skips it', (tester) async {
      final (_, finished, _) = await pumpTour(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('First'), findsNothing);
      expect(finished, [false]);
    });

    testWidgets('blocks taps outside the spotlight and passes them inside', (
      tester,
    ) async {
      final (_, _, taps) = await pumpTour(tester);
      await tester.tap(find.text('B'), warnIfMissed: false);
      await tester.pump();
      expect(taps, isEmpty);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(taps, ['first']);
    });

    testWidgets('a wait-for-tap step moves on after the target tap', (
      tester,
    ) async {
      final (controller, _, taps) = await pumpTour(tester, waitForTap: true);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsNothing);
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(taps, ['second']);
      expect(controller.index, 2);
    });
  });
}
