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

import '../theme/extensions/chrome_colors.dart';
import '../theme/extensions/semantic_colors.dart';
import '../tokens/colors.dart';
import '../tokens/geometry.dart';

/// Returns the semantic colors of the closest theme, or colors derived
/// from its `ColorScheme` and the status palette when the theme wasn't
/// built by `Oito2Theme`.
Oito2SemanticColors semanticColorsOf(BuildContext context) {
  final extension = Oito2SemanticColors.maybeOf(context);
  if (extension != null) return extension;
  final theme = Theme.of(context);
  final status = Oito2StatusPalette.of(theme.brightness);
  return Oito2SemanticColors(
    primaryText: theme.colorScheme.primary,
    errorText: theme.colorScheme.error,
    success: status.success,
    warning: status.warning,
    info: status.info,
    link: status.link,
  );
}

/// Returns the chrome colors of the closest theme, or colors derived from
/// its scaffold background when the theme wasn't built by `Oito2Theme`.
Oito2ChromeColors chromeColorsOf(BuildContext context) {
  return Oito2ChromeColors.maybeOf(context) ??
      Oito2ChromeColors.fromTheme(Theme.of(context));
}

/// An [IconButton] placed inside a text field decoration, such as a clear
/// or picker button.
///
/// Its tap target is shrink-wrapped, so on touch platforms it stays as
/// tall as the field instead of growing the field to the padded 48-pixel
/// target; the whole field row remains the touch target.
class FieldIconButton extends StatelessWidget {
  /// Creates a field icon button.
  const FieldIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  /// The icon.
  final IconData icon;

  /// The tooltip and accessibility label.
  final String tooltip;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: Oito2Sizes.iconSize),
    );
  }
}
