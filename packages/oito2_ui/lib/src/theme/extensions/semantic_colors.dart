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

/// Text-safe accent and status colors of an oito2 scheme.
///
/// Every color reaches at least a 4.5:1 contrast ratio against every
/// surface of the scheme it belongs to, so it can color text, links,
/// icons and focus indicators. The `ColorScheme.primary` and
/// `ColorScheme.error` fills keep the scheme's own colors, which may not
/// reach that ratio.
@immutable
class Oito2SemanticColors extends ThemeExtension<Oito2SemanticColors> {
  /// Creates semantic colors from explicit values.
  const Oito2SemanticColors({
    required this.primaryText,
    required this.errorText,
    required this.success,
    required this.warning,
    required this.info,
    required this.link,
  });

  /// Returns the semantic colors of the closest [Theme], or null when the
  /// theme has none.
  static Oito2SemanticColors? maybeOf(BuildContext context) =>
      Theme.of(context).extension<Oito2SemanticColors>();

  /// The primary accent hue, adjusted for text on surfaces.
  final Color primaryText;

  /// The error hue, adjusted for text on surfaces, such as validation
  /// messages.
  final Color errorText;

  /// Successful or positive outcomes.
  final Color success;

  /// Warnings that need attention.
  final Color warning;

  /// Neutral information.
  final Color info;

  /// Hyperlinks.
  final Color link;

  @override
  Oito2SemanticColors copyWith({
    Color? primaryText,
    Color? errorText,
    Color? success,
    Color? warning,
    Color? info,
    Color? link,
  }) {
    return Oito2SemanticColors(
      primaryText: primaryText ?? this.primaryText,
      errorText: errorText ?? this.errorText,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      link: link ?? this.link,
    );
  }

  @override
  Oito2SemanticColors lerp(Oito2SemanticColors? other, double t) {
    if (other == null) return this;
    return Oito2SemanticColors(
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      link: Color.lerp(link, other.link, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2SemanticColors &&
      other.primaryText == primaryText &&
      other.errorText == errorText &&
      other.success == success &&
      other.warning == warning &&
      other.info == info &&
      other.link == link;

  @override
  int get hashCode =>
      Object.hash(primaryText, errorText, success, warning, info, link);
}
