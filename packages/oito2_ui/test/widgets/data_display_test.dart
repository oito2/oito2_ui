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
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

class _Host<T> extends StatefulWidget {
  const _Host({required this.initial, required this.builder});

  final T initial;
  final Widget Function(T value, ValueChanged<T> set) builder;

  @override
  State<_Host<T>> createState() => _HostState<T>();
}

class _HostState<T> extends State<_Host<T>> {
  late T value = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(value, (v) => setState(() => value = v));
}

T _hostValue<T>(WidgetTester tester) =>
    tester.state<_HostState<T>>(find.byType(_Host<T>)).value;

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

final _files = Oito2TreeCollection<void>([
  const Oito2TreeNode(
    value: 'src',
    children: [
      Oito2TreeNode(value: 'src/main.dart', label: 'main.dart'),
      Oito2TreeNode(
        value: 'src/widgets',
        label: 'widgets',
        children: [
          Oito2TreeNode(value: 'src/widgets/a.dart', label: 'a.dart'),
          Oito2TreeNode(value: 'src/widgets/b.dart', label: 'b.dart'),
        ],
      ),
    ],
  ),
  const Oito2TreeNode(value: 'README.md'),
  const Oito2TreeNode(value: 'LICENSE', disabled: true),
]);

void main() {
  group('Oito2Pagination', () {
    test('page items keep their count and use ellipses', () {
      expect(oito2PaginationItems(1, 5), [1, 2, 3, 4, 5]);
      expect(oito2PaginationItems(1, 10), [1, 2, 3, 4, 5, null, 10]);
      expect(oito2PaginationItems(5, 10), [1, null, 4, 5, 6, null, 10]);
      expect(oito2PaginationItems(10, 10), [1, null, 6, 7, 8, 9, 10]);
      expect(oito2PaginationItems(4, 10), [1, 2, 3, 4, 5, null, 10]);
      expect(oito2PaginationItems(1, 1), [1]);
      expect(oito2PaginationItems(1, 0), isEmpty);
    });

    Future<void> pumpPager(WidgetTester tester, {double width = 600}) =>
        pumpOito2(
          tester,
          Center(
            child: SizedBox(
              width: width,
              child: _Host<int>(
                initial: 5,
                builder: (page, set) =>
                    Oito2Pagination(page: page, pageCount: 10, onChanged: set),
              ),
            ),
          ),
        );

    testWidgets('page buttons and arrows change the page', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPager(tester);
      await tester.tap(find.text('10'));
      await tester.pump();
      expect(_hostValue<int>(tester), 10);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Page 10')),
        isSemantics(isSelected: true),
      );
      await tester.tap(find.byTooltip('Previous page'));
      await tester.pump();
      expect(_hostValue<int>(tester), 9);
      handle.dispose();
    });

    test('item counts below zero are rejected', () {
      expect(
        () => oito2PaginationItems(5, 10, siblingCount: -1),
        throwsAssertionError,
      );
    });

    testWidgets('the compact form keeps the page size selector', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            child: Oito2Pagination(
              page: 1,
              pageCount: 4,
              onChanged: (_) {},
              pageSize: 20,
              pageSizes: const [10, 20],
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Page 1 of 4'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('page buttons are as tall as a button', (tester) async {
      await pumpPager(tester);
      final button = find.ancestor(
        of: find.text('10'),
        matching: find.byType(TextButton),
      );
      expect(tester.getSize(button).height, Oito2Sizes.buttonHeight);
    });

    testWidgets('narrow widths show the compact form', (tester) async {
      await pumpPager(tester, width: 300);
      expect(find.text('Page 5 of 10'), findsOneWidget);
      await tester.tap(find.byTooltip('Next page'));
      await tester.pump();
      expect(find.text('Page 6 of 10'), findsOneWidget);
    });

    testWidgets('arrows point the reading direction in RTL', (tester) async {
      await pumpOito2(
        tester,
        Directionality(
          textDirection: TextDirection.rtl,
          child: Oito2Pagination(page: 5, pageCount: 10, onChanged: (_) {}),
        ),
      );
      Finder icon(String tooltip, IconData data) => find.descendant(
        of: find.byTooltip(tooltip),
        matching: find.byIcon(data),
      );
      expect(icon('Previous page', LucideIcons.chevron_right), findsOneWidget);
      expect(icon('Next page', LucideIcons.chevron_left), findsOneWidget);
    });
  });

  group('Oito2Steps', () {
    const steps = [
      Oito2Step(title: 'Account', content: Text('Account form')),
      Oito2Step(title: 'Profile', content: Text('Profile form')),
      Oito2Step(title: 'Done'),
    ];

    Future<void> pumpSteps(
      WidgetTester tester, {
      bool linear = true,
      Axis axis = Axis.horizontal,
    }) => pumpOito2(
      tester,
      Padding(
        padding: const EdgeInsets.all(16),
        child: _Host<int>(
          initial: 1,
          builder: (current, set) => Oito2Steps(
            steps: steps,
            current: current,
            linear: linear,
            axis: axis,
            onStepTapped: set,
          ),
        ),
      ),
    );

    testWidgets('linear steps reach only done and current ones', (
      tester,
    ) async {
      await pumpSteps(tester);
      expect(find.text('Profile form'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(_hostValue<int>(tester), 1);
      await tester.tap(find.text('Account'));
      await tester.pump();
      expect(_hostValue<int>(tester), 0);
      expect(find.text('Account form'), findsOneWidget);
    });

    testWidgets('free steps reach any step, also vertically', (tester) async {
      await pumpSteps(tester, linear: false, axis: Axis.vertical);
      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(_hostValue<int>(tester), 2);
    });

    testWidgets('steps describe their position and state', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSteps(tester);
      expect(
        find.bySemanticsLabel('Account, Step 1 of 3, Completed'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Profile, Step 2 of 3, Current'),
        findsOneWidget,
      );
      handle.dispose();
    });
    testWidgets('vertical steps hold content built by a LayoutBuilder', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        Oito2Steps(
          axis: Axis.vertical,
          current: 0,
          steps: [
            const Oito2Step(
              title: 'Upload',
              content: Oito2LinearProgressIndicator(value: 0.5),
            ),
            const Oito2Step(title: 'Done'),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(Oito2LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('long horizontal titles do not overflow', (tester) async {
      await pumpOito2(
        tester,
        SizedBox(
          width: 320,
          child: Oito2Steps(
            current: 0,
            steps: [
              for (var i = 0; i < 4; i++)
                Oito2Step(title: 'A rather long step title number $i'),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Oito2Splitter', () {
    testWidgets('collapses after the number of panes changes', (tester) async {
      Widget build(int count) => SizedBox(
        width: 600,
        height: 200,
        child: Oito2Splitter(
          panes: [
            for (var i = 0; i < count; i++)
              Oito2SplitterPane(
                collapsible: i == count - 1,
                minSize: 60,
                child: Text('P$i'),
              ),
          ],
        ),
      );
      Future<void> doubleTap(int divider) async {
        final handle = find.bySemanticsLabel('Resize pane').at(divider);
        await tester.tap(handle);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(handle);
        await tester.pumpAndSettle();
      }

      final semantics = tester.ensureSemantics();
      await pumpOito2(tester, build(2));
      await doubleTap(0);
      expect(find.text('P1'), findsNothing);
      await pumpOito2(tester, build(3));
      await doubleTap(1);
      expect(tester.takeException(), isNull);
      expect(find.text('P2'), findsNothing);
      await doubleTap(1);
      expect(tester.takeException(), isNull);
      semantics.dispose();
      expect(find.text('P2'), findsOneWidget);
    });

    final sizes = <List<double>>[];

    Future<void> pumpSplitter(WidgetTester tester) {
      sizes.clear();
      return pumpOito2(
        tester,
        SizedBox(
          width: 602,
          height: 300,
          child: Oito2Splitter(
            onSizesChanged: sizes.add,
            panes: const [
              Oito2SplitterPane(
                initialFraction: 0.25,
                minSize: 100,
                collapsible: true,
                child: Text('A'),
              ),
              Oito2SplitterPane(
                child: Oito2Splitter(
                  axis: Axis.vertical,
                  resizeLabel: 'Resize rows',
                  panes: [
                    Oito2SplitterPane(child: Text('B1')),
                    Oito2SplitterPane(child: Text('B2')),
                  ],
                ),
              ),
              Oito2SplitterPane(minSize: 100, child: Text('C')),
            ],
          ),
        ),
      );
    }

    double width(WidgetTester tester, String text) => tester
        .getSize(
          find
              .ancestor(of: find.text(text), matching: find.byType(SizedBox))
              .first,
        )
        .width;

    testWidgets('lays out the initial fractions and drags a divider', (
      tester,
    ) async {
      await pumpSplitter(tester);
      expect(width(tester, 'A'), 150);
      expect(width(tester, 'C'), closeTo(225, 0.01));
      final divider = find.bySemanticsLabel('Resize pane').first;
      await tester.drag(divider, const Offset(30, 0));
      await tester.pump();
      expect(width(tester, 'A'), 180);
      await tester.drag(divider, const Offset(-200, 0));
      await tester.pump();
      expect(width(tester, 'A'), 100);
      expect(sizes, isNotEmpty);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('keys resize and Enter collapses and restores', (tester) async {
      await pumpSplitter(tester);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(width(tester, 'A'), 166);
      await _key(tester, LogicalKeyboardKey.enter);
      expect(find.text('A'), findsNothing);
      await _key(tester, LogicalKeyboardKey.enter);
      expect(width(tester, 'A'), 166);
    });
  });

  group('Oito2TableOfContents', () {
    testWidgets('follows the scroll and scrolls to a section', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final keys = [for (var i = 0; i < 3; i++) GlobalKey()];
      await pumpOito2(
        tester,
        Row(
          children: [
            SizedBox(
              width: 200,
              child: Oito2TableOfContents(
                controller: controller,
                entries: [
                  for (var i = 0; i < 3; i++)
                    Oito2TocEntry(title: 'Section $i', target: keys[i]),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  for (var i = 0; i < 3; i++)
                    SizedBox(key: keys[i], height: 600, child: Text('Body $i')),
                  const SizedBox(height: 900),
                ],
              ),
            ),
          ],
        ),
      );
      await tester.pump();
      bool selected(int i) =>
          tester
              .widget<Semantics>(
                find
                    .ancestor(
                      of: find.text('Section $i'),
                      matching: find.byWidgetPredicate(
                        (w) => w is Semantics && w.properties.selected != null,
                      ),
                    )
                    .first,
              )
              .properties
              .selected ??
          false;
      expect(selected(0), isTrue);
      controller.jumpTo(650);
      await tester.pump();
      await tester.pump();
      expect(selected(1), isTrue);
      await tester.tap(find.text('Section 2'));
      await tester.pumpAndSettle();
      expect(controller.offset, 1200);
      expect(selected(2), isTrue);
    });

    testWidgets('keeps the section while no heading is built', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final keys = [for (var i = 0; i < 3; i++) GlobalKey()];
      await pumpOito2(
        tester,
        Row(
          children: [
            SizedBox(
              width: 200,
              child: Oito2TableOfContents(
                controller: controller,
                entries: [
                  for (var i = 0; i < 3; i++)
                    Oito2TocEntry(title: 'Section $i', target: keys[i]),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    SizedBox(key: keys[i], height: 40, child: Text('Head $i')),
                    const SizedBox(height: 4000),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
      bool selected(int i) =>
          tester
              .widget<Semantics>(
                find
                    .ancestor(
                      of: find.text('Section $i'),
                      matching: find.byWidgetPredicate(
                        (w) => w is Semantics && w.properties.selected != null,
                      ),
                    )
                    .first,
              )
              .properties
              .selected ??
          false;
      controller.jumpTo(4100);
      await tester.pump();
      await tester.pump();
      expect(selected(1), isTrue);
      controller.jumpTo(6000);
      await tester.pump();
      await tester.pump();
      expect(find.text('Head 1'), findsNothing);
      expect(selected(1), isTrue);
    });
  });

  group('Oito2FloatingPanel', () {
    testWidgets('minimizing keeps the content state', (tester) async {
      await pumpOito2(
        tester,
        const Stack(
          children: [
            Oito2FloatingPanel(
              title: 'Notes',
              initialRect: Rect.fromLTWH(50, 50, 300, 200),
              child: TextField(),
            ),
          ],
        ),
      );
      await tester.enterText(find.byType(TextField), 'draft');
      await tester.tap(find.bySemanticsLabel('Minimize'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Minimize'));
      await tester.pumpAndSettle();
      expect(find.text('draft'), findsOneWidget);
    });

    Future<List<String>> pumpPanel(WidgetTester tester) async {
      final events = <String>[];
      await pumpOito2(
        tester,
        Stack(
          children: [
            Oito2FloatingPanel(
              title: 'Inspector',
              initialRect: const Rect.fromLTWH(50, 50, 300, 200),
              onClose: () => events.add('close'),
              child: const Text('Panel body'),
            ),
          ],
        ),
      );
      return events;
    }

    Rect panelRect(WidgetTester tester) => tester.getRect(
      find
          .ancestor(
            of: find.text('Inspector'),
            matching: find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == 'Inspector',
            ),
          )
          .first,
    );

    testWidgets('moves by dragging the title and resizes by the corner', (
      tester,
    ) async {
      await pumpPanel(tester);
      expect(panelRect(tester).topLeft, const Offset(50, 50));
      await tester.dragFrom(const Offset(70, 70), const Offset(100, 40));
      await tester.pump();
      expect(panelRect(tester).topLeft, const Offset(150, 90));
      final corner = panelRect(tester).bottomRight - const Offset(3, 3);
      await tester.dragFrom(corner, const Offset(50, 30));
      await tester.pump();
      expect(panelRect(tester).size, const Size(350, 230));
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('minimizing a maximized panel leaves only the title bar', (
      tester,
    ) async {
      await pumpPanel(tester);
      await tester.tap(find.bySemanticsLabel('Maximize'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Minimize'));
      await tester.pump();
      final rect = panelRect(tester);
      expect(rect.height, lessThan(60));
      expect(rect.width, 300);
      expect(find.bySemanticsLabel('Maximize'), findsOneWidget);
    });

    testWidgets('maximizes, minimizes and closes', (tester) async {
      final events = await pumpPanel(tester);
      await tester.tap(find.bySemanticsLabel('Maximize'));
      await tester.pump();
      expect(panelRect(tester), Offset.zero & const Size(1000, 800));
      await tester.tap(find.bySemanticsLabel('Restore'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Minimize'));
      await tester.pump();
      expect(find.text('Panel body'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Close'));
      expect(events, ['close']);
    });

    testWidgets('the arrow keys move it from the title bar', (tester) async {
      await pumpPanel(tester);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      await _key(tester, LogicalKeyboardKey.arrowDown, shift: true);
      final rect = panelRect(tester);
      expect(rect.left, 66);
      expect(rect.height, 216);
    });
  });

  group('Oito2Avatar', () {
    test('initials', () {
      expect(oito2Initials('Ana Maria Souza'), 'AS');
      expect(oito2Initials('  joão '), 'J');
      expect(oito2Initials(''), '');
      // Decomposed accents and emoji sequences stay whole.
      expect(oito2Initials('e\u0301lise'), 'E\u0301');
      expect(
        oito2Initials('\u{1F469}\u200D\u{1F4BB} dev'),
        '\u{1F469}\u200D\u{1F4BB}D',
      );
    });

    testWidgets('a group can be square and labelled as a whole', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(
        tester,
        const Center(
          child: Oito2AvatarGroup(
            shape: Oito2AvatarShape.square,
            semanticLabel: 'Project members',
            avatars: [
              Oito2Avatar(name: 'Ana', shape: Oito2AvatarShape.square),
              Oito2Avatar(name: 'Bia', shape: Oito2AvatarShape.square),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Project members'), findsOneWidget);
      final ring = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Oito2AvatarGroup),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((ring.decoration! as BoxDecoration).shape, BoxShape.rectangle);
      handle.dispose();
    });

    testWidgets('shows initials and reads name and status', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(
        tester,
        const Center(
          child: Oito2Avatar(name: 'Ana Souza', status: Oito2AvatarStatus.busy),
        ),
      );
      expect(find.text('AS'), findsOneWidget);
      expect(find.bySemanticsLabel('Ana Souza, Busy'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a group shows the extra count', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: Oito2AvatarGroup(
            max: 2,
            avatars: [
              for (final n in ['A B', 'C D', 'E F', 'G H'])
                Oito2Avatar(name: n, size: 32),
            ],
          ),
        ),
      );
      expect(find.byType(Oito2Avatar), findsNWidgets(2));
      expect(find.text('+2'), findsOneWidget);
    });
  });

  group('Oito2CopyButton', () {
    testWidgets('copies and shows the copied state for a while', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpOito2(
        tester,
        const Center(
          child: SizedBox(
            width: 300,
            child: Oito2CopyField(value: 'https://oito2.dev'),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Copy'));
      await tester.pump();
      expect(copied, 'https://oito2.dev');
      expect(find.byTooltip('Copied'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Copy'), findsOneWidget);
    });
  });

  group('Oito2Marquee', () {
    Widget marquee({double width = 200, String text = 'A long headline'}) =>
        Center(
          child: SizedBox(
            width: width,
            child: Oito2Marquee(speed: 100, child: Text(text)),
          ),
        );

    testWidgets('scrolls content that overflows', (tester) async {
      await pumpOito2(tester, marquee(width: 60));
      await tester.pump();
      expect(find.text('A long headline'), findsNWidgets(2));
      final start = tester.getTopLeft(find.text('A long headline').first).dx;
      await tester.pump(const Duration(milliseconds: 200));
      final later = tester.getTopLeft(find.text('A long headline').first).dx;
      expect(later, lessThan(start));
    });

    testWidgets('content that fits stays still', (tester) async {
      await pumpOito2(tester, marquee(width: 500));
      await tester.pump();
      expect(find.text('A long headline'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('stops under reduced motion and on hover', (tester) async {
      await pumpOito2(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: marquee(width: 60),
        ),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);

      await pumpOito2(tester, marquee(width: 60));
      await tester.pump();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(
        location: tester.getCenter(find.byType(Oito2Marquee)),
      );
      await tester.pump();
      final x = tester.getTopLeft(find.text('A long headline').first).dx;
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getTopLeft(find.text('A long headline').first).dx, x);
    });
  });

  group('Oito2TimerController', () {
    test('formats durations', () {
      expect(oito2FormatDuration(const Duration(seconds: 5)), '0:05');
      expect(
        oito2FormatDuration(const Duration(minutes: 61, seconds: 2)),
        '1:01:02',
      );
      expect(
        oito2FormatDuration(const Duration(milliseconds: 1250), tenths: true),
        '0:01.2',
      );
    });

    testWidgets('counts down, pauses and completes', (tester) async {
      var completed = 0;
      final timer = Oito2TimerController(
        countdown: const Duration(seconds: 5),
        now: () => tester.binding.clock.now(),
        onComplete: () => completed++,
      );
      addTearDown(timer.dispose);
      await pumpOito2(tester, Center(child: Oito2TimerText(controller: timer)));
      expect(find.text('0:05'), findsOneWidget);
      timer.start();
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('0:03'), findsOneWidget);
      timer.pause();
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('0:03'), findsOneWidget);
      timer.start();
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('0:00'), findsOneWidget);
      expect(timer.isCompleted, isTrue);
      expect(timer.isRunning, isFalse);
      expect(completed, 1);
      timer.reset();
      await tester.pump();
      expect(find.text('0:05'), findsOneWidget);
    });

    testWidgets('a stopwatch counts up', (tester) async {
      final timer = Oito2TimerController(now: () => tester.binding.clock.now());
      addTearDown(timer.dispose);
      await pumpOito2(tester, Center(child: Oito2TimerText(controller: timer)));
      timer.start();
      await tester.pump(const Duration(seconds: 65));
      expect(find.text('1:05'), findsOneWidget);
      timer.pause();
    });

    testWidgets('a countdown completes on time between ticks', (tester) async {
      var completed = 0;
      final timer = Oito2TimerController(
        countdown: const Duration(milliseconds: 1500),
        now: () => tester.binding.clock.now(),
        onComplete: () => completed++,
      );
      addTearDown(timer.dispose);
      timer.start();
      await tester.pump(const Duration(milliseconds: 1500));
      expect(completed, 1);
      expect(timer.remaining, Duration.zero);
    });

    testWidgets('does not start once disposed', (tester) async {
      final timer = Oito2TimerController(now: () => tester.binding.clock.now());
      timer.dispose();
      timer.start();
      expect(timer.isRunning, isFalse);
    });
  });

  group('Oito2TreeView', () {
    Future<Oito2TreeController> pumpTree(
      WidgetTester tester, {
      Oito2SelectionMode mode = Oito2SelectionMode.single,
      bool checkable = false,
      String query = '',
      ValueChanged<Oito2TreeNode<void>>? onActivate,
      void Function(Oito2TreeNode<void>, String)? onRename,
    }) async {
      final controller = Oito2TreeController(selectionMode: mode);
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          width: 300,
          height: 400,
          child: Oito2TreeView(
            collection: _files,
            controller: controller,
            checkable: checkable,
            query: query,
            onActivate: onActivate,
            onRename: onRename,
            semanticLabel: 'Files',
          ),
        ),
      );
      return controller;
    }

    testWidgets('the arrow keys move, open and close branches', (tester) async {
      final controller = await pumpTree(tester);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.home);
      expect(controller.selected, {'src'});
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(controller.isExpanded('src'), isTrue);
      expect(find.text('main.dart'), findsOneWidget);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(controller.selected, {'src/main.dart'});
      await _key(tester, LogicalKeyboardKey.arrowLeft);
      expect(controller.selected, {'src'});
      await _key(tester, LogicalKeyboardKey.arrowLeft);
      expect(controller.isExpanded('src'), isFalse);
      await _key(tester, LogicalKeyboardKey.end);
      expect(controller.selected, {'README.md'});
      await _key(tester, LogicalKeyboardKey.keyS);
      expect(controller.selected, {'src'});
    });

    testWidgets('Enter activates; a double click on a branch toggles it', (
      tester,
    ) async {
      final activated = <String>[];
      await pumpTree(tester, onActivate: (n) => activated.add(n.value));
      await tester.tap(find.text('README.md'));
      await _key(tester, LogicalKeyboardKey.enter);
      expect(activated, ['README.md']);

      final controller = await pumpTree(tester);
      await tester.tap(find.text('src'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('src'));
      await tester.pumpAndSettle();
      expect(controller.isExpanded('src'), isTrue);
    });

    testWidgets('two slow clicks are not a double click', (tester) async {
      final activated = <String>[];
      await pumpTree(tester, onActivate: (n) => activated.add(n.value));
      await tester.tap(find.text('README.md'));
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.text('README.md'));
      await tester.pump();
      expect(activated, isEmpty);
      await tester.tap(find.text('README.md'));
      await tester.pump(const Duration(milliseconds: 80));
      expect(activated, ['README.md']);
    });

    testWidgets('Shift+click works after the anchor branch closes', (
      tester,
    ) async {
      final controller = await pumpTree(
        tester,
        mode: Oito2SelectionMode.multiple,
      );
      controller.expandAll(_files);
      await tester.pump();
      await tester.tap(find.text('a.dart'));
      await tester.pump(const Duration(seconds: 1));
      controller.setExpanded('src/widgets', false);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(find.text('README.md'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(controller.selected, {'README.md'});
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('check boxes cascade and show the mixed state', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = await pumpTree(tester, checkable: true);
      controller.expandAll(_files);
      await tester.pump();
      await tester.tap(find.text('widgets'));
      await _key(tester, LogicalKeyboardKey.space);
      expect(controller.checked, {'src/widgets/a.dart', 'src/widgets/b.dart'});
      expect(controller.checkStateOf(_files, 'src'), isNull);
      expect(controller.checkStateOf(_files, 'src/widgets'), isTrue);
      expect(
        tester.getSemantics(find.bySemanticsLabel('src')),
        isSemantics(isCheckStateMixed: true),
      );
      handle.dispose();
    });

    testWidgets('multiple selection with Shift, Control and Control+A', (
      tester,
    ) async {
      final controller = await pumpTree(
        tester,
        mode: Oito2SelectionMode.multiple,
      );
      await tester.tap(find.text('src'));
      await _key(tester, LogicalKeyboardKey.arrowDown, shift: true);
      expect(controller.selected, {'src', 'README.md'});
      await _key(tester, LogicalKeyboardKey.keyA, control: true);
      expect(controller.selected, {'src', 'README.md'});
    });

    testWidgets('a query shows matches with their ancestors', (tester) async {
      await pumpTree(tester, query: 'b.da');
      expect(find.byType(Oito2HighlightedText), findsNWidgets(3));
      expect(find.text('README.md'), findsNothing);
    });

    testWidgets('F2 renames the active node', (tester) async {
      final renamed = <String>[];
      await pumpTree(tester, onRename: (n, label) => renamed.add(label));
      await tester.tap(find.text('README.md'));
      await _key(tester, LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'READ.md');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(renamed, ['READ.md']);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('Escape cancels a rename', (tester) async {
      final renamed = <String>[];
      await pumpTree(tester, onRename: (n, label) => renamed.add(label));
      await tester.tap(find.text('README.md'));
      await _key(tester, LogicalKeyboardKey.f2);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'READ.md');
      await _key(tester, LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(renamed, isEmpty);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('README.md'), findsOneWidget);
    });

    Future<Oito2TreeController> pumpFocusedTree(
      WidgetTester tester,
      Oito2TreeCollection<void> collection, {
      TextDirection textDirection = TextDirection.ltr,
    }) async {
      final controller = Oito2TreeController();
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          width: 300,
          height: 300,
          child: Oito2TreeView(
            autofocus: true,
            collection: collection,
            controller: controller,
          ),
        ),
        textDirection: textDirection,
      );
      await tester.pump();
      return controller;
    }

    testWidgets('the arrows follow the reading direction in RTL', (
      tester,
    ) async {
      final controller = await pumpFocusedTree(
        tester,
        _files,
        textDirection: TextDirection.rtl,
      );
      await _key(tester, LogicalKeyboardKey.arrowLeft);
      expect(controller.isExpanded('src'), isTrue);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(controller.isExpanded('src'), isFalse);
    });

    testWidgets('typing the same letter cycles through its matches', (
      tester,
    ) async {
      final controller = await pumpFocusedTree(
        tester,
        Oito2TreeCollection<void>([
          const Oito2TreeNode(value: 'alpha'),
          const Oito2TreeNode(value: 'apple'),
          const Oito2TreeNode(value: 'beta'),
        ]),
      );
      final seen = <String>[];
      for (var i = 0; i < 3; i++) {
        await _key(tester, LogicalKeyboardKey.keyA);
        seen.add(controller.selected.single);
      }
      expect(seen, ['apple', 'alpha', 'apple']);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('an empty branch loads its children once', (tester) async {
      var loads = 0;
      final controller = Oito2TreeController();
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          width: 300,
          height: 300,
          child: _Host<Oito2TreeCollection<void>>(
            initial: Oito2TreeCollection([
              const Oito2TreeNode(value: 'remote', children: []),
            ]),
            builder: (tree, set) => Oito2TreeView(
              collection: tree,
              controller: controller,
              onLoadChildren: (node) async {
                loads++;
                await Future<void>.delayed(const Duration(seconds: 1));
                set(
                  tree.insert('remote', [
                    const Oito2TreeNode(value: 'remote/file.txt'),
                  ]),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(LucideIcons.chevron_right));
      await tester.pump();
      expect(find.byType(Oito2CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('remote/file.txt'), findsOneWidget);
      expect(loads, 1);
    });
    testWidgets('the keyboard keeps the active row fully in view', (
      tester,
    ) async {
      final controller = Oito2TreeController();
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: Oito2TreeView(
              autofocus: true,
              controller: controller,
              collection: Oito2TreeCollection<void>([
                for (var i = 0; i < 30; i++) Oito2TreeNode(value: 'n$i'),
              ]),
            ),
          ),
        ),
      );
      await tester.pump();
      final view = tester.getRect(find.byType(Oito2TreeView<void>));
      for (var i = 0; i < 12; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
      }
      // Rows are a fixed height apart; the last one shown and the list
      // padding below it fit in the view.
      final height =
          tester.getCenter(find.text('n12')).dy -
          tester.getCenter(find.text('n11')).dy;
      final rowBottom = tester.getCenter(find.text('n12')).dy + height / 2;
      expect(rowBottom + Oito2Spacing.xs, lessThanOrEqualTo(view.bottom));
      for (var i = 0; i < 12; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
      }
      expect(tester.getRect(find.text('n0')).top, greaterThan(view.top));
    });

    testWidgets('a failed load is reported and retried on reopening', (
      tester,
    ) async {
      var loads = 0;
      final controller = Oito2TreeController();
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        SizedBox(
          width: 300,
          height: 300,
          child: _Host<Oito2TreeCollection<void>>(
            initial: Oito2TreeCollection([
              const Oito2TreeNode(value: 'remote', children: []),
            ]),
            builder: (tree, set) => Oito2TreeView(
              collection: tree,
              controller: controller,
              onLoadChildren: (node) async {
                if (++loads == 1) throw StateError('offline');
                set(
                  tree.insert('remote', [
                    const Oito2TreeNode(value: 'remote/file.txt'),
                  ]),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(LucideIcons.chevron_right));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isStateError);
      expect(controller.isExpanded('remote'), isFalse);
      await tester.tap(find.byIcon(LucideIcons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('remote/file.txt'), findsOneWidget);
      expect(loads, 2);
    });
  });

  group('Oito2JsonTreeView', () {
    test('paths for keys and indexes', () {
      final tree = oito2JsonTree({
        'name': 'oito2',
        'tags': ['ui', 'flutter'],
        'a b': null,
      });
      expect(tree.values, [
        r'$',
        r'$.name',
        r'$.tags',
        r'$.tags[0]',
        r'$.tags[1]',
        r'$["a b"]',
      ]);
    });

    testWidgets('new data opens to the expand depth again', (tester) async {
      Widget build(Object data) => SizedBox(
        width: 400,
        height: 300,
        child: Oito2JsonTreeView(data: data, expandDepth: 2),
      );
      await pumpOito2(
        tester,
        build({
          'a': {'b': 1},
        }),
      );
      expect(find.textContaining('b', findRichText: true), findsWidgets);
      await pumpOito2(
        tester,
        build({
          'z': {'w': 1},
        }),
      );
      await tester.pump();
      expect(find.textContaining('w', findRichText: true), findsOneWidget);
    });

    testWidgets('shows values JSON cannot encode', (tester) async {
      await pumpOito2(
        tester,
        SizedBox(
          width: 400,
          height: 300,
          child: Oito2JsonTreeView(
            data: {'ratio': double.nan, 'when': DateTime.utc(2026)},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.textContaining('NaN', findRichText: true), findsOneWidget);
      expect(find.textContaining('2026', findRichText: true), findsOneWidget);
    });

    testWidgets('shows keys, values and sizes', (tester) async {
      await pumpOito2(
        tester,
        const SizedBox(
          width: 400,
          height: 300,
          child: Oito2JsonTreeView(
            data: {
              'name': 'oito2',
              'stars': 42,
              'tags': ['ui'],
            },
          ),
        ),
      );
      expect(
        find.textContaining('"oito2"', findRichText: true),
        findsOneWidget,
      );
      expect(find.textContaining('42', findRichText: true), findsOneWidget);
      expect(find.textContaining('[1]', findRichText: true), findsOneWidget);
    });
  });
}
