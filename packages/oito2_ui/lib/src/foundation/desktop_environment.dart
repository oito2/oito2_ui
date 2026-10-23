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

/// A Linux desktop environment.
enum Oito2DesktopEnvironment {
  /// GNOME, including Ubuntu's and Pop!_OS's GNOME sessions.
  gnome,

  /// KDE Plasma.
  kde,

  /// Xfce.
  xfce,

  /// Budgie.
  budgie,

  /// COSMIC.
  cosmic,

  /// Cinnamon.
  cinnamon,

  /// MATE.
  mate,

  /// LXQt.
  lxqt,

  /// Pantheon (elementary OS).
  pantheon,

  /// Unity.
  unity,

  /// A desktop environment not recognized by [detect].
  unknown;

  /// Detects the desktop environment from the values of the
  /// `XDG_CURRENT_DESKTOP` and `DESKTOP_SESSION` environment variables.
  ///
  /// `XDG_CURRENT_DESKTOP` is a colon-separated list (for example
  /// `Budgie:GNOME` or `ubuntu:GNOME`); its entries are checked in order and
  /// the first recognized one wins. `DESKTOP_SESSION` is checked only when no
  /// entry is recognized. Matching ignores case. Returns [unknown] when
  /// neither value is recognized.
  static Oito2DesktopEnvironment detect({
    String? xdgCurrentDesktop,
    String? desktopSession,
  }) {
    for (final entry in (xdgCurrentDesktop ?? '').split(':')) {
      final match = _fromName(entry);
      if (match != null) return match;
    }
    return _fromName(desktopSession ?? '') ?? unknown;
  }

  /// Maps one desktop or session [name], ignoring case and surrounding
  /// spaces, to its environment; returns null when it isn't recognized.
  static Oito2DesktopEnvironment? _fromName(String name) {
    return switch (name.trim().toLowerCase()) {
      'gnome' || 'gnome-classic' || 'gnome-xorg' || 'gnome-wayland' => gnome,
      'kde' || 'plasma' || 'plasmawayland' || 'plasmax11' => kde,
      'xfce' || 'xfce4' || 'xubuntu' => xfce,
      'budgie' || 'budgie-desktop' => budgie,
      'cosmic' => cosmic,
      'x-cinnamon' || 'cinnamon' || 'cinnamon2d' => cinnamon,
      'mate' => mate,
      'lxqt' || 'lubuntu' => lxqt,
      'pantheon' => pantheon,
      'unity' || 'unity7' => unity,
      _ => null,
    };
  }
}
