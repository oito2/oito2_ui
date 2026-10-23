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

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'palettes/dracula_palette.dart';
import 'palettes/everforest_palette.dart';
import 'palettes/nord_palette.dart';
import 'palettes/rose_pine_palette.dart';
import 'theme_preset.dart';

/// The role colors of [preset], with the brightness the preset declares.
Oito2ColorRoles presetRoles(Oito2ThemePreset preset) {
  final b = preset.brightness;
  return switch (preset) {
    Oito2ThemePreset.everforestLight => _everforest(
      Oito2EverforestPalette.light,
      b,
    ),
    Oito2ThemePreset.everforestDark => _everforest(
      Oito2EverforestPalette.dark,
      b,
    ),
    Oito2ThemePreset.rosePine => _rosePine(Oito2RosePinePalette.main, b),
    Oito2ThemePreset.rosePineMoon => _rosePine(Oito2RosePinePalette.moon, b),
    Oito2ThemePreset.rosePineDawn => _rosePine(Oito2RosePinePalette.dawn, b),
    Oito2ThemePreset.nordDark => _nordDark(b),
    Oito2ThemePreset.nordLight => _nordLight(b),
    Oito2ThemePreset.dracula => _dracula(b),
    Oito2ThemePreset.alucard => _alucard(b),
    Oito2ThemePreset.catppuccinLatte => _catppuccin(catppuccin.latte, b),
    Oito2ThemePreset.catppuccinFrappe => _catppuccin(catppuccin.frappe, b),
    Oito2ThemePreset.catppuccinMacchiato => _catppuccin(
      catppuccin.macchiato,
      b,
    ),
    Oito2ThemePreset.catppuccinMocha => _catppuccin(catppuccin.mocha, b),
  };
}

/// Everforest: every role is official.
Oito2ColorRoles _everforest(Oito2EverforestPalette p, Brightness brightness) =>
    Oito2ColorRoles(
      brightness: brightness,
      background: p.bgDim,
      card: p.bg0,
      foreground: p.fg,
      primary: p.green,
      secondary: p.bg1,
      mutedForeground: p.grey1,
      destructive: p.red,
      border: brightness == Brightness.dark ? p.bg2 : p.bg3,
      success: p.green,
      warning: p.yellow,
      info: p.blue,
      syntax: Oito2SyntaxPalette(
        foreground: p.fg,
        comment: p.grey1,
        keyword: p.red,
        string: p.aqua,
        number: p.purple,
        function: p.green,
        type: p.yellow,
        tag: p.orange,
        attribute: p.blue,
        constant: p.purple,
        invalid: p.red,
      ),
    );

/// Rosé Pine: every role is official; `overlay` serves as both secondary
/// surface and border.
Oito2ColorRoles _rosePine(Oito2RosePinePalette p, Brightness brightness) =>
    Oito2ColorRoles(
      brightness: brightness,
      background: p.base,
      card: p.surface,
      foreground: p.text,
      primary: p.pine,
      secondary: p.overlay,
      mutedForeground: p.muted,
      destructive: p.love,
      border: p.overlay,
      success: p.foam,
      warning: p.gold,
      info: p.iris,
      syntax: Oito2SyntaxPalette(
        foreground: p.text,
        comment: p.muted,
        keyword: p.pine,
        string: p.gold,
        number: p.gold,
        function: p.rose,
        type: p.foam,
        tag: p.foam,
        attribute: p.iris,
        constant: p.gold,
        invalid: p.love,
      ),
    );

/// Nord, dark: every role is official.
Oito2ColorRoles _nordDark(Brightness brightness) => Oito2ColorRoles(
  brightness: brightness,
  background: Oito2NordPalette.nord0,
  card: Oito2NordPalette.nord1,
  foreground: Oito2NordPalette.nord4,
  primary: Oito2NordPalette.nord8,
  secondary: Oito2NordPalette.nord2,
  mutedForeground: Oito2NordPalette.nord3,
  destructive: Oito2NordPalette.nord11,
  border: Oito2NordPalette.nord3,
  success: Oito2NordPalette.nord14,
  warning: Oito2NordPalette.nord13,
  info: Oito2NordPalette.nord9,
  syntax: Oito2SyntaxPalette(
    foreground: Oito2NordPalette.nord4,
    comment: Oito2NordPalette.nord3,
    keyword: Oito2NordPalette.nord9,
    string: Oito2NordPalette.nord14,
    number: Oito2NordPalette.nord15,
    function: Oito2NordPalette.nord8,
    type: Oito2NordPalette.nord7,
    tag: Oito2NordPalette.nord9,
    attribute: Oito2NordPalette.nord7,
    constant: Oito2NordPalette.nord12,
    invalid: Oito2NordPalette.nord11,
  ),
);

