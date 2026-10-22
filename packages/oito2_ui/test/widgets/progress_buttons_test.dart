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
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

void main() {
  group('Oito2CircularProgressIndicator', () {
    testWidgets('spins without rebuilding its paint', (tester) async {
      await pumpOito2(
        tester,
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Oito2CircularProgressIndicator(),
              SizedBox(width: 200, child: Oito2LinearProgressIndicator()),
            ],
          ),
        ),
      );
      List<CustomPaint> paints() => tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(Column),
              matching: find.byType(CustomPaint),
            ),
          )
          .toList();
      final before = paints();
      await tester.pump(const Duration(milliseconds: 100));
      final after = paints();
      for (var i = 0; i < before.length; i++) {
        expect(after[i], same(before[i]));
      }
    });

    testWidgets('determinate progress reads as a percentage', (tester) async {
      await pumpOito2(
        tester,
        const Center(
          child: Oito2CircularProgressIndicator(
            value: 0.42,
            semanticsLabel: 'Downloading',
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(Oito2CircularProgressIndicator)),
        isSemantics(label: 'Downloading', value: '42%'),
      );
      expect(tester.hasRunningAnimations, isFalse);
      expect(
        tester.getSize(find.byType(Oito2CircularProgressIndicator)),
        const Size.square(32),
      );
    });

    testWidgets('indeterminate progress animates until it gets a value', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const Center(child: Oito2CircularProgressIndicator()),
      );
      expect(tester.hasRunningAnimations, isTrue);
      await pumpOito2(
        tester,
        const Center(child: Oito2CircularProgressIndicator(value: 0.5)),
      );
      // Lets the app's theme transition from the second pump finish.
      await tester.pump(const Duration(seconds: 1));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('stays still when animations are disabled', (tester) async {
      await pumpOito2(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(child: Oito2CircularProgressIndicator()),
        ),
      );
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('uses the theme progress colors', (tester) async {
      await pumpOito2(
        tester,
        const Center(child: Oito2CircularProgressIndicator(value: 0.5)),
      );
      final context = tester.element(
        find.byType(Oito2CircularProgressIndicator),
      );
      final theme = Oito2ProgressIndicatorThemeData.maybeOf(context)!;
      expect(theme.color, Theme.of(context).colorScheme.primary);
      expect(
        theme.trackColor,
        Theme.of(context).colorScheme.surfaceContainerHighest,
      );
    });
  });

  group('Oito2LinearProgressIndicator', () {
    testWidgets('fills the width at the theme height', (tester) async {
      await pumpOito2(
        tester,
        const SizedBox(
          width: 300,
          child: Oito2LinearProgressIndicator(value: 0.25),
        ),
      );
      expect(
        tester.getSize(find.byType(Oito2LinearProgressIndicator)),
        const Size(300, 6),
      );
      expect(
        tester.getSemantics(find.byType(Oito2LinearProgressIndicator)),
        isSemantics(value: '25%'),
      );
    });

    testWidgets('indeterminate progress pulses', (tester) async {
      await pumpOito2(
        tester,
        const SizedBox(width: 300, child: Oito2LinearProgressIndicator()),
      );
      expect(tester.hasRunningAnimations, isTrue);
    });
  });

  group('Oito2IconButton', () {
    testWidgets('is a square of the control height', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: Oito2IconButton(
            icon: const Icon(LucideIcons.settings),
            tooltip: 'Settings',
            onPressed: () {},
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(Oito2IconButton)),
        const Size.square(Oito2Sizes.buttonHeight),
      );
      expect(find.byTooltip('Settings'), findsOneWidget);
    });

    testWidgets('a toggle fills when selected and reads as selected', (
      tester,
    ) async {
      var selected = false;
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Oito2IconButton(
              icon: const Icon(LucideIcons.bold),
              selectedIcon: const Icon(LucideIcons.italic),
              tooltip: 'Bold',
              isSelected: selected,
              onPressed: () => setState(() => selected = !selected),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Oito2IconButton));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
      expect(find.byIcon(LucideIcons.italic), findsOneWidget);
      final context = tester.element(find.byIcon(LucideIcons.italic));
      final material = tester.widget<Material>(
        find
            .ancestor(
              of: find.byIcon(LucideIcons.italic),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, Theme.of(context).colorScheme.secondaryContainer);
      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(hasSelectedState: true, isSelected: true),
      );
    });
  });

  group('back and close buttons', () {
    Future<void> pushPage(WidgetTester tester, Widget button) async {
      await pumpOito2(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(body: Center(child: button)),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('the back button pops and has the localized tooltip', (
      tester,
    ) async {
      await pushPage(tester, const Oito2BackButton());
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevron_left), findsOneWidget);
      await tester.tap(find.byType(Oito2BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('the back button points right in right-to-left layouts', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        const Center(child: Oito2BackButton()),
        textDirection: TextDirection.rtl,
      );
      expect(find.byIcon(LucideIcons.chevron_right), findsOneWidget);
    });

    testWidgets('the close button pops and has the localized tooltip', (
      tester,
    ) async {
      await pushPage(tester, const Oito2CloseButton());
      expect(find.byTooltip('Close'), findsOneWidget);
      await tester.tap(find.byType(Oito2CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
    });
  });
}
