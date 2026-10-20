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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

/// Synthetic role sets that exercise [Oito2ColorTheme.fromRoles] in the
/// layouts theme families use, keyed by a readable name.
///
/// - `roles light dim`: a light scheme whose page background is darker
///   than its cards, with faint muted text.
/// - `roles dark lifted`: a dark scheme whose cards are much lighter than
///   the background.
/// - `roles light flat`: a light scheme whose card is the background
///   itself, with a pale accent.
final Map<String, Oito2ColorRoles> sampleRoles = {
  'roles light dim': const Oito2ColorRoles(
    brightness: Brightness.light,
    background: Color(0xFFE9E4D4),
    card: Color(0xFFFBF7EC),
    foreground: Color(0xFF4A4A4A),
    primary: Color(0xFF7A9A3A),
    secondary: Color(0xFFF0EADA),
    mutedForeground: Color(0xFFB0AA9A),
    destructive: Color(0xFFE05050),
    border: Color(0xFFDCD6C4),
    success: Color(0xFF8AB040),
    warning: Color(0xFFE0B020),
    info: Color(0xFF50A0C8),
    syntax: _lightSyntax,
  ),
  'roles dark lifted': const Oito2ColorRoles(
    brightness: Brightness.dark,
    background: Color(0xFF20222C),
    card: Color(0xFF40435A),
    foreground: Color(0xFFF0F0EA),
    primary: Color(0xFFB090F0),
    secondary: Color(0xFF4C5068),
    mutedForeground: Color(0xFF6070A0),
    destructive: Color(0xFFF05050),
    border: Color(0xFF555970),
    success: Color(0xFF50E080),
    warning: Color(0xFFF0F090),
    info: Color(0xFF80E0F0),
    syntax: _darkSyntax,
  ),
  'roles light flat': const Oito2ColorRoles(
    brightness: Brightness.light,
    background: Color(0xFFFFFBEE),
    card: Color(0xFFFFFBEE),
    foreground: Color(0xFF202020),
    primary: Color(0xFFFFC0D0),
    secondary: Color(0xFFF2EEE0),
    mutedForeground: Color(0xFF8A8670),
    destructive: Color(0xFFD04030),
    border: Color(0xFFDAD6C6),
    success: Color(0xFF208020),
    warning: Color(0xFFA06010),
    info: Color(0xFF106090),
    syntax: _lightSyntax,
  ),
};

const _lightSyntax = Oito2SyntaxPalette(
  foreground: Color(0xFF4A4A4A),
  comment: Color(0xFFB0AA9A),
  keyword: Color(0xFFE05050),
  string: Color(0xFF50A090),
  number: Color(0xFFB070C0),
  function: Color(0xFF7A9A3A),
  type: Color(0xFFE0B020),
  tag: Color(0xFFE08030),
  attribute: Color(0xFF50A0C8),
  constant: Color(0xFFB070C0),
  invalid: Color(0xFFE05050),
);

const _darkSyntax = Oito2SyntaxPalette(
  foreground: Color(0xFFF0F0EA),
  comment: Color(0xFF6070A0),
  keyword: Color(0xFFF080C0),
  string: Color(0xFFF0F090),
  number: Color(0xFFB090F0),
  function: Color(0xFF50E080),
  type: Color(0xFF80E0F0),
  tag: Color(0xFFF080C0),
  attribute: Color(0xFF50E080),
  constant: Color(0xFFB090F0),
  invalid: Color(0xFFF05050),
);
