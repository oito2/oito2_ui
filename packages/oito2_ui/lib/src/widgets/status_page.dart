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

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';

/// A centered message for a page or pane without content to show, such
/// as an empty folder, no search results or a failed load: a large
/// [icon], a [title], a [description] and [actions].
///
/// It fills the available space and centers its content, which scrolls
/// when it doesn't fit. [compact] uses a smaller icon and title, for
/// sidebars and small panes.
class Oito2StatusPage extends StatelessWidget {
  /// Creates a status page.
  const Oito2StatusPage({
    super.key,
    required this.title,
    this.icon,
    this.description,
    this.actions = const [],
    this.child,
    this.compact = false,
  });

  /// The large icon above the title, usually an [Icon].
  final Widget? icon;

  /// The headline, usually a [Text]; read as a header by assistive
  /// technologies.
  final Widget title;

  /// The text below the title that explains the state or what to do.
  final Widget? description;

  /// Buttons below the description, such as "Retry" or "New file".
  final List<Widget> actions;

  /// Extra content below the actions.
  final Widget? child;

  /// Whether the page uses a smaller icon, title and spacing.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final icon = this.icon;
    final description = this.description;
    final child = this.child;
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 320 : 480),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: compact ? Oito2Spacing.md : Oito2Spacing.xl,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  size: compact ? 32 : 64,
                  color: scheme.onSurfaceVariant,
                ),
                child: icon,
              ),
            ),
          Semantics(
            header: true,
            child: DefaultTextStyle.merge(
              textAlign: TextAlign.center,
              style: compact
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.headlineSmall,
              child: title,
            ),
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: Oito2Spacing.sm),
              child: DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                style:
                    (compact
                            ? theme.textTheme.bodySmall
                            : theme.textTheme.bodyMedium)
                        ?.copyWith(color: scheme.onSurfaceVariant),
                child: description,
              ),
            ),
          if (actions.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: compact ? Oito2Spacing.md : Oito2Spacing.xl,
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: Oito2Spacing.sm,
                runSpacing: Oito2Spacing.sm,
                children: actions,
              ),
            ),
          if (child != null)
            Padding(
              padding: const EdgeInsets.only(top: Oito2Spacing.md),
              child: child,
            ),
        ],
      ),
    );
    final padding = compact ? Oito2Spacing.md : Oito2Spacing.xl;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.hasBoundedWidth
                ? math.max(0, constraints.maxWidth - 2 * padding)
                : 0,
            minHeight: constraints.hasBoundedHeight
                ? math.max(0, constraints.maxHeight - 2 * padding)
                : 0,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}
