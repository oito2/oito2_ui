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

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

Widget _host(Widget child) => MaterialApp(
  theme: Oito2Theme.light(
    platform: const Oito2Platform(
      targetPlatform: TargetPlatform.linux,
      isWeb: false,
    ),
  ),
  home: Scaffold(body: Center(child: child)),
);

ShapeDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(Oito2WindowControl),
      matching: find.byType(Container),
    ),
  );
  return container.decoration! as ShapeDecoration;
}

void main() {
  const drawn = [
    Oito2WindowControlStyle.gnome,
    Oito2WindowControlStyle.breeze,
    Oito2WindowControlStyle.xfwm,
    Oito2WindowControlStyle.cosmic,
    Oito2WindowControlStyle.windows,
    Oito2WindowControlStyle.macos,
  ];

  for (final style in drawn) {
    for (final type in Oito2WindowControlType.values) {
      testWidgets('${style.name} ${type.name} renders and reacts to taps', (
        tester,
      ) async {
        var taps = 0;
        await tester.pumpWidget(
          _host(
            Oito2WindowControl(
              type: type,
              style: style,
              onPressed: () => taps++,
            ),
          ),
        );
        expect(
          tester.getSize(find.byType(Oito2WindowControl)).width,
          Oito2WindowControl.widthFor(style, Oito2Sizes.titleBarHeight),
        );
        await tester.tap(find.byType(Oito2WindowControl));
        expect(taps, 1);
      });
    }
  }

  testWidgets('none renders nothing', (tester) async {
    await tester.pumpWidget(
      _host(
        Oito2WindowControl(
          type: Oito2WindowControlType.close,
          style: Oito2WindowControlStyle.none,
          onPressed: () {},
        ),
      ),
    );
    expect(tester.getSize(find.byType(Oito2WindowControl)), Size.zero);
  });

  testWidgets('Windows buttons fill the title bar height', (tester) async {
    await tester.pumpWidget(
      _host(
        Oito2WindowControl(
          type: Oito2WindowControlType.minimize,
          style: Oito2WindowControlStyle.windows,
          onPressed: () {},
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(Oito2WindowControl)),
      const Size(
        Oito2Sizes.windowsWindowControlWidth,
        Oito2Sizes.titleBarHeight,
      ),
    );
  });

  for (final style in [
    Oito2WindowControlStyle.windows,
    Oito2WindowControlStyle.breeze,
  ]) {
    testWidgets('${style.name} close turns red on hover', (tester) async {
      await tester.pumpWidget(
        _host(
          Oito2WindowControl(
            type: Oito2WindowControlType.close,
            style: style,
            onPressed: () {},
          ),
        ),
      );
      final idle = _decoration(tester).color!;
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(Oito2WindowControl)));
      await tester.pump();
      final hovered = _decoration(tester).color!;
      expect(hovered, isNot(idle));
      expect(hovered.r, greaterThan(hovered.g + 0.3));
    });
  }

  testWidgets('exposes a button with its label and tap action', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      _host(
        Oito2WindowControl(
          type: Oito2WindowControlType.maximize,
          style: Oito2WindowControlStyle.gnome,
          label: 'Maximizar',
          onPressed: () => taps++,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(Oito2WindowControl)),
      matchesSemantics(
        label: 'Maximizar',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    tester.semantics.tap(find.semantics.byLabel('Maximizar'));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('a button without action is disabled', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const Oito2WindowControl(
          type: Oito2WindowControlType.close,
          style: Oito2WindowControlStyle.gnome,
          onPressed: null,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(Oito2WindowControl)),
      matchesSemantics(label: 'Close', isButton: true, hasEnabledState: true),
    );
    handle.dispose();
  });

  test('labels return only the given overrides', () {
    const labels = Oito2WindowControlLabels(close: 'Shut');
    expect(labels.of(Oito2WindowControlType.close), 'Shut');
    expect(labels.of(Oito2WindowControlType.minimize), isNull);
    expect(labels.of(Oito2WindowControlType.maximize), isNull);
    expect(labels.of(Oito2WindowControlType.restore), isNull);
  });

  testWidgets('resolve falls back to the localized strings', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('pt', 'BR'),
        delegates: const [
          Oito2Localizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    const labels = Oito2WindowControlLabels(close: 'Shut');
    String resolve(Oito2WindowControlType type) =>
        Oito2WindowControlLabels.resolve(context, type, labels);
    expect(resolve(Oito2WindowControlType.close), 'Shut');
    expect(resolve(Oito2WindowControlType.minimize), 'Minimizar');
    expect(resolve(Oito2WindowControlType.maximize), 'Maximizar');
    expect(resolve(Oito2WindowControlType.restore), 'Restaurar');
  });
}
