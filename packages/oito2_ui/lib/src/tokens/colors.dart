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

/// The neutral GTK-style surface, text and border colors of the oito2 base
/// scheme, for one brightness.
///
/// Surfaces go from [surfaceContainerLowest] to [surfaceContainerHighest];
/// [onSurface] and [onSurfaceVariant] reach a 4.5:1 contrast ratio on all
/// of them, and [outline] reaches 3:1.
@immutable
class Oito2NeutralPalette {
  /// Creates a neutral palette from explicit colors.
  const Oito2NeutralPalette({
    required this.brightness,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.titleBar,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
  });

  /// The light neutral palette.
  static const light = Oito2NeutralPalette(
    brightness: Brightness.light,
    surface: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFAFAFA),
    surfaceContainer: Color(0xFFF5F5F5),
    surfaceContainerHigh: Color(0xFFEFEFEF),
    surfaceContainerHighest: Color(0xFFE8E8E8),
    titleBar: Color(0xFFEBEBEB),
    onSurface: Color(0xFF202020),
    onSurfaceVariant: Color(0xFF5E5E5E),
    outline: Color(0xFF7E7E7E),
    outlineVariant: Color(0xFFD9D9D9),
  );

  /// The dark neutral palette.
  static const dark = Oito2NeutralPalette(
    brightness: Brightness.dark,
    surface: Color(0xFF202020),
    surfaceContainerLowest: Color(0xFF1A1A1A),
    surfaceContainerLow: Color(0xFF242424),
    surfaceContainer: Color(0xFF2A2A2A),
    surfaceContainerHigh: Color(0xFF303030),
    surfaceContainerHighest: Color(0xFF383838),
    titleBar: Color(0xFF303030),
    onSurface: Color(0xFFF7F7F7),
    onSurfaceVariant: Color(0xFFBDBDBD),
    outline: Color(0xFF8A8A8A),
    outlineVariant: Color(0xFF3D3D3D),
  );

  /// Returns [light] or [dark] for [brightness].
  static Oito2NeutralPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// The brightness this palette is designed for.
  final Brightness brightness;

  /// The default surface for content.
  final Color surface;

  /// The lowest-emphasis container surface.
  final Color surfaceContainerLowest;

  /// A low-emphasis container surface.
  final Color surfaceContainerLow;

  /// The default container surface.
  final Color surfaceContainer;

  /// A high-emphasis container surface.
  final Color surfaceContainerHigh;

  /// The highest-emphasis container surface.
  final Color surfaceContainerHighest;

  /// The window title bar background.
  final Color titleBar;

  /// Primary text and icons on any surface.
  final Color onSurface;

  /// Secondary text and icons on any surface.
  final Color onSurfaceVariant;

  /// Borders of interactive components, such as input fields.
  final Color outline;

  /// Decorative borders and dividers.
  final Color outlineVariant;

  /// All surfaces of this palette: [surface], the containers from
  /// [surfaceContainerLowest] to [surfaceContainerHighest], and [titleBar].
  List<Color> get surfaces => [
    surface,
    surfaceContainerLowest,
    surfaceContainerLow,
    surfaceContainer,
    surfaceContainerHigh,
    surfaceContainerHighest,
    titleBar,
  ];
}

/// The named accent colors available to the oito2 base scheme, taken from
/// the GNOME accent color palette.
enum Oito2AccentColor {
  /// Blue, the default accent: #3584E4.
  blue(Color(0xFF3584E4)),

  /// Teal: #2190A4.
  teal(Color(0xFF2190A4)),

  /// Green: #3A944A.
  green(Color(0xFF3A944A)),

  /// Yellow: #C88800.
  yellow(Color(0xFFC88800)),

  /// Orange: #ED5B00.
  orange(Color(0xFFED5B00)),

  /// Red: #E62D42.
  red(Color(0xFFE62D42)),

  /// Pink: #D56199.
  pink(Color(0xFFD56199)),

  /// Purple: #9141AC.
  purple(Color(0xFF9141AC)),

  /// Slate: #6F8396.
  slate(Color(0xFF6F8396));

  const Oito2AccentColor(this.color);

  /// The default accent color.
  static const Oito2AccentColor fallback = blue;

  /// The color value of this accent.
  final Color color;
}

/// Status colors for messages, badges and links, for one brightness.
///
/// Every color reaches a 4.5:1 contrast ratio, readable as text, on all
/// surfaces of the [Oito2NeutralPalette] with the same brightness.
@immutable
class Oito2StatusPalette {
  /// Creates a status palette from explicit colors.
  const Oito2StatusPalette({
    required this.brightness,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.link,
  });

  /// Status colors for light surfaces.
  static const light = Oito2StatusPalette(
    brightness: Brightness.light,
    success: Color(0xFF187549),
    warning: Color(0xFF886003),
    error: Color(0xFFC01C28),
    info: Color(0xFF1966C2),
    link: Color(0xFF1966C2),
  );

  /// Status colors for dark surfaces.
  static const dark = Oito2StatusPalette(
    brightness: Brightness.dark,
    success: Color(0xFF8FF0A4),
    warning: Color(0xFFF8E45C),
    error: Color(0xFFFF7B63),
    info: Color(0xFF78AEED),
    link: Color(0xFF78AEED),
  );

  /// Returns [light] or [dark] for [brightness].
  static Oito2StatusPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// The brightness this palette is designed for.
  final Brightness brightness;

  /// Successful or positive outcomes.
  final Color success;

  /// Warnings that need attention.
  final Color warning;

  /// Errors and destructive actions.
  final Color error;

  /// Neutral information.
  final Color info;

  /// Hyperlinks.
  final Color link;

  /// All colors of this palette.
  List<Color> get colors => [success, warning, error, info, link];
}
