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

/// A container with a thin `outlineVariant` border, the large radius and
/// the scheme surface as background.
///
/// It paints on a [Material], so ink effects of widgets inside it, such as
/// [ListTile] hover and splashes, show on its surface.
class Oito2BorderContainer extends StatelessWidget {
  /// Creates a bordered container.
  const Oito2BorderContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.borderRadius = Oito2Radius.largeAll,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Creates a container tinted with [tint]: a [tint] border over a fill
  /// of [tint] at [opacity], such as a status color for a highlighted
  /// note.
  Oito2BorderContainer.tinted({
    super.key,
    required Color tint,
    double opacity = 0.1,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = Oito2Radius.largeAll,
    this.clipBehavior = Clip.antiAlias,
  }) : assert(opacity >= 0 && opacity <= 1),
       color = tint.withValues(alpha: tint.a * opacity),
       borderColor = tint;

  /// The content.
  final Widget? child;

  /// Space inside the border.
  final EdgeInsetsGeometry? padding;

  /// Space outside the border.
  final EdgeInsetsGeometry? margin;

  /// A fixed width.
  final double? width;

  /// A fixed height.
  final double? height;

  /// The background; defaults to the scheme surface.
  final Color? color;

  /// The border color; defaults to the scheme `outlineVariant`.
  final Color? borderColor;

  /// The corner radius.
  final BorderRadius borderRadius;

  /// How the content is clipped to the rounded border.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final padding = this.padding;
    final child = this.child;
    Widget result = Material(
      color: color ?? scheme.surface,
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: borderColor ?? scheme.outlineVariant),
      ),
      child: padding == null || child == null
          ? child
          : Padding(padding: padding, child: child),
    );
    if (width != null || height != null) {
      result = SizedBox(width: width, height: height, child: result);
    }
    final margin = this.margin;
    return margin == null ? result : Padding(padding: margin, child: result);
  }
}

/// A titled group of content: a headline with optional actions above a
/// [Oito2BorderContainer].
class Oito2Section extends StatelessWidget {
  /// Creates a section.
  const Oito2Section({
    super.key,
    this.headline,
    this.actions = const [],
    required this.child,
    this.padding = const EdgeInsets.all(Oito2Spacing.lg),
    this.margin,
  });

  /// The section title, usually a [Text]; exposed as a header to
  /// assistive technologies.
  final Widget? headline;

  /// Widgets placed at the end of the headline row, such as buttons.
  final List<Widget> actions;

  /// The section content.
  final Widget child;

  /// Space inside the bordered container.
  final EdgeInsetsGeometry padding;

  /// Space around the whole section.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final headline = this.headline;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (headline != null || actions.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: Oito2Spacing.xs,
                bottom: Oito2Spacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: headline == null
                        ? const SizedBox.shrink()
                        : Semantics(
                            header: true,
                            child: DefaultTextStyle.merge(
                              style: Theme.of(context).textTheme.titleMedium,
                              child: headline,
                            ),
                          ),
                  ),
                  ...actions,
                ],
              ),
            ),
          Oito2BorderContainer(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// A row with an optional leading widget, a title, a subtitle and a
/// trailing widget, as used in settings and property lists.
///
/// With [onTap] the whole row is a button.
class Oito2Tile extends StatelessWidget {
  /// Creates a tile.
  const Oito2Tile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Oito2Spacing.lg,
      vertical: Oito2Spacing.md,
    ),
  });

  /// A widget before the text, usually an icon.
  final Widget? leading;

  /// The primary text.
  final Widget? title;

  /// The secondary text, below the title.
  final Widget? subtitle;

  /// A widget after the text, such as a switch or a value.
  final Widget? trailing;

  /// Called when the tile is activated; null makes the tile static.
  final VoidCallback? onTap;

  /// Whether the tile can be interacted with; disabled tiles are dimmed.
  final bool enabled;

  /// Space around the content.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = enabled
        ? scheme.onSurface
        : scheme.onSurface.withValues(alpha: 0.38);
    final secondary = enabled
        ? scheme.onSurfaceVariant
        : scheme.onSurface.withValues(alpha: 0.38);
    final title = this.title;
    final subtitle = this.subtitle;
    final leading = this.leading;
    final trailing = this.trailing;

    Widget content = Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: secondary),
              child: leading,
            ),
            const SizedBox(width: Oito2Spacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  DefaultTextStyle.merge(
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: foreground,
                    ),
                    child: title,
                  ),
                if (subtitle != null)
                  DefaultTextStyle.merge(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondary,
                    ),
                    child: subtitle,
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: Oito2Spacing.md),
            trailing,
          ],
        ],
      ),
    );

    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: enabled ? onTap : null, child: content),
      );
    }
    return Semantics(container: true, enabled: enabled, child: content);
  }
}

/// A bordered list of [Oito2Tile]s separated by dividers.
class Oito2TileList extends StatelessWidget {
  /// Creates a tile list.
  const Oito2TileList({super.key, required this.children});

  /// The tiles, in order.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Oito2BorderContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Places a faint [watermark] behind [child], for example a large icon
/// in an empty page. The watermark is hidden from assistive technologies
/// and ignores pointer events.
///
/// The watermark covers the area [child] takes; to watermark a whole page,
/// give [child] the full size, for example with [Center] or [Align].
class Oito2Watermark extends StatelessWidget {
  /// Creates a watermarked area.
  const Oito2Watermark({
    super.key,
    required this.watermark,
    required this.child,
    this.alignment = AlignmentDirectional.centerEnd,
    this.padding = const EdgeInsets.all(Oito2Spacing.page),
    this.opacity = 0.1,
  });

  /// The decorative widget.
  final Widget watermark;

  /// The content drawn over the watermark.
  final Widget child;

  /// Where the watermark sits.
  final AlignmentGeometry alignment;

  /// Space between the watermark and the edges.
  final EdgeInsetsGeometry padding;

  /// The watermark opacity.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: Padding(
                padding: padding,
                child: Align(
                  alignment: alignment,
                  child: Opacity(opacity: opacity, child: watermark),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
