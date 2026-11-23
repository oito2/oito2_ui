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

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'info.dart';
import 'progress.dart';
import 'widget_helpers.dart';

/// A compact rounded label for the state of an item, such as "Synced" or
/// "Offline", with a dot or an icon before the text.
///
/// The [type] tints it with a semantic color; without one it is neutral,
/// in the surface tones. With [busy], a small spinner takes the place of
/// the dot or icon; it stands still when animations are disabled.
///
/// Assistive technologies read [label], or [semanticLabel] when given,
/// with "Loading" as its value while [busy] and [tooltip] as a hint.
class Oito2StatusPill extends StatelessWidget {
  /// Creates a status pill.
  const Oito2StatusPill({
    super.key,
    required this.label,
    this.type,
    this.icon,
    this.busy = false,
    this.tooltip,
    this.semanticLabel,
  });

  /// The status text.
  final String label;

  /// The kind of status, which picks the color; neutral when null.
  final Oito2InfoType? type;

  /// An icon shown instead of the dot, usually an [Icon].
  final Widget? icon;

  /// Whether the status is in progress, shown by a spinner.
  final bool busy;

  /// A message shown when the pointer rests on the pill or it is long
  /// pressed, such as the time of the last sync.
  final String? tooltip;

  /// The accessibility label; defaults to [label].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final type = this.type;
    final (background, foreground) = type == null
        ? (scheme.surfaceContainerHighest, scheme.onSurfaceVariant)
        : infoColorsOf(context, type, 0.14);
    final Widget leading = busy
        ? Oito2CircularProgressIndicator(
            size: 10,
            strokeWidth: 2,
            color: foreground,
          )
        : icon ??
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: foreground,
                  shape: BoxShape.circle,
                ),
              );
    Widget pill = Semantics(
      container: true,
      label: semanticLabel ?? label,
      value: busy ? Oito2Localizations.of(context).loading : null,
      hint: this.tooltip,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(
          Oito2Spacing.sm,
          Oito2Spacing.xxs,
          Oito2Spacing.sm + 2,
          Oito2Spacing.xxs,
        ),
        decoration: ShapeDecoration(
          color: background,
          shape: const StadiumBorder(),
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.xs + 2,
            children: [
              SizedBox.square(dimension: 14, child: Center(child: leading)),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final tooltip = this.tooltip;
    if (tooltip != null) {
      pill = Tooltip(message: tooltip, excludeFromSemantics: true, child: pill);
    }
    return pill;
  }
}
