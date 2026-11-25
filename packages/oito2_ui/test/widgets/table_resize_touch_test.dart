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
import 'package:oito2_ui/src/widgets/resize_handle.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// The sideways scroll position of the table or the tree.
ScrollPosition _sideways(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
      ),
    )
    .position;

void main() {
  testWidgets('touch resizes a column of a table that scrolls sideways', (
    tester,
  ) async {
    final files = Oito2ListCollection(const ['a', 'b'], valueOf: (f) => f);
    final controller = Oito2SelectionController(collection: files);
    addTearDown(controller.dispose);
    final resized = <(String, double)>[];
    await pumpOito2(
      tester,
      Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: Oito2DataTable<String>(
            collection: files,
            controller: controller,
            onColumnResized: (id, w) => resized.add((id, w)),
            columns: const [
              Oito2TableColumn(
                id: 'name',
                label: 'Name',
                width: Oito2ColumnWidth.fixed(150),
                resizable: true,
              ),
              Oito2TableColumn(
                id: 'size',
                label: 'Size',
                width: Oito2ColumnWidth.fixed(300),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.drag(find.byType(ResizeHandle), const Offset(40, 0));
    await tester.pump();
    // The whole movement resizes, and the table doesn't scroll.
    expect(resized, [('name', 190.0)]);
    expect(_sideways(tester).pixels, 0);
  });

  testWidgets('touch resizes a column of a tree grid that scrolls sideways', (
    tester,
  ) async {
    final tree = Oito2TreeCollection<void>(const [Oito2TreeNode(value: 'a')]);
    final controller = Oito2TreeController();
    addTearDown(controller.dispose);
    final resized = <(String, double)>[];
    await pumpOito2(
      tester,
      Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: Oito2TreeView<void>(
            collection: tree,
            controller: controller,
            onColumnResized: (id, w) => resized.add((id, w)),
            columns: const [
              Oito2TableColumn(
                id: 'name',
                label: 'Name',
                width: Oito2ColumnWidth.fixed(150),
                resizable: true,
              ),
              Oito2TableColumn(
                id: 'size',
                label: 'Size',
                width: Oito2ColumnWidth.fixed(300),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.drag(find.byType(ResizeHandle), const Offset(40, 0));
    await tester.pump();
    // The whole movement resizes, and the table doesn't scroll.
    expect(resized, [('name', 190.0)]);
    expect(_sideways(tester).pixels, 0);
  });
}
