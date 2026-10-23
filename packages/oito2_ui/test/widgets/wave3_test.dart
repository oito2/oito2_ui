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

final _desktops = Oito2ListCollection(
  const [
    ('gnome', 'GNOME', 'GTK'),
    ('xfce', 'Xfce', 'GTK'),
    ('kde', 'KDE Plasma', 'Qt'),
    ('lxqt', 'LXQt (unavailable)', 'Qt'),
  ],
  valueOf: (d) => d.$1,
  labelOf: (d) => d.$2,
  groupOf: (d) => d.$3,
  isDisabled: (d) => d.$1 == 'lxqt',
);

void main() {
  group('Oito2PopupMenuButton', () {
    testWidgets('is as tall as a field and opens its menu', (tester) async {
      var picked = '';
      await pumpOito2(
        tester,
        Center(
          child: Oito2PopupMenuButton(
            menuChildren: [
              MenuItemButton(
                onPressed: () => picked = 'one',
                child: const Text('One'),
              ),
            ],
            child: const Text('Choose'),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(OutlinedButton)).height,
        Oito2Sizes.buttonHeight,
      );
      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      expect(picked, 'one');
      expect(find.text('One'), findsNothing);
    });

    testWidgets('the Down arrow opens the menu', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: Oito2PopupMenuButton(
            menuChildren: [
              MenuItemButton(onPressed: () {}, child: const Text('One')),
            ],
            child: const Text('Choose'),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('One'), findsOneWidget);
    });

    testWidgets('a multi-select item keeps the menu open', (tester) async {
      var checked = false;
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Oito2PopupMenuButton(
              menuChildren: [
                Oito2MultiSelectMenuItem(
                  checked: checked,
                  onChanged: (v) => setState(() => checked = v),
                  child: const Text('Bold'),
                ),
              ],
              child: const Text('Style'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Style'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bold'));
      await tester.pumpAndSettle();
      expect(checked, isTrue);
      expect(find.text('Bold'), findsOneWidget);
    });
  });

  group('Oito2Select', () {
    testWidgets('shows the selection and picks from groups', (tester) async {
      String? value = 'gnome';
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Oito2Select(
              collection: _desktops,
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      expect(find.text('GNOME'), findsOneWidget);
      await tester.tap(find.text('GNOME'));
      await tester.pumpAndSettle();
      expect(find.text('GTK'), findsOneWidget);
      expect(find.text('Qt'), findsOneWidget);
      await tester.tap(find.text('LXQt (unavailable)'));
      await tester.pumpAndSettle();
      expect(value, 'gnome');
      await tester.tap(find.text('KDE Plasma'));
      await tester.pumpAndSettle();
      expect(value, 'kde');
      expect(find.text('KDE Plasma'), findsOneWidget);
    });

    testWidgets('the selected item is checked on its tappable node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(
        tester,
        Center(
          child: Oito2Select(
            collection: _desktops,
            value: 'kde',
            onChanged: (_) {},
          ),
        ),
      );
      await tester.tap(find.text('KDE Plasma'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('KDE Plasma').last),
        isSemantics(
          label: 'KDE Plasma',
          hasCheckedState: true,
          isChecked: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('hovered and selected items draw no border', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: Oito2Select(
            collection: _desktops,
            value: 'kde',
            onChanged: (_) {},
          ),
        ),
      );
      await tester.tap(find.text('KDE Plasma'));
      await tester.pumpAndSettle();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Xfce')));
      await tester.pumpAndSettle();
      BorderSide sideOf(String label) {
        final material = tester.widget<Material>(
          find
              .descendant(
                of: find.ancestor(
                  of: find.text(label).last,
                  matching: find.byType(MenuItemButton),
                ),
                matching: find.byType(Material),
              )
              .first,
        );
        return (material.shape! as OutlinedBorder).side;
      }

      expect(sideOf('Xfce'), BorderSide.none);
      expect(sideOf('KDE Plasma'), BorderSide.none);
    });

    testWidgets('shows the placeholder without a value', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: Oito2Select(
            collection: _desktops,
            value: null,
            placeholder: const Text('Desktop'),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Desktop'), findsOneWidget);
    });
  });

  group('Oito2ListTile', () {
    testWidgets('activates on tap and reads as a selected button', (
      tester,
    ) async {
      var taps = 0;
      await pumpOito2(
        tester,
        Oito2ListTile(
          titleText: 'Wi-Fi',
          subtitleText: 'Connected',
          selected: true,
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.text('Wi-Fi'));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.text('Wi-Fi')),
        isSemantics(isButton: true, isSelected: true, hasSelectedState: true),
      );
      expect(tester.getSize(find.byType(Oito2ListTile)).height, 52);
    });

    testWidgets('a static row declares no enabled or selected state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(tester, const Oito2ListTile(titleText: 'Version'));
      expect(
        tester.getSemantics(find.text('Version')),
        isSemantics(hasEnabledState: false, hasSelectedState: false),
      );
      handle.dispose();
    });

    testWidgets('a disabled tile ignores taps and focus', (tester) async {
      var taps = 0;
      await pumpOito2(
        tester,
        Oito2ListTile(titleText: 'VPN', enabled: false, onTap: () => taps++),
      );
      await tester.tap(find.text('VPN'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(taps, 0);
      expect(tester.getSize(find.byType(Oito2ListTile)).height, 40);
    });

    testWidgets('Enter activates the focused tile', (tester) async {
      var taps = 0;
      await pumpOito2(
        tester,
        Oito2ListTile.square(
          titleText: 'Bluetooth',
          autofocus: true,
          onTap: () => taps++,
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('Oito2ExpansionPanel', () {
    Widget panel({bool collapse = true, List<(int, bool)>? changes}) =>
        Oito2ExpansionPanel(
          headers: const [Text('First'), Text('Second')],
          initiallyExpanded: const {0},
          collapseOnExpand: collapse,
          onExpansionChanged: (i, e) => changes?.add((i, e)),
          children: const [Text('First body'), Text('Second body')],
        );

    testWidgets('opening a section closes the others', (tester) async {
      final changes = <(int, bool)>[];
      await pumpOito2(tester, panel(changes: changes));
      expect(find.text('First body'), findsOneWidget);
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(find.text('Second body'), findsOneWidget);
      expect(find.text('First body'), findsNothing);
      expect(changes, [(1, true)]);
    });

    testWidgets('sections stay open without collapseOnExpand', (tester) async {
      await pumpOito2(tester, panel(collapse: false));
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(find.text('First body'), findsOneWidget);
      expect(find.text('Second body'), findsOneWidget);
    });
  });

  group('Oito2TabBar', () {
    testWidgets('switches tabs with a pill indicator', (tester) async {
      await pumpOito2(
        tester,
        DefaultTabController(
          length: 2,
          child: Builder(
            builder: (context) => Column(
              children: [
                const Oito2TabBar(
                  tabs: [
                    Oito2Tab(
                      label: Text('General'),
                      icon: Icon(LucideIcons.settings),
                    ),
                    Oito2Tab(label: Text('About')),
                  ],
                ),
                Text('Tab ${DefaultTabController.of(context).index}'),
              ],
            ),
          ),
        ),
      );
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.indicator, isA<ShapeDecoration>());
      expect(
        tester
            .getSize(
              find.ancestor(
                of: find.text('About'),
                matching: find.byType(Oito2Tab),
              ),
            )
            .height,
        Oito2Sizes.buttonHeight,
      );
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(
        DefaultTabController.of(tester.element(find.text('About'))).index,
        1,
      );
    });

    testWidgets('the subtle style tints the selected tab at the start', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const DefaultTabController(
          length: 2,
          child: Oito2TabBar(
            style: Oito2TabBarStyle.subtle,
            tabs: [
              Oito2Tab(label: Text('General')),
              Oito2Tab(label: Text('About')),
            ],
          ),
        ),
      );
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      final scheme = Theme.of(tester.element(find.byType(TabBar))).colorScheme;
      final fill = (tabBar.indicator! as ShapeDecoration).color!;
      expect(fill, isNot(scheme.secondaryContainer));
      expect(fill.a, closeTo(0.12, 0.01));
      expect(tabBar.labelColor, fill.withValues(alpha: 1));
      expect(tabBar.isScrollable, isTrue);
      expect(tabBar.tabAlignment, TabAlignment.start);
      expect(tester.getTopLeft(find.text('General')).dx, lessThan(100));
    });

    testWidgets('long labels end with an ellipsis instead of overflowing', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const SizedBox(
          width: 240,
          child: DefaultTabController(
            length: 3,
            child: Oito2TabBar(
              tabs: [
                Oito2Tab(
                  icon: Icon(LucideIcons.settings),
                  label: Text('General settings'),
                ),
                Oito2Tab(
                  icon: Icon(LucideIcons.palette),
                  label: Text('Appearance'),
                ),
                Oito2Tab(
                  icon: Icon(LucideIcons.info),
                  label: Text('About this app'),
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
