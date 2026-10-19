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
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'test_app.dart';

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
      await tester.tap(find.text('Locked'));
      expect(tester.takeException(), isNull);
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
    final control = tester.getCenter(find.byType(Switch));
    expect(label.dx, lessThan(control.dx));
    await tester.tap(find.text('Dark style'));
    await tester.pump();
    expect(value, isTrue);
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
      await tester.tap(find.byIcon(LucideIcons.chevronDown));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save as…'));
      await tester.pumpAndSettle();
      expect(item, 1);
      expect(find.bySemanticsLabel('More options'), findsOneWidget);
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

  testWidgets('Oito2ColorDisk shows a readable check when selected', (
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
    final check = tester.widget<Icon>(find.byIcon(LucideIcons.check));
    expect(check.color, const Color(0xFF000000));
    expect(
      tester.getSemantics(find.byType(Oito2ColorDisk)),
      matchesSemantics(
        label: 'Yellow',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.byType(Oito2ColorDisk));
    expect(taps, 1);
    handle.dispose();
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
  });
}
