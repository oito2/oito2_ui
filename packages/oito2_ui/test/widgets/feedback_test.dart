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

/// Wraps [child] in a media query that disables animations.
Widget _still(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child,
  ),
);

/// Builds an alert of [type] keyed and titled [id].
Oito2Alert _alert(String id, Oito2InfoType type, {VoidCallback? onDismiss}) =>
    Oito2Alert(
      key: ValueKey(id),
      type: type,
      title: Text(id),
      onDismiss: onDismiss,
    );

/// Returns the titles of the alerts shown, top to bottom.
List<String> _shownTitles(WidgetTester tester) {
  final titles = [
    for (final alert in tester.widgetList<Oito2Alert>(find.byType(Oito2Alert)))
      (alert.title! as Text).data!,
  ];
  return titles..sort(
    (a, b) => tester
        .getTopLeft(find.text(a))
        .dy
        .compareTo(tester.getTopLeft(find.text(b)).dy),
  );
}

void main() {
  group('Oito2Alert', () {
    testWidgets('the dismiss button and actions call back', (tester) async {
      var dismissed = 0;
      var retried = 0;
      await pumpOito2(
        tester,
        SizedBox(
          width: 420,
          child: Oito2Alert(
            type: Oito2InfoType.danger,
            title: const Text('Sync failed'),
            message: const Text('The server did not answer.'),
            actions: [
              TextButton(
                onPressed: () => retried++,
                child: const Text('Retry'),
              ),
            ],
            onDismiss: () => dismissed++,
          ),
        ),
      );
      await tester.tap(find.text('Retry'));
      await tester.tap(find.byTooltip('Dismiss'));
      expect((retried, dismissed), (1, 1));
    });

    testWidgets('action labels line up with the message, in both directions', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await pumpOito2(
          tester,
          Directionality(
            textDirection: direction,
            child: SizedBox(
              width: 420,
              child: Oito2Alert(
                type: Oito2InfoType.danger,
                title: const Text('Sync failed'),
                message: const Text('The server did not answer.'),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        );
        final message = tester.getRect(find.text('The server did not answer.'));
        final label = tester.getRect(find.text('Retry'));
        if (direction == TextDirection.ltr) {
          expect(label.left, closeTo(message.left, 0.5));
        } else {
          expect(label.right, closeTo(message.right, 0.5));
        }
        // The button keeps its padding around the label.
        final button = tester.getRect(find.byType(TextButton));
        expect(
          button.width,
          greaterThan(label.width + 2 * Oito2Spacing.md - 1),
        );
      }
    });

    testWidgets('without onDismiss there is no dismiss button', (tester) async {
      await pumpOito2(
        tester,
        const Oito2Alert(type: Oito2InfoType.success, title: Text('Saved')),
      );
      expect(find.byTooltip('Dismiss'), findsNothing);
    });

    testWidgets('compact alerts are one row', (tester) async {
      await pumpOito2(
        tester,
        SizedBox(
          width: 600,
          child: Oito2Alert(
            type: Oito2InfoType.information,
            compact: true,
            title: const Text('Offline'),
            message: const Text('Changes sync later.'),
            actions: [
              TextButton(onPressed: () {}, child: const Text('Details')),
            ],
            onDismiss: () {},
          ),
        ),
      );
      final title = tester.getCenter(find.text('Offline')).dy;
      expect(tester.getCenter(find.text('Changes sync later.')).dy, title);
      expect(tester.getCenter(find.text('Details')).dy, closeTo(title, 1));
      expect(tester.getSize(find.byType(Oito2Alert)).height, lessThan(48));
    });

    testWidgets('the kind is read out and urgent kinds are live regions', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpOito2(
        tester,
        const Column(
          children: [
            Oito2Alert(type: Oito2InfoType.warning, title: Text('Low disk')),
            Oito2Alert(type: Oito2InfoType.success, title: Text('Saved')),
          ],
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Warning')), findsOne);
      expect(
        tester.getSemantics(find.byType(Oito2Alert).first),
        isSemantics(isLiveRegion: true),
      );
      expect(
        tester.getSemantics(find.byType(Oito2Alert).last),
        isSemantics(isLiveRegion: false),
      );
      semantics.dispose();
    });
  });

  group('Oito2AlertStack', () {
    Future<void> pumpStack(
      WidgetTester tester,
      List<Oito2Alert> alerts, {
      int maxVisible = 3,
      bool still = false,
    }) {
      final stack = SizedBox(
        width: 420,
        child: Oito2AlertStack(alerts: alerts, maxVisible: maxVisible),
      );
      return pumpOito2(tester, still ? _still(stack) : stack);
    }

    testWidgets('orders by severity, then by insertion', (tester) async {
      await pumpStack(tester, [
        _alert('info 1', Oito2InfoType.information),
        _alert('warning 1', Oito2InfoType.warning),
        _alert('success', Oito2InfoType.success),
        _alert('danger', Oito2InfoType.danger),
        _alert('warning 2', Oito2InfoType.warning),
      ], maxVisible: 5);
      expect(_shownTitles(tester), [
        'danger',
        'warning 1',
        'warning 2',
        'info 1',
        'success',
      ]);
    });

    testWidgets('shows maxVisible alerts and a button for the rest', (
      tester,
    ) async {
      await pumpStack(tester, [
        for (var i = 1; i <= 5; i++)
          _alert('info $i', Oito2InfoType.information),
      ]);
      expect(_shownTitles(tester), ['info 1', 'info 2', 'info 3']);
      await tester.tap(find.text('Show 2 more'));
      await tester.pumpAndSettle();
      expect(_shownTitles(tester), hasLength(5));
      await tester.tap(find.text('Show fewer'));
      await tester.pumpAndSettle();
      expect(_shownTitles(tester), hasLength(3));
    });

    testWidgets('a more urgent alert takes the place of a visible one', (
      tester,
    ) async {
      final alerts = [
        _alert('info 1', Oito2InfoType.information),
        _alert('info 2', Oito2InfoType.information),
      ];
      await pumpStack(tester, alerts, maxVisible: 2);
      await pumpStack(tester, [
        ...alerts,
        _alert('danger', Oito2InfoType.danger),
      ], maxVisible: 2);
      await tester.pumpAndSettle();
      expect(_shownTitles(tester), ['danger', 'info 1']);
      expect(find.text('Show 1 more'), findsOne);
    });

    testWidgets('alerts animate in and out', (tester) async {
      final first = _alert('first', Oito2InfoType.information);
      await pumpStack(tester, [first]);
      final height = tester.getSize(find.byType(Oito2AlertStack)).height;
      await pumpStack(tester, [
        first,
        _alert('second', Oito2InfoType.information),
      ]);
      await tester.pump(const Duration(milliseconds: 50));
      final growing = tester.getSize(find.byType(Oito2AlertStack)).height;
      expect(growing, greaterThan(height));
      await tester.pumpAndSettle();
      final full = tester.getSize(find.byType(Oito2AlertStack)).height;
      expect(growing, lessThan(full));
      await pumpStack(tester, [first]);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('second'), findsOne);
      await tester.pumpAndSettle();
      expect(find.text('second'), findsNothing);
      expect(tester.getSize(find.byType(Oito2AlertStack)).height, height);
    });

    testWidgets('alerts come and go at once when animations are disabled', (
      tester,
    ) async {
      final first = _alert('first', Oito2InfoType.information);
      await pumpStack(tester, [first], still: true);
      final height = tester.getSize(find.byType(Oito2AlertStack)).height;
      await pumpStack(tester, [
        first,
        _alert('second', Oito2InfoType.information),
      ], still: true);
      await tester.pump();
      await tester.pump();
      final full = tester.getSize(find.byType(Oito2AlertStack)).height;
      expect(full, greaterThan(height * 1.5));
      await pumpStack(tester, [first], still: true);
      await tester.pump();
      await tester.pump();
      expect(find.text('second'), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('dismissing removes the alert through the app', (tester) async {
      var alerts = <String>['a', 'b'];
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 420,
            child: Oito2AlertStack(
              alerts: [
                for (final id in alerts)
                  _alert(
                    id,
                    Oito2InfoType.warning,
                    onDismiss: () =>
                        setState(() => alerts = [...alerts]..remove(id)),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Dismiss').first);
      await tester.pumpAndSettle();
      expect(_shownTitles(tester), ['b']);
    });
  });

  group('Oito2StatusPill', () {
    testWidgets('reads its label and the busy state', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpOito2(
        tester,
        const Column(
          children: [
            Oito2StatusPill(label: 'Synced', type: Oito2InfoType.success),
            Oito2StatusPill(label: 'Syncing', busy: true, tooltip: '3 files'),
          ],
        ),
      );
      expect(
        tester.getSemantics(find.text('Synced')),
        isSemantics(label: 'Synced'),
      );
      expect(
        tester.getSemantics(find.text('Syncing')),
        isSemantics(label: 'Syncing', value: 'Loading', hint: '3 files'),
      );
      semantics.dispose();
    });

    testWidgets('busy spins, and stands still without animations', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const Oito2StatusPill(label: 'Syncing', busy: true),
      );
      expect(find.byType(Oito2CircularProgressIndicator), findsOne);
      expect(tester.hasRunningAnimations, isTrue);
      await pumpOito2(
        tester,
        _still(const Oito2StatusPill(label: 'Syncing', busy: true)),
      );
      expect(find.byType(Oito2CircularProgressIndicator), findsOne);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the tooltip shows on hover', (tester) async {
      await pumpOito2(
        tester,
        const Center(
          child: Oito2StatusPill(label: 'Offline', tooltip: 'Since 10:42'),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(
        location: tester.getCenter(find.byType(Oito2StatusPill)),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Since 10:42'), findsOne);
    });
  });

  group('Oito2Skeleton', () {
    testWidgets('text lines fill the width, the last one shorter', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            child: Oito2Skeleton.text(lines: 3, lastLineWidthFactor: 0.5),
          ),
        ),
      );
      final lines = find.descendant(
        of: find.byType(Oito2Skeleton),
        matching: find.byType(DecoratedBox),
      );
      expect(lines, findsNWidgets(3));
      expect(tester.getSize(lines.first).width, 300);
      expect(tester.getSize(lines.last).width, 150);
    });

    testWidgets('circles and rects take their size, 200 when unbounded', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Oito2Skeleton.circle(size: 32),
              Oito2Skeleton.rect(height: 20),
            ],
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(Oito2Skeleton).first),
        const Size(32, 32),
      );
      expect(
        tester.getSize(find.byType(Oito2Skeleton).last),
        const Size(200, 20),
      );
    });

    testWidgets('pulses, and stands still without animations', (tester) async {
      await pumpOito2(tester, const Oito2Skeleton.text());
      expect(tester.hasRunningAnimations, isTrue);
      await pumpOito2(tester, _still(const Oito2Skeleton.text()));
      expect(tester.hasRunningAnimations, isFalse);
      final fade = tester.widget<FadeTransition>(
        find.descendant(
          of: find.byType(Oito2Skeleton),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(fade.opacity.value, 1);
    });

    testWidgets('the switcher reads "Loading" once, then the content', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      Widget switcher(bool loading) => _still(
        Oito2SkeletonSwitcher(
          loading: loading,
          skeleton: const Column(
            children: [Oito2Skeleton.circle(), Oito2Skeleton.text(lines: 2)],
          ),
          child: const Text('Ada Lovelace'),
        ),
      );
      await pumpOito2(tester, switcher(true));
      expect(find.semantics.byLabel('Loading'), findsOne);
      expect(find.text('Ada Lovelace'), findsNothing);
      await pumpOito2(tester, switcher(false));
      await tester.pump();
      expect(find.semantics.byLabel('Loading'), findsNothing);
      expect(find.text('Ada Lovelace'), findsOne);
      expect(find.byType(Oito2Skeleton), findsNothing);
      semantics.dispose();
    });
  });

  group('Oito2StatusPage', () {
    testWidgets('centers its content and marks the title as a header', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var created = 0;
      await pumpOito2(
        tester,
        SizedBox(
          width: 600,
          height: 500,
          child: Oito2StatusPage(
            icon: const Icon(LucideIcons.folder_open),
            title: const Text('No files'),
            description: const Text('Drop files here to add them.'),
            actions: [
              FilledButton(
                onPressed: () => created++,
                child: const Text('New file'),
              ),
            ],
          ),
        ),
      );
      final page = tester.getRect(find.byType(Oito2StatusPage));
      expect(
        tester.getCenter(find.text('No files')).dx,
        closeTo(page.center.dx, 1),
      );
      expect(tester.getSize(find.byIcon(LucideIcons.folder_open)).height, 64);
      expect(
        tester.getSemantics(find.text('No files')),
        isSemantics(label: 'No files', isHeader: true),
      );
      await tester.tap(find.text('New file'));
      expect(created, 1);
      semantics.dispose();
    });

    testWidgets('scrolls when the pane is too short; compact is smaller', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const SizedBox(
          width: 240,
          height: 120,
          child: Oito2StatusPage(
            compact: true,
            icon: Icon(LucideIcons.search_x),
            title: Text('No results'),
            description: Text(
              'Try other words, check the spelling or clear the filters '
              'to see every item again.',
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byIcon(LucideIcons.search_x)).height, 32);
      expect(find.byType(Scrollable), findsOne);
      await tester.drag(find.byType(Oito2StatusPage), const Offset(0, -200));
      await tester.pump();
      expect(
        tester.getTopLeft(find.byIcon(LucideIcons.search_x)).dy,
        lessThan(0),
      );
    });
  });

  group('Oito2BusyButton', () {
    Widget button(bool busy, VoidCallback onPressed) => Center(
      child: Oito2BusyButton(
        busy: busy,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Oito2BusyLabel(child: Icon(LucideIcons.save)),
          label: const Text('Save'),
        ),
      ),
    );

    testWidgets('keeps its width and shows a spinner in place of the icon', (
      tester,
    ) async {
      await pumpOito2(tester, button(false, () {}));
      final idle = tester.getSize(find.byType(FilledButton));
      expect(find.byType(Oito2CircularProgressIndicator), findsNothing);
      await pumpOito2(tester, button(true, () {}));
      expect(tester.getSize(find.byType(FilledButton)), idle);
      expect(find.byType(Oito2CircularProgressIndicator), findsOne);
      final icon = tester.getCenter(find.byIcon(LucideIcons.save));
      expect(
        tester.getCenter(find.byType(Oito2CircularProgressIndicator)),
        icon,
      );
    });

    testWidgets('blocks clicks and activation keys while busy', (tester) async {
      var pressed = 0;
      await pumpOito2(tester, button(true, () => pressed++));
      await tester.tap(find.text('Save'), warnIfMissed: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        Focus.of(tester.element(find.text('Save'))).hasPrimaryFocus,
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(pressed, 0);
      await pumpOito2(tester, button(false, () => pressed++));
      await tester.tap(find.text('Save'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(pressed, 2);
    });

    testWidgets('reads "Loading" with no tap action while busy', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpOito2(tester, button(true, () {}));
      final node = tester.getSemantics(find.byType(FilledButton));
      expect(
        node,
        isSemantics(label: 'Save', value: 'Loading', isButton: true),
      );
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      await pumpOito2(tester, button(false, () {}));
      expect(
        tester.getSemantics(find.byType(FilledButton)),
        isSemantics(label: 'Save', isButton: true, hasTapAction: true),
      );
      semantics.dispose();
    });

    testWidgets('shows the progress cursor while busy', (tester) async {
      await pumpOito2(tester, button(true, () {}));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: tester.getCenter(find.text('Save')));
      await tester.pump();
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.progress,
      );
    });
  });

  group('stacked dialogs', () {
    testWidgets('Escape closes the top dialog and focus returns below', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Account'),
                  actions: [
                    TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete the account?'),
                          actions: [
                            TextButton(
                              autofocus: true,
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ),
                      child: const Text('Delete…'),
                    ),
                  ],
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        Focus.of(tester.element(find.text('Delete…'))).hasPrimaryFocus,
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Delete the account?'), findsOne);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Delete the account?'), findsNothing);
      expect(find.text('Account'), findsOne);
      expect(
        Focus.of(tester.element(find.text('Delete…'))).hasPrimaryFocus,
        isTrue,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Account'), findsNothing);
      expect(find.text('Open'), findsOne);
    });
  });
}
