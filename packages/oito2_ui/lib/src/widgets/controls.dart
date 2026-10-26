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

import '../foundation/contrast.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'toggles.dart';
import 'widget_helpers.dart';

/// The default padding of the check, radio and switch buttons.
const _rowPadding = EdgeInsets.symmetric(
  horizontal: Oito2Spacing.xs,
  vertical: Oito2Spacing.xxs,
);

/// A desktop check box with a clickable label: an [Oito2Checkbox] in an
/// [Oito2ToggleButton].
class Oito2CheckButton extends StatelessWidget {
  /// Creates a check button.
  const Oito2CheckButton({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.tristate = false,
    this.padding = _rowPadding,
  });

  /// Whether the box is checked; null is the mixed state when [tristate].
  final bool? value;

  /// Called with the new value; null disables the button.
  final ValueChanged<bool?>? onChanged;

  /// The label.
  final Widget title;

  /// Secondary text below the label.
  final Widget? subtitle;

  /// Whether the box cycles through a mixed state.
  final bool tristate;

  /// Space around the row.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return Oito2ToggleButton(
      control: Oito2Checkbox(
        value: value,
        tristate: tristate,
        onChanged: onChanged,
      ),
      title: title,
      subtitle: subtitle,
      padding: padding,
      onToggled: onChanged == null
          ? null
          : () => onChanged(nextCheckValue(value, tristate: tristate)),
    );
  }
}

/// A desktop radio button with a clickable label: an [Oito2Radio] in an
/// [Oito2ToggleButton].
///
/// It is selected when [value] equals [groupValue].
class Oito2RadioButton<T> extends StatelessWidget {
  /// Creates a radio button.
  const Oito2RadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.padding = _rowPadding,
    this.toggleable = false,
  });

  /// The value this button represents.
  final T value;

  /// The currently selected value of the group.
  final T? groupValue;

  /// Called with [value] when selected; null disables the button.
  final ValueChanged<T?>? onChanged;

  /// Whether activating the selected button clears the group, calling
  /// [onChanged] with null.
  final bool toggleable;

  /// The label.
  final Widget title;

  /// Secondary text below the label.
  final Widget? subtitle;

  /// Space around the row.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return Oito2ToggleButton(
      control: Oito2Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        toggleable: toggleable,
      ),
      title: title,
      subtitle: subtitle,
      padding: padding,
      onToggled: onChanged == null
          ? null
          : () => activateRadio(
              value,
              groupValue,
              onChanged,
              toggleable: toggleable,
            ),
    );
  }
}

/// A desktop switch with a clickable label placed before it: an
/// [Oito2Switch] in an [Oito2ToggleButton].
class Oito2SwitchButton extends StatelessWidget {
  /// Creates a switch button.
  const Oito2SwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.padding = _rowPadding,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value; null disables the button.
  final ValueChanged<bool>? onChanged;

  /// The label.
  final Widget title;

  /// Secondary text below the label.
  final Widget? subtitle;

  /// Space around the row.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return Oito2ToggleButton(
      control: Oito2Switch(value: value, onChanged: onChanged),
      title: title,
      subtitle: subtitle,
      padding: padding,
      controlAtEnd: true,
      onToggled: onChanged == null ? null : () => onChanged(!value),
    );
  }
}

/// The visual variant of an [Oito2SplitButton].
enum Oito2SplitButtonVariant {
  /// A neutral elevated button.
  elevated,

  /// A filled primary button.
  filled,

  /// An outlined button.
  outlined,
}

/// A button with a main action and an attached arrow that opens a menu of
/// related actions.
class Oito2SplitButton extends StatelessWidget {
  /// Creates a split button.
  const Oito2SplitButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.menuChildren,
    this.variant = Oito2SplitButtonVariant.elevated,
    this.menuLabel,
  });

  /// The main action; null disables both parts.
  final VoidCallback? onPressed;

  /// The main button label.
  final Widget child;

  /// The menu entries, usually [MenuItemButton]s.
  final List<Widget> menuChildren;

  /// The visual variant.
  final Oito2SplitButtonVariant variant;

  /// The accessibility label of the arrow part; defaults to
  /// [Oito2Localizations.moreOptions].
  final String? menuLabel;

  /// Returns a style with [radius] corners, the theme button height as
  /// [minimumHeight], no minimum width and an optional [padding].
  ButtonStyle _shape(
    BorderRadius radius,
    double minimumHeight, {
    EdgeInsetsGeometry? padding,
  }) {
    return ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: radius),
      ),
      padding: padding == null ? null : WidgetStatePropertyAll(padding),
      // Narrow parts are allowed; the height stays the theme's button
      // height.
      minimumSize: WidgetStatePropertyAll(Size(0, minimumHeight)),
    );
  }

  /// Builds a button of [variant] with [style], [onPressed] and [child].
  Widget _button(ButtonStyle style, VoidCallback? onPressed, Widget child) {
    return switch (variant) {
      Oito2SplitButtonVariant.elevated => ElevatedButton(
        style: style,
        onPressed: onPressed,
        child: child,
      ),
      Oito2SplitButtonVariant.filled => FilledButton(
        style: style,
        onPressed: onPressed,
        child: child,
      ),
      Oito2SplitButtonVariant.outlined => OutlinedButton(
        style: style,
        onPressed: onPressed,
        child: child,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(Oito2Radius.medium);
    final enabled = onPressed != null;
    final minimumHeight =
        Theme.of(context).filledButtonTheme.style?.minimumSize
            ?.resolve(const {})
            ?.height ??
        0;
    final direction = Directionality.of(context);
    final startRadius = direction == TextDirection.ltr
        ? const BorderRadius.horizontal(left: radius)
        : const BorderRadius.horizontal(right: radius);
    final endRadius = direction == TextDirection.ltr
        ? const BorderRadius.horizontal(right: radius)
        : const BorderRadius.horizontal(left: radius);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(_shape(startRadius, minimumHeight), onPressed, child),
        const SizedBox(width: 1),
        MenuAnchor(
          menuChildren: menuChildren,
          builder: (context, controller, _) => Semantics(
            label: menuLabel ?? Oito2Localizations.of(context).moreOptions,
            child: _button(
              _shape(
                endRadius,
                minimumHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: Oito2Spacing.sm,
                ),
              ),
              enabled
                  ? () => controller.isOpen
                        ? controller.close()
                        : controller.open()
                  : null,
              const Icon(LucideIcons.chevron_down),
            ),
          ),
        ),
      ],
    );
  }
}

