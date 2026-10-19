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

import 'fake_window_controller.dart';

void main() {
  test('Oito2WindowState defaults, copyWith and equality', () {
    const state = Oito2WindowState();
    expect(state.isMaximized, isFalse);
    expect(state.isFullScreen, isFalse);
    expect(state.isActive, isTrue);
    expect(state.canShowMenu, isFalse);
    final changed = state.copyWith(isMaximized: true, canShowMenu: true);
    expect(changed.isMaximized, isTrue);
    expect(changed.canShowMenu, isTrue);
    expect(changed, isNot(state));
    expect(changed.copyWith(), changed);
    expect(changed.copyWith().hashCode, changed.hashCode);
    expect(changed.toString(), contains('isMaximized: true'));
  });

  testWidgets('Oito2WindowScope provides its controller', (tester) async {
    final controller = FakeWindowController();
    Oito2WindowController? found;
    await tester.pumpWidget(
      Oito2WindowScope(
        controller: controller,
        child: Builder(
          builder: (context) {
            found = Oito2WindowScope.maybeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(found, same(controller));

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          found = Oito2WindowScope.maybeOf(context);
          return const SizedBox();
        },
      ),
    );
    expect(found, isNull);
  });

  group('Oito2TitleBarThemeData', () {
    const a = Oito2TitleBarThemeData(
      style: Oito2TitleBarStyle.normal,
      height: 40,
      backgroundColor: Color(0xFF000000),
      border: BorderSide(),
      centerTitle: true,
      inactiveOpacity: 0.5,
    );
    const b = Oito2TitleBarThemeData(
      style: Oito2TitleBarStyle.undecorated,
      height: 60,
      backgroundColor: Color(0xFFFFFFFF),
      border: BorderSide(width: 3),
      centerTitle: false,
      inactiveOpacity: 1,
    );

    test('copyWith and equality', () {
      expect(a.copyWith(), a);
      expect(a.copyWith(height: 50).height, 50);
      expect(a.hashCode, a.copyWith().hashCode);
      expect(a, isNot(b));
    });

    test('lerp interpolates numbers and colors and snaps enums', () {
      final mid = a.lerp(b, 0.5);
      expect(mid.height, 50);
      expect(mid.inactiveOpacity, 0.75);
      expect(mid.border!.width, 2);
      expect(a.lerp(b, 0.4).style, Oito2TitleBarStyle.normal);
      expect(a.lerp(b, 0.6).style, Oito2TitleBarStyle.undecorated);
      expect(a.lerp(null, 0.5), a);
    });

    testWidgets('of falls back to an empty theme', (tester) async {
      late Oito2TitleBarThemeData found;
      await tester.pumpWidget(
        Theme(
          data: ThemeData(),
          child: Builder(
            builder: (context) {
              found = Oito2TitleBarThemeData.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(found, const Oito2TitleBarThemeData());
    });

    test('Oito2Theme provides a title bar theme', () {
      const linux = Oito2Platform(
        targetPlatform: TargetPlatform.linux,
        isWeb: false,
      );
      const windows = Oito2Platform(
        targetPlatform: TargetPlatform.windows,
        isWeb: false,
      );
      final colors = Oito2ColorTheme.dark();
      final theme = Oito2Theme.fromColors(
        colors,
        platform: linux,
      ).extension<Oito2TitleBarThemeData>()!;
      expect(theme.backgroundColor, colors.chrome.titleBar);
      expect(theme.height, Oito2Sizes.titleBarHeight);
      expect(theme.centerTitle, isTrue);
      expect(
        Oito2Theme.fromColors(
          colors,
          platform: windows,
        ).extension<Oito2TitleBarThemeData>()!.centerTitle,
        isFalse,
      );
    });
  });
}
