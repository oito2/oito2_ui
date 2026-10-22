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

import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

import '../../tokens/geometry.dart';

/// Colors and sizes of `Oito2CircularProgressIndicator` and
/// `Oito2LinearProgressIndicator`.
@immutable
class Oito2ProgressIndicatorThemeData
    extends ThemeExtension<Oito2ProgressIndicatorThemeData> {
  /// Creates progress indicator theme data.
  const Oito2ProgressIndicatorThemeData({
    required this.color,
    required this.trackColor,
    this.strokeWidth = 4,
    this.linearHeight = Oito2Sizes.progressHeight,
  });

  /// The progress fill.
  final Color color;

  /// The track behind determinate progress.
  final Color trackColor;

  /// The ring thickness of the circular indicator.
  final double strokeWidth;

  /// The bar height of the linear indicator.
  final double linearHeight;

  /// Returns the data of the closest [Theme], or null when it has none.
  static Oito2ProgressIndicatorThemeData? maybeOf(BuildContext context) =>
      Theme.of(context).extension<Oito2ProgressIndicatorThemeData>();

  @override
  Oito2ProgressIndicatorThemeData copyWith({
    Color? color,
    Color? trackColor,
    double? strokeWidth,
    double? linearHeight,
  }) {
    return Oito2ProgressIndicatorThemeData(
      color: color ?? this.color,
      trackColor: trackColor ?? this.trackColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      linearHeight: linearHeight ?? this.linearHeight,
    );
  }

  @override
  Oito2ProgressIndicatorThemeData lerp(
    Oito2ProgressIndicatorThemeData? other,
    double t,
  ) {
    if (other == null) return this;
    return Oito2ProgressIndicatorThemeData(
      color: Color.lerp(color, other.color, t)!,
      trackColor: Color.lerp(trackColor, other.trackColor, t)!,
      strokeWidth: lerpDouble(strokeWidth, other.strokeWidth, t)!,
      linearHeight: lerpDouble(linearHeight, other.linearHeight, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2ProgressIndicatorThemeData &&
      other.color == color &&
      other.trackColor == trackColor &&
      other.strokeWidth == strokeWidth &&
      other.linearHeight == linearHeight;

  @override
  int get hashCode => Object.hash(color, trackColor, strokeWidth, linearHeight);
}
