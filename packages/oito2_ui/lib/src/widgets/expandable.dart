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
import 'widget_helpers.dart';

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
/// expanded state exposed to assistive technologies.
///
/// With [onChanged], the state is controlled: activating the header only
/// calls [onChanged], and the content follows [isExpanded], so the parent
/// decides whether it changes. Without [onChanged], [isExpanded] is only
/// the initial state and the header toggles the content itself.
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

  /// Called with the requested state when the header is activated; when
  /// set, the parent applies it through [isExpanded].
  final ValueChanged<bool>? onChanged;

  /// Where the expand button sits.
  final Oito2ExpandButtonPosition buttonPosition;

  /// Space between the header and the content.
  final double gap;

  @override
  State<Oito2Expandable> createState() => _Oito2ExpandableState();
}

class _Oito2ExpandableState extends State<Oito2Expandable> {
  late bool _ownExpanded = widget.isExpanded;

  bool get _expanded =>
      widget.onChanged == null ? _ownExpanded : widget.isExpanded;

  @override
  void didUpdateWidget(Oito2Expandable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _ownExpanded = widget.isExpanded;
    }
  }

  void _toggle() {
    final onChanged = widget.onChanged;
    if (onChanged != null) {
      onChanged(!widget.isExpanded);
    } else {
      setState(() => _ownExpanded = !_ownExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = AnimatedRotation(
      turns: _expanded ? 0.5 : 0,
      duration: motionDuration(context, const Duration(milliseconds: 200)),
      child: Icon(
        LucideIcons.chevron_down,
        size: Oito2Sizes.iconSize,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    final atStart = widget.buttonPosition == Oito2ExpandButtonPosition.start;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final collapsedChild = widget.collapsedChild;
    final body = _expanded
        ? Padding(
            padding: EdgeInsets.only(top: widget.gap),
            child: widget.child,
          )
        : collapsedChild == null
        ? const SizedBox(width: double.infinity)
        : Padding(
            padding: EdgeInsets.only(top: widget.gap),
            child: collapsedChild,
          );

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
          // AnimatedSize can't run with a zero duration, so reduced motion
          // shows the content directly.
          child: reduced
              ? body
              : AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: AlignmentDirectional.topStart,
                  child: body,
                ),
        ),
      ],
    );
  }
}
