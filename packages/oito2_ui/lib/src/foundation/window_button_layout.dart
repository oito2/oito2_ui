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

import 'desktop_environment.dart';
import 'platform_info.dart';

/// A button that controls the native window.
enum Oito2WindowButton {
  /// Minimizes the window.
  minimize,

  /// Maximizes or restores the window.
  maximize,

  /// Closes the window.
  close,
}

/// The visual family used to draw window control buttons.
enum Oito2WindowControlStyle {
  /// Round buttons on a neutral background, as in GNOME and its relatives.
  gnome,

  /// Flat glyph buttons, as in KDE Plasma's Breeze decoration.
  breeze,

  /// Compact glyph buttons, as in Xfce's window manager.
  xfwm,

  /// Round buttons, as in COSMIC.
  cosmic,

  /// Rectangular buttons with a red close hover, as in Windows.
  windows,

  /// The native macOS traffic lights.
  macos,

  /// No window controls: the browser or the mobile system owns the window.
  none;

  /// Resolves the control style for [platform] and, on Linux, for the
  /// [desktopEnvironment].
  ///
  /// Returns [none] on the web and on touch platforms. Linux desktop
  /// environments without their own style use [gnome].
  static Oito2WindowControlStyle resolve(
    Oito2Platform platform, {
    Oito2DesktopEnvironment? desktopEnvironment,
  }) {
    if (!platform.isDesktopNative) return none;
    if (platform.isWindows) return windows;
    if (platform.isMacOS) return macos;
    return switch (desktopEnvironment) {
      Oito2DesktopEnvironment.kde => breeze,
      Oito2DesktopEnvironment.xfce => xfwm,
      Oito2DesktopEnvironment.cosmic => cosmic,
      _ => gnome,
    };
  }
}

/// The order and side of the window control buttons in a title bar.
@immutable
class Oito2WindowButtonLayout {
  /// Creates a layout with [leading] buttons before the title and
  /// [trailing] buttons after it.
  const Oito2WindowButtonLayout({
    this.leading = const [],
    this.trailing = const [],
  });

  /// Parses the GNOME `button-layout` format used by GNOME, Budgie,
  /// Cinnamon, MATE and Pantheon, for example
  /// `appmenu:minimize,maximize,close`.
  ///
  /// Names before the colon are leading, names after it are trailing.
  /// Entries other than `minimize`, `maximize` and `close` are ignored, and
  /// each button is kept only at its first position.
  factory Oito2WindowButtonLayout.parseGnome(String value) {
    final sides = value.split(':');
    final seen = <Oito2WindowButton>{};
    List<Oito2WindowButton> side(String names) => [
      for (final name in names.split(','))
        if (_gnomeNames[name.trim()] case final button?)
          if (seen.add(button)) button,
    ];
    return Oito2WindowButtonLayout(
      leading: side(sides.first),
      trailing: sides.length > 1 ? side(sides[1]) : const [],
    );
  }

  /// Parses the KDE KWin `ButtonsOnLeft` and `ButtonsOnRight` values, for
  /// example `MS` and `HIAX`.
  ///
  /// Recognizes `I` (minimize), `A` (maximize) and `X` (close); other
  /// letters are ignored, and each button is kept only at its first
  /// position.
  factory Oito2WindowButtonLayout.parseKde({
    required String buttonsOnLeft,
    required String buttonsOnRight,
  }) {
    final seen = <Oito2WindowButton>{};
    List<Oito2WindowButton> side(String letters) => [
      for (final letter in letters.split(''))
        if (_kdeLetters[letter] case final button?)
          if (seen.add(button)) button,
    ];
    return Oito2WindowButtonLayout(
      leading: side(buttonsOnLeft),
      trailing: side(buttonsOnRight),
    );
  }

  /// Parses the Xfce xfwm4 `button_layout` format, for example `O|HMC`.
  ///
  /// Letters before the `|` title marker are leading, letters after it are
  /// trailing. Recognizes `H` (minimize), `M` (maximize) and `C` (close);
  /// other letters are ignored, and each button is kept only at its first
  /// position.
  factory Oito2WindowButtonLayout.parseXfwm(String value) {
    final sides = value.split('|');
    final seen = <Oito2WindowButton>{};
    List<Oito2WindowButton> side(String letters) => [
      for (final letter in letters.split(''))
        if (_xfwmLetters[letter] case final button?)
          if (seen.add(button)) button,
    ];
    return Oito2WindowButtonLayout(
      leading: side(sides.first),
      trailing: sides.length > 1 ? side(sides[1]) : const [],
    );
  }

  /// The default layout for [style]: leading close, minimize and maximize
  /// for [Oito2WindowControlStyle.macos], no buttons for
  /// [Oito2WindowControlStyle.none], and trailing minimize, maximize and
  /// close otherwise.
  factory Oito2WindowButtonLayout.defaultFor(Oito2WindowControlStyle style) {
    return switch (style) {
      Oito2WindowControlStyle.macos => const Oito2WindowButtonLayout(
        leading: [
          Oito2WindowButton.close,
          Oito2WindowButton.minimize,
          Oito2WindowButton.maximize,
        ],
      ),
      Oito2WindowControlStyle.none => const Oito2WindowButtonLayout(),
      _ => const Oito2WindowButtonLayout(
        trailing: [
          Oito2WindowButton.minimize,
          Oito2WindowButton.maximize,
          Oito2WindowButton.close,
        ],
      ),
    };
  }

  static const _gnomeNames = {
    'minimize': Oito2WindowButton.minimize,
    'maximize': Oito2WindowButton.maximize,
    'close': Oito2WindowButton.close,
  };

  static const _kdeLetters = {
    'I': Oito2WindowButton.minimize,
    'A': Oito2WindowButton.maximize,
    'X': Oito2WindowButton.close,
  };

  static const _xfwmLetters = {
    'H': Oito2WindowButton.minimize,
    'M': Oito2WindowButton.maximize,
    'C': Oito2WindowButton.close,
  };

  /// The buttons placed before the title, in display order.
  final List<Oito2WindowButton> leading;

  /// The buttons placed after the title, in display order.
  final List<Oito2WindowButton> trailing;

  /// Whether the layout has no buttons at all.
  bool get isEmpty => leading.isEmpty && trailing.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is Oito2WindowButtonLayout &&
      listEquals(other.leading, leading) &&
      listEquals(other.trailing, trailing);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(leading), Object.hashAll(trailing));

  @override
  String toString() =>
      'Oito2WindowButtonLayout(leading: $leading, trailing: $trailing)';
}
