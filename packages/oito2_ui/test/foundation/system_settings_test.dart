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

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

const _linux = Oito2Platform(
  targetPlatform: TargetPlatform.linux,
  isWeb: false,
);

void main() {
  group('fallback', () {
    test('native Linux gets an unknown desktop environment', () {
      final settings = Oito2SystemSettings.fallback(_linux);
      expect(settings.desktopEnvironment, Oito2DesktopEnvironment.unknown);
      expect(settings.windowControlStyle, Oito2WindowControlStyle.gnome);
      expect(
        settings.windowButtonLayout,
        Oito2WindowButtonLayout.defaultFor(Oito2WindowControlStyle.gnome),
      );
      expect(settings.accentColor, isNull);
      expect(settings.highContrast, isFalse);
    });

    test('native Linux keeps a given desktop environment', () {
      final settings = Oito2SystemSettings.fallback(
        _linux,
        desktopEnvironment: Oito2DesktopEnvironment.kde,
      );
      expect(settings.desktopEnvironment, Oito2DesktopEnvironment.kde);
      expect(settings.windowControlStyle, Oito2WindowControlStyle.breeze);
    });

    test('other platforms have no desktop environment', () {
      for (final platform in const [
        Oito2Platform(targetPlatform: TargetPlatform.linux, isWeb: true),
        Oito2Platform(targetPlatform: TargetPlatform.windows, isWeb: false),
        Oito2Platform(targetPlatform: TargetPlatform.android, isWeb: false),
      ]) {
        final settings = Oito2SystemSettings.fallback(
          platform,
          desktopEnvironment: Oito2DesktopEnvironment.gnome,
        );
        expect(settings.desktopEnvironment, isNull, reason: '$platform');
      }
    });

    test('touch platforms have no window buttons', () {
      final settings = Oito2SystemSettings.fallback(
        const Oito2Platform(targetPlatform: TargetPlatform.iOS, isWeb: false),
      );
      expect(settings.windowControlStyle, Oito2WindowControlStyle.none);
      expect(settings.windowButtonLayout.isEmpty, isTrue);
    });
  });

  test('copyWith replaces fields and keeps the rest', () {
    final base = Oito2SystemSettings.fallback(_linux);
    final changed = base.copyWith(
      accentColor: Oito2AccentColor.green.color,
      highContrast: true,
    );
    expect(changed.accentColor, Oito2AccentColor.green.color);
    expect(changed.highContrast, isTrue);
    expect(changed.platform, base.platform);
    expect(changed, isNot(base));
    expect(changed.copyWith(), changed);
    expect(changed.copyWith().hashCode, changed.hashCode);
  });

  group('Oito2SystemScope', () {
    testWidgets('provides its settings to descendants', (tester) async {
      final settings = Oito2SystemSettings.fallback(
        _linux,
        desktopEnvironment: Oito2DesktopEnvironment.xfce,
      );
      late Oito2SystemSettings found;
      await tester.pumpWidget(
        Oito2SystemScope(
          settings: settings,
          child: Builder(
            builder: (context) {
              found = Oito2SystemScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(found, settings);
    });

    testWidgets('falls back to the current platform without a scope', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      Oito2SystemSettings? maybe;
      late Oito2SystemSettings found;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            maybe = Oito2SystemScope.maybeOf(context);
            found = Oito2SystemScope.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(maybe, isNull);
      expect(found.windowControlStyle, Oito2WindowControlStyle.windows);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('rebuilds dependents only when the settings change', (
      tester,
    ) async {
      var builds = 0;
      final child = Builder(
        builder: (context) {
          Oito2SystemScope.of(context);
          builds++;
          return const SizedBox();
        },
      );
      Widget scope(Oito2SystemSettings settings) =>
          Oito2SystemScope(settings: settings, child: child);

      final settings = Oito2SystemSettings.fallback(_linux);
      await tester.pumpWidget(scope(settings));
      await tester.pumpWidget(scope(settings.copyWith()));
      expect(builds, 1);

      await tester.pumpWidget(scope(settings.copyWith(highContrast: true)));
      expect(builds, 2);
    });
  });
}