/// Nord, light: an unofficial derivation that swaps Polar Night and Snow
/// Storm and uses `nord10` as primary for contrast on a light background.
Oito2ColorRoles _nordLight(Brightness brightness) => Oito2ColorRoles(
  brightness: brightness,
  background: Oito2NordPalette.nord6,
  card: Oito2NordPalette.nord5,
  foreground: Oito2NordPalette.nord0,
  primary: Oito2NordPalette.nord10,
  secondary: Oito2NordPalette.nord4,
  mutedForeground: Oito2NordPalette.nord3,
  destructive: Oito2NordPalette.nord11,
  border: Oito2NordPalette.nord4,
  success: Oito2NordPalette.nord14,
  warning: Oito2NordPalette.nord12,
  info: Oito2NordPalette.nord10,
  syntax: Oito2SyntaxPalette(
    foreground: Oito2NordPalette.nord0,
    comment: Oito2NordPalette.nord3,
    keyword: Oito2NordPalette.nord10,
    string: Oito2NordPalette.nord14,
    number: Oito2NordPalette.nord15,
    function: Oito2NordPalette.nord8,
    type: Oito2NordPalette.nord7,
    tag: Oito2NordPalette.nord10,
    attribute: Oito2NordPalette.nord7,
    constant: Oito2NordPalette.nord12,
    invalid: Oito2NordPalette.nord11,
  ),
);

/// Dracula: `background`, `currentLine` (card) and the accents are
/// official. Dracula has no third surface layer, so the secondary surface
/// is derived 12% from `currentLine` toward `foreground`, and the border
/// 15%.
Oito2ColorRoles _dracula(Brightness brightness) {
  const p = Oito2DraculaPalette.dracula;
  return Oito2ColorRoles(
    brightness: brightness,
    background: p.background,
    card: p.currentLine,
    foreground: p.foreground,
    primary: p.purple,
    secondary: Color.lerp(p.currentLine, p.foreground, 0.12)!,
    mutedForeground: p.comment,
    destructive: p.red,
    border: Color.lerp(p.currentLine, p.foreground, 0.15)!,
    success: p.green,
    warning: p.yellow,
    info: p.cyan,
    syntax: _draculaSyntax(p),
  );
}

/// Alucard: `background` and the accents are official. Alucard has no
/// second surface layer, so the card is the background itself, the
/// secondary surface is derived 6% from `background` toward `foreground`,
/// and the border 15%.
Oito2ColorRoles _alucard(Brightness brightness) {
  const p = Oito2DraculaPalette.alucard;
  return Oito2ColorRoles(
    brightness: brightness,
    background: p.background,
    card: p.background,
    foreground: p.foreground,
    primary: p.purple,
    secondary: Color.lerp(p.background, p.foreground, 0.06)!,
    mutedForeground: p.comment,
    destructive: p.red,
    border: Color.lerp(p.background, p.foreground, 0.15)!,
    success: p.green,
    warning: p.orange,
    info: p.cyan,
    syntax: _draculaSyntax(p),
  );
}

/// The syntax colors shared by Dracula and Alucard, from palette [p].
Oito2SyntaxPalette _draculaSyntax(Oito2DraculaPalette p) => Oito2SyntaxPalette(
  foreground: p.foreground,
  comment: p.comment,
  keyword: p.pink,
  string: p.yellow,
  number: p.purple,
  function: p.green,
  type: p.cyan,
  tag: p.pink,
  attribute: p.green,
  constant: p.purple,
  invalid: p.red,
);

/// Catppuccin: every role is official, read from `catppuccin_flutter`.
Oito2ColorRoles _catppuccin(Flavor f, Brightness brightness) => Oito2ColorRoles(
  brightness: brightness,
  background: f.mantle,
  card: f.base,
  foreground: f.text,
  primary: f.mauve,
  secondary: f.surface0,
  mutedForeground: f.overlay0,
  destructive: f.red,
  border: f.surface1,
  success: f.green,
  warning: f.yellow,
  info: f.blue,
  syntax: Oito2SyntaxPalette(
    foreground: f.text,
    comment: f.overlay2,
    keyword: f.mauve,
    string: f.green,
    number: f.peach,
    function: f.blue,
    type: f.yellow,
    tag: f.blue,
    attribute: f.yellow,
    constant: f.peach,
    invalid: f.red,
  ),
);