/// A small square outlined button for secondary options, such as the
/// buttons next to a list. [Oito2OptionButton.color] shows a color swatch.
class Oito2OptionButton extends StatelessWidget {
  /// Creates an option button showing [child], with an optional
  /// [label] used as tooltip and accessibility label.
  ///
  /// An [Icon] child needs a [label], since an icon alone has no name for
  /// assistive technologies; an [AssertionError] is thrown in debug builds
  /// when it is missing.
  const Oito2OptionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.label,
  }) : color = null,
       assert(
         label != null || child is! Icon,
         'An option button showing only an icon needs a label.',
       );

  /// Creates an option button showing a [color] swatch, named by [label].
  const Oito2OptionButton.color({
    super.key,
    required this.onPressed,
    required Color this.color,
    required String this.label,
  }) : child = null;

  /// Called when the button is activated; null disables it.
  final VoidCallback? onPressed;

  /// The content, usually an [Icon].
  final Widget? child;

  /// The swatch color of [Oito2OptionButton.color].
  final Color? color;

  /// The tooltip and accessibility label.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    final content =
        child ??
        ExcludeSemantics(
          child: Container(
            width: Oito2Sizes.iconSize,
            height: Oito2Sizes.iconSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: Oito2Radius.checkAll,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        );
    final label = this.label;
    final button = OutlinedButton(
      onPressed: onPressed,
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: WidgetStatePropertyAll(
          Size.square(Oito2Sizes.buttonHeight),
        ),
        fixedSize: WidgetStatePropertyAll(Size.square(Oito2Sizes.buttonHeight)),
      ),
      child: content,
    );
    return label == null
        ? button
        : Tooltip(
            message: label,
            excludeFromSemantics: true,
            child: Semantics(label: label, child: button),
          );
  }
}

/// A round color swatch that can be selected, as in accent color pickers.
///
/// A ring in [color] itself surrounds the selected disk, and a fainter one
/// shows while the pointer hovers it or the keyboard focus is on it. A
/// disk whose color has less than 3:1 contrast with the surface gets a
/// thin outline, so it doesn't blend into the background.
class Oito2ColorDisk extends StatefulWidget {
  /// Creates a color disk.
  const Oito2ColorDisk({
    super.key,
    required this.color,
    required this.selected,
    required this.onPressed,
    required this.label,
    this.size = 20,
  });

  /// The swatch color.
  final Color color;

  /// Whether this color is the selected one.
  final bool selected;

  /// Called when the disk is activated; null disables it.
  final VoidCallback? onPressed;

  /// The color name for assistive technologies and the tooltip.
  final String label;

  /// The disk diameter, without its ring.
  final double size;

  @override
  State<Oito2ColorDisk> createState() => _Oito2ColorDiskState();
}

/// Tracks hover and focus of [Oito2ColorDisk] to show its faint ring.
class _Oito2ColorDiskState extends State<Oito2ColorDisk> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final keyboard =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final ringAlpha = widget.selected
        ? 1.0
        : _hovered || (_focused && keyboard)
        ? 0.5
        : 0.0;
    const ring = Oito2Sizes.focusBorderWidth;
    const gap = 2.0;
    // The ring keeps the disk's hue, adjusted when needed to stand out
    // from the surface, so a disk close to the background still shows it.
    final scheme = Theme.of(context).colorScheme;
    final ringColor = Oito2Contrast.ensure(widget.color.withValues(alpha: 1), [
      scheme.surface,
    ], Oito2Contrast.nonTextAA);
    final blends =
        Oito2Contrast.ratio(
          Color.alphaBlend(widget.color, scheme.surface),
          scheme.surface,
        ) <
        Oito2Contrast.nonTextAA;
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      selected: widget.selected,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: Tooltip(
        message: widget.label,
        excludeFromSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onPressed,
            onHover: (value) => setState(() => _hovered = value),
            onFocusChange: (value) => setState(() => _focused = value),
            customBorder: const CircleBorder(),
            overlayColor: const WidgetStatePropertyAll(Color(0x00000000)),
            child: Container(
              width: widget.size + 2 * (ring + gap),
              height: widget.size + 2 * (ring + gap),
              padding: const EdgeInsets.all(gap),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringColor.withValues(
                    alpha: widget.color.a * ringAlpha,
                  ),
                  width: ring,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: blends
                      ? Border.all(color: scheme.outlineVariant)
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
