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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/src/widgets/anchored_panel.dart';

const _panelKey = Key('panel');

/// Lays out a 100 by 50 panel next to [anchor] in a 400 by 400 area, over
/// a background that counts taps.
Future<List<String>> _pump(
  WidgetTester tester, {
  required Rect anchor,
  Oito2PopoverPlacement placement = Oito2PopoverPlacement.bottom,
  Oito2PopoverAlignment alignment = Oito2PopoverAlignment.center,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  final taps = <String>[];
  await tester.pumpWidget(
    Directionality(
      textDirection: textDirection,
      child: Center(
        child: SizedBox.square(
          dimension: 400,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => taps.add('background'),
                ),
              ),
              Positioned.fill(
                child: AnchoredPanel(
                  anchor: anchor,
                  placement: placement,
                  alignment: alignment,
                  textDirection: textDirection,
                  color: const Color(0xFFFFFFFF),
                  borderColor: const Color(0xFF888888),
                  shadowColor: const Color(0xFF000000),
                  arrowSize: const Size(14, 7),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => taps.add('panel'),
                    child: const SizedBox(
                      key: _panelKey,
                      width: 100,
                      height: 50,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return taps;
}

/// The panel content's rectangle, relative to the 400 by 400 area.
Rect _panel(WidgetTester tester) {
  final area = tester.getTopLeft(find.byType(Stack));
  return tester.getRect(find.byKey(_panelKey)).shift(-area);
}

void main() {
  testWidgets('sits below the anchor, centered on it', (tester) async {
    const anchor = Rect.fromLTWH(150, 100, 100, 30);
    await _pump(tester, anchor: anchor);
    final panel = _panel(tester);
    expect(panel.top, greaterThan(anchor.bottom));
    expect(panel.center.dx, closeTo(anchor.center.dx, 0.5));
  });

  testWidgets('moves above when the room below runs out', (tester) async {
    const anchor = Rect.fromLTWH(150, 360, 100, 30);
    await _pump(tester, anchor: anchor);
    expect(_panel(tester).bottom, lessThan(anchor.top));
  });

  testWidgets('stays inside the area with its margin', (tester) async {
    const anchor = Rect.fromLTWH(370, 100, 30, 30);
    await _pump(tester, anchor: anchor);
    expect(_panel(tester).right, lessThanOrEqualTo(400 - 8));
  });

  testWidgets('start follows the reading direction', (tester) async {
    const anchor = Rect.fromLTWH(150, 150, 100, 30);
    await _pump(
      tester,
      anchor: anchor,
      placement: Oito2PopoverPlacement.start,
      textDirection: TextDirection.rtl,
    );
    expect(_panel(tester).left, greaterThan(anchor.right));
  });

  testWidgets('taps outside the panel reach what is below', (tester) async {
    const anchor = Rect.fromLTWH(150, 100, 100, 30);
    final taps = await _pump(tester, anchor: anchor);
    await tester.tap(find.byKey(_panelKey));
    final area = tester.getTopLeft(find.byType(Stack));
    await tester.tapAt(area + const Offset(20, 380));
    expect(taps, ['panel', 'background']);
  });
}
