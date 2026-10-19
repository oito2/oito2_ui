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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'test_app.dart';

BoxDecoration _decorationOf(WidgetTester tester, Finder finder) {
  final container = tester.widget<Container>(
    find.descendant(of: finder, matching: find.byType(Container)).first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  final colors = Oito2ColorTheme.light();

  testWidgets('Oito2BorderContainer draws the outline and surface', (
    tester,
  ) async {
    await pumpOito2(tester, const Oito2BorderContainer(child: Text('x')));
    final decoration = _decorationOf(tester, find.byType(Oito2BorderContainer));
    expect(decoration.color, colors.colorScheme.surface);
    expect(decoration.borderRadius, Oito2Radius.largeAll);
    expect(
      (decoration.border! as Border).top.color,
      colors.colorScheme.outlineVariant,
    );
  });

  testWidgets('Oito2Section shows a header and its actions', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpOito2(
      tester,
      Oito2Section(
        headline: const Text('Appearance'),
        actions: [TextButton(onPressed: () {}, child: const Text('Reset'))],
        child: const Text('content'),
      ),
    );
    expect(find.text('Reset'), findsOneWidget);
    expect(find.byType(Oito2BorderContainer), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Appearance')),
      matchesSemantics(label: 'Appearance', isHeader: true),
    );
    handle.dispose();
  });

  group('Oito2Tile', () {
    testWidgets('renders its parts and reacts to taps', (tester) async {
      var taps = 0;
      await pumpOito2(
        tester,
        Oito2Tile(
          leading: const Icon(Icons.wifi),
          title: const Text('Wi-Fi'),
          subtitle: const Text('Connected'),
          trailing: const Text('On'),
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.text('Wi-Fi'));
      expect(taps, 1);
      final subtitle = DefaultTextStyle.of(
        tester.element(find.text('Connected')),
      ).style;
      expect(subtitle.color, colors.colorScheme.onSurfaceVariant);
    });

    testWidgets('disabled tiles are dimmed and ignore taps', (tester) async {
      var taps = 0;
      await pumpOito2(
        tester,
        Oito2Tile(
          title: const Text('Bluetooth'),
          enabled: false,
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.text('Bluetooth'));
      expect(taps, 0);
      final title = DefaultTextStyle.of(tester.element(find.text('Bluetooth')))
          .style;
      expect(title.color!.a, closeTo(0.38, 0.01));
    });
  });

  testWidgets('Oito2TileList separates its tiles with dividers', (
    tester,
  ) async {
    await pumpOito2(
      tester,
      const Oito2TileList(
        children: [
          Oito2Tile(title: Text('One')),
          Oito2Tile(title: Text('Two')),
          Oito2Tile(title: Text('Three')),
        ],
      ),
    );
    expect(find.byType(Divider), findsNWidgets(2));
    expect(find.byType(Oito2BorderContainer), findsOneWidget);
  });

  testWidgets('Oito2Watermark stays behind and out of semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpOito2(
      tester,
      Oito2Watermark(
        watermark: const Text('mark'),
        child: Center(
          child: TextButton(onPressed: () => taps++, child: const Text('go')),
        ),
      ),
    );
    expect(find.text('mark'), findsOneWidget);
    expect(find.bySemanticsLabel('mark'), findsNothing);
    await tester.tap(find.text('go'));
    expect(taps, 1);
    handle.dispose();
  });
}
