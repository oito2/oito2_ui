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

import '../support/sample_roles.dart';

/// The border side of the first [Material] under [finder].
BorderSide _side(WidgetTester tester, Finder finder) {
  final material = tester.widget<Material>(
    find.descendant(of: finder, matching: find.byType(Material)).first,
  );
  return (material.shape! as RoundedRectangleBorder).side;
}

void main() {
  final colors = Oito2ColorTheme.light();

  group('Oito2SelectableContainer', () {
    testWidgets('changes at once when animations are disabled', (tester) async {
      await pumpOito2(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Center(
            child: Oito2SelectableContainer(
              selected: true,
              onTap: () {},
              child: const Text('Dark'),
            ),
          ),
        ),
      );
      expect(
        tester
            .widget<AnimatedContainer>(
              find.descendant(
                of: find.byType(Oito2SelectableContainer),
                matching: find.byType(AnimatedContainer),
              ),
            )
            .duration,
        Duration.zero,
      );
    });

    testWidgets('shows the selection border and exposes it', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpOito2(
        tester,
        Center(
          child: Oito2SelectableContainer(
            selected: true,
            onTap: () => taps++,
            child: const Text('Dark'),
          ),
        ),
      );
      final side = _side(tester, find.byType(Oito2SelectableContainer));
      expect(side.color, colors.semantic.primaryText);
      expect(side.width, Oito2Sizes.focusBorderWidth);
      expect(
        tester.getSemantics(find.byType(Oito2SelectableContainer)),
        matchesSemantics(
          isSelected: true,
          hasSelectedState: true,
          isButton: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
          label: 'Dark',
        ),
      );
      await tester.tap(find.text('Dark'));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('shows a focus ring with the keyboard', (tester) async {
      await pumpOito2(
        tester,
        Center(
          child: Oito2SelectableContainer(
            selected: false,
            onTap: () {},
            child: const Text('Light'),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final ring = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final border = (ring.decoration! as BoxDecoration).border! as Border;
      expect(border.top.color, colors.semantic.primaryText);
    });
  });

  testWidgets('Oito2Banner.tile lays out its parts and reports hovering', (
    tester,
  ) async {
    final hovers = <bool>[];
    await pumpOito2(
      tester,
      Center(
        child: SizedBox(
          width: 320,
          child: Oito2Banner.tile(
            icon: const Icon(LucideIcons.sun, size: 48),
            title: const Text('Weather'),
            subtitle: const Text('Sunny all week'),
            tint: const Color(0xFFE91E63),
            onHover: hovers.add,
          ),
        ),
      ),
    );
    final icon = tester.getRect(find.byType(Icon));
    expect(icon.right, lessThan(tester.getRect(find.text('Weather')).left));
    expect(
      tester.getRect(find.text('Sunny all week')).top,
      greaterThan(tester.getRect(find.text('Weather')).bottom),
    );
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(Oito2Banner),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, isNot(colors.colorScheme.surface));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Weather')));
    await tester.pump();
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(hovers, [true, false]);
  });

  testWidgets('Oito2Banner strengthens its border on hover', (tester) async {
    await pumpOito2(
      tester,
      Center(
        child: SizedBox(
          width: 200,
          child: Oito2Banner(onTap: () {}, child: const Text('App')),
        ),
      ),
    );
    expect(
      _side(tester, find.byType(Oito2Banner)).color,
      colors.colorScheme.outlineVariant,
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('App')));
    await tester.pumpAndSettle();
    expect(
      _side(tester, find.byType(Oito2Banner)).color,
      colors.colorScheme.outline,
    );
  });

  group('info', () {
    testWidgets('a box names its kind to assistive technologies', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpOito2(
        tester,
        const Oito2InfoBox(
          type: Oito2InfoType.warning,
          title: Text('Battery low'),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Warning')), findsOneWidget);
      handle.dispose();
    });

    final schemes = {
      'light': Oito2ColorTheme.light(),
      'dark': Oito2ColorTheme.dark(),
      for (final MapEntry(key: name, value: roles) in sampleRoles.entries)
        name: Oito2ColorTheme.fromRoles(roles),
    };
    for (final MapEntry(key: name, value: scheme) in schemes.entries) {
      for (final type in Oito2InfoType.values) {
        testWidgets('${type.name} box title is readable in $name', (
          tester,
        ) async {
          await pumpOito2(
            tester,
            Oito2InfoBox(
              type: type,
              title: const Text('Title'),
              subtitle: const Text('Body'),
            ),
            colors: scheme,
          );
          final container = tester.widget<Container>(
            find
                .descendant(
                  of: find.byType(Oito2InfoBox),
                  matching: find.byType(Container),
                )
                .first,
          );
          final background = (container.decoration! as BoxDecoration).color!;
          final title = DefaultTextStyle.of(tester.element(find.text('Title')))
              .style
              .color!;
          final body = DefaultTextStyle.of(tester.element(find.text('Body')))
              .style
              .color!;
          expect(
            Oito2Contrast.ratio(title, background),
            greaterThanOrEqualTo(Oito2Contrast.textAA),
          );
          expect(
            Oito2Contrast.ratio(body, background),
            greaterThanOrEqualTo(Oito2Contrast.textAA),
          );
          expect(find.byIcon(type.icon), findsOneWidget);
        });
      }
    }

    testWidgets('Oito2InfoBadge is readable on its tint', (tester) async {
      await pumpOito2(
        tester,
        const Center(
          child: Oito2InfoBadge(
            type: Oito2InfoType.warning,
            label: Text('Beta'),
          ),
        ),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Oito2InfoBadge),
          matching: find.byType(Container),
        ),
      );
      final background = (container.decoration! as ShapeDecoration).color!;
      final label = DefaultTextStyle.of(tester.element(find.text('Beta')))
          .style
          .color!;
      expect(
        Oito2Contrast.ratio(label, background),
        greaterThanOrEqualTo(Oito2Contrast.textAA),
      );
    });

    test('every type maps to its semantic color', () {
      final semantic = colors.semantic;
      expect(Oito2InfoType.information.colorIn(semantic), semantic.info);
      expect(Oito2InfoType.success.colorIn(semantic), semantic.success);
      expect(Oito2InfoType.warning.colorIn(semantic), semantic.warning);
      expect(Oito2InfoType.danger.colorIn(semantic), semantic.errorText);
      expect(Oito2InfoType.important.colorIn(semantic), semantic.primaryText);
    });
  });

  group('Oito2Expandable', () {
    testWidgets('toggles its content from the header', (tester) async {
      final handle = tester.ensureSemantics();
      final changes = <bool>[];
      var expanded = false;
      await pumpOito2(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Oito2Expandable(
            header: const Text('Advanced'),
            collapsedChild: const Text('summary'),
            isExpanded: expanded,
            onChanged: (value) {
              changes.add(value);
              setState(() => expanded = value);
            },
            child: const Text('details'),
          ),
        ),
      );
      expect(find.text('details'), findsNothing);
      expect(find.text('summary'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Advanced')),
        matchesSemantics(
          label: 'Advanced',
          isButton: true,
          hasExpandedState: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      expect(find.text('details'), findsOneWidget);
      expect(find.text('summary'), findsNothing);
      expect(changes, [true]);
      expect(
        tester.getSemantics(find.text('Advanced')),
        matchesSemantics(
          label: 'Advanced',
          isButton: true,
          hasExpandedState: true,
          isExpanded: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      expect(find.text('details'), findsNothing);
      expect(changes, [true, false]);
      handle.dispose();
    });

    testWidgets('follows isExpanded when controlled', (tester) async {
      Widget build(bool expanded) => Oito2Expandable(
        header: const Text('Advanced'),
        isExpanded: expanded,
        child: const Text('details'),
      );
      await pumpOito2(tester, build(false));
      expect(find.text('details'), findsNothing);
      await pumpOito2(tester, build(true));
      await tester.pumpAndSettle();
      expect(find.text('details'), findsOneWidget);
    });

    testWidgets('a controlled section waits for the parent', (tester) async {
      final changes = <bool>[];
      await pumpOito2(
        tester,
        Oito2Expandable(
          header: const Text('Advanced'),
          onChanged: changes.add,
          child: const Text('details'),
        ),
      );
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      expect(changes, [true]);
      expect(find.text('details'), findsNothing);
    });

    testWidgets('opens at once when animations are disabled', (tester) async {
      await pumpOito2(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Oito2Expandable(
            header: Text('Advanced'),
            child: Text('details'),
          ),
        ),
      );
      expect(find.text('details').hitTestable(), findsNothing);
      await tester.tap(find.text('Advanced'));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      // A single frame is enough to show the content.
      expect(find.text('details').hitTestable(), findsOneWidget);
    });

    testWidgets('an uncontrolled section toggles itself', (tester) async {
      await pumpOito2(
        tester,
        const Oito2Expandable(header: Text('Advanced'), child: Text('details')),
      );
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      expect(find.text('details'), findsOneWidget);
    });

    testWidgets('can place the button at the start', (tester) async {
      await pumpOito2(
        tester,
        const Oito2Expandable(
          header: Text('Advanced'),
          buttonPosition: Oito2ExpandButtonPosition.start,
          child: Text('details'),
        ),
      );
      final icon = tester.getCenter(find.byType(Icon));
      final header = tester.getCenter(find.text('Advanced'));
      expect(icon.dx, lessThan(header.dx));
    });
  });
}
