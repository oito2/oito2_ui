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

import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

/// How a window title bar is presented.
enum Oito2TitleBarStyle {
  /// The title bar is not shown.
  hidden,

  /// The title bar is shown without window controls.
  undecorated,

  /// The title bar is shown with window controls.
  normal,
}

/// Visual properties of `Oito2TitleBar` and the widgets built on it.
///
/// `Oito2Theme` adds one to every theme it builds; each null field falls
/// back to the matching `AppBarTheme` value.
@immutable
class Oito2TitleBarThemeData extends ThemeExtension<Oito2TitleBarThemeData> {
  /// Creates title bar theme data.
  const Oito2TitleBarThemeData({
    this.style,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
    this.titleTextStyle,
    this.centerTitle,
    this.inactiveOpacity,
  });

  /// Returns the title bar theme of the closest [Theme], or an empty one
  /// when the theme has none.
  static Oito2TitleBarThemeData of(BuildContext context) =>
      Theme.of(context).extension<Oito2TitleBarThemeData>() ??
      const Oito2TitleBarThemeData();

  /// How the title bar is presented.
  final Oito2TitleBarStyle? style;

  /// The height of the title bar.
  final double? height;

  /// The background color.
  final Color? backgroundColor;

  /// The color of the title, icons and window control glyphs.
  final Color? foregroundColor;

  /// The border drawn along the bottom edge.
  final BorderSide? border;

  /// The text style of the title.
  final TextStyle? titleTextStyle;

  /// Whether the title is centered.
  final bool? centerTitle;

  /// The opacity of the title bar content while the window is inactive.
  final double? inactiveOpacity;

  @override
  Oito2TitleBarThemeData copyWith({
    Oito2TitleBarStyle? style,
    double? height,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderSide? border,
    TextStyle? titleTextStyle,
    bool? centerTitle,
    double? inactiveOpacity,
  }) {
    return Oito2TitleBarThemeData(
      style: style ?? this.style,
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      border: border ?? this.border,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      centerTitle: centerTitle ?? this.centerTitle,
      inactiveOpacity: inactiveOpacity ?? this.inactiveOpacity,
    );
  }

  @override
  Oito2TitleBarThemeData lerp(Oito2TitleBarThemeData? other, double t) {
    if (other == null) return this;
    return Oito2TitleBarThemeData(
      style: t < 0.5 ? style : other.style,
      height: lerpDouble(height, other.height, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t),
      border: border == null || other.border == null
          ? (t < 0.5 ? border : other.border)
          : BorderSide.lerp(border!, other.border!, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      centerTitle: t < 0.5 ? centerTitle : other.centerTitle,
      inactiveOpacity: lerpDouble(inactiveOpacity, other.inactiveOpacity, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2TitleBarThemeData &&
      other.style == style &&
      other.height == height &&
      other.backgroundColor == backgroundColor &&
      other.foregroundColor == foregroundColor &&
      other.border == border &&
      other.titleTextStyle == titleTextStyle &&
      other.centerTitle == centerTitle &&
      other.inactiveOpacity == inactiveOpacity;

  @override
  int get hashCode => Object.hash(
    style,
    height,
    backgroundColor,
    foregroundColor,
    border,
    titleTextStyle,
    centerTitle,
    inactiveOpacity,
  );
}
