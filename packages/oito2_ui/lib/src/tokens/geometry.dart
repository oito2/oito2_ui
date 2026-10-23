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

import 'package:material_ui/material_ui.dart';

/// Corner radius tokens.
abstract final class Oito2Radius {
  /// Radius for check boxes and other very small controls: 4.
  static const double check = 4;

  /// Radius for small surfaces such as chips, tooltips and menu items: 6.
  static const double small = 6;

  /// Radius for buttons and input fields: 8.
  static const double medium = 8;

  /// Radius for cards and containers: 12.
  static const double large = 12;

  /// Radius for windows, dialogs and sheets: 14.
  static const double window = 14;

  /// [check] as a uniform [BorderRadius].
  static const BorderRadius checkAll = BorderRadius.all(Radius.circular(check));

  /// [small] as a uniform [BorderRadius].
  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(small));

  /// [medium] as a uniform [BorderRadius].
  static const BorderRadius mediumAll = BorderRadius.all(
    Radius.circular(medium),
  );

  /// [large] as a uniform [BorderRadius].
  static const BorderRadius largeAll = BorderRadius.all(Radius.circular(large));

  /// [window] as a uniform [BorderRadius].
  static const BorderRadius windowAll = BorderRadius.all(
    Radius.circular(window),
  );
}

/// Spacing tokens on a 4-point scale, for padding, gaps and margins.
abstract final class Oito2Spacing {
  /// Extra-extra-small spacing: 2.
  static const double xxs = 2;

  /// Extra-small spacing: 4.
  static const double xs = 4;

  /// Small spacing: 8.
  static const double sm = 8;

  /// Medium spacing: 12.
  static const double md = 12;

  /// Large spacing: 16.
  static const double lg = 16;

  /// 20, the default padding around page content.
  static const double page = 20;

  /// Extra-large spacing: 24.
  static const double xl = 24;

  /// Extra-extra-large spacing: 32.
  static const double xxl = 32;

  /// The largest spacing: 48.
  static const double xxxl = 48;
}

/// Size tokens for controls and chrome.
abstract final class Oito2Sizes {
  /// Height of buttons and single-line input fields on pointer platforms:
  /// 34.
  static const double buttonHeight = 34;

  /// Height of buttons and single-line input fields on touch platforms:
  /// 40, with the tap target padded to [minTouchTarget].
  static const double touchButtonHeight = 40;

  /// Height of the window title bar: 46.
  static const double titleBarHeight = 46;

  /// Height of the items placed inside the title bar: 34.
  static const double titleBarItemHeight = 34;

  /// Default icon size: 20.
  static const double iconSize = 20;

  /// Thickness of linear progress bars, Material and oito2 alike: 6.
  static const double progressHeight = 6;

  /// Width of the focus border around a focused control: 2.
  static const double focusBorderWidth = 2;

  /// Size of a round window control button: 24.
  static const double windowControlSize = 24;

  /// Width of a Windows-style rectangular window control button: 46.
  static const double windowsWindowControlWidth = 46;

  /// Minimum target size for pointer input, from WCAG 2.2 criterion 2.5.8:
  /// 24.
  static const double minPointerTarget = 24;

  /// Minimum target size for touch input, from the Material guidelines: 48.
  static const double minTouchTarget = 48;
}
