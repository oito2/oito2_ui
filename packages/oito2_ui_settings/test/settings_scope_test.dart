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

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_settings/oito2_ui_settings.dart';

import 'fakes.dart';

const _linux = Oito2Platform(
  targetPlatform: TargetPlatform.linux,
  isWeb: false,
);

void main() {
  testWidgets('starts with the initial settings and follows changes', (
    tester,
  ) async {
    final accent = FakeAccent(const Color(0xFF111111));
    final reader = Oito2SystemSettingsReader(
      platform: _linux,
      environment: const {'XDG_CURRENT_DESKTOP': 'KDE'},
      accent: accent,
      debounce: Duration.zero,
    );
    final initial = Oito2SystemSettings.fallback(_linux);
    Oito2SystemSettings? seen;

    await tester.pumpWidget(
      Oito2SystemSettingsScope(
        reader: reader,
        initialSettings: initial,
        child: Builder(
          builder: (context) {
            seen = Oito2SystemScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(seen, initial);

    await tester.pump();
    await tester.pump();
    expect(seen!.desktopEnvironment, Oito2DesktopEnvironment.kde);
    expect(seen!.accentColor, const Color(0xFF111111));

    accent.change(const Color(0xFF222222));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump();
    expect(seen!.accentColor, const Color(0xFF222222));
  });

  testWidgets('falls back to the platform settings without initial ones', (
    tester,
  ) async {
    final reader = Oito2SystemSettingsReader(platform: _linux);
    Oito2SystemSettings? seen;
    await tester.pumpWidget(
      Oito2SystemSettingsScope(
        reader: reader,
        child: Builder(
          builder: (context) {
            seen = Oito2SystemScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(seen, Oito2SystemSettings.fallback(_linux));
  });

  testWidgets('reads again when the platform brightness changes', (
    tester,
  ) async {
    const windows = Oito2Platform(
      targetPlatform: TargetPlatform.windows,
      isWeb: false,
    );
    final reader = Oito2SystemSettingsReader(
      platform: windows,
      platformBrightness: () => tester.platformDispatcher.platformBrightness,
      debounce: Duration.zero,
    );
    Oito2SystemSettings? seen;
    await tester.pumpWidget(
      Oito2SystemSettingsScope(
        reader: reader,
        child: Builder(
          builder: (context) {
            seen = Oito2SystemScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(seen!.colorScheme, Brightness.light);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pump();
    await tester.pump();
    expect(seen!.colorScheme, Brightness.dark);
  });

  test('Oito2Settings.reader targets the given platform', () {
    expect(Oito2Settings.reader(platform: _linux).platform, _linux);
  });

  testWidgets('leaves a reader it was given open', (tester) async {
    final gsettings = FakeGSettings();
    final reader = Oito2SystemSettingsReader(
      platform: _linux,
      environment: const {'XDG_CURRENT_DESKTOP': 'GNOME'},
      gsettings: gsettings,
      debounce: Duration.zero,
    );
    await tester.pumpWidget(
      Oito2SystemSettingsScope(reader: reader, child: const SizedBox()),
    );
    await tester.pumpWidget(const SizedBox());
    expect(gsettings.closed, isFalse);
  });

  testWidgets('follows a new reader', (tester) async {
    Oito2SystemSettingsReader reader(Color color) => Oito2SystemSettingsReader(
      platform: _linux,
      environment: const {'XDG_CURRENT_DESKTOP': 'KDE'},
      accent: FakeAccent(color),
      debounce: Duration.zero,
    );
    Oito2SystemSettings? seen;
    Widget build(Oito2SystemSettingsReader reader) => Oito2SystemSettingsScope(
      reader: reader,
      child: Builder(
        builder: (context) {
          seen = Oito2SystemScope.of(context);
          return const SizedBox();
        },
      ),
    );
    await tester.pumpWidget(build(reader(const Color(0xFF111111))));
    await tester.pump();
    await tester.pump();
    expect(seen!.accentColor, const Color(0xFF111111));
    await tester.pumpWidget(build(reader(const Color(0xFF222222))));
    await tester.pump();
    await tester.pump();
    expect(seen!.accentColor, const Color(0xFF222222));
  });

  group('media query', () {
    /// Pumps a scope over [reader] and returns a getter for the media query
    /// its child sees, after the first read.
    Future<MediaQueryData Function()> pumpScope(
      WidgetTester tester,
      Oito2SystemSettingsReader reader, {
      MediaQueryData Function(MediaQueryData)? override,
    }) async {
      late MediaQueryData seen;
      final Widget inner = Oito2SystemSettingsScope(
        reader: reader,
        child: Builder(
          builder: (context) {
            seen = MediaQuery.of(context);
            return const SizedBox();
          },
        ),
      );
      await tester.pumpWidget(
        override == null
            ? inner
            : Builder(
                builder: (context) => MediaQuery(
                  data: override(MediaQuery.of(context)),
                  child: inner,
                ),
              ),
      );
      await tester.pump();
      await tester.pump();
      return () => seen;
    }

    Oito2SystemSettingsReader reader(
      String desktop, {
      FakeGSettings? gsettings,
      FakeConfigFiles? files,
      FakeReducedMotion? reducedMotion,
    }) => Oito2SystemSettingsReader(
      platform: _linux,
      environment: {'XDG_CURRENT_DESKTOP': desktop},
      gsettings: gsettings ?? FakeGSettings(),
      configFiles: files ?? FakeConfigFiles(),
      reducedMotion: reducedMotion ?? FakeReducedMotion(),
      debounce: Duration.zero,
    );

    testWidgets('reduced motion disables animations and follows changes', (
      tester,
    ) async {
      final reducedMotion = FakeReducedMotion(true);
      final media = await pumpScope(
        tester,
        reader('XFCE', reducedMotion: reducedMotion),
      );
      expect(media().disableAnimations, isTrue);

      reducedMotion.change(false);
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump();
      expect(media().disableAnimations, isFalse);
    });

    testWidgets('never turns off animations the platform disabled', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final media = await pumpScope(
        tester,
        reader('XFCE', reducedMotion: FakeReducedMotion(false)),
      );
      expect(media().disableAnimations, isTrue);
    });

    testWidgets('replaces the text scale on desktops Flutter does not read', (
      tester,
    ) async {
      final files = FakeConfigFiles({
        'kcmfonts': '[General]\nforceFontDPI=144\n',
      });
      final media = await pumpScope(tester, reader('KDE', files: files));
      expect(media().textScaler, const TextScaler.linear(1.5));

      files.write('kcmfonts', '[General]\nforceFontDPI=120\n');
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump();
      expect(media().textScaler, const TextScaler.linear(1.25));
    });

    testWidgets('scales text once when Flutter reports a GNOME factor', (
      tester,
    ) async {
      // Flutter reads GNOME's text-scaling-factor on any desktop; the
      // desktop's own factor replaces it instead of multiplying it.
      tester.platformDispatcher.textScaleFactorTestValue = 1.25;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final gsettings = FakeGSettings({
        'org.cinnamon.desktop.interface/text-scaling-factor': 1.5,
      });
      final media = await pumpScope(
        tester,
        reader('X-Cinnamon', gsettings: gsettings),
      );
      expect(media().textScaler, const TextScaler.linear(1.5));
    });

    testWidgets('leaves the text scale Flutter applies on GNOME', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final gsettings = FakeGSettings({
        'org.gnome.desktop.interface/text-scaling-factor': 1.5,
      });
      final media = await pumpScope(
        tester,
        reader('GNOME', gsettings: gsettings),
      );
      expect(media().textScaler, isA<SystemTextScaler>());
      expect(media().textScaler.scale(10), 15);
    });

    testWidgets('leaves a text scaler an ancestor changed', (tester) async {
      final files = FakeConfigFiles({
        'kcmfonts': '[General]\nforceFontDPI=144\n',
      });
      final media = await pumpScope(
        tester,
        reader('KDE', files: files),
        override: (data) =>
            data.copyWith(textScaler: const TextScaler.linear(2)),
      );
      expect(media().textScaler, const TextScaler.linear(2));
    });

    testWidgets('keeps the state of its child when a preference changes', (
      tester,
    ) async {
      final reducedMotion = FakeReducedMotion(false);
      await tester.pumpWidget(
        Oito2SystemSettingsScope(
          reader: reader('XFCE', reducedMotion: reducedMotion),
          child: const _Counter(),
        ),
      );
      await tester.pump();
      final state = tester.state<_CounterState>(find.byType(_Counter));

      reducedMotion.change(true);
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump();
      expect(tester.state<_CounterState>(find.byType(_Counter)), same(state));
    });

    testWidgets('reads again when the platform text scale changes', (
      tester,
    ) async {
      const windows = Oito2Platform(
        targetPlatform: TargetPlatform.windows,
        isWeb: false,
      );
      Oito2SystemSettings? seen;
      await tester.pumpWidget(
        Oito2SystemSettingsScope(
          reader: Oito2SystemSettingsReader(
            platform: windows,
            platformTextScaleFactor: () =>
                tester.platformDispatcher.textScaleFactor,
            debounce: Duration.zero,
          ),
          child: Builder(
            builder: (context) {
              seen = Oito2SystemScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(seen!.textScaleFactor, 1.0);

      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pump();
      await tester.pump();
      expect(seen!.textScaleFactor, 1.5);
    });
  });
}

/// A stateful widget whose state identity tells whether it was rebuilt
/// from scratch.
class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}
