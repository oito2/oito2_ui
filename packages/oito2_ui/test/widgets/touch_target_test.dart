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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// A theme for a touch platform, which pads tap targets.
final _touchTheme = Oito2Theme.light(
  platform: const Oito2Platform(
    targetPlatform: TargetPlatform.android,
    isWeb: false,
  ),
);

/// Pumps [child] centered in the touch theme with semantics on and expects
/// every tap target to be at least 48 by 48 pixels.
Future<void> _expectTouchTargets(WidgetTester tester, Widget child) async {
  final semantics = tester.ensureSemantics();
  await pumpOito2(
    tester,
    Center(
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
    theme: _touchTheme,
  );
  await tester.pump(const Duration(milliseconds: 500));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  semantics.dispose();
}

enum _Speed { full, limited }

void main() {
  group('Oito2TouchTarget', () {
    Widget box(VoidCallback onTap) => Oito2TouchTarget(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const SizedBox(width: 40, height: 40),
      ),
    );

    testWidgets('adds nothing on pointer platforms', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await pumpOito2(tester, Center(child: box(() => taps++)));
      expect(tester.getSize(find.byType(Oito2TouchTarget)), const Size(40, 40));
      await tester.tapAt(
        tester.getTopLeft(find.byType(Oito2TouchTarget)) - const Offset(2, 2),
      );
      expect(taps, 0);
      semantics.dispose();
    });

    testWidgets('pads to 48 pixels and sends margin taps to the child', (
      tester,
    ) async {
      var taps = 0;
      await pumpOito2(
        tester,
        Center(child: box(() => taps++)),
        theme: _touchTheme,
      );
      expect(tester.getSize(find.byType(Oito2TouchTarget)), const Size(48, 48));
      expect(tester.getSize(find.byType(GestureDetector)), const Size(40, 40));
      final topLeft = tester.getTopLeft(find.byType(Oito2TouchTarget));
      await tester.tapAt(topLeft + const Offset(1, 1));
      await tester.tapAt(topLeft + const Offset(24, 47));
      expect(taps, 2);
    });

    testWidgets('gives a plain text field a 48-pixel target', (tester) async {
      await _expectTouchTargets(
        tester,
        const SizedBox(
          width: 300,
          child: Oito2TouchTarget(
            child: TextField(decoration: InputDecoration(labelText: 'Name')),
          ),
        ),
      );
      final topLeft = tester.getTopLeft(find.byType(Oito2TouchTarget));
      await tester.tapAt(topLeft + const Offset(150, 1));
      await tester.pump();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
    });
  });

  group('touch targets reach 48 pixels on touch', () {
    final cases = <String, Widget Function()>{
      'search field and its clear button': () => SizedBox(
        width: 300,
        child: Oito2SearchField(
          controller: TextEditingController(text: 'query'),
        ),
      ),
      'password field and its visibility button': () => const SizedBox(
        width: 300,
        child: Oito2PasswordField(labelText: 'Password'),
      ),
      'number entry and its step buttons': () => SizedBox(
        width: 240,
        child: Oito2NumberEntry(
          value: 3,
          onChanged: (_) {},
          labelText: 'Copies',
        ),
      ),
      'date entry and its picker button': () => SizedBox(
        width: 300,
        child: Oito2DateEntry(
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
        ),
      ),
      'time entry and its picker button': () =>
          const SizedBox(width: 240, child: Oito2TimeEntry()),
      'segmented entry': () => Oito2SegmentedEntry(
        segments: const [
          Oito2EntrySegment(length: 3, hint: '000'),
          Oito2EntrySegment(length: 3, hint: '000'),
        ],
        onChanged: (_) {},
      ),
      'pin entry': () => const Oito2PinEntry(length: 4),
      'autocomplete': () => SizedBox(
        width: 300,
        child: Oito2Autocomplete<String>(
          collection: Oito2ListCollection(const ['Belo Horizonte', 'Santos']),
          hintText: 'City',
        ),
      ),
      'tags field and its tags': () => SizedBox(
        width: 360,
        child: Oito2TagsField(
          tags: const ['flutter', 'dart'],
          onChanged: (_) {},
          hintText: 'Add tag',
        ),
      ),
      'pagination': () =>
          Oito2Pagination(page: 5, pageCount: 12, onChanged: (_) {}),
      'toggle group': () => Oito2ToggleGroup<String>(
        items: const [
          Oito2ToggleItem(
            value: 'b',
            child: Icon(LucideIcons.letter_b),
            tooltip: 'Bold',
          ),
          Oito2ToggleItem(
            value: 'i',
            child: Icon(LucideIcons.italic),
            tooltip: 'Italic',
          ),
        ],
        selected: const {'b'},
        onChanged: (_) {},
      ),
      'segment group': () => Oito2SegmentGroup<String>(
        segments: const [
          Oito2Segment(value: 'day', label: Text('Day')),
          Oito2Segment(value: 'week', label: Text('Week')),
        ],
        selected: 'day',
        onChanged: (_) {},
      ),
      'tab bar': () => const DefaultTabController(
        length: 3,
        child: SizedBox(
          width: 420,
          child: Oito2TabBar(
            tabs: [
              Oito2Tab(label: Text('General')),
              Oito2Tab(label: Text('Appearance')),
              Oito2Tab(label: Text('About')),
            ],
          ),
        ),
      ),
      'breadcrumb': () => SizedBox(
        width: 260,
        child: Oito2Breadcrumb<String>(
          items: const [
            Oito2BreadcrumbItem(label: 'Root', value: '/'),
            Oito2BreadcrumbItem(label: 'home', value: '/home'),
            Oito2BreadcrumbItem(label: 'ana', value: '/home/ana'),
            Oito2BreadcrumbItem(label: 'Documents', value: '/home/ana/Docs'),
            Oito2BreadcrumbItem(label: 'Reports', value: '/home/ana/Docs/R'),
          ],
          onSelected: (_) {},
          onSubmitted: (_) {},
        ),
      ),
      'list box': () {
        final fruits = Oito2ListCollection(const ['Apple', 'Banana']);
        return SizedBox(
          width: 240,
          child: Oito2ListBox(
            collection: fruits,
            controller: Oito2SelectionController(collection: fruits),
          ),
        );
      },
      'editable label': () =>
          Oito2EditableLabel(text: 'Project notes', onSubmitted: (_) {}),
      'small selectable container': () => Oito2SelectableContainer(
        selected: true,
        onTap: () {},
        child: const Text('S'),
      ),
      'rating': () =>
          Oito2Rating(value: 3, onChanged: (_) {}, semanticLabel: 'Quality'),
    };
    for (final MapEntry(key: name, value: build) in cases.entries) {
      testWidgets(name, (tester) => _expectTouchTargets(tester, build()));
    }

    testWidgets('table of contents', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final keys = [GlobalKey(), GlobalKey()];
      await _expectTouchTargets(
        tester,
        SizedBox(
          width: 600,
          height: 300,
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: Oito2TableOfContents(
                  controller: controller,
                  entries: [
                    for (var i = 0; i < 2; i++)
                      Oito2TocEntry(title: 'Section $i', target: keys[i]),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    for (var i = 0; i < 2; i++)
                      SizedBox(key: keys[i], height: 400, child: Text('$i')),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });

    testWidgets('sortable data table header', (tester) async {
      final semantics = tester.ensureSemantics();
      final files = Oito2ListCollection<(String, int)>(const [('a.txt', 10)]);
      final selection = Oito2SelectionController(collection: files);
      addTearDown(selection.dispose);
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: 400,
            height: 200,
            child: Oito2DataTable<(String, int)>(
              collection: files,
              controller: selection,
              sort: const Oito2SortDescriptor('name'),
              onSortChanged: (_) {},
              columns: const [
                Oito2TableColumn<(String, int)>(
                  id: 'name',
                  label: 'Name',
                  sortable: true,
                ),
              ],
            ),
          ),
        ),
        theme: _touchTheme,
      );
      final size = tester.getSemantics(find.text('Name')).rect.size;
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      semantics.dispose();
    });

    group('data table and virtual list rows', () {
      final files = Oito2ListCollection<String>(const ['a.txt', 'b.txt']);

      /// Pumps [table] in [theme] and returns the height of the
      /// semantics node of the row of `a.txt`.
      Future<double> rowHeight(
        WidgetTester tester,
        Widget Function(Oito2SelectionController selection) table, {
        ThemeData? theme,
      }) async {
        final selection = Oito2SelectionController(collection: files);
        addTearDown(selection.dispose);
        await pumpOito2(
          tester,
          Center(
            child: SizedBox(width: 400, height: 300, child: table(selection)),
          ),
          theme: theme,
        );
        return tester.getSemantics(find.text('a.txt')).rect.height;
      }

      Widget Function(Oito2SelectionController) dataTable({
        double? rowHeight,
      }) =>
          (selection) => Oito2DataTable<String>(
            collection: files,
            controller: selection,
            rowHeight: rowHeight,
            columns: const [
              Oito2TableColumn<String>(id: 'name', label: 'Name'),
            ],
          );

      Widget Function(Oito2SelectionController) virtualList({
        double? itemExtent,
        bool variableHeight = false,
      }) =>
          (selection) => Oito2VirtualList<String>(
            collection: files,
            controller: selection,
            itemExtent: itemExtent,
            variableHeight: variableHeight,
          );

      testWidgets('data table rows are 48 pixels tall on touch', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        expect(
          await rowHeight(tester, dataTable(), theme: _touchTheme),
          greaterThanOrEqualTo(48),
        );
        semantics.dispose();
      });

      testWidgets('virtual list rows are 48 pixels tall on touch', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        expect(
          await rowHeight(tester, virtualList(), theme: _touchTheme),
          greaterThanOrEqualTo(48),
        );
        semantics.dispose();
      });

      testWidgets('variable-height list rows are 48 pixels tall on touch', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        expect(
          await rowHeight(
            tester,
            virtualList(variableHeight: true),
            theme: _touchTheme,
          ),
          greaterThanOrEqualTo(48),
        );
        semantics.dispose();
      });

      testWidgets('rows keep their pointer height', (tester) async {
        final semantics = tester.ensureSemantics();
        final row = Oito2Sizes.buttonHeight - 2;
        expect(await rowHeight(tester, dataTable()), row);
        expect(await rowHeight(tester, virtualList()), row);
        expect(await rowHeight(tester, virtualList(variableHeight: true)), 30);
        semantics.dispose();
      });

      testWidgets('an explicit row height wins on touch', (tester) async {
        final semantics = tester.ensureSemantics();
        expect(
          await rowHeight(tester, dataTable(rowHeight: 36), theme: _touchTheme),
          34,
        );
        expect(
          await rowHeight(
            tester,
            virtualList(itemExtent: 36),
            theme: _touchTheme,
          ),
          34,
        );
        semantics.dispose();
      });
    });

    testWidgets('color picker sliders and fields', (tester) async {
      await _expectTouchTargets(
        tester,
        Oito2ColorPicker(value: const Color(0xFF3584E4), onChanged: (_) {}),
      );
    });

    testWidgets('floating panel window buttons', (tester) async {
      await _expectTouchTargets(
        tester,
        SizedBox(
          width: 500,
          height: 400,
          child: Stack(
            children: [
              Oito2FloatingPanel(
                title: 'Inspector',
                onClose: () {},
                child: const SizedBox.expand(),
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(Oito2TitleBar)).height,
        Oito2Sizes.minTouchTarget + 1,
      );
    });

    testWidgets('floating panel keeps its pointer title bar', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpOito2(
        tester,
        SizedBox(
          width: 500,
          height: 400,
          child: Stack(
            children: [
              Oito2FloatingPanel(
                title: 'Inspector',
                onClose: () {},
                child: const SizedBox.expand(),
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(Oito2TitleBar)).height,
        Oito2Sizes.titleBarHeight,
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Close')).rect.size,
        const Size.square(Oito2Sizes.windowControlSize),
      );
      semantics.dispose();
    });

    testWidgets('week schedule legend', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpOito2(
        tester,
        Center(
          child: Oito2WeekScheduleGrid<_Speed>(
            values: const [
              Oito2ScheduleValue(value: _Speed.full, label: 'Unlimited'),
              Oito2ScheduleValue(value: _Speed.limited, label: 'Limited'),
            ],
            schedule: List.filled(7 * 24, _Speed.full),
            onChanged: (_) {},
          ),
        ),
        theme: _touchTheme,
      );
      final size = tester.getSemantics(find.text('Limited')).rect.size;
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      semantics.dispose();
    });
  });
}
