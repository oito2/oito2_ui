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
import 'package:oito2_ui/oito2_ui.dart';

const _min = Oito2WindowButton.minimize;
const _max = Oito2WindowButton.maximize;
const _close = Oito2WindowButton.close;

void main() {
  group('Oito2WindowControlStyle.resolve', () {
    Oito2WindowControlStyle resolve(
      TargetPlatform target, {
      bool isWeb = false,
      Oito2DesktopEnvironment? environment,
    }) => Oito2WindowControlStyle.resolve(
      Oito2Platform(targetPlatform: target, isWeb: isWeb),
      desktopEnvironment: environment,
    );

    test('web and touch platforms have no window controls', () {
      expect(
        resolve(TargetPlatform.linux, isWeb: true),
        Oito2WindowControlStyle.none,
      );
      expect(resolve(TargetPlatform.android), Oito2WindowControlStyle.none);
      expect(resolve(TargetPlatform.iOS), Oito2WindowControlStyle.none);
    });

    test('Windows and macOS use their own styles', () {
      expect(resolve(TargetPlatform.windows), Oito2WindowControlStyle.windows);
      expect(resolve(TargetPlatform.macOS), Oito2WindowControlStyle.macos);
    });

    test('Linux follows the desktop environment', () {
      const cases = {
        Oito2DesktopEnvironment.kde: Oito2WindowControlStyle.breeze,
        Oito2DesktopEnvironment.xfce: Oito2WindowControlStyle.xfwm,
        Oito2DesktopEnvironment.cosmic: Oito2WindowControlStyle.cosmic,
        Oito2DesktopEnvironment.gnome: Oito2WindowControlStyle.gnome,
        Oito2DesktopEnvironment.budgie: Oito2WindowControlStyle.gnome,
        Oito2DesktopEnvironment.cinnamon: Oito2WindowControlStyle.gnome,
        Oito2DesktopEnvironment.lxqt: Oito2WindowControlStyle.gnome,
        Oito2DesktopEnvironment.unknown: Oito2WindowControlStyle.gnome,
      };
      cases.forEach((environment, style) {
        expect(
          resolve(TargetPlatform.linux, environment: environment),
          style,
          reason: environment.name,
        );
      });
      expect(resolve(TargetPlatform.linux), Oito2WindowControlStyle.gnome);
    });
  });

  group('parseGnome', () {
    test('reads leading and trailing sides', () {
      expect(
        Oito2WindowButtonLayout.parseGnome('appmenu:minimize,maximize,close'),
        const Oito2WindowButtonLayout(trailing: [_min, _max, _close]),
      );
      expect(
        Oito2WindowButtonLayout.parseGnome('close,minimize,maximize:'),
        const Oito2WindowButtonLayout(leading: [_close, _min, _max]),
      );
    });

    test('ignores unknown entries, spaces and duplicates', () {
      expect(
        Oito2WindowButtonLayout.parseGnome('icon, close:spacer,close,menu'),
        const Oito2WindowButtonLayout(leading: [_close]),
      );
    });

    test('vanilla GNOME default keeps only close', () {
      expect(
        Oito2WindowButtonLayout.parseGnome('appmenu:close'),
        const Oito2WindowButtonLayout(trailing: [_close]),
      );
    });

    test('handles empty and colon-less values', () {
      expect(Oito2WindowButtonLayout.parseGnome('').isEmpty, isTrue);
      expect(
        Oito2WindowButtonLayout.parseGnome('close'),
        const Oito2WindowButtonLayout(leading: [_close]),
      );
    });
  });

  group('parseKde', () {
    test('reads the default Breeze layout', () {
      expect(
        Oito2WindowButtonLayout.parseKde(
          buttonsOnLeft: 'MS',
          buttonsOnRight: 'HIAX',
        ),
        const Oito2WindowButtonLayout(trailing: [_min, _max, _close]),
      );
    });

    test('reads buttons on the left', () {
      expect(
        Oito2WindowButtonLayout.parseKde(
          buttonsOnLeft: 'XIA',
          buttonsOnRight: 'M',
        ),
        const Oito2WindowButtonLayout(leading: [_close, _min, _max]),
      );
    });
  });

  group('parseXfwm', () {
    test('reads the default Xfce layout', () {
      expect(
        Oito2WindowButtonLayout.parseXfwm('O|HMC'),
        const Oito2WindowButtonLayout(trailing: [_min, _max, _close]),
      );
    });

    test('reads buttons on the left and ignores other letters', () {
      expect(
        Oito2WindowButtonLayout.parseXfwm('CHMS|T'),
        const Oito2WindowButtonLayout(leading: [_close, _min, _max]),
      );
    });
  });

  group('defaultFor', () {
    test('macOS places close, minimize and maximize on the left', () {
      expect(
        Oito2WindowButtonLayout.defaultFor(Oito2WindowControlStyle.macos),
        const Oito2WindowButtonLayout(leading: [_close, _min, _max]),
      );
    });

    test('none has no buttons', () {
      expect(
        Oito2WindowButtonLayout.defaultFor(Oito2WindowControlStyle.none)
            .isEmpty,
        isTrue,
      );
    });

    test('every other style places the buttons on the right', () {
      for (final style in [
        Oito2WindowControlStyle.gnome,
        Oito2WindowControlStyle.breeze,
        Oito2WindowControlStyle.xfwm,
        Oito2WindowControlStyle.cosmic,
        Oito2WindowControlStyle.windows,
      ]) {
        expect(
          Oito2WindowButtonLayout.defaultFor(style),
          const Oito2WindowButtonLayout(trailing: [_min, _max, _close]),
          reason: style.name,
        );
      }
    });
  });

  test('equal layouts share a hashCode', () {
    const a = Oito2WindowButtonLayout(trailing: [_min, _close]);
    const b = Oito2WindowButtonLayout(trailing: [_min, _close]);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const Oito2WindowButtonLayout(leading: [_min, _close])));
  });
}
