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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_example/src/docs/api_reference.g.dart';
import 'package:oito2_ui_example/src/docs/doc_widgets.dart';
import 'package:oito2_ui_example/src/docs/markdown.dart';
import 'package:oito2_ui_example/src/pages/docs_pages.dart';
import 'package:oito2_ui_example/src/showcase_catalog.dart';

/// The method channels of the url_launcher implementations a test can
/// reach.
const _launcherChannels = [
  MethodChannel('plugins.flutter.io/url_launcher'),
  MethodChannel('plugins.flutter.io/url_launcher_linux'),
];

/// Records the URLs the url_launcher channels are asked to open, until the
/// test ends.
List<String> _recordLaunches(WidgetTester tester) {
  final launched = <String>[];
  final messenger = tester.binding.defaultBinaryMessenger;
  for (final channel in _launcherChannels) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'launch') {
        launched.add((call.arguments as Map)['url'] as String);
        return true;
      }
      return call.method == 'canLaunch';
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  }
  return launched;
}

/// Wraps [child] in an app with the oito2 theme, its localizations and a
/// toaster.
Widget _app(Widget child) => MaterialApp(
  theme: Oito2Theme.light(),
  localizationsDelegates: const [
    Oito2Localizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: Oito2Localizations.supportedLocales,
  builder: (context, child) => Oito2Toaster(child: child!),
  home: Scaffold(body: child),
);

/// Returns the tap recognizer of the link span that reads [label].
TapGestureRecognizer _linkRecognizer(WidgetTester tester, String label) {
  TapGestureRecognizer? found;
  for (final text in tester.widgetList<RichText>(find.byType(RichText))) {
    text.text.visitChildren((span) {
      if (span is TextSpan && span.text == label) {
        found = span.recognizer as TapGestureRecognizer?;
      }
      return found == null;
    });
  }
  return found!;
}

/// Returns the names of the Markdown files in the asset folder [folder],
/// without the extension.
Set<String> _markdownFiles(String folder) => {
  for (final file in Directory(folder).listSync())
    if (file.path.endsWith('.md'))
      file.uri.pathSegments.last.replaceFirst(RegExp(r'\.md$'), ''),
};

/// Returns the workspace members listed in the root `pubspec.yaml`.
List<String> _workspaceMembers() {
  final pubspec = File('../pubspec.yaml').readAsLinesSync();
  final start = pubspec.indexOf('workspace:');
  return [
    for (final line
        in pubspec.skip(start + 1).takeWhile((line) => line.startsWith('  - ')))
      line.substring(4).trim(),
  ];
}

/// An asset bundle that serves [assets] from memory.
class _MemoryBundle extends CachingAssetBundle {
  _MemoryBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final text = assets[key];
    if (text == null) throw FlutterError('No asset $key');
    return ByteData.sublistView(Uint8List.fromList(text.codeUnits));
  }
}

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
      for (final (_, file, _, _) in showcaseGuides)
        'assets/docs/guides/$file.md',
      for (final package in changelogPackages)
        'assets/docs/changelog/$package.md',
    ]) {
      final blocks = parseMarkdown(await rootBundle.loadString(asset));
      expect(blocks.whereType<MdHeading>(), isNotEmpty, reason: asset);
    }
  });

  test('the oito2_ui changelog keeps its nested lists', () async {
    final blocks = parseMarkdown(
      await rootBundle.loadString('assets/docs/changelog/oito2_ui.md'),
    );
    final nested = [
      for (final list in blocks.whereType<MdList>())
        for (var i = 0; i < list.items.length; i++)
          if (list.depthOf(i) > 0) list.items[i],
    ];
    expect(nested, contains(startsWith('`Oito2ListCollection`')));
  });

  group('workspace lists', () {
    test('the changelog page lists every generated changelog', () {
      expect(
        changelogPackages.toSet(),
        _markdownFiles('assets/docs/changelog'),
      );
    });

    test('the changelog page lists every published workspace package', () {
      expect(changelogPackages.toSet(), {
        for (final member in _workspaceMembers())
          if (member.startsWith('packages/') &&
              member != 'packages/oito2_ui_test_utils')
            member.substring('packages/'.length),
      });
    });

    test('every guide has its file and every guide file a page', () {
      expect({
        for (final (_, file, _, _) in showcaseGuides) file,
      }, _markdownFiles('assets/docs/guides'));
    });

    test('the CI test matrices list every package and the example', () {
      final ci = File('../.github/workflows/ci.yml').readAsLinesSync();
      final matrices = <Set<String>>[];
      for (var i = 0; i < ci.length; i++) {
        if (ci[i].trim() != 'package:') continue;
        matrices.add({
          for (final line
              in ci
                  .skip(i + 1)
                  .takeWhile((line) => line.trimLeft().startsWith('- ')))
            line.trim().substring(2),
        });
      }
      final expected = {
        for (final member in _workspaceMembers())
          if (member != 'tools/parity') member,
      };
      expect(matrices, hasLength(2));
      for (final matrix in matrices) {
        expect(matrix, expected);
      }
    });
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

    test('reads the nesting depth of indented list items', () {
      final blocks = parseMarkdown(
        '- a\n  - b\n    continued\n    - c\n- d\n      - e',
      );
      final list = blocks.single as MdList;
      expect(list.items, ['a', 'b continued', 'c', 'd', 'e']);
      expect([for (var i = 0; i < 5; i++) list.depthOf(i)], [0, 1, 2, 0, 1]);
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

  group('doc widgets', () {
    testWidgets('indents nested list items under their parent', (tester) async {
      await tester.pumpWidget(
        _app(Column(children: markdownWidgets('- parent\n  - child'))),
      );
      final parent = tester.getTopLeft(find.text('parent', findRichText: true));
      final child = tester.getTopLeft(find.text('child', findRichText: true));
      expect(child.dx, greaterThan(parent.dx));
    });

    for (final url in [
      'file:///etc/passwd',
      'javascript:alert(1)',
      'http://[',
    ]) {
      testWidgets('a link to $url does not open and shows a toast', (
        tester,
      ) async {
        final launched = _recordLaunches(tester);
        await tester.pumpWidget(_app(DocText('[link]($url)')));
        _linkRecognizer(tester, 'link').onTap!();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(launched, isEmpty);
        expect(find.text('Could not open the link'), findsOneWidget);
        // Lets the toast time out.
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpAndSettle();
      });
    }

    testWidgets('an https link opens in the browser', (tester) async {
      final launched = _recordLaunches(tester);
      await tester.pumpWidget(_app(const DocText('[docs](https://a.b/c)')));
      _linkRecognizer(tester, 'docs').onTap!();
      await tester.pump();
      expect(launched, ['https://a.b/c']);
      expect(find.text('Could not open the link'), findsNothing);
    });

    testWidgets('link recognizers survive rebuilds and are disposed', (
      tester,
    ) async {
      final created = <Object>{};
      final disposed = <Object>{};
      void listen(ObjectEvent event) {
        if (event.object is! GestureRecognizer) return;
        if (event is ObjectCreated) created.add(event.object);
        if (event is ObjectDisposed) disposed.add(event.object);
      }

      FlutterMemoryAllocations.instance.addListener(listen);
      addTearDown(
        () => FlutterMemoryAllocations.instance.removeListener(listen),
      );
      const text = DocText('[docs](https://a.b/c)');
      await tester.pumpWidget(_app(text));
      final first = _linkRecognizer(tester, 'docs');
      // A theme change rebuilds the text with the same content.
      await tester.pumpWidget(
        MaterialApp(
          theme: Oito2Theme.dark(),
          home: const Scaffold(body: text),
        ),
      );
      expect(_linkRecognizer(tester, 'docs'), same(first));
      await tester.pumpWidget(const SizedBox());
      final links = created.whereType<TapGestureRecognizer>();
      expect(links, isNotEmpty);
      expect(disposed, containsAll(links));
    });

    testWidgets('the changelog page builds a version only when opened', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final bundle = _MemoryBundle({
        for (final package in changelogPackages)
          'assets/docs/changelog/$package.md':
              '# Changelog\n\nIntro.\n\n## [Unreleased]\n\n### Added\n\n'
              '- new in $package\n\n## [0.1.0]\n\n- old in $package\n',
      });
      await tester.pumpWidget(
        _app(DefaultAssetBundle(bundle: bundle, child: const ChangelogPage())),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Unreleased'), findsNWidgets(changelogPackages.length));
      expect(find.text('new in oito2_ui', findRichText: true), findsNothing);
      expect(find.text('old in oito2_ui', findRichText: true), findsNothing);
      await tester.tap(find.text('Unreleased').first);
      await tester.pumpAndSettle();
      expect(find.text('new in oito2_ui', findRichText: true), findsOneWidget);
      expect(find.text('old in oito2_ui', findRichText: true), findsNothing);
    });
  });
}
