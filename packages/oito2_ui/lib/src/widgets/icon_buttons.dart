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

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_helpers.dart';

/// A square icon button sized by the oito2 icon button theme to the
/// control height: 34 pixels on pointer platforms and 40 on touch
/// platforms, where the tap target is padded to 48.
///
/// With [isSelected], it is a toggle: the selected state fills the button
/// with the secondary container and shows [selectedIcon] when given, and
/// assistive technologies read its selected state. The focus ring shows
/// in keyboard navigation.
class Oito2IconButton extends StatelessWidget {
  /// Creates an icon button.
  const Oito2IconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isSelected,
    this.selectedIcon,
    this.focusNode,
    this.autofocus = false,
  });

  /// The icon, usually an [Icon]; shown while not selected when
  /// [selectedIcon] is given.
  final Widget icon;

  /// Called when the button is pressed; null disables the button.
  final VoidCallback? onPressed;

  /// The tooltip, also used as the accessibility label.
  final String? tooltip;

  /// Whether the toggle is on; null makes a plain button.
  final bool? isSelected;

  /// The icon shown while [isSelected] is true.
  final Widget? selectedIcon;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// Whether the button takes focus when first shown.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: icon,
      selectedIcon: selectedIcon,
      isSelected: isSelected,
      onPressed: onPressed,
      tooltip: tooltip,
      focusNode: focusNode,
      autofocus: autofocus,
      style: isSelected == null
          ? null
          : ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) &&
                        !states.contains(WidgetState.disabled)
                    ? scheme.secondaryContainer
                    : null,
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) &&
                        !states.contains(WidgetState.disabled)
                    ? scheme.onSecondaryContainer
                    : null,
              ),
            ),
    );
  }
}

/// An [Oito2IconButton] that goes back: a chevron pointing to the start
/// side, with the localized "Back" tooltip. By default it pops the
/// closest [Navigator] route.
class Oito2BackButton extends StatelessWidget {
  /// Creates a back button.
  const Oito2BackButton({super.key, this.onPressed, this.tooltip});

  /// Called when the button is pressed; defaults to popping the current
  /// route.
  final VoidCallback? onPressed;

  /// The tooltip; defaults to the localized "Back".
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Oito2IconButton(
      icon: Icon(directionalChevron(context, forward: false)),
      tooltip: tooltip ?? MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
  }
}

/// An [Oito2IconButton] that closes: an "x" with the localized "Close"
/// tooltip. By default it pops the closest [Navigator] route.
class Oito2CloseButton extends StatelessWidget {
  /// Creates a close button.
  const Oito2CloseButton({super.key, this.onPressed, this.tooltip});

  /// Called when the button is pressed; defaults to popping the current
  /// route.
  final VoidCallback? onPressed;

  /// The tooltip; defaults to the localized "Close".
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Oito2IconButton(
      icon: const Icon(LucideIcons.x),
      tooltip: tooltip ?? MaterialLocalizations.of(context).closeButtonTooltip,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
  }
}
