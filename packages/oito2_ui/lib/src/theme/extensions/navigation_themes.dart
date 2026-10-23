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

/// Layout defaults of `Oito2NavigationPage`: its breakpoints, the rail
/// color and padding, and the separator beside the rail.
///
/// The page's own parameters override these values.
@immutable
class Oito2NavigationPageThemeData
    extends ThemeExtension<Oito2NavigationPageThemeData> {
  /// Creates navigation page theme data.
  const Oito2NavigationPageThemeData({
    this.compactBreakpoint = 600,
    this.extendedBreakpoint,
    this.railColor,
    this.railPadding = const EdgeInsets.symmetric(vertical: 8),
    this.includeSeparator = true,
  });

  /// The width below which touch layouts use a bottom bar and pointer
  /// layouts a compact rail.
  final double compactBreakpoint;

  /// The width at which the rail shows labels beside the icons; null
  /// never extends it.
  final double? extendedBreakpoint;

  /// The rail background; defaults to the chrome sidebar color.
  final Color? railColor;

  /// Space around the rail items.
  final EdgeInsetsGeometry railPadding;

  /// Whether a divider separates the rail from the page.
  final bool includeSeparator;

  /// Returns the data of the closest [Theme], or null when it has none.
  static Oito2NavigationPageThemeData? maybeOf(BuildContext context) =>
      Theme.of(context).extension<Oito2NavigationPageThemeData>();

  @override
  Oito2NavigationPageThemeData copyWith({
    double? compactBreakpoint,
    double? extendedBreakpoint,
    Color? railColor,
    EdgeInsetsGeometry? railPadding,
    bool? includeSeparator,
  }) {
    return Oito2NavigationPageThemeData(
      compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
      extendedBreakpoint: extendedBreakpoint ?? this.extendedBreakpoint,
      railColor: railColor ?? this.railColor,
      railPadding: railPadding ?? this.railPadding,
      includeSeparator: includeSeparator ?? this.includeSeparator,
    );
  }

  @override
  Oito2NavigationPageThemeData lerp(
    Oito2NavigationPageThemeData? other,
    double t,
  ) {
    if (other == null) return this;
    final near = t < 0.5 ? this : other;
    return Oito2NavigationPageThemeData(
      compactBreakpoint: lerpDouble(
        compactBreakpoint,
        other.compactBreakpoint,
        t,
      )!,
      extendedBreakpoint: near.extendedBreakpoint,
      railColor: Color.lerp(railColor, other.railColor, t),
      railPadding: EdgeInsetsGeometry.lerp(railPadding, other.railPadding, t)!,
      includeSeparator: near.includeSeparator,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2NavigationPageThemeData &&
      other.compactBreakpoint == compactBreakpoint &&
      other.extendedBreakpoint == extendedBreakpoint &&
      other.railColor == railColor &&
      other.railPadding == railPadding &&
      other.includeSeparator == includeSeparator;

  @override
  int get hashCode => Object.hash(
    compactBreakpoint,
    extendedBreakpoint,
    railColor,
    railPadding,
    includeSeparator,
  );
}

/// Layout defaults of `Oito2MasterDetailPage`: the breakpoint, the pane
/// sizes, the list spacing and color, and the separator beside the pane.
///
/// The page's own parameters override these values.
@immutable
class Oito2MasterDetailThemeData
    extends ThemeExtension<Oito2MasterDetailThemeData> {
  /// Creates master-detail theme data.
  const Oito2MasterDetailThemeData({
    this.breakpoint = 620,
    this.paneSize = 280,
    this.minPaneSize = 180,
    this.minPageSize = 320,
    this.tileSpacing = 4,
    this.listPadding = const EdgeInsets.all(8),
    this.paneColor,
  });

  /// The width at which the master and the detail sit side by side.
  final double breakpoint;

  /// The initial master pane width.
  final double paneSize;

  /// The smallest master pane width.
  final double minPaneSize;

  /// The smallest width left for the detail page.
  final double minPageSize;

  /// Space between master tiles.
  final double tileSpacing;

  /// Space around the master list.
  final EdgeInsetsGeometry listPadding;

  /// The master pane background; defaults to the chrome mainbar color.
  final Color? paneColor;

  /// Returns the data of the closest [Theme], or null when it has none.
  static Oito2MasterDetailThemeData? maybeOf(BuildContext context) =>
      Theme.of(context).extension<Oito2MasterDetailThemeData>();

  @override
  Oito2MasterDetailThemeData copyWith({
    double? breakpoint,
    double? paneSize,
    double? minPaneSize,
    double? minPageSize,
    double? tileSpacing,
    EdgeInsetsGeometry? listPadding,
    Color? paneColor,
  }) {
    return Oito2MasterDetailThemeData(
      breakpoint: breakpoint ?? this.breakpoint,
      paneSize: paneSize ?? this.paneSize,
      minPaneSize: minPaneSize ?? this.minPaneSize,
      minPageSize: minPageSize ?? this.minPageSize,
      tileSpacing: tileSpacing ?? this.tileSpacing,
      listPadding: listPadding ?? this.listPadding,
      paneColor: paneColor ?? this.paneColor,
    );
  }

  @override
  Oito2MasterDetailThemeData lerp(Oito2MasterDetailThemeData? other, double t) {
    if (other == null) return this;
    return Oito2MasterDetailThemeData(
      breakpoint: lerpDouble(breakpoint, other.breakpoint, t)!,
      paneSize: lerpDouble(paneSize, other.paneSize, t)!,
      minPaneSize: lerpDouble(minPaneSize, other.minPaneSize, t)!,
      minPageSize: lerpDouble(minPageSize, other.minPageSize, t)!,
      tileSpacing: lerpDouble(tileSpacing, other.tileSpacing, t)!,
      listPadding: EdgeInsetsGeometry.lerp(listPadding, other.listPadding, t)!,
      paneColor: Color.lerp(paneColor, other.paneColor, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2MasterDetailThemeData &&
      other.breakpoint == breakpoint &&
      other.paneSize == paneSize &&
      other.minPaneSize == minPaneSize &&
      other.minPageSize == minPageSize &&
      other.tileSpacing == tileSpacing &&
      other.listPadding == listPadding &&
      other.paneColor == paneColor;

  @override
  int get hashCode => Object.hash(
    breakpoint,
    paneSize,
    minPaneSize,
    minPageSize,
    tileSpacing,
    listPadding,
    paneColor,
  );
}
