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

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// Returns the semantics label of the only sparkline.
String _label(WidgetTester tester) => tester
    .getSemantics(
      find.descendant(
        of: find.byType(Oito2Sparkline),
        matching: find.byType(Semantics),
      ),
    )
    .label;

void main() {
  group('Oito2SparklineStats.of', () {
    test('returns null without finite values', () {
      expect(Oito2SparklineStats.of([]), isNull);
      expect(Oito2SparklineStats.of([double.nan, double.infinity]), isNull);
    });

    test('summarizes one value as steady', () {
      final stats = Oito2SparklineStats.of([5])!;
      expect(stats.count, 1);
      expect((stats.min, stats.max, stats.first, stats.last), (5, 5, 5, 5));
      expect((stats.minIndex, stats.maxIndex, stats.lastIndex), (0, 0, 0));
      expect(stats.trend, Oito2SparklineTrend.steady);
    });

    test('finds the first minimum and maximum and the last value', () {
      final stats = Oito2SparklineStats.of([3, 9, 1, 9, 1, 4])!;
      expect((stats.min, stats.minIndex), (1, 2));
      expect((stats.max, stats.maxIndex), (9, 1));
      expect((stats.last, stats.lastIndex), (4, 5));
      expect(stats.count, 6);
    });

    test('skips values that are not finite', () {
      final stats = Oito2SparklineStats.of([
        double.nan,
        2,
        double.infinity,
        -4,
        double.negativeInfinity,
      ])!;
      expect(stats.count, 2);
      expect((stats.first, stats.last, stats.lastIndex), (2, -4, 3));
      expect((stats.min, stats.max), (-4, 2));
      expect(stats.trend, Oito2SparklineTrend.falling);
    });

    test('reads equal values as steady', () {
      expect(
        Oito2SparklineStats.of([4, 4, 4])!.trend,
        Oito2SparklineTrend.steady,
      );
    });

    test('handles negative values', () {
      final stats = Oito2SparklineStats.of([-3, -1.5, -7, -2])!;
      expect((stats.min, stats.max), (-7, -1.5));
      expect(stats.trend, Oito2SparklineTrend.rising);
    });
  });

  group('Oito2SparklineStats.trendOf', () {
    test('compares the change with the threshold times the range', () {
      // Range 10, threshold 0.1: changes beyond 1 count.
      expect(
        Oito2SparklineStats.trendOf(5, 6.01, 0, 10),
        Oito2SparklineTrend.rising,
      );
      expect(
        Oito2SparklineStats.trendOf(5, 6, 0, 10),
        Oito2SparklineTrend.steady,
      );
      expect(
        Oito2SparklineStats.trendOf(5, 4, 0, 10),
        Oito2SparklineTrend.steady,
      );
      expect(
        Oito2SparklineStats.trendOf(5, 3.99, 0, 10),
        Oito2SparklineTrend.falling,
      );
      expect(
        Oito2SparklineStats.trendOf(5, 6.5, 0, 10, threshold: 0.2),
        Oito2SparklineTrend.steady,
      );
    });

    test('any change counts with a zero threshold', () {
      expect(
        Oito2SparklineStats.trendOf(1, 1.001, 0, 10, threshold: 0),
        Oito2SparklineTrend.rising,
      );
    });

    test('is steady with an empty range', () {
      expect(
        Oito2SparklineStats.trendOf(3, 3, 3, 3),
        Oito2SparklineTrend.steady,
      );
    });
  });

  group('Oito2SparklineStats.describe', () {
    test('summarizes in English and Portuguese', () {
      final stats = Oito2SparklineStats.of([3, 12, 1.5, 8])!;
      expect(
        stats.describe(const Oito2LocalizationsEn()),
        'Minimum 1.5, maximum 12, last 8, rising',
      );
      expect(
        stats.describe(const Oito2LocalizationsPtBr()),
        'Mínimo 1,5, máximo 12, último valor 8, em alta',
      );
    });

    test('formats values with the formatter', () {
      final stats = Oito2SparklineStats.of([8, 2])!;
      expect(
        stats.describe(const Oito2LocalizationsEn(), (v) => '$v MB/s'),
        'Minimum 2.0 MB/s, maximum 8.0 MB/s, last 2.0 MB/s, falling',
      );
    });

    test('reads one value alone', () {
      expect(
        Oito2SparklineStats.of([5])!.describe(const Oito2LocalizationsEn()),
        'Value 5',
      );
    });
  });

  group('Oito2Sparkline', () {
    testWidgets('reads the summary after the label', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpOito2(
        tester,
        Center(
          child: Oito2Sparkline(
            values: const [1, 4, 2, 6],
            semanticsLabel: 'Download speed',
            formatValue: (context, value) => '${value.round()} MB/s',
          ),
        ),
      );
      expect(
        _label(tester),
        'Download speed, Minimum 1 MB/s, maximum 6 MB/s, last 6 MB/s, '
        'rising',
      );
      final node = tester.getSemantics(
        find.descendant(
          of: find.byType(Oito2Sparkline),
          matching: find.byType(Semantics),
        ),
      );
      expect(node.flagsCollection.isImage, isTrue);
      expect(
        find.descendant(
          of: find.byType(Oito2Sparkline),
          matching: find.byType(Focus),
        ),
        findsNothing,
      );
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      semantics.dispose();
    });

    testWidgets('reads "No data" without finite values', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpOito2(
        tester,
        const Center(child: Oito2Sparkline(values: [double.nan])),
      );
      expect(_label(tester), 'No data');
      await pumpOito2(tester, const Center(child: Oito2Sparkline(values: [])));
      expect(tester.takeException(), isNull);
      expect(_label(tester), 'No data');
      semantics.dispose();
    });

    testWidgets('reads the summary in Portuguese', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt', 'BR'),
          supportedLocales: Oito2Localizations.supportedLocales,
          localizationsDelegates: const [
            Oito2Localizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: const Center(child: Oito2Sparkline(values: [2.5, 2.5, 2.5])),
        ),
      );
      expect(
        _label(tester),
        'Mínimo 2,5, máximo 2,5, último valor 2,5, estável',
      );
      semantics.dispose();
    });

    testWidgets('paints every variant and edge case without errors', (
      tester,
    ) async {
      const series = <List<double>>[
        [],
        [5],
        [4, 4, 4],
        [-3, 2, -7, 5],
        [-3, -1, -7],
        [double.nan, 2, double.infinity, 4, double.negativeInfinity],
        [0, 0, 0],
      ];
      for (final type in Oito2SparklineType.values) {
        for (final direction in TextDirection.values) {
          await pumpOito2(
            tester,
            Column(
              children: [
                for (final values in series)
                  Oito2Sparkline(
                    values: values,
                    type: type,
                    showMin: true,
                    showMax: true,
                    showLast: true,
                  ),
                Oito2Sparkline(
                  values: const [1, 50, 3],
                  type: type,
                  min: 0,
                  max: 10,
                  tone: Oito2InfoType.warning,
                ),
              ],
            ),
            textDirection: direction,
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(CustomPaint), findsWidgets);
        }
      }
    });

    testWidgets('repaints a list changed in place', (tester) async {
      final values = <double>[1, 2, 3];
      const key = ValueKey('boundary');
      Future<void> pump() => pumpOito2(
        tester,
        Center(
          child: RepaintBoundary(
            key: key,
            child: Oito2Sparkline(values: values),
          ),
        ),
      );
      await pump();
      // Returns how many times the boundary has painted.
      int paints() {
        final RenderRepaintBoundary boundary = tester.renderObject(
          find.byKey(key),
        );
        return boundary.debugSymmetricPaintCount +
            boundary.debugAsymmetricPaintCount;
      }

      final before = paints();
      await pump();
      expect(paints(), before);
      values[0] = 9;
      await pump();
      expect(paints(), before + 1);
    });

    testWidgets('sizes to the default width when unbounded', (tester) async {
      await pumpOito2(
        tester,
        const Row(
          children: [
            Oito2Sparkline(values: [1, 2]),
          ],
        ),
      );
      expect(
        tester.getSize(find.byType(Oito2Sparkline)),
        const Size(Oito2Sparkline.defaultWidth, 32),
      );
      await pumpOito2(
        tester,
        const Row(
          children: [
            Oito2Sparkline(values: [1, 2], width: 60),
          ],
        ),
      );
      expect(tester.getSize(find.byType(Oito2Sparkline)), const Size(60, 32));
    });

    testWidgets('raises the tone color to 3:1 on the surface', (tester) async {
      await pumpOito2(
        tester,
        const Center(
          child: Oito2Sparkline(values: [1, 2], tone: Oito2InfoType.warning),
        ),
      );
      final context = tester.element(find.byType(Oito2Sparkline));
      final surface = Theme.of(context).colorScheme.surface;
      final warning = Oito2SemanticColors.maybeOf(context)!.warning;
      final expected = Oito2Contrast.ensure(warning, [
        surface,
      ], Oito2Contrast.nonTextAA);
      expect(Oito2Contrast.ratio(expected, surface), greaterThanOrEqualTo(3));
      expect(
        tester.renderObject(
          find.descendant(
            of: find.byType(Oito2Sparkline),
            matching: find.byType(CustomPaint),
          ),
        ),
        paints..path(color: expected),
      );
    });
  });
}
