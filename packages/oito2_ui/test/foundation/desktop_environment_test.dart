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
import 'package:oito2_ui/oito2_ui.dart';

void main() {
  group('detect from XDG_CURRENT_DESKTOP', () {
    const cases = {
      'GNOME': Oito2DesktopEnvironment.gnome,
      'ubuntu:GNOME': Oito2DesktopEnvironment.gnome,
      'pop:GNOME': Oito2DesktopEnvironment.gnome,
      'GNOME-Classic:GNOME': Oito2DesktopEnvironment.gnome,
      'KDE': Oito2DesktopEnvironment.kde,
      'XFCE': Oito2DesktopEnvironment.xfce,
      'Budgie:GNOME': Oito2DesktopEnvironment.budgie,
      'COSMIC': Oito2DesktopEnvironment.cosmic,
      'X-Cinnamon': Oito2DesktopEnvironment.cinnamon,
      'MATE': Oito2DesktopEnvironment.mate,
      'LXQt': Oito2DesktopEnvironment.lxqt,
      'Pantheon': Oito2DesktopEnvironment.pantheon,
      'Unity:Unity7:ubuntu': Oito2DesktopEnvironment.unity,
      'Hyprland': Oito2DesktopEnvironment.unknown,
    };
    cases.forEach((value, expected) {
      test(value, () {
        expect(
          Oito2DesktopEnvironment.detect(xdgCurrentDesktop: value),
          expected,
        );
      });
    });
  });

  test('falls back to DESKTOP_SESSION when no entry is recognized', () {
    expect(
      Oito2DesktopEnvironment.detect(
        xdgCurrentDesktop: 'custom',
        desktopSession: 'plasma',
      ),
      Oito2DesktopEnvironment.kde,
    );
    expect(
      Oito2DesktopEnvironment.detect(desktopSession: 'budgie-desktop'),
      Oito2DesktopEnvironment.budgie,
    );
  });

  test('prefers XDG_CURRENT_DESKTOP over DESKTOP_SESSION', () {
    expect(
      Oito2DesktopEnvironment.detect(
        xdgCurrentDesktop: 'XFCE',
        desktopSession: 'gnome',
      ),
      Oito2DesktopEnvironment.xfce,
    );
  });

  test('returns unknown for missing or empty values', () {
    expect(Oito2DesktopEnvironment.detect(), Oito2DesktopEnvironment.unknown);
    expect(
      Oito2DesktopEnvironment.detect(xdgCurrentDesktop: '', desktopSession: ''),
      Oito2DesktopEnvironment.unknown,
    );
  });
}
