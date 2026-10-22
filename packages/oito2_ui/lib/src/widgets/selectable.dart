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

import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// A clickable surface that shows hover, keyboard focus and selection.
///
/// The focus ring and the selected border use the text-safe primary tone,
/// so they reach 3:1 against every surface.
class _InteractiveSurface extends StatefulWidget {
  const _InteractiveSurface({
    required this.child,
    required this.onTap,
    required this.selected,
    required this.color,
    required this.borderColor,
    required this.hoverBorderColor,
    required this.borderRadius,
    required this.padding,
    this.selectedColor,
    this.onHover,
  });

  final Widget child;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;
  final bool selected;
  final Color? color;
  final Color borderColor;
  final Color hoverBorderColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? selectedColor;

  @override
  State<_InteractiveSurface> createState() => _InteractiveSurfaceState();
}

class _InteractiveSurfaceState extends State<_InteractiveSurface> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final indicator = semanticColorsOf(context).primaryText;
    final interactive = widget.onTap != null;
    final selectedColor =
        widget.selectedColor ?? scheme.primary.withValues(alpha: 0.12);
    final background = widget.selected
        ? Color.alphaBlend(selectedColor, widget.color ?? scheme.surface)
        : widget.color;
    final borderColor = widget.selected
        ? indicator
        : (_hovered && interactive
              ? widget.hoverBorderColor
              : widget.borderColor);
    final borderWidth = widget.selected ? Oito2Sizes.focusBorderWidth : 1.0;

    void hover(bool value) {
      setState(() => _hovered = value);
      widget.onHover?.call(value);
    }

    // The pointer is tracked even without onTap, so onHover always runs.
    return Semantics(
      container: true,
      button: interactive,
      selected: widget.selected,
      child: MouseRegion(
        onEnter: (_) => hover(true),
        onExit: (_) => hover(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            border: _focused
                ? Border.all(
                    color: indicator,
                    width: Oito2Sizes.focusBorderWidth,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  )
                : null,
          ),
          child: Material(
            color: background ?? const Color(0x00000000),
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius,
              side: BorderSide(color: borderColor, width: borderWidth),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onFocusChange: (value) => setState(() => _focused = value),
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// A container that can be selected, such as an option in a grid of
/// choices. Selection shows as a tinted background with a 2-pixel border
/// in the text-safe primary tone.
class Oito2SelectableContainer extends StatelessWidget {
  /// Creates a selectable container.
  const Oito2SelectableContainer({
    super.key,
    required this.child,
    required this.selected,
    this.onTap,
    this.padding = const EdgeInsets.all(Oito2Spacing.sm),
    this.borderRadius = Oito2Radius.largeAll,
    this.selectionColor,
  });

  /// The content.
  final Widget child;

  /// Whether the container is selected.
  final bool selected;

  /// Called when the container is activated.
  final VoidCallback? onTap;

  /// Space around the content.
  final EdgeInsetsGeometry padding;

  /// The corner radius.
  final BorderRadius borderRadius;

  /// The tint applied when selected; defaults to the primary color at 12%
  /// opacity.
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _InteractiveSurface(
      onTap: onTap,
      selected: selected,
      color: null,
      borderColor: const Color(0x00000000),
      hoverBorderColor: scheme.outlineVariant,
      borderRadius: borderRadius,
      padding: padding,
      selectedColor: selectionColor,
      child: child,
    );
  }
}

/// A card-like clickable surface for promoting content, such as an app in
/// a store grid. Hovering strengthens its border.
///
/// [Oito2Banner.tile] lays out an icon, a title and a subtitle. [onHover]
/// tells when the pointer enters and leaves, so the content can change
/// on hover, and [tint] washes the background with a color.
class Oito2Banner extends StatelessWidget {
  /// Creates a banner around [child].
  const Oito2Banner({
    super.key,
    required this.child,
    this.onTap,
    this.onHover,
    this.selected = false,
    this.color,
    this.tint,
    this.padding = const EdgeInsets.all(Oito2Spacing.lg),
  });

  /// Creates a banner with [icon] before a [title] and an optional
  /// [subtitle].
  Oito2Banner.tile({
    Key? key,
    required Widget title,
    Widget? subtitle,
    Widget? icon,
    VoidCallback? onTap,
    ValueChanged<bool>? onHover,
    bool selected = false,
    Color? color,
    Color? tint,
    EdgeInsetsGeometry padding = const EdgeInsets.all(Oito2Spacing.lg),
  }) : this(
         key: key,
         onTap: onTap,
         onHover: onHover,
         selected: selected,
         color: color,
         tint: tint,
         padding: padding,
         child: _BannerTile(title: title, subtitle: subtitle, icon: icon),
       );

  /// The content.
  final Widget child;

  /// Called when the banner is activated.
  final VoidCallback? onTap;

  /// Called with true when the pointer enters the banner and false when
  /// it leaves.
  final ValueChanged<bool>? onHover;

  /// Whether the banner is selected.
  final bool selected;

  /// The background; defaults to the scheme surface.
  final Color? color;

  /// A color blended lightly over the background.
  final Color? tint;

  /// Space around the content.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = color ?? scheme.surface;
    final tint = this.tint;
    return _InteractiveSurface(
      onTap: onTap,
      onHover: onHover,
      selected: selected,
      color: tint == null
          ? base
          : Color.alphaBlend(tint.withValues(alpha: 0.08), base),
      borderColor: scheme.outlineVariant,
      hoverBorderColor: scheme.outline,
      borderRadius: Oito2Radius.largeAll,
      padding: padding,
      child: child,
    );
  }
}

/// The icon, title and subtitle of an [Oito2Banner.tile].
class _BannerTile extends StatelessWidget {
  const _BannerTile({required this.title, this.subtitle, this.icon});

  final Widget title;
  final Widget? subtitle;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;
    final icon = this.icon;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Oito2Spacing.lg,
      children: [
        ?icon,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.xs,
            children: [
              DefaultTextStyle.merge(
                style: theme.textTheme.titleMedium,
                child: title,
              ),
              if (subtitle != null)
                DefaultTextStyle.merge(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  child: subtitle,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
