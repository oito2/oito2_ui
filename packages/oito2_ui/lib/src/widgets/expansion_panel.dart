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
import 'containers.dart';
import 'expandable.dart';

/// A bordered stack of sections, each with a header that expands its
/// content, as an accordion.
///
/// [headers] and [children] pair up by index. With [collapseOnExpand],
/// opening a section closes the others, so at most one is open.
/// [onExpansionChanged] reports each section that opens or closes.
class Oito2ExpansionPanel extends StatefulWidget {
  /// Creates an expansion panel.
  ///
  /// Throws an [AssertionError] in debug builds, when built, if [headers]
  /// and [children] differ in length.
  const Oito2ExpansionPanel({
    super.key,
    required this.headers,
    required this.children,
    this.initiallyExpanded = const {},
    this.collapseOnExpand = true,
    this.placeDividers = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Oito2Spacing.md,
      vertical: Oito2Spacing.sm,
    ),
    this.onExpansionChanged,
  });

  /// The section headers, usually [Text]s.
  final List<Widget> headers;

  /// The section contents, in the order of [headers]; one per header.
  final List<Widget> children;

  /// The indexes of the sections open at start; with [collapseOnExpand],
  /// only the first of them opens.
  final Set<int> initiallyExpanded;

  /// Whether opening a section closes the others.
  final bool collapseOnExpand;

  /// Whether dividers separate the sections.
  final bool placeDividers;

  /// Space around each section.
  final EdgeInsetsGeometry padding;

  /// Called with the index of each section that opens or closes and
  /// whether it is now open, including the sections [collapseOnExpand]
  /// closes, which are reported before the section that opened.
  final void Function(int index, bool expanded)? onExpansionChanged;

  @override
  State<Oito2ExpansionPanel> createState() => _Oito2ExpansionPanelState();
}

/// Holds the set of open sections of [Oito2ExpansionPanel].
class _Oito2ExpansionPanelState extends State<Oito2ExpansionPanel> {
  late final Set<int> _expanded = {
    if (widget.collapseOnExpand)
      ...widget.initiallyExpanded.take(1)
    else
      ...widget.initiallyExpanded,
  };

  /// Opens or closes the section at [index], closing the others first
  /// when [Oito2ExpansionPanel.collapseOnExpand] is set, and reports every
  /// section that changed.
  void _change(int index, bool expanded) {
    final closed = expanded && widget.collapseOnExpand
        ? [..._expanded.where((i) => i != index)]
        : const <int>[];
    setState(() {
      if (expanded) {
        _expanded
          ..removeAll(closed)
          ..add(index);
      } else {
        _expanded.remove(index);
      }
    });
    final report = widget.onExpansionChanged;
    if (report == null) return;
    for (final i in closed) {
      report(i, false);
    }
    report(index, expanded);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.headers.length == widget.children.length,
      'Give one child per header',
    );
    return Oito2BorderContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < widget.headers.length; i++) ...[
            if (i > 0 && widget.placeDividers) const Divider(height: 1),
            Padding(
              padding: widget.padding,
              child: Oito2Expandable(
                header: widget.headers[i],
                isExpanded: _expanded.contains(i),
                onChanged: (expanded) => _change(i, expanded),
                child: widget.children[i],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
