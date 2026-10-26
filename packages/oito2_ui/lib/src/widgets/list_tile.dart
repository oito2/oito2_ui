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

import '../tokens/geometry.dart';
import 'utilities.dart';

/// An interactive row with a title, an optional subtitle and widgets on
/// both sides, styled for desktop lists and settings pages.
///
/// Unlike [Oito2Tile], it is meant to be activated: it shows hover and
/// selected states, takes keyboard focus with the oito2 focus ring and
/// reads as a button to assistive technologies when it has [onTap]. Use
/// [Oito2ListTile.square] inside an `Oito2TileList`, whose border already
/// rounds the corners.
///
/// The row is at least 40 pixels tall (52 with a subtitle) on pointer
/// platforms and 56 (72) on touch platforms.
class Oito2ListTile extends StatelessWidget {
  /// Creates a list tile with rounded corners.
  ///
  /// Throws an [AssertionError] in debug builds when both [title] and
  /// [titleText], or both [subtitle] and [subtitleText], are given.
  const Oito2ListTile({
    super.key,
    this.leading,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.enabled = true,
    this.centerTitle = false,
    this.borderRadius = Oito2Radius.mediumAll,
    this.contentPadding,
    this.horizontalGap = Oito2Spacing.md,
    this.focusNode,
    this.autofocus = false,
  }) : assert(title == null || titleText == null),
       assert(subtitle == null || subtitleText == null);

  /// Creates a list tile with square corners, for tile lists.
  ///
  /// Throws an [AssertionError] in debug builds when both [title] and
  /// [titleText], or both [subtitle] and [subtitleText], are given.
  const Oito2ListTile.square({
    super.key,
    this.leading,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.enabled = true,
    this.centerTitle = false,
    this.contentPadding,
    this.horizontalGap = Oito2Spacing.md,
    this.focusNode,
    this.autofocus = false,
  }) : borderRadius = BorderRadius.zero,
       assert(title == null || titleText == null),
       assert(subtitle == null || subtitleText == null);

  /// A widget before the title, usually an icon.
  final Widget? leading;

  /// The primary content.
  final Widget? title;

  /// The primary text, as a shortcut for a [Text] [title].
  final String? titleText;

  /// The secondary content below the title.
  final Widget? subtitle;

  /// The secondary text, as a shortcut for a [Text] [subtitle].
  final String? subtitleText;

  /// A widget after the title, such as a switch or a chevron.
  final Widget? trailing;

  /// Called when the row is activated; without it the row is static.
  final VoidCallback? onTap;

  /// Whether the row is highlighted as selected.
  final bool selected;

  /// Whether the row responds to input; a disabled row is dimmed.
  final bool enabled;

  /// Whether the title and subtitle are centered.
  final bool centerTitle;

  /// The corner radius of the hover, selection and focus shapes.
  final BorderRadius borderRadius;

  /// Space around the row content; defaults to medium horizontal and
  /// extra-small vertical spacing.
  final EdgeInsetsGeometry? contentPadding;

  /// Space between [leading], the text and [trailing].
  final double horizontalGap;

  /// The focus node of the row; one is created when null.
  final FocusNode? focusNode;

  /// Whether the row takes focus when first shown.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final touch = theme.materialTapTargetSize == MaterialTapTargetSize.padded;
    final title = this.title ?? (titleText == null ? null : Text(titleText!));
    final subtitle =
        this.subtitle ?? (subtitleText == null ? null : Text(subtitleText!));
    final minHeight = switch ((touch, subtitle != null)) {
      (false, false) => 40.0,
      (false, true) => 52.0,
      (true, false) => 56.0,
      (true, true) => 72.0,
    };
    final disabledTone = scheme.onSurface.withValues(alpha: 0.38);
    final foreground = !enabled
        ? disabledTone
        : selected
        ? scheme.onSecondaryContainer
        : scheme.onSurface;
    final secondary = !enabled
        ? disabledTone
        : selected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    final align = centerTitle
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final leading = this.leading;
    final trailing = this.trailing;

    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding:
            contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: Oito2Spacing.md,
              vertical: Oito2Spacing.xs,
            ),
        child: Row(
          spacing: horizontalGap,
          children: [
            if (leading != null)
              IconTheme.merge(
                data: IconThemeData(color: secondary),
                child: leading,
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: align,
                children: [
                  if (title != null)
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: foreground,
                      ),
                      textAlign: centerTitle ? TextAlign.center : null,
                      child: title,
                    ),
                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: secondary,
                      ),
                      textAlign: centerTitle ? TextAlign.center : null,
                      child: subtitle,
                    ),
                ],
              ),
            ),
            if (trailing != null)
              IconTheme.merge(
                data: IconThemeData(color: secondary),
                child: trailing,
              ),
          ],
        ),
      ),
    );

    final interactive = onTap != null && enabled;
    // Static rows declare no enabled state and unselected rows no selected
    // state, which a screen reader would otherwise read on every row.
    return Semantics(
      button: onTap != null,
      enabled: onTap != null ? enabled : null,
      selected: selected ? true : null,
      child: Oito2FocusBorder(
        borderRadius: borderRadius,
        child: Material(
          color: selected ? scheme.secondaryContainer : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            mouseCursor: WidgetStateMouseCursor.clickable,
            onTap: interactive ? onTap : null,
            canRequestFocus: interactive,
            focusNode: focusNode,
            autofocus: autofocus,
            focusColor: Colors.transparent,
            child: content,
          ),
        ),
      ),
    );
  }
}
