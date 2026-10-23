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

@Tags(['golden'])
library;

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

/// A wavy stroke across [width] pixels around the height [y].
List<Oito2SignaturePoint> _wave(double width, double y) => [
  for (var x = 20.0; x < width - 20; x += 6)
    (
      position: Offset(x, y + math.sin(x / 18) * 18),
      width: 1.6 + (math.cos(x / 30) + 1),
    ),
];

class _ExtrasScene extends StatelessWidget {
  const _ExtrasScene({required this.signature});

  final Oito2SignatureController signature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.lg,
          children: [
            Oito2NavigationMenu(
              selectedIndex: 1,
              items: [
                Oito2NavigationMenuItem(
                  label: 'Products',
                  panelBuilder: (_) => const Text('Panel'),
                ),
                Oito2NavigationMenuItem(label: 'Docs', onPressed: () {}),
                Oito2NavigationMenuItem(label: 'Blog', onPressed: () {}),
              ],
            ),
            const Row(
              spacing: Oito2Spacing.lg,
              children: [
                Oito2QrCode(
                  data: 'https://oito2.github.io/oito2_ui/',
                  size: 120,
                ),
                Oito2QrCode(
                  data: 'https://oito2.github.io/oito2_ui/',
                  size: 120,
                  roundedModules: true,
                  errorLevel: Oito2QrErrorLevel.high,
                ),
              ],
            ),
            SizedBox(
              width: 420,
              child: Oito2SignaturePad(controller: signature, height: 140),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  const linux = Oito2Platform(
    targetPlatform: TargetPlatform.linux,
    isWeb: false,
  );
  final schemes = {
    'light': Oito2ColorTheme.light(),
    'dark': Oito2ColorTheme.dark(),
  };
  for (final MapEntry(key: name, value: colors) in schemes.entries) {
    testWidgets('extras in $name', (tester) async {
      tester.view.physicalSize = const Size(480, 420);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final signature = Oito2SignatureController()..addStroke(_wave(420, 70));
      addTearDown(signature.dispose);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Oito2Theme.fromColors(colors, platform: linux),
          home: RepaintBoundary(child: _ExtrasScene(signature: signature)),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/extras_$name.png'),
      );
    });
  }
}
