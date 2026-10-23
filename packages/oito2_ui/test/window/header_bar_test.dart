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

import 'fake_window_controller.dart';

const _linux = Oito2Platform(
  targetPlatform: TargetPlatform.linux,
  isWeb: false,
);

/// Pumps a scaffold with [appBar] and [body] on Linux, with a window scope.
Future<void> _pump(
  WidgetTester tester,
  PreferredSizeWidget appBar, {
  Widget body = const SizedBox(),
}) {
  tester.view.physicalSize = const Size(1000, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    Oito2SystemScope(
      settings: Oito2SystemSettings.fallback(_linux),
      child: Oito2WindowScope(
        controller: FakeWindowController(),
        child: MaterialApp(
          theme: Oito2Theme.light(platform: _linux),
          home: Scaffold(appBar: appBar, body: body),
        ),
      ),
    ),
  );
}

void main() {
  group('Oito2HeaderBar', () {
    testWidgets('lays out start, title, end and the main menu', (tester) async {
      var opened = 0;
      await _pump(
        tester,
        Oito2HeaderBar(
          title: const Text('Files'),
          start: [
            Oito2IconButton(
              tooltip: 'Back',
              icon: const Icon(LucideIcons.arrow_left),
              onPressed: () {},
            ),
          ],
          end: [
            Oito2IconButton(
              tooltip: 'New folder',
              icon: const Icon(LucideIcons.folder_plus),
              onPressed: () {},
            ),
          ],
          menuChildren: [
            MenuItemButton(
              onPressed: () => opened++,
              child: const Text('Preferences'),
            ),
          ],
          platform: _linux,
        ),
      );
      expect(find.byType(Oito2WindowTitleBar), findsOneWidget);
      final back = tester.getCenter(find.byTooltip('Back')).dx;
      final title = tester.getCenter(find.text('Files')).dx;
      final folder = tester.getCenter(find.byTooltip('New folder')).dx;
      final menu = tester.getCenter(find.byTooltip('Main menu')).dx;
      expect(back < title && title < folder && folder < menu, isTrue);
      await tester.tap(find.byTooltip('Main menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();
      expect(opened, 1);
    });

    testWidgets('tabs in the middle switch the tab controller', (tester) async {
      await _pump(
        tester,
        const PreferredSize(
          preferredSize: Size.fromHeight(46),
          child: DefaultTabController(
            length: 2,
            child: Oito2HeaderBar(
              tabs: [
                Oito2Tab(label: Text('Albums')),
                Oito2Tab(label: Text('Artists')),
              ],
              platform: _linux,
            ),
          ),
        ),
      );
      final bar = tester.getRect(find.byType(Oito2TitleBar));
      final tabs = tester.getRect(find.byType(TabBar));
      expect(tabs.center.dx, moreOrLessEquals(bar.center.dx, epsilon: 1));
      expect(tabs.width, lessThanOrEqualTo(2 * 120 + 1));
      await tester.tap(find.text('Artists'));
      await tester.pumpAndSettle();
      expect(
        DefaultTabController.of(tester.element(find.text('Artists'))).index,
        1,
      );
    });

    testWidgets('the search replaces the title until Escape', (tester) async {
      final searched = <String>[];
      await _pump(
        tester,
        Oito2HeaderBar(
          title: const Text('Files'),
          search: Oito2HeaderBarSearch(onChanged: searched.add),
          platform: _linux,
        ),
      );
      expect(find.byType(Oito2SearchField), findsNothing);
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Files'), findsNothing);
      expect(find.byType(Oito2SearchField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'notes');
      expect(searched.last, 'notes');
      // Escape clears the text, then closes the search.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Oito2SearchField), findsNothing);
      expect(find.text('Files'), findsOneWidget);
      final button = tester.widget<Oito2IconButton>(
        find.ancestor(
          of: find.byIcon(LucideIcons.search),
          matching: find.byType(Oito2IconButton),
        ),
      );
      expect(button.focusNode!.hasFocus, isTrue);
    });

    testWidgets('a controlled search only reports requests', (tester) async {
      final requests = <bool>[];
      await _pump(
        tester,
        Oito2HeaderBar(
          title: const Text('Files'),
          search: const Oito2HeaderBarSearch(),
          searchActive: false,
          onSearchActiveChanged: requests.add,
          platform: _linux,
        ),
      );
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(requests, [true]);
      expect(find.byType(Oito2SearchField), findsNothing);
    });

    test('rejects a title together with tabs', () {
      expect(
        () => Oito2HeaderBar(
          title: const Text('Files'),
          tabs: const [Oito2Tab(label: Text('One'))],
        ),
        throwsAssertionError,
      );
    });
  });
}
