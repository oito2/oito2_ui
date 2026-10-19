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

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../foundation/contrast.dart';
import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// A compact row with a toggle [control] and a clickable [title] and
/// [subtitle]: clicking anywhere on the row activates the control, and the
/// row reads as one element to assistive technologies.
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.control,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.padding,
    this.controlAtEnd = false,
  });

  final Widget control;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool controlAtEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;
    final foreground = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);
    final subtitle = this.subtitle;
    final text = Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultTextStyle.merge(
            style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            child: title,
          ),
          if (subtitle != null)
            DefaultTextStyle.merge(
              style: theme.textTheme.bodySmall?.copyWith(
                color: enabled
                    ? theme.colorScheme.onSurfaceVariant
                    : foreground,
              ),
              child: subtitle,
            ),
        ],
      ),
    );
    return MergeSemantics(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          canRequestFocus: false,
          borderRadius: Oito2Radius.smallAll,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.sm,
              children: controlAtEnd ? [text, control] : [control, text],
            ),
          ),
        ),
      ),
    );
  }
}

const _rowPadding = EdgeInsets.symmetric(
  horizontal: Oito2Spacing.xs,
  vertical: Oito2Spacing.xxs,
);

/// A desktop check box with a clickable label.
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

  bool? get _next => switch (value) {
    false => true,
    true => tristate ? null : false,
    null => false,
  };

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return _ToggleRow(
      control: Checkbox(value: value, tristate: tristate, onChanged: onChanged),
      title: title,
      subtitle: subtitle,
      padding: padding,
      onTap: onChanged == null ? null : () => onChanged(_next),
    );
  }
}

/// A desktop radio button with a clickable label.
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
  });

  /// The value this button represents.
  final T value;

  /// The currently selected value of the group.
  final T? groupValue;

  /// Called with [value] when selected; null disables the button.
  final ValueChanged<T?>? onChanged;

  /// The label.
  final Widget title;

  /// Secondary text below the label.
  final Widget? subtitle;

  /// Space around the row.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return _ToggleRow(
      control: RadioGroup<T>(
        groupValue: groupValue,
        onChanged: onChanged ?? (_) {},
        child: Radio<T>(value: value, enabled: onChanged != null),
      ),
      title: title,
      subtitle: subtitle,
      padding: padding,
      onTap: onChanged == null ? null : () => onChanged(value),
    );
  }
}

/// A desktop switch with a clickable label placed before it.
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
    return _ToggleRow(
      control: Switch(value: value, onChanged: onChanged),
      title: title,
      subtitle: subtitle,
      padding: padding,
      controlAtEnd: true,
      onTap: onChanged == null ? null : () => onChanged(!value),
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

  ButtonStyle _shape(BorderRadius radius, {EdgeInsetsGeometry? padding}) {
    return ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: radius),
      ),
      padding: padding == null ? null : WidgetStatePropertyAll(padding),
      minimumSize: const WidgetStatePropertyAll(Size(0, 0)),
    );
  }

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
        _button(_shape(startRadius), onPressed, child),
        const SizedBox(width: 1),
        MenuAnchor(
          menuChildren: menuChildren,
          builder: (context, controller, _) => Semantics(
            label: menuLabel ?? Oito2Localizations.of(context).moreOptions,
            child: _button(
              _shape(
                endRadius,
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
  const Oito2OptionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.label,
  }) : color = null;

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
/// The selected disk shows a check mark in black or white, whichever
/// contrasts more with [color], and a ring in the text-safe primary tone.
class Oito2ColorDisk extends StatelessWidget {
  /// Creates a color disk.
  const Oito2ColorDisk({
    super.key,
    required this.color,
    required this.selected,
    required this.onPressed,
    required this.label,
    this.size = 32,
  });

  /// The swatch color.
  final Color color;

  /// Whether this color is the selected one.
  final bool selected;

  /// Called when the disk is activated.
  final VoidCallback? onPressed;

  /// The color name for assistive technologies and the tooltip.
  final String label;

  /// The disk diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final ring = semanticColorsOf(context).primaryText;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: size + 8,
              height: size + 8,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? ring : const Color(0x00000000),
                  width: Oito2Sizes.focusBorderWidth,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: selected
                    ? Icon(
                        LucideIcons.check,
                        size: size * 0.55,
                        color: Oito2Contrast.foregroundFor(color),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
