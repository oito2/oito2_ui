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

import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/list_collection.dart';
import '../tokens/geometry.dart';
import 'toggles.dart';

/// A button that looks like a field and opens a menu of [menuChildren]
/// below it, for choices that don't fit a segmented button.
///
/// The button is as tall as the text fields, shows [child] and a chevron,
/// and opens the menu on a click, Enter, Space or the Down arrow; the menu
/// is a `MenuAnchor`, navigated with the arrow keys. Use
/// [Oito2CheckedMenuItem] and [Oito2MultiSelectMenuItem] for choices, or
/// [Oito2Select] for a value picked from a collection.
class Oito2PopupMenuButton extends StatelessWidget {
  /// Creates a popup menu button.
  const Oito2PopupMenuButton({
    super.key,
    required this.child,
    required this.menuChildren,
    this.enabled = true,
    this.leading,
    this.tooltip,
    this.semanticLabel,
    this.focusNode,
  });

  /// The button content, usually the current choice as a [Text].
  final Widget child;

  /// The menu entries.
  final List<Widget> menuChildren;

  /// Whether the button opens its menu.
  final bool enabled;

  /// An optional icon before [child].
  final Widget? leading;

  /// A tooltip for the button.
  final String? tooltip;

  /// The accessibility label; defaults to the text of [child].
  final String? semanticLabel;

  /// The focus node of the button.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      menuChildren: menuChildren,
      builder: (context, controller, _) {
        void toggle() =>
            controller.isOpen ? controller.close() : controller.open();
        final button = CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () {
              if (enabled && !controller.isOpen) controller.open();
            },
          },
          child: Semantics(
            expanded: controller.isOpen,
            label: semanticLabel,
            child: OutlinedButton(
              focusNode: focusNode,
              onPressed: enabled ? toggle : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: scheme.surfaceContainerHigh,
                foregroundColor: scheme.onSurface,
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsetsDirectional.only(
                  start: Oito2Spacing.md,
                  end: Oito2Spacing.sm,
                ),
                side: BorderSide(color: scheme.outline),
                shape: const RoundedRectangleBorder(
                  borderRadius: Oito2Radius.mediumAll,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Oito2Spacing.sm,
                children: [
                  ?leading,
                  Flexible(
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                      child: child,
                    ),
                  ),
                  Icon(
                    controller.isOpen
                        ? LucideIcons.chevron_up
                        : LucideIcons.chevron_down,
                    size: Oito2Sizes.iconSize,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
        final tooltip = this.tooltip;
        return tooltip == null
            ? button
            : Tooltip(message: tooltip, child: button);
      },
    );
  }
}

/// A menu item that shows a check mark when [checked], for single choices
/// in an [Oito2PopupMenuButton]; it closes the menu when activated.
class Oito2CheckedMenuItem extends StatelessWidget {
  /// Creates a checked menu item.
  const Oito2CheckedMenuItem({
    super.key,
    required this.checked,
    required this.onPressed,
    required this.child,
  });

  /// Whether the check mark shows.
  final bool checked;

  /// Called when the item is activated; null disables it.
  final VoidCallback? onPressed;

  /// The item label.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The checked state joins the button's own node.
    return MergeSemantics(
      child: Semantics(
        checked: checked,
        inMutuallyExclusiveGroup: true,
        child: MenuItemButton(
          onPressed: onPressed,
          leadingIcon: checked
              ? const Icon(LucideIcons.check, size: Oito2Sizes.iconSize)
              : const SizedBox.square(dimension: Oito2Sizes.iconSize),
          child: child,
        ),
      ),
    );
  }
}

/// A menu item with a check box, for multiple choices in an
/// [Oito2PopupMenuButton]; the menu stays open, so several items can be
/// toggled in a row.
class Oito2MultiSelectMenuItem extends StatelessWidget {
  /// Creates a multi-select menu item.
  const Oito2MultiSelectMenuItem({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.child,
  });

  /// Whether the item is checked.
  final bool checked;

  /// Called with the new state; null disables the item.
  final ValueChanged<bool>? onChanged;

  /// The item label.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    // The button's node carries the checked state; the painted check box
    // adds no node of its own.
    return MergeSemantics(
      child: Semantics(
        checked: checked,
        child: MenuItemButton(
          closeOnActivate: false,
          onPressed: onChanged == null ? null : () => onChanged(!checked),
          leadingIcon: ExcludeSemantics(
            child: ExcludeFocus(
              child: IgnorePointer(
                child: Oito2Checkbox(
                  value: checked,
                  onChanged: onChanged == null ? null : (_) {},
                ),
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// An [Oito2PopupMenuButton] that picks one value of a [collection]: the
/// button shows the selected item's label (or [placeholder]), and the menu
/// lists the items under their group names, with a check mark on the
/// selected one and disabled items greyed out.
class Oito2Select<T> extends StatelessWidget {
  /// Creates a select.
  const Oito2Select({
    super.key,
    required this.collection,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.leading,
    this.semanticLabel,
  });

  /// The choices.
  final Oito2ListCollection<T> collection;

  /// The selected value, or null.
  final String? value;

  /// Called with the chosen value; null disables the select.
  final ValueChanged<String>? onChanged;

  /// Shown when nothing is selected.
  final Widget? placeholder;

  /// An optional icon before the label.
  final Widget? leading;

  /// The accessibility label of the button.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = collection.find(value);
    final onChanged = this.onChanged;
    return Oito2PopupMenuButton(
      enabled: onChanged != null,
      leading: leading,
      semanticLabel: semanticLabel,
      menuChildren: [
        for (final group in collection.groups) ...[
          if (group.group case final name?)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Oito2Spacing.md,
                Oito2Spacing.sm,
                Oito2Spacing.md,
                Oito2Spacing.xxs,
              ),
              child: Text(
                name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final item in group.items)
            Oito2CheckedMenuItem(
              checked: collection.valueOf(item) == value,
              onPressed: collection.isDisabled(item) || onChanged == null
                  ? null
                  : () => onChanged(collection.valueOf(item)),
              child: Text(collection.labelOf(item)),
            ),
        ],
      ],
      child: selected == null
          ? DefaultTextStyle.merge(
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              child: placeholder ?? const SizedBox.shrink(),
            )
          : Text(collection.labelOf(selected)),
    );
  }
}
