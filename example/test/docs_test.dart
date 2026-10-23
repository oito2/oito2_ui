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
import 'package:oito2_ui_example/src/docs/api_reference.g.dart';
import 'package:oito2_ui_example/src/docs/doc_widgets.dart';
import 'package:oito2_ui_example/src/docs/markdown.dart';
import 'package:oito2_ui_example/src/showcase_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every example region named by a page exists in its source', () async {
    final regionName = RegExp(r"region: '([\w-]+)'");
    final regionList = RegExp(r'regions: (?:const )?\[([^\]]*)\]');
    for (final source in {for (final page in showcasePages) page.sourceAsset}) {
      final text = await rootBundle.loadString(source);
      final regions = sourceRegions(text);
      final named = {
        for (final match in regionName.allMatches(text)) match.group(1)!,
        for (final match in regionList.allMatches(text))
          for (final name in RegExp(r"'([\w-]+)'").allMatches(match.group(1)!))
            name.group(1)!,
      };
      for (final name in named) {
        expect(regions, contains(name), reason: '$source names $name');
      }
    }
  });

  test('every API reference name is in the generated reference', () async {
    final call = RegExp(r'apiReferenceWidgets\(\[([^\]]*)\]');
    for (final source in {for (final page in showcasePages) page.sourceAsset}) {
      final text = await rootBundle.loadString(source);
      for (final match in call.allMatches(text)) {
        for (final name in RegExp(r"'(\w+)'").allMatches(match.group(1)!)) {
          expect(
            apiReference,
            contains(name.group(1)),
            reason: '$source lists ${name.group(1)}',
          );
        }
      }
    }
  });

  test('the documentation assets parse', () async {
    for (final asset in [
      'assets/docs/getting_started.md',
      'assets/docs/about.md',
      for (final guide in [
        'styling',
        'composition',
        'component_state',
        'animations',
        'forms',
        'refs',
      ])
        'assets/docs/guides/$guide.md',
    ]) {
      final blocks = parseMarkdown(await rootBundle.loadString(asset));
      expect(blocks.whereType<MdHeading>(), isNotEmpty, reason: asset);
    }
  });

  testWidgets('a long table of contents scrolls instead of overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocPage(
            title: 'Long',
            children: [for (var i = 0; i < 40; i++) DocHeading('Section $i')],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(Oito2TableOfContents), findsOneWidget);
  });

  group('sourceRegions', () {
    test('dedents and drops the argument name and the last comma', () {
      final regions = sourceRegions('''
    children: [
      // #region demo
      child: Foo(
        bar: 1,
      ),
      // #endregion
    ],
''');
      expect(regions, {'demo': 'Foo(\n  bar: 1,\n)'});
    });
  });

  group('parseMarkdown', () {
    test('reads headings, lists, code, tables and quotes', () {
      final blocks = parseMarkdown('''
# Title

Some `code` text.

## Section

- one
- two

```dart
final x = 1;
```

| A | B |
|---|---|
| 1 | 2 |

> A note.
''');
      expect(blocks.map((b) => b.runtimeType), [
        MdHeading,
        MdParagraph,
        MdHeading,
        MdList,
        MdCode,
        MdTable,
        MdQuote,
      ]);
      expect((blocks[4] as MdCode).language, 'dart');
      expect((blocks[5] as MdTable).rows, [
        ['1', '2'],
      ]);
    });

    test('splits inline code, bold, links and symbol references', () {
      final runs = parseInline(
        'Use `x`, **bold**, [docs](https://a.b) and [Foo].',
      );
      expect(runs.where((r) => r.code).map((r) => r.text), ['x', 'Foo']);
      expect(runs.singleWhere((r) => r.bold).text, 'bold');
      expect(runs.singleWhere((r) => r.link != null).link, 'https://a.b');
    });
  });
}
