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
import '../theme/extensions/semantic_colors.dart';
import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// The kind of message shown by [Oito2InfoBox] and [Oito2InfoBadge].
enum Oito2InfoType {
  /// Neutral information.
  information(LucideIcons.info),

  /// A successful or positive outcome.
  success(LucideIcons.circle_check),

  /// Something that needs attention.
  warning(LucideIcons.triangle_alert),

  /// An error or a destructive consequence.
  danger(LucideIcons.circle_x),

  /// Something the user should notice, in the accent color.
  important(LucideIcons.star);

  const Oito2InfoType(this.icon);

  /// The icon that represents this kind.
  final IconData icon;

  /// Returns the localized name of this kind from [strings], such as
  /// "Warning", for assistive technologies.
  String labelIn(Oito2Localizations strings) => switch (this) {
    information => strings.infoInformation,
    success => strings.infoSuccess,
    warning => strings.infoWarning,
    danger => strings.infoDanger,
    important => strings.infoImportant,
  };

  /// Returns the color of this kind in [colors].
  Color colorIn(Oito2SemanticColors colors) => switch (this) {
    information => colors.info,
    success => colors.success,
    warning => colors.warning,
    danger => colors.errorText,
    important => colors.primaryText,
  };
}

/// Returns the tinted background and the readable foreground for [type]
/// over the scheme surface: the type color at [tint] opacity for the
/// background and the type color adjusted to reach 4.5:1 on it.
(Color background, Color foreground) _infoColors(
  BuildContext context,
  Oito2InfoType type,
  double tint,
) {
  final surface = Theme.of(context).colorScheme.surface;
  final color = type.colorIn(semanticColorsOf(context));
  final background = Color.alphaBlend(color.withValues(alpha: tint), surface);
  return (
    background,
    Oito2Contrast.ensure(color, [background], Oito2Contrast.textAA),
  );
}

/// A message box tinted by its [type], with an icon, a title, an optional
/// subtitle, extra content and a trailing widget.
class Oito2InfoBox extends StatelessWidget {
  /// Creates an info box.
  const Oito2InfoBox({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.child,
    this.trailing,
    this.icon,
  });

  /// The kind of message.
  final Oito2InfoType type;

  /// The headline, in the type color.
  final Widget? title;

  /// The message text.
  final Widget? subtitle;

  /// Extra content below the subtitle.
  final Widget? child;

  /// A widget at the end, such as a close or action button.
  final Widget? trailing;

  /// Replaces the type icon; unlike the default icon, it carries no kind
  /// label for assistive technologies.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (background, foreground) = _infoColors(context, type, 0.08);
    final title = this.title;
    final subtitle = this.subtitle;
    final child = this.child;
    final trailing = this.trailing;
    return Semantics(
      container: true,
      liveRegion: type == Oito2InfoType.danger || type == Oito2InfoType.warning,
      child: Container(
        padding: const EdgeInsets.all(Oito2Spacing.md),
        decoration: BoxDecoration(
          color: background,
          borderRadius: Oito2Radius.mediumAll,
          border: Border.all(color: foreground.withValues(alpha: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTheme.merge(
              data: IconThemeData(color: foreground, size: Oito2Sizes.iconSize),
              // The kind is read out, not only shown by color and icon.
              child:
                  icon ??
                  Icon(
                    type.icon,
                    semanticLabel: type.labelIn(Oito2Localizations.of(context)),
                  ),
            ),
            const SizedBox(width: Oito2Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: Oito2Spacing.xs,
                children: [
                  if (title != null)
                    DefaultTextStyle.merge(
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: foreground,
                      ),
                      child: title,
                    ),
                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      child: subtitle,
                    ),
                  ?child,
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: Oito2Spacing.sm),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}

/// A small pill-shaped label tinted by its [type], for statuses and
/// counters.
class Oito2InfoBadge extends StatelessWidget {
  /// Creates an info badge.
  const Oito2InfoBadge({super.key, required this.type, required this.label});

  /// The kind of status.
  final Oito2InfoType type;

  /// The badge text, usually a [Text].
  final Widget label;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _infoColors(context, type, 0.14);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Oito2Spacing.sm,
        vertical: Oito2Spacing.xxs,
      ),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
        child: label,
      ),
    );
  }
}
