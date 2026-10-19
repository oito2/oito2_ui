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

import '../tokens/geometry.dart';

/// Where [Oito2Expandable] places its expand button.
enum Oito2ExpandButtonPosition {
  /// Before the header.
  start,

  /// After the header.
  end,
}

/// A header that shows or hides [child] when activated.
///
/// The whole header row toggles the content, with keyboard support and the
/// expanded state exposed to assistive technologies. Pass [isExpanded]
/// with [onChanged] to control the state from outside; otherwise
/// [isExpanded] is only the initial state.
class Oito2Expandable extends StatefulWidget {
  /// Creates an expandable section.
  const Oito2Expandable({
    super.key,
    required this.header,
    required this.child,
    this.collapsedChild,
    this.isExpanded = false,
    this.onChanged,
    this.buttonPosition = Oito2ExpandButtonPosition.end,
    this.gap = Oito2Spacing.xs,
  });

  /// The always-visible header, usually a [Text].
  final Widget header;

  /// The content shown when expanded.
  final Widget child;

  /// The content shown when collapsed, such as a summary.
  final Widget? collapsedChild;

  /// Whether the content is shown.
  final bool isExpanded;

  /// Called with the new state when the header is activated.
  final ValueChanged<bool>? onChanged;

  /// Where the expand button sits.
  final Oito2ExpandButtonPosition buttonPosition;

  /// Space between the header and the content.
  final double gap;

  @override
  State<Oito2Expandable> createState() => _Oito2ExpandableState();
}

class _Oito2ExpandableState extends State<Oito2Expandable> {
  late bool _expanded = widget.isExpanded;

  @override
  void didUpdateWidget(Oito2Expandable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _expanded = widget.isExpanded;
    }
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = AnimatedRotation(
      turns: _expanded ? 0.5 : 0,
      duration: const Duration(milliseconds: 200),
      child: Icon(
        LucideIcons.chevron_down,
        size: Oito2Sizes.iconSize,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    final atStart = widget.buttonPosition == Oito2ExpandButtonPosition.start;
    final collapsed = widget.collapsedChild;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          expanded: _expanded,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _toggle,
              borderRadius: Oito2Radius.mediumAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Oito2Spacing.xs),
                child: Row(
                  spacing: Oito2Spacing.sm,
                  children: [
                    if (atStart) icon,
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: theme.textTheme.titleSmall,
                        child: widget.header,
                      ),
                    ),
                    if (!atStart) icon,
                  ],
                ),
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: AlignmentDirectional.topStart,
            child: _expanded
                ? Padding(
                    padding: EdgeInsets.only(top: widget.gap),
                    child: widget.child,
                  )
                : collapsed == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: EdgeInsets.only(top: widget.gap),
                    child: collapsed,
                  ),
          ),
        ),
      ],
    );
  }
}
