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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

final _cities = Oito2ListCollection(const [
  'Belo Horizonte',
  'Brasília',
  'São Paulo',
  'Salvador',
  'Recife',
], isDisabled: (c) => c == 'Recife');

List<Widget> _slides(int count) => [
  for (var i = 0; i < count; i++) Center(child: Text('Slide $i')),
];

void main() {
  group('Oito2Carousel', () {
    testWidgets('the buttons and arrows move between pages', (tester) async {
      final pages = <int>[];
      await pumpOito2(
        tester,
        Oito2Carousel(onPageChanged: pages.add, children: _slides(3)),
      );
      expect(find.text('Slide 0'), findsOneWidget);
      await tester.tap(find.byTooltip('Next page'));
      await tester.pumpAndSettle();
      expect(find.text('Slide 1'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.tap(find.byTooltip('Previous page'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Previous page'));
      await tester.pumpAndSettle();
      expect(find.text('Slide 2'), findsOneWidget);
      expect(pages, [1, 0, 2]);
    });

    testWidgets('without loop the ends disable the buttons', (tester) async {
      await pumpOito2(tester, Oito2Carousel(loop: false, children: _slides(2)));
      final previous = tester.widget<Oito2IconButton>(
        find.ancestor(
          of: find.byIcon(LucideIcons.chevron_left),
          matching: find.byType(Oito2IconButton),
        ),
      );
      expect(previous.onPressed, isNull);
    });

    testWidgets('the dots jump to a page', (tester) async {
      await pumpOito2(tester, Oito2Carousel(children: _slides(4)));
      await tester.tap(find.bySemanticsLabel('Page 4 of 4'));
      await tester.pumpAndSettle();
      expect(find.text('Slide 3'), findsOneWidget);
    });

    testWidgets('auto-scroll advances and wraps', (tester) async {
      final controller = Oito2CarouselController(
        autoScroll: true,
        autoScrollInterval: const Duration(seconds: 2),
      );
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        Oito2Carousel(controller: controller, children: _slides(2)),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(controller.currentPage, 1);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(controller.currentPage, 0);
    });

    testWidgets('auto-scroll advances while the parent rebuilds', (
      tester,
    ) async {
      final controller = Oito2CarouselController(
        autoScroll: true,
        autoScrollInterval: const Duration(seconds: 2),
      );
      addTearDown(controller.dispose);
      for (var i = 0; i < 5; i++) {
        await pumpOito2(
          tester,
          Oito2Carousel(controller: controller, children: _slides(2)),
        );
        await tester.pump(const Duration(milliseconds: 500));
      }
      await tester.pumpAndSettle();
      expect(controller.currentPage, 1);
    });

    testWidgets('auto-scroll stays still when animations are disabled', (
      tester,
    ) async {
      final controller = Oito2CarouselController(
        autoScroll: true,
        autoScrollInterval: const Duration(seconds: 1),
      );
      addTearDown(controller.dispose);
      await pumpOito2(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Oito2Carousel(controller: controller, children: _slides(2)),
        ),
      );
      await tester.pump(const Duration(seconds: 3));
      expect(controller.currentPage, 0);
    });
  });

  group('Oito2PageIndicator layouts', () {
    Future<double> gap(
      WidgetTester tester,
      Oito2PageIndicatorLayout layout,
      int length, {
      double width = 600,
    }) async {
      await pumpOito2(
        tester,
        Center(
          child: SizedBox(
            width: width,
            child: Center(
              child: Oito2PageIndicator(
                length: length,
                page: 0,
                layout: layout,
              ),
            ),
          ),
        ),
      );
      return tester
          .widget<Row>(
            find.descendant(
              of: find.byType(Oito2PageIndicator),
              matching: find.byType(Row),
            ),
          )
          .spacing;
    }

    testWidgets('stepped spacing shrinks with more pages', (tester) async {
      expect(await gap(tester, Oito2PageIndicatorLayout.stepped, 4), 8);
      expect(await gap(tester, Oito2PageIndicatorLayout.stepped, 8), 6);
      expect(await gap(tester, Oito2PageIndicatorLayout.stepped, 12), 4);
    });

    testWidgets('bounded spacing shrinks to fit the width', (tester) async {
      expect(await gap(tester, Oito2PageIndicatorLayout.bounded, 10), 8);
      final fitted = await gap(
        tester,
        Oito2PageIndicatorLayout.bounded,
        10,
        width: 150,
      );
      expect(fitted, lessThan(8));
      expect(fitted, greaterThanOrEqualTo(4));
    });
  });

  group('Oito2Autocomplete', () {
    Future<List<String>> pumpField(
      WidgetTester tester, {
      bool showAll = false,
    }) async {
      final picked = <String>[];
      await pumpOito2(
        tester,
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 300,
            child: Oito2Autocomplete<String>(
              collection: _cities,
              hintText: 'City',
              showAllWhenEmpty: showAll,
              onSelected: picked.add,
            ),
          ),
        ),
      );
      return picked;
    }

    testWidgets('suggests matches ignoring accents and skips disabled', (
      tester,
    ) async {
      await pumpField(tester);
      await tester.enterText(find.byType(TextField), 'sa');
      await tester.pumpAndSettle();
      expect(find.byType(Oito2HighlightedText), findsNWidgets(2));
      await tester.enterText(find.byType(TextField), 're');
      await tester.pumpAndSettle();
      expect(find.byType(Oito2HighlightedText), findsNothing);
    });

    testWidgets('picks with the arrows and Enter', (tester) async {
      final picked = await pumpField(tester);
      await tester.enterText(find.byType(TextField), 'b');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(picked, ['Brasília']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Brasília',
      );
    });

    testWidgets('a click picks an option', (tester) async {
      final picked = await pumpField(tester, showAll: true);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(Oito2HighlightedText), findsNWidgets(4));
      await tester.tap(find.text('Salvador'));
      await tester.pumpAndSettle();
      expect(picked, ['Salvador']);
    });

    testWidgets('announces the number of suggestions', (tester) async {
      await pumpField(tester);
      await tester.enterText(find.byType(TextField), 'sa');
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('2 results'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'zz');
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('No results'), findsOneWidget);
    });

    testWidgets('follows a swapped controller', (tester) async {
      final first = TextEditingController();
      final second = TextEditingController();
      final firstFocus = FocusNode();
      final secondFocus = FocusNode();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      addTearDown(firstFocus.dispose);
      addTearDown(secondFocus.dispose);
      Widget build(TextEditingController controller, FocusNode focusNode) =>
          SizedBox(
            width: 300,
            child: Oito2Autocomplete<String>(
              collection: _cities,
              controller: controller,
              focusNode: focusNode,
            ),
          );
      await pumpOito2(tester, build(first, firstFocus));
      await pumpOito2(tester, build(second, secondFocus));
      await tester.tap(find.byType(TextField));
      second.text = 'sa';
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('2 results'), findsOneWidget);
      await pumpOito2(tester, const SizedBox());
      first.text = 'b';
      firstFocus.requestFocus();
      expect(tester.takeException(), isNull);
    });
  });
}
