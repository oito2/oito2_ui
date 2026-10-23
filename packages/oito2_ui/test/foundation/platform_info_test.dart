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

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

void main() {
  const desktop = [
    TargetPlatform.linux,
    TargetPlatform.windows,
    TargetPlatform.macOS,
  ];
  const touch = [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.fuchsia,
  ];

  group('native desktop', () {
    for (final target in desktop) {
      test(target.name, () {
        final platform = Oito2Platform(targetPlatform: target, isWeb: false);
        expect(platform.isDesktopNative, isTrue);
        expect(platform.isTouch, isFalse);
        expect(platform.isWebTouch, isFalse);
        expect(platform.usesTouchInput, isFalse);
        expect(platform.visualDensity, VisualDensity.comfortable);
      });
    }
  });

  group('native touch', () {
    for (final target in touch) {
      test(target.name, () {
        final platform = Oito2Platform(targetPlatform: target, isWeb: false);
        expect(platform.isDesktopNative, isFalse);
        expect(platform.isTouch, isTrue);
        expect(platform.isWebTouch, isFalse);
        expect(platform.usesTouchInput, isTrue);
        expect(platform.visualDensity, VisualDensity.standard);
      });
    }
  });

  group('web on a desktop host', () {
    for (final target in desktop) {
      test(target.name, () {
        final platform = Oito2Platform(targetPlatform: target, isWeb: true);
        expect(platform.isDesktopNative, isFalse);
        expect(platform.isTouch, isFalse);
        expect(platform.isWebTouch, isFalse);
        expect(platform.visualDensity, VisualDensity.comfortable);
      });
    }
  });

  group('web on a touch host', () {
    for (final target in touch) {
      test(target.name, () {
        final platform = Oito2Platform(targetPlatform: target, isWeb: true);
        expect(platform.isDesktopNative, isFalse);
        expect(platform.isTouch, isFalse);
        expect(platform.isWebTouch, isTrue);
        expect(platform.usesTouchInput, isTrue);
        expect(platform.visualDensity, VisualDensity.standard);
      });
    }
  });

  test('operating system getters match the target platform', () {
    Oito2Platform of(TargetPlatform t) =>
        Oito2Platform(targetPlatform: t, isWeb: false);
    expect(of(TargetPlatform.linux).isLinux, isTrue);
    expect(of(TargetPlatform.windows).isWindows, isTrue);
    expect(of(TargetPlatform.macOS).isMacOS, isTrue);
    expect(of(TargetPlatform.android).isAndroid, isTrue);
    expect(of(TargetPlatform.iOS).isIOS, isTrue);
    expect(of(TargetPlatform.linux).isWindows, isFalse);
  });

  test('current() honors the target platform override', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final platform = Oito2Platform.current();
    expect(platform.targetPlatform, TargetPlatform.windows);
    expect(platform.isWeb, kIsWeb);
  });

  test('equality, hashCode and copyWith', () {
    const a = Oito2Platform(targetPlatform: TargetPlatform.linux, isWeb: false);
    const b = Oito2Platform(targetPlatform: TargetPlatform.linux, isWeb: false);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a.copyWith(isWeb: true), isNot(a));
    expect(
      a.copyWith(targetPlatform: TargetPlatform.android).targetPlatform,
      TargetPlatform.android,
    );
  });
}
