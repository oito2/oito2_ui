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

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

import '../window/fake_window_controller.dart';

/// Pumps [child] with semantics on and expects the text contrast and the
/// labeled tap target guidelines to pass.
Future<void> _expectGuidelines(
  WidgetTester tester,
  Widget child, {
  Oito2ColorTheme? colors,
}) async {
  final semantics = tester.ensureSemantics();
  await pumpOito2(tester, child, colors: colors);
  await tester.pump(const Duration(milliseconds: 500));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  semantics.dispose();
}

enum _Speed { full, paused }

void main() {
  group('fixed findings', () {
    for (final (name, colors) in [
      ('light', Oito2ColorTheme.light()),
      ('dark', Oito2ColorTheme.dark()),
    ]) {
      testWidgets('a selected list tile reads on the sidebar, $name', (
        tester,
      ) async {
        await _expectGuidelines(
          tester,
          Material(
            color: colors.chrome.sidebar,
            child: const Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 260,
                child: ListTile(selected: true, title: Text('Selected')),
              ),
            ),
          ),
          colors: colors,
        );
      });
    }

    testWidgets('the arrow of a split button is labeled', (tester) async {
      await _expectGuidelines(
        tester,
        Center(
          child: Oito2SplitButton(
            onPressed: () {},
            menuChildren: [
              MenuItemButton(onPressed: () {}, child: const Text('Save as…')),
            ],
            child: const Text('Save'),
          ),
        ),
      );
    });

    testWidgets('an option button is labeled', (tester) async {
      await _expectGuidelines(
        tester,
        Center(
          child: Oito2OptionButton(
            onPressed: () {},
            label: 'Add',
            child: const Icon(LucideIcons.plus),
          ),
        ),
      );
    });

    testWidgets('a switch in a tile takes the tile title as label', (
      tester,
    ) async {
      await _expectGuidelines(
        tester,
        Oito2Tile(
          title: const Text('Wi-Fi'),
          subtitle: const Text('Home network'),
          trailing: Oito2Switch(value: true, onChanged: (_) {}),
        ),
      );
      expect(
        tester.getSemantics(find.byType(Oito2Switch)),
        isSemantics(label: 'Wi-Fi\nHome network', hasToggledState: true),
      );
    });

    testWidgets('a tile without onTap and its switch are one node', (
      tester,
    ) async {
      var value = false;
      await _expectGuidelines(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Oito2Tile(
            title: const Text('Wi-Fi'),
            trailing: Oito2Switch(
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );
      final tile = tester.getSemantics(find.byType(Oito2Tile));
      expect(tester.getSemantics(find.byType(Oito2Switch)).id, tile.id);
      expect(
        tile,
        isSemantics(label: 'Wi-Fi', hasToggledState: true, hasTapAction: true),
      );
      tile.owner!.performAction(tile.id, SemanticsAction.tap);
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('a tile with onTap keeps its switch as a labeled node', (
      tester,
    ) async {
      var taps = 0;
      var value = false;
      await _expectGuidelines(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Oito2Tile(
            title: const Text('Wi-Fi'),
            subtitle: const Text('Home network'),
            onTap: () => taps++,
            trailing: Oito2Switch(
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );
      final tile = tester.getSemantics(find.byType(Oito2Tile));
      final toggle = tester.getSemantics(find.byType(Oito2Switch));
      expect(toggle.id, isNot(tile.id));
      expect(
        tile,
        isSemantics(
          label: 'Wi-Fi\nHome network',
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(
        toggle,
        isSemantics(label: 'Wi-Fi', hasToggledState: true, hasTapAction: true),
      );
      tile.owner!.performAction(tile.id, SemanticsAction.tap);
      await tester.pump();
      expect((taps, value), (1, false));
      toggle.owner!.performAction(toggle.id, SemanticsAction.tap);
      await tester.pump();
      expect((taps, value), (1, true));
    });

    testWidgets('the color area exposes no unlabeled tap target', (
      tester,
    ) async {
      await _expectGuidelines(
        tester,
        Center(
          child: Oito2ColorPicker(
            value: const Color(0xFF3584E4),
            onChanged: (_) {},
          ),
        ),
      );
    });

    testWidgets('a title bar drag area exposes no unlabeled tap target', (
      tester,
    ) async {
      await _expectGuidelines(
        tester,
        Oito2TitleBarGestureDetector(
          controller: FakeWindowController(),
          child: const SizedBox(width: 400, height: 46),
        ),
      );
    });

    testWidgets('the long press of a hover card joins the child label', (
      tester,
    ) async {
      await _expectGuidelines(
        tester,
        Row(
          children: [
            Oito2HoverCard(
              cardBuilder: (_) => const Text('Card'),
              child: TextButton(onPressed: () {}, child: const Text('Name')),
            ),
          ],
        ),
      );
    });

    testWidgets('the week schedule grid exposes only labeled cells', (
      tester,
    ) async {
      await _expectGuidelines(
        tester,
        Oito2WeekScheduleGrid<_Speed>(
          values: const [
            Oito2ScheduleValue(
              value: _Speed.full,
              label: 'Unlimited',
              type: Oito2InfoType.success,
            ),
            Oito2ScheduleValue(
              value: _Speed.paused,
              label: 'Paused',
              type: Oito2InfoType.danger,
            ),
          ],
          schedule: List.filled(7 * 24, _Speed.full),
          paintValue: null,
          onChanged: (_) {},
        ),
      );
    });
  });

  group('new components', () {
    testWidgets('alert and status pill', (tester) async {
      await _expectGuidelines(
        tester,
        Column(
          children: [
            for (final type in Oito2InfoType.values)
              Oito2Alert(type: type, title: Text(type.name), onDismiss: () {}),
            for (final type in Oito2InfoType.values)
              Oito2StatusPill(label: type.name, type: type),
          ],
        ),
      );
    });

    testWidgets('skeleton', (tester) async {
      await _expectGuidelines(
        tester,
        const SizedBox(
          width: 300,
          child: Oito2Skeleton.text(lines: 3, lastLineWidthFactor: 0.5),
        ),
      );
    });

    testWidgets('status page and busy button', (tester) async {
      await _expectGuidelines(
        tester,
        SizedBox(
          width: 600,
          height: 500,
          child: Oito2StatusPage(
            icon: const Icon(LucideIcons.folder_open),
            title: const Text('No files'),
            description: const Text('Drop files here to add them.'),
            actions: [
              Oito2BusyButton(
                busy: false,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Oito2BusyLabel(child: Icon(LucideIcons.save)),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      );
    });

    testWidgets('virtual list and data table', (tester) async {
      final fruits = Oito2ListCollection(const ['Apple', 'Banana', 'Cherry']);
      final files = Oito2ListCollection<(String, int)>(const [
        ('a.txt', 10),
        ('b.txt', 20),
      ]);
      final list = Oito2SelectionController(collection: fruits);
      final table = Oito2SelectionController(collection: files);
      addTearDown(list.dispose);
      addTearDown(table.dispose);
      await _expectGuidelines(
        tester,
        Row(
          children: [
            SizedBox(
              width: 240,
              height: 300,
              child: Oito2VirtualList(
                collection: fruits,
                controller: list,
                semanticLabel: 'Fruits',
              ),
            ),
            SizedBox(
              width: 500,
              height: 300,
              child: Oito2DataTable<(String, int)>(
                collection: files,
                controller: table,
                semanticLabel: 'Files',
                sort: const Oito2SortDescriptor('name'),
                onSortChanged: (_) {},
                columns: [
                  const Oito2TableColumn<(String, int)>(
                    id: 'name',
                    label: 'Name',
                    sortable: true,
                    resizable: true,
                  ),
                  Oito2TableColumn<(String, int)>(
                    id: 'size',
                    label: 'Size',
                    width: const Oito2ColumnWidth.fixed(100),
                    cellBuilder: (context, file) => Text('${file.$2} B'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });

    testWidgets('usage bar and property list', (tester) async {
      await _expectGuidelines(
        tester,
        SizedBox(
          width: 500,
          child: Column(
            children: [
              Oito2UsageBar(value: 0.95),
              Oito2PropertyList(
                properties: const [
                  Oito2Property(label: 'Name', value: 'report.pdf'),
                  Oito2Property(
                    label: 'Location',
                    value: '/home/ana',
                    copyable: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });

    testWidgets('account switcher and breadcrumb', (tester) async {
      const accounts = [
        Oito2Account(id: 'ana', name: 'Ana Souza', count: 3),
        Oito2Account(id: 'bruno', name: 'Bruno Lima'),
      ];
      await _expectGuidelines(
        tester,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 240,
              child: Oito2AccountSwitcher(
                accounts: accounts,
                current: accounts.first,
                onSelected: (_) {},
                onAdd: () {},
              ),
            ),
            SizedBox(
              width: 300,
              child: Oito2Breadcrumb<String>(
                items: const [
                  Oito2BreadcrumbItem(label: 'Root', value: '/'),
                  Oito2BreadcrumbItem(label: 'home', value: '/home'),
                  Oito2BreadcrumbItem(label: 'ana', value: '/home/ana'),
                  Oito2BreadcrumbItem(label: 'Docs', value: '/home/ana/Docs'),
                  Oito2BreadcrumbItem(
                    label: 'Reports',
                    value: '/home/ana/Docs/Reports',
                  ),
                ],
                onSelected: (_) {},
                path: '/home/ana/Docs/Reports',
              ),
            ),
          ],
        ),
      );
    });

    testWidgets('password strength meter', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpOito2(
        tester,
        const SizedBox(
          width: 300,
          child: Oito2PasswordField(showStrength: true),
        ),
      );
      await tester.enterText(find.byType(TextField), 'correct horse');
      await tester.pump(const Duration(milliseconds: 500));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();
    });

    testWidgets('tree columns header', (tester) async {
      final controller = Oito2TreeController();
      addTearDown(controller.dispose);
      await _expectGuidelines(
        tester,
        SizedBox(
          width: 400,
          height: 300,
          child: Oito2TreeView(
            collection: Oito2TreeCollection<void>([
              const Oito2TreeNode(
                value: 'src',
                children: [Oito2TreeNode(value: 'src/a.dart', label: 'a.dart')],
              ),
              const Oito2TreeNode(value: 'README.md'),
            ]),
            controller: controller,
            onColumnResized: (_, _) {},
            columns: [
              const Oito2TableColumn(id: 'name', label: 'Name'),
              Oito2TableColumn(
                id: 'size',
                label: 'Size',
                width: const Oito2ColumnWidth.fixed(80),
                resizable: true,
                cellBuilder: (context, node) => Text('${node.value}#'),
              ),
            ],
          ),
        ),
      );
    });
  });
}
