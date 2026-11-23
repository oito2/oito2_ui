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

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// Returns the bar of the only usage bar.
Oito2LinearProgressIndicator _bar(WidgetTester tester) =>
    tester.widget(find.byType(Oito2LinearProgressIndicator));

/// Returns the semantic colors of the test theme.
Oito2SemanticColors _colors(WidgetTester tester) =>
    Oito2SemanticColors.maybeOf(tester.element(find.byType(Scaffold)))!;

const _properties = [
  Oito2Property(label: 'Name', value: 'report.pdf'),
  Oito2Property(label: 'Location', value: '/home/ana', copyable: true),
];

void main() {
  group('Oito2UsageBar', () {
    testWidgets('switches tones at the thresholds', (tester) async {
      Future<Color?> colorAt(double value) async {
        await pumpOito2(
          tester,
          SizedBox(width: 300, child: Oito2UsageBar(value: value)),
        );
        return _bar(tester).color;
      }

      expect(await colorAt(0.5), isNull);
      expect(await colorAt(0.7), _colors(tester).warning);
      expect(await colorAt(0.89), _colors(tester).warning);
      expect(await colorAt(0.9), _colors(tester).errorText);
    });

    testWidgets('takes custom thresholds', (tester) async {
      await pumpOito2(
        tester,
        const SizedBox(
          width: 300,
          child: Oito2UsageBar(value: 0.6, warningAt: 0.5, dangerAt: 0.95),
        ),
      );
      expect(_bar(tester).color, _colors(tester).warning);
    });

    testWidgets('over quota keeps the bar full in the danger tone', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const SizedBox(
          width: 300,
          child: Oito2UsageBar.bytes(used: 18000000000, total: 15000000000),
        ),
      );
      expect(_bar(tester).value, 1);
      expect(_bar(tester).color, _colors(tester).errorText);
      expect(find.text('18 GB of 15 GB'), findsOneWidget);
    });

    testWidgets('labels amounts as bytes, numbers or a percentage', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const SizedBox(
          width: 300,
          child: Column(
            children: [
              Oito2UsageBar.bytes(
                title: Text('Drive'),
                used: 4200000000,
                total: 15000000000,
              ),
              Oito2UsageBar(value: 3, total: 10),
              Oito2UsageBar(value: 0.25, compact: true),
            ],
          ),
        ),
      );
      expect(find.text('Drive'), findsOneWidget);
      expect(find.text('4.2 GB of 15 GB'), findsOneWidget);
      expect(find.text('3 of 10'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('reads the title and label with the percentage', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(
        tester,
        const SizedBox(
          width: 300,
          child: Oito2UsageBar.bytes(
            title: Text('Drive'),
            used: 4200000000,
            total: 15000000000,
          ),
        ),
      );
      final data = tester
          .getSemantics(find.byType(Oito2UsageBar))
          .getSemanticsData();
      expect(data.label, 'Drive\n4.2 GB of 15 GB');
      expect(data.value, '28%');
      handle.dispose();
    });

    testWidgets('formats bytes for the locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt', 'BR'),
          supportedLocales: Oito2Localizations.supportedLocales,
          localizationsDelegates: const [
            Oito2Localizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: const Scaffold(
            body: Oito2UsageBar.bytes(used: 4200000000, total: 15000000000),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('4,2 GB de 15 GB'), findsOneWidget);
    });
  });

  group('Oito2PropertyList', () {
    testWidgets('aligns labels beside values when wide', (tester) async {
      await pumpOito2(
        tester,
        SizedBox(width: 500, child: Oito2PropertyList(properties: _properties)),
      );
      expect(
        tester.getTopLeft(find.text('Name')).dy,
        tester.getTopLeft(find.text('report.pdf')).dy,
      );
      expect(
        tester.getTopLeft(find.text('report.pdf')).dx,
        tester.getTopLeft(find.text('/home/ana')).dx,
      );
    });

    testWidgets('stacks labels above values when narrow', (tester) async {
      await pumpOito2(
        tester,
        SizedBox(width: 200, child: Oito2PropertyList(properties: _properties)),
      );
      expect(
        tester.getTopLeft(find.text('report.pdf')).dy,
        greaterThan(tester.getBottomLeft(find.text('Name')).dy - 1),
      );
      expect(
        tester.getTopLeft(find.text('Name')).dx,
        tester.getTopLeft(find.text('report.pdf')).dx,
      );
    });

    testWidgets('shows group headings', (tester) async {
      await pumpOito2(
        tester,
        const Oito2PropertyList.grouped(
          groups: [
            Oito2PropertyGroup(heading: 'General', properties: _properties),
            Oito2PropertyGroup(
              heading: 'Sync',
              properties: [Oito2Property(label: 'Status', value: 'Synced')],
            ),
          ],
        ),
      );
      expect(find.text('General'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Sync')).dy,
        greaterThan(tester.getTopLeft(find.text('/home/ana')).dy),
      );
    });

    testWidgets('reads each property as label: value', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(tester, Oito2PropertyList(properties: _properties));
      expect(find.bySemanticsLabel('Name: report.pdf'), findsOneWidget);
      expect(find.bySemanticsLabel('Location: /home/ana'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('copies a copyable value', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpOito2(tester, Oito2PropertyList(properties: _properties));
      expect(find.byType(Oito2CopyButton), findsOneWidget);
      await tester.tap(find.byType(Oito2CopyButton));
      await tester.pump();
      expect(copied, '/home/ana');
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('with a mouse, shows the copy button on hover', (tester) async {
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await pumpOito2(
        tester,
        SizedBox(width: 400, child: Oito2PropertyList(properties: _properties)),
      );
      double opacity() =>
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
      expect(opacity(), 0);
      await mouse.moveTo(tester.getCenter(find.text('/home/ana')));
      await tester.pumpAndSettle();
      expect(opacity(), 1);
    });
  });
}
