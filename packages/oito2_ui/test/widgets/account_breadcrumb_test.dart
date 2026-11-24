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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

const _accounts = [
  Oito2Account(
    id: 'ana',
    name: 'Ana Souza',
    subtitle: 'ana@example.com',
    status: Oito2AvatarStatus.online,
    count: 3,
  ),
  Oito2Account(
    id: 'bruno',
    name: 'Bruno Lima',
    subtitle: 'bruno@work.example',
    status: Oito2AvatarStatus.away,
    count: 120,
  ),
  Oito2Account(id: 'carla', name: 'Carla Dias'),
];

const _items = [
  Oito2BreadcrumbItem(label: 'Root', icon: LucideIcons.hard_drive, value: '/'),
  Oito2BreadcrumbItem(label: 'home', value: '/home'),
  Oito2BreadcrumbItem(label: 'ana', value: '/home/ana'),
  Oito2BreadcrumbItem(label: 'Documents', value: '/home/ana/Documents'),
  Oito2BreadcrumbItem(label: 'Projects', value: '/home/ana/Documents/Projects'),
  Oito2BreadcrumbItem(
    label: 'Reports 2026',
    value: '/home/ana/Documents/Projects/Reports 2026',
  ),
];

void main() {
  group('Oito2AccountSwitcher', () {
    testWidgets('shows the current account and switches from the menu', (
      tester,
    ) async {
      final selected = <String>[];
      var added = 0;
      await pumpOito2(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 240,
            child: Oito2AccountSwitcher(
              accounts: _accounts,
              current: _accounts.first,
              onSelected: (account) => selected.add(account.id),
              onAdd: () => added++,
            ),
          ),
        ),
      );
      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.text('ana@example.com'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Add account'), findsNothing);

      await tester.tap(find.text('Ana Souza'));
      await tester.pumpAndSettle();
      expect(find.text('Bruno Lima'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(find.text('Add account'), findsOneWidget);
      // Only the current account has a check mark.
      expect(find.byIcon(LucideIcons.check), findsOneWidget);

      await tester.tap(find.text('Bruno Lima'));
      await tester.pumpAndSettle();
      expect(selected, ['bruno']);
      expect(find.text('Bruno Lima'), findsNothing);

      await tester.tap(find.text('Ana Souza'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add account'));
      await tester.pumpAndSettle();
      expect(added, 1);
    });

    testWidgets('hides the add entry without onAdd', (tester) async {
      await pumpOito2(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 240,
            child: Oito2AccountSwitcher(
              accounts: _accounts,
              current: _accounts.first,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ana Souza'));
      await tester.pumpAndSettle();
      expect(find.text('Carla Dias'), findsOneWidget);
      expect(find.text('Add account'), findsNothing);
    });

    testWidgets('is only the avatar in a compact rail', (tester) async {
      await pumpOito2(
        tester,
        Oito2NavigationRail(
          items: const [
            Oito2NavigationItem(icon: Icon(LucideIcons.house), label: 'Home'),
          ],
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          style: Oito2NavigationRailStyle.compact,
          leading: Oito2AccountSwitcher(
            accounts: _accounts,
            current: _accounts.first,
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.text('Ana Souza'), findsNothing);
      expect(find.byType(Oito2Avatar), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is Tooltip && w.message == 'Ana Souza'),
        findsOneWidget,
      );
      await tester.tap(find.byType(Oito2Avatar));
      await tester.pumpAndSettle();
      expect(find.text('Carla Dias'), findsOneWidget);
    });

    testWidgets('an explicit compact flag wins over the width', (tester) async {
      await pumpOito2(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            child: Oito2AccountSwitcher(
              accounts: _accounts,
              current: _accounts.first,
              onSelected: (_) {},
              compact: true,
            ),
          ),
        ),
      );
      expect(find.text('Ana Souza'), findsNothing);
    });

    testWidgets('opens from the keyboard and reads the current account', (
      tester,
    ) async {
      final selected = <String>[];
      final handle = tester.ensureSemantics();
      await pumpOito2(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 240,
            child: Oito2AccountSwitcher(
              accounts: _accounts,
              current: _accounts.first,
              onSelected: (account) => selected.add(account.id),
            ),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel(
          'Switch account, current: Ana Souza, Online, ana@example.com, '
          '3 pending',
        ),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Carla Dias'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Bruno Lima'))),
        isSemantics(label: 'Bruno Lima, Away, bruno@work.example, 120 pending'),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Carla Dias'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('Carla Dias'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(selected, ['bruno']);
      handle.dispose();
    });
  });

  group('Oito2Breadcrumb', () {
    Future<void> pumpBar(
      WidgetTester tester, {
      double width = 1000,
      ValueChanged<int>? onSelected,
      ValueChanged<String>? onSubmitted,
      TextDirection textDirection = TextDirection.ltr,
    }) => pumpOito2(
      tester,
      Align(
        alignment: AlignmentDirectional.topStart,
        child: SizedBox(
          width: width,
          child: Oito2Breadcrumb<String>(
            items: _items,
            onSelected: onSelected ?? (_) {},
            onSubmitted: onSubmitted,
            path: '/home/ana/Documents/Projects/Reports 2026',
          ),
        ),
      ),
      textDirection: textDirection,
    );

    testWidgets('shows every segment when wide and selects them', (
      tester,
    ) async {
      final selected = <int>[];
      await pumpBar(tester, onSelected: selected.add);
      for (final item in _items) {
        expect(find.text(item.label), findsOneWidget);
      }
      expect(find.byIcon(LucideIcons.ellipsis), findsNothing);
      await tester.tap(find.text('home'));
      await tester.tap(find.text('Root'));
      // The current location is not a link.
      await tester.tap(find.text('Reports 2026'));
      expect(selected, [1, 0]);
    });

    testWidgets('the current location reads as such', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBar(tester);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Reports 2026')),
        isSemantics(label: 'Reports 2026', value: 'Current location'),
      );
      handle.dispose();
    });

    testWidgets('collapses the leading middle segments into a menu', (
      tester,
    ) async {
      final selected = <int>[];
      await pumpBar(tester, width: 500, onSelected: selected.add);
      expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      expect(find.text('Root'), findsOneWidget);
      expect(find.text('Reports 2026'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('home'), findsNothing);
      // Every shown segment fits.
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(LucideIcons.ellipsis));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
      expect(find.text('ana'), findsOneWidget);
      await tester.tap(find.text('ana'));
      await tester.pumpAndSettle();
      expect(selected, [2]);
    });

    testWidgets('keeps only the last segment when very narrow', (tester) async {
      await pumpBar(tester, width: 120);
      expect(find.text('Root'), findsNothing);
      expect(find.text('Reports 2026'), findsOneWidget);
      expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      await tester.tap(find.byIcon(LucideIcons.ellipsis));
      await tester.pumpAndSettle();
      expect(find.text('Root'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
    });

    testWidgets('edits the path and submits it with Enter', (tester) async {
      final submitted = <String>[];
      await pumpBar(tester, onSubmitted: submitted.add);
      await tester.tap(find.byIcon(LucideIcons.pencil));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(
        field.controller!.text,
        '/home/ana/Documents/Projects/Reports 2026',
      );
      await tester.enterText(find.byType(TextField), '/tmp');
      await tester.testTextInput.receiveAction(TextInputAction.go);
      await tester.pumpAndSettle();
      expect(submitted, ['/tmp']);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('Escape cancels the edit, and the empty area starts it', (
      tester,
    ) async {
      final submitted = <String>[];
      await pumpBar(tester, onSubmitted: submitted.add);
      final bar = tester.getRect(find.byType(Oito2Breadcrumb<String>));
      await tester.tapAt(Offset(bar.right - 80, bar.center.dy));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), '/tmp');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(submitted, isEmpty);
      expect(find.text('Documents'), findsOneWidget);
    });

    testWidgets('without onSubmitted there is no edit mode', (tester) async {
      await pumpBar(tester);
      expect(find.byIcon(LucideIcons.pencil), findsNothing);
      final bar = tester.getRect(find.byType(Oito2Breadcrumb<String>));
      await tester.tapAt(Offset(bar.right - 20, bar.center.dy));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('arrow keys move between the segments', (tester) async {
      final selected = <int>[];
      await pumpBar(tester, onSelected: selected.add);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selected, [1]);
    });

    testWidgets('runs from the right in RTL, with left chevrons', (
      tester,
    ) async {
      final selected = <int>[];
      await pumpBar(
        tester,
        onSelected: selected.add,
        textDirection: TextDirection.rtl,
      );
      expect(find.byIcon(LucideIcons.chevron_left), findsNWidgets(5));
      expect(find.byIcon(LucideIcons.chevron_right), findsNothing);
      expect(
        tester.getCenter(find.text('Root')).dx,
        greaterThan(tester.getCenter(find.text('home')).dx),
      );
      // In RTL, Left moves toward the end of the path.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selected, [1]);
    });

    test('collapse keeps every segment when they fit', () {
      // 100 + 20 + 100 + 20 + 100 = 340.
      expect(Oito2Breadcrumb.collapse([100, 100, 100], maxWidth: 340), (
        collapsedStart: 0,
        collapsedEnd: 0,
        lastTruncated: false,
      ));
    });

    test('collapse hides as few middle segments as needed', () {
      // Without the second: 100 + 28 + 100 + 100 and three separators.
      expect(Oito2Breadcrumb.collapse([100, 100, 100, 100], maxWidth: 388), (
        collapsedStart: 1,
        collapsedEnd: 2,
        lastTruncated: false,
      ));
      expect(Oito2Breadcrumb.collapse([100, 100, 100, 100], maxWidth: 387), (
        collapsedStart: 1,
        collapsedEnd: 3,
        lastTruncated: false,
      ));
    });

    test('collapse folds the first and cuts the last when narrow', () {
      expect(Oito2Breadcrumb.collapse([100, 100, 100], maxWidth: 120), (
        collapsedStart: 0,
        collapsedEnd: 2,
        lastTruncated: true,
      ));
      expect(Oito2Breadcrumb.collapse([300], maxWidth: 200), (
        collapsedStart: 0,
        collapsedEnd: 0,
        lastTruncated: true,
      ));
    });

    test('collapse reserves the edit button and minimum widths', () {
      expect(
        Oito2Breadcrumb.collapse([10, 10, 100], maxWidth: 196, editWidth: 32),
        (collapsedStart: 0, collapsedEnd: 0, lastTruncated: false),
      );
      expect(
        Oito2Breadcrumb.collapse(
          [10, 10, 100],
          maxWidth: 196,
          editWidth: 32,
          minSegmentWidth: 48,
        ),
        (collapsedStart: 0, collapsedEnd: 2, lastTruncated: false),
      );
    });
  });
}
