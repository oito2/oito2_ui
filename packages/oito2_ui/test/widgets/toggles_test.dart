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

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// Pumps [builder] with a value that the built widget updates through the
/// given setter.
Future<void> _pumpStateful<T>(
  WidgetTester tester,
  T initial,
  Widget Function(T value, ValueChanged<T> set) builder, {
  TextDirection textDirection = TextDirection.ltr,
}) {
  var value = initial;
  return pumpOito2(
    tester,
    StatefulBuilder(
      builder: (context, setState) =>
          Center(child: builder(value, (v) => setState(() => value = v))),
    ),
    textDirection: textDirection,
  );
}

/// The semantics node of the toggle found by [finder], which sits on its
/// painted content.
SemanticsNode _semanticsOf(WidgetTester tester, Finder finder) =>
    tester.getSemantics(
      find.descendant(of: finder, matching: find.byType(CustomPaint)).first,
    );

void main() {
  group('Oito2Checkbox', () {
    testWidgets('a tap toggles it', (tester) async {
      final values = <bool?>[];
      await pumpOito2(
        tester,
        Center(child: Oito2Checkbox(value: false, onChanged: values.add)),
      );
      await tester.tap(find.byType(Oito2Checkbox));
      expect(values, [true]);
    });

    testWidgets('the checked node also carries the tap action', (tester) async {
      final handle = tester.ensureSemantics();
      final values = <bool?>[];
      await pumpOito2(
        tester,
        Center(
          child: Oito2Checkbox(
            value: false,
            onChanged: values.add,
            semanticLabel: 'Wi-Fi',
          ),
        ),
      );
      final node = _semanticsOf(tester, find.byType(Oito2Checkbox));
      expect(
        node,
        isSemantics(
          label: 'Wi-Fi',
          hasCheckedState: true,
          isChecked: false,
          hasTapAction: true,
        ),
      );
      tester.semantics.tap(find.semantics.byLabel('Wi-Fi'));
      expect(values, [true]);
      handle.dispose();
    });

    testWidgets('a tristate box cycles unchecked, checked, mixed', (
      tester,
    ) async {
      final seen = <bool?>[];
      await _pumpStateful<bool?>(
        tester,
        false,
        (value, set) => Oito2Checkbox(
          value: value,
          tristate: true,
          onChanged: (v) {
            seen.add(v);
            set(v);
          },
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(Oito2Checkbox));
        await tester.pumpAndSettle();
      }
      expect(seen, [true, null, false]);
    });

    testWidgets('a disabled box ignores taps and keys', (tester) async {
      await pumpOito2(
        tester,
        const Center(child: Oito2Checkbox(value: false, onChanged: null)),
      );
      await tester.tap(find.byType(Oito2Checkbox));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(tester.takeException(), isNull);
      expect(
        _semanticsOf(tester, find.byType(Oito2Checkbox)),
        isSemantics(
          hasCheckedState: true,
          isChecked: false,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
    });

    testWidgets('exposes checked and mixed states', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: Column(
            children: [
              Oito2Checkbox(value: true, onChanged: (_) {}),
              Oito2Checkbox(value: null, tristate: true, onChanged: (_) {}),
            ],
          ),
        ),
      );
      final boxes = find.byType(Oito2Checkbox);
      expect(
        _semanticsOf(tester, boxes.first),
        isSemantics(hasCheckedState: true, isChecked: true),
      );
      expect(
        _semanticsOf(tester, boxes.last),
        isSemantics(hasCheckedState: true, isCheckStateMixed: true),
      );
    });

    testWidgets('Space toggles the focused box', (tester) async {
      final values = <bool?>[];
      await pumpOito2(
        tester,
        Center(
          child: Oito2Checkbox(
            value: false,
            autofocus: true,
            onChanged: values.add,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(values, [true]);
    });

    testWidgets('is 34 px on pointer and 48 px on touch platforms', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        Center(child: Oito2Checkbox(value: false, onChanged: (_) {})),
      );
      expect(tester.getSize(find.byType(Oito2Checkbox)).height, 34);

      await tester.pumpWidget(
        MaterialApp(
          theme: Oito2Theme.light(
            platform: const Oito2Platform(
              targetPlatform: TargetPlatform.android,
              isWeb: false,
            ),
          ),
          home: Center(child: Oito2Checkbox(value: false, onChanged: (_) {})),
        ),
      );
      // The app animates from the previous theme.
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Oito2Checkbox)).height, 48);
    });

    testWidgets('jumps to the new state when animations are disabled', (
      tester,
    ) async {
      await _pumpStateful<bool?>(
        tester,
        false,
        (value, set) => MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Oito2Checkbox(value: value, onChanged: set),
        ),
      );
      await tester.tap(find.byType(Oito2Checkbox));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('Oito2Radio', () {
    testWidgets('a tap selects its value', (tester) async {
      final values = <String?>[];
      await pumpOito2(
        tester,
        Center(
          child: Oito2Radio<String>(
            value: 'b',
            groupValue: 'a',
            onChanged: values.add,
          ),
        ),
      );
      await tester.tap(find.byType(Oito2Radio<String>));
      expect(values, ['b']);
    });

    testWidgets('a selected radio ignores taps unless toggleable', (
      tester,
    ) async {
      final values = <String?>[];
      await pumpOito2(
        tester,
        Center(
          child: Column(
            children: [
              Oito2Radio<String>(
                value: 'a',
                groupValue: 'a',
                onChanged: values.add,
              ),
              Oito2Radio<String>(
                value: 'a',
                groupValue: 'a',
                toggleable: true,
                onChanged: values.add,
              ),
            ],
          ),
        ),
      );
      final radios = find.byType(Oito2Radio<String>);
      await tester.tap(radios.first);
      await tester.tap(radios.last);
      expect(values, [null]);
    });

    testWidgets('reads as a selected member of an exclusive group', (
      tester,
    ) async {
      await pumpOito2(
        tester,
        Center(
          child: Oito2Radio<int>(value: 1, groupValue: 1, onChanged: (_) {}),
        ),
      );
      expect(
        _semanticsOf(tester, find.byType(Oito2Radio<int>)),
        isSemantics(
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
    });
  });

  group('Oito2Switch', () {
    testWidgets('a tap and Enter toggle it', (tester) async {
      final seen = <bool>[];
      await _pumpStateful<bool>(
        tester,
        false,
        (value, set) => Oito2Switch(
          value: value,
          autofocus: true,
          onChanged: (v) {
            seen.add(v);
            set(v);
          },
        ),
      );
      await tester.tap(find.byType(Oito2Switch));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(seen, [true, false]);
    });

    testWidgets('exposes its toggled state', (tester) async {
      await pumpOito2(
        tester,
        Center(child: Oito2Switch(value: true, onChanged: (_) {})),
      );
      expect(
        _semanticsOf(tester, find.byType(Oito2Switch)),
        isSemantics(hasToggledState: true, isToggled: true),
      );
    });

    testWidgets('fits the control height on pointer platforms', (tester) async {
      await pumpOito2(
        tester,
        Center(child: Oito2Switch(value: false, onChanged: (_) {})),
      );
      expect(tester.getSize(find.byType(Oito2Switch)), const Size(50, 34));
    });
  });

  group('Oito2ToggleButton', () {
    testWidgets('the row is one focus stop and Space toggles it', (
      tester,
    ) async {
      var toggles = 0;
      await pumpOito2(
        tester,
        Center(
          child: Oito2ToggleButton(
            control: Oito2Checkbox(value: false, onChanged: (_) {}),
            title: const Text('Show hidden files'),
            onToggled: () => toggles++,
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(toggles, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<Oito2Checkbox>(),
        isNull,
      );
    });

    testWidgets('tapping the label activates it', (tester) async {
      var toggles = 0;
      await pumpOito2(
        tester,
        Center(
          child: Oito2ToggleButton(
            control: Oito2Switch(value: false, onChanged: (_) {}),
            controlAtEnd: true,
            title: const Text('Dark style'),
            onToggled: () => toggles++,
          ),
        ),
      );
      await tester.tap(find.text('Dark style'));
      expect(toggles, 1);
    });
  });

  group('toggle list tiles', () {
    testWidgets('tapping the tile toggles the check box', (tester) async {
      final values = <bool?>[];
      await pumpOito2(
        tester,
        Oito2CheckboxListTile(
          value: false,
          onChanged: values.add,
          title: const Text('Wi-Fi'),
        ),
      );
      await tester.tap(find.text('Wi-Fi'));
      expect(values, [true]);
      final checkbox = tester.getCenter(find.byType(Oito2Checkbox));
      expect(checkbox.dx, lessThan(tester.getCenter(find.text('Wi-Fi')).dx));
    });

    testWidgets('a radio tile selects its value', (tester) async {
      final values = <int?>[];
      await pumpOito2(
        tester,
        Oito2RadioListTile<int>(
          value: 2,
          groupValue: 1,
          onChanged: values.add,
          title: const Text('Two'),
        ),
      );
      await tester.tap(find.text('Two'));
      expect(values, [2]);
    });

    testWidgets('a switch tile puts the switch at the end by default', (
      tester,
    ) async {
      final values = <bool>[];
      await pumpOito2(
        tester,
        Column(
          children: [
            Oito2SwitchListTile(
              value: false,
              onChanged: values.add,
              title: const Text('Bluetooth'),
            ),
            Oito2SwitchListTile(
              value: false,
              onChanged: values.add,
              controlAffinity: Oito2ControlAffinity.leading,
              title: const Text('Airplane mode'),
            ),
          ],
        ),
      );
      final switches = find.byType(Oito2Switch);
      expect(
        tester.getCenter(switches.first).dx,
        greaterThan(tester.getCenter(find.text('Bluetooth')).dx),
      );
      expect(
        tester.getCenter(switches.last).dx,
        lessThan(tester.getCenter(find.text('Airplane mode')).dx),
      );
      await tester.tap(find.text('Bluetooth'));
      expect(values, [true]);
    });

    testWidgets('a disabled tile ignores taps', (tester) async {
      await pumpOito2(
        tester,
        const Oito2SwitchListTile(
          value: false,
          onChanged: null,
          title: Text('Unavailable'),
        ),
      );
      await tester.tap(find.text('Unavailable'));
      expect(tester.takeException(), isNull);
    });
  });
}
