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
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

void main() {
  group('Oito2CheckButton', () {
    testWidgets('the label toggles the box and reads as one element', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      bool? value = false;
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Oito2CheckButton(
              value: value,
              onChanged: (v) => setState(() => value = v),
              title: const Text('Show hidden files'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show hidden files'));
      await tester.pump();
      expect(value, isTrue);
      expect(
        tester.getSemantics(find.byType(Oito2CheckButton)),
        matchesSemantics(
          label: 'Show hidden files',
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('tristate cycles through the mixed state', (tester) async {
      final values = <bool?>[];
      Widget build(bool? value) => Center(
        child: Oito2CheckButton(
          value: value,
          tristate: true,
          onChanged: values.add,
          title: const Text('All'),
        ),
      );
      for (final value in [false, true, null]) {
        await pumpOito2(tester, build(value));
        await tester.tap(find.text('All'));
      }
      expect(values, [true, null, false]);
    });

    testWidgets('a disabled button ignores taps', (tester) async {
      await pumpOito2(
        tester,
        const Center(
          child: Oito2CheckButton(
            value: false,
            onChanged: null,
            title: Text('Locked'),
          ),
        ),
      );
      final handle = tester.ensureSemantics();
      await tester.tap(find.text('Locked'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Locked')),
        isSemantics(
          hasEnabledState: true,
          isEnabled: false,
          hasCheckedState: true,
          isChecked: false,
          hasTapAction: false,
        ),
      );
      handle.dispose();
    });
  });

  testWidgets('Oito2RadioButton selects its value from the label', (
    tester,
  ) async {
    String? group = 'a';
    await pumpOito2(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            for (final value in ['a', 'b'])
              Oito2RadioButton<String>(
                value: value,
                groupValue: group,
                onChanged: (v) => setState(() => group = v),
                title: Text('Option $value'),
              ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Option b'));
    await tester.pump();
    expect(group, 'b');
  });

  testWidgets('Oito2SwitchButton toggles from the label', (tester) async {
    var value = false;
    await pumpOito2(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Center(
          child: Oito2SwitchButton(
            value: value,
            onChanged: (v) => setState(() => value = v),
            title: const Text('Dark style'),
          ),
        ),
      ),
    );
    final label = tester.getCenter(find.text('Dark style'));
    final control = tester.getCenter(find.byType(Oito2Switch));
    expect(label.dx, lessThan(control.dx));
    await tester.tap(find.text('Dark style'));
    await tester.pump();
    expect(value, isTrue);
  });

  group('Oito2RadioButton and Oito2OptionButton', () {
    testWidgets('a toggleable radio button clears its group', (tester) async {
      final values = <String?>[];
      await pumpOito2(
        tester,
        Center(
          child: Oito2RadioButton<String>(
            value: 'a',
            groupValue: 'a',
            toggleable: true,
            onChanged: values.add,
            title: const Text('Option A'),
          ),
        ),
      );
      await tester.tap(find.text('Option A'));
      expect(values, [null]);
    });

    test('an icon-only option button needs a label', () {
      expect(
        () => Oito2OptionButton(onPressed: () {}, child: const Icon(Icons.add)),
        throwsAssertionError,
      );
    });
  });

  group('Oito2SplitButton', () {
    testWidgets('runs the main action and opens the menu', (tester) async {
      var pressed = 0;
      var item = 0;
      await pumpOito2(
        tester,
        Center(
          child: Oito2SplitButton(
            onPressed: () => pressed++,
            menuChildren: [
              MenuItemButton(
                onPressed: () => item++,
                child: const Text('Save as…'),
              ),
            ],
            child: const Text('Save'),
          ),
        ),
      );
      await tester.tap(find.text('Save'));
      expect(pressed, 1);
      await tester.tap(find.byIcon(LucideIcons.chevron_down));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save as…'));
      await tester.pumpAndSettle();
      expect(item, 1);
      expect(find.bySemanticsLabel('More options'), findsOneWidget);
    });

    testWidgets('both parts are as tall as a button', (tester) async {
      for (final variant in Oito2SplitButtonVariant.values) {
        await pumpOito2(
          tester,
          Center(
            child: Oito2SplitButton(
              variant: variant,
              onPressed: () {},
              menuChildren: const [],
              child: const Text('Save'),
            ),
          ),
        );
        for (final part in [
          find.text('Save'),
          find.byIcon(LucideIcons.chevron_down),
        ]) {
          final button = find.ancestor(
            of: part,
            matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
          );
          expect(
            tester.getSize(button.first).height,
            Oito2Sizes.buttonHeight,
            reason: variant.name,
          );
        }
      }
    });

    testWidgets('variants use the matching button', (tester) async {
      for (final (variant, type) in [
        (Oito2SplitButtonVariant.filled, FilledButton),
        (Oito2SplitButtonVariant.outlined, OutlinedButton),
        (Oito2SplitButtonVariant.elevated, ElevatedButton),
      ]) {
        await pumpOito2(
          tester,
          Center(
            child: Oito2SplitButton(
              onPressed: () {},
              variant: variant,
              menuChildren: const [],
              child: const Text('Go'),
            ),
          ),
        );
        expect(find.byType(type), findsNWidgets(2), reason: variant.name);
      }
    });

    testWidgets('a disabled split button disables both parts', (tester) async {
      await pumpOito2(
        tester,
        const Center(
          child: Oito2SplitButton(
            onPressed: null,
            menuChildren: [],
            child: Text('Go'),
          ),
        ),
      );
      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(buttons.every((b) => !b.enabled), isTrue);
    });
  });

  testWidgets('Oito2OptionButton is a square control', (tester) async {
    var taps = 0;
    await pumpOito2(
      tester,
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Oito2OptionButton(
              onPressed: () => taps++,
              label: 'Add',
              child: const Icon(Icons.add),
            ),
            Oito2OptionButton.color(
              onPressed: () {},
              color: const Color(0xFF3584E4),
              label: 'Blue',
            ),
          ],
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(Oito2OptionButton).first),
      const Size.square(Oito2Sizes.buttonHeight),
    );
    expect(find.bySemanticsLabel('Blue'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    expect(taps, 1);
  });

  testWidgets('Oito2ColorDisk rings itself in its color when selected', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    const yellow = Color(0xFFF8E45C);
    await pumpOito2(
      tester,
      Center(
        child: Oito2ColorDisk(
          color: yellow,
          selected: true,
          label: 'Yellow',
          onPressed: () => taps++,
        ),
      ),
    );
    expect(find.byIcon(LucideIcons.check), findsNothing);
    final ring = tester.widget<Container>(
      find.descendant(
        of: find.byType(Oito2ColorDisk),
        matching: find.byType(Container),
      ),
    );
    final border = (ring.decoration! as BoxDecoration).border! as Border;
    // Light yellow on a light surface is adjusted to stand out, keeping
    // its hue.
    final surface = Theme.of(tester.element(find.byType(Oito2ColorDisk)))
        .colorScheme
        .surface;
    expect(
      Oito2Contrast.ratio(border.top.color, surface),
      greaterThanOrEqualTo(Oito2Contrast.nonTextAA),
    );
    expect(
      HSLColor.fromColor(border.top.color).hue,
      closeTo(HSLColor.fromColor(yellow).hue, 1),
    );
    expect(tester.getSize(find.byType(Container).last).width, 28);
    expect(
      tester.getSemantics(find.byType(Oito2ColorDisk)),
      matchesSemantics(
        label: 'Yellow',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.byType(Oito2ColorDisk));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('Oito2ColorDisk keeps a contrasting color as is and '
      'reports when it is disabled', (tester) async {
    final handle = tester.ensureSemantics();
    const blue = Color(0xFF1A5FB4);
    await pumpOito2(
      tester,
      const Center(
        child: Oito2ColorDisk(
          color: blue,
          selected: true,
          label: 'Blue',
          onPressed: null,
        ),
      ),
    );
    final ring = tester.widget<Container>(
      find.descendant(
        of: find.byType(Oito2ColorDisk),
        matching: find.byType(Container),
      ),
    );
    final border = (ring.decoration! as BoxDecoration).border! as Border;
    expect(border.top.color, blue);
    expect(
      tester.getSemantics(find.byType(Oito2ColorDisk)),
      matchesSemantics(
        label: 'Blue',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('Oito2ColorDisk outlines only a color close to the surface', (
    tester,
  ) async {
    Border? outline(Color color) {
      final disk = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byKey(ValueKey(color)),
              matching: find.byType(DecoratedBox),
            )
            .last,
      );
      return (disk.decoration as BoxDecoration).border as Border?;
    }

    const white = Color(0xFFFFFFFF);
    const blue = Color(0xFF1A5FB4);
    await pumpOito2(
      tester,
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final color in [white, blue])
              Oito2ColorDisk(
                key: ValueKey(color),
                color: color,
                selected: false,
                label: 'Color',
                onPressed: () {},
              ),
          ],
        ),
      ),
    );
    final scheme = Theme.of(tester.element(find.byType(Row))).colorScheme;
    expect(outline(white)?.top.color, scheme.outlineVariant);
    expect(outline(blue), isNull);
  });

  group('Oito2ChoiceChipBar', () {
    final labels = [
      for (final name in [
        'All',
        'Audio',
        'Development',
        'Education',
        'Games',
        'Graphics',
        'Office',
        'Science',
      ])
        Text(name),
    ];

    testWidgets('chips follow the chip theme unless shaped; the check mark '
        'is optional', (tester) async {
      Widget bar({required bool check, OutlinedBorder? shape}) => SizedBox(
        width: 360,
        child: Oito2ChoiceChipBar(
          labels: labels,
          isSelected: [for (var i = 0; i < labels.length; i++) i == 0],
          onSelected: (_) {},
          showCheckmark: check,
          shape: shape,
        ),
      );
      await pumpOito2(tester, bar(check: true));
      final chip = tester.widget<ChoiceChip>(find.byType(ChoiceChip).first);
      // Without a shape, the chip theme's rounded rectangle applies.
      expect(chip.shape, isNull);
      final themed = ChipTheme.of(tester.element(find.byType(ChoiceChip).first))
          .shape;
      expect(
        (themed! as RoundedRectangleBorder).borderRadius,
        Oito2Radius.mediumAll,
      );
      expect(chip.showCheckmark, isTrue);
      await pumpOito2(tester, bar(check: true, shape: const StadiumBorder()));
      expect(
        tester.widget<ChoiceChip>(find.byType(ChoiceChip).first).shape,
        isA<StadiumBorder>(),
      );
      await pumpOito2(tester, bar(check: false));
      expect(
        tester.widget<ChoiceChip>(find.byType(ChoiceChip).first).showCheckmark,
        isFalse,
      );
    });

    testWidgets('selects chips and shows arrows only when overflowing', (
      tester,
    ) async {
      final selected = <int>[];
      await pumpOito2(
        tester,
        SizedBox(
          width: 360,
          child: Oito2ChoiceChipBar(
            labels: labels,
            isSelected: [for (var i = 0; i < labels.length; i++) i == 0],
            onSelected: selected.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Scroll back'), findsNothing);
      expect(find.byTooltip('Scroll forward'), findsOneWidget);

      await tester.tap(find.text('Audio'));
      expect(selected, [1]);

      await tester.tap(find.byTooltip('Scroll forward'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Scroll back'), findsOneWidget);
    });

    testWidgets('the wrap style lays all chips out', (tester) async {
      await pumpOito2(
        tester,
        SizedBox(
          width: 360,
          child: Oito2ChoiceChipBar(
            labels: labels,
            style: Oito2ChoiceChipBarStyle.wrap,
            isSelected: List.filled(labels.length, false),
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.byType(ChoiceChip), findsNWidgets(labels.length));
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byTooltip('Scroll forward'), findsNothing);
    });
  });

  group('Oito2PageIndicator', () {
    testWidgets('shows a dot per page and reports taps', (tester) async {
      final handle = tester.ensureSemantics();
      final taps = <int>[];
      await pumpOito2(
        tester,
        Center(child: Oito2PageIndicator(length: 5, page: 1, onTap: taps.add)),
      );
      expect(find.byType(AnimatedContainer), findsNWidgets(5));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Page 2 of 5')),
        matchesSemantics(
          label: 'Page 2 of 5',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(find.bySemanticsLabel('Page 4 of 5'));
      expect(taps, [3]);
      handle.dispose();
    });

    testWidgets('interactive dots are 24-pixel targets and take the keys', (
      tester,
    ) async {
      final taps = <int>[];
      await pumpOito2(
        tester,
        Center(child: Oito2PageIndicator(length: 5, page: 1, onTap: taps.add)),
      );
      final dots = find.descendant(
        of: find.byType(Oito2PageIndicator),
        matching: find.byType(GestureDetector),
      );
      expect(dots, findsNWidgets(5));
      for (var i = 0; i < 5; i++) {
        final size = tester.getSize(dots.at(i));
        expect(size.width, greaterThanOrEqualTo(24));
        expect(size.height, 24);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      expect(taps, [2, 0, 4, 0]);
    });

    testWidgets('falls back to text when the dots don\'t fit', (tester) async {
      await pumpOito2(
        tester,
        const Center(
          child: SizedBox(
            width: 80,
            child: Oito2PageIndicator(length: 30, page: 2),
          ),
        ),
      );
      expect(find.text('3 / 30'), findsOneWidget);
      expect(find.bySemanticsLabel('Page 3 of 30'), findsOneWidget);
    });

    testWidgets('shows the dots when they fit the width exactly', (
      tester,
    ) async {
      // A 24-pixel current pill, four 8-pixel dots and four 8-pixel gaps.
      await pumpOito2(
        tester,
        const Center(
          child: SizedBox(
            width: 88,
            child: Oito2PageIndicator(length: 5, page: 0),
          ),
        ),
      );
      expect(find.text('1 / 5'), findsNothing);
      expect(find.byType(AnimatedContainer), findsNWidgets(5));
    });

    testWidgets('minTargetSize shrinks the interactive targets', (
      tester,
    ) async {
      final taps = <int>[];
      await pumpOito2(
        tester,
        Center(
          child: Oito2PageIndicator(
            length: 5,
            page: 0,
            minTargetSize: 0,
            onTap: taps.add,
          ),
        ),
      );
      final dots = find.descendant(
        of: find.byType(Oito2PageIndicator),
        matching: find.byType(GestureDetector),
      );
      expect(tester.getSize(dots.at(0)), const Size(24, 8));
      expect(tester.getSize(dots.at(1)), const Size(8, 8));
      expect(
        tester
            .widget<Row>(
              find.descendant(
                of: find.byType(Oito2PageIndicator),
                matching: find.byType(Row),
              ),
            )
            .spacing,
        8,
      );
      await tester.tap(dots.at(2));
      expect(taps, [2]);
    });
  });
}
