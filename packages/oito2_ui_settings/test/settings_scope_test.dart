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
}
