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

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// A section listed by an [Oito2TableOfContents].
@immutable
class Oito2TocEntry {
  /// Creates a table of contents entry.
  const Oito2TocEntry({
    required this.title,
    required this.target,
    this.depth = 0,
  });

  /// The section name.
  final String title;

  /// The key of the section heading widget inside the scroll view, used to
  /// measure where the section starts and to scroll to it.
  final GlobalKey target;

  /// The nesting level, from 0; each level indents the entry further.
  final int depth;
}

/// A list of the sections of a scroll view that highlights the section in
/// view and scrolls to a section when it is picked.
///
/// The current section is the last one whose heading has reached
/// [activationOffset] pixels below the top of the viewport, or the last
/// section when the view is scrolled to the end. [controller] must be the
/// controller of the scroll view that holds the [Oito2TocEntry.target]s.
///
/// In a lazily built scroll view, only built headings are measured: while
/// none is built the current section stays as it was, and picking a
/// section whose heading isn't built only calls [onSelected], which can
/// scroll there.
class Oito2TableOfContents extends StatefulWidget {
  /// Creates a table of contents.
  const Oito2TableOfContents({
    super.key,
    required this.entries,
    required this.controller,
    this.activationOffset = 32,
    this.onSelected,
  });

  /// The sections, in document order.
  final List<Oito2TocEntry> entries;

  /// The controller of the scroll view the sections are in.
  final ScrollController controller;

  /// How far below the top of the viewport, in logical pixels, a heading
  /// makes its section current.
  final double activationOffset;

  /// Called with the index of a picked section, before the view starts
  /// scrolling to it.
  final ValueChanged<int>? onSelected;

  @override
  State<Oito2TableOfContents> createState() => _Oito2TableOfContentsState();
}

class _Oito2TableOfContentsState extends State<Oito2TableOfContents> {
  int _active = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
    SchedulerBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(Oito2TableOfContents oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controllerChanged = oldWidget.controller != widget.controller;
    if (controllerChanged) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
    // Measuring the headings costs a layout query each, so it runs again
    // only when what it depends on changes.
    if (controllerChanged ||
        oldWidget.activationOffset != widget.activationOffset ||
        !listEquals(oldWidget.entries, widget.entries)) {
      _scheduleUpdate();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  /// The scroll offset at which [entry]'s heading reaches the top of the
  /// viewport, or null when it isn't laid out.
  double? _offsetOf(Oito2TocEntry entry) {
    final box = entry.target.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return null;
    return viewport.getOffsetToReveal(box, 0).offset;
  }

  bool _updateScheduled = false;

  /// Follows a scroll change at once, from the headings as last laid out,
  /// so the highlight moves in the same frame as the content. During
  /// layout, or when a heading isn't laid out, it measures again after
  /// the next layout instead.
  void _onScroll() {
    if (SchedulerBinding.instance.schedulerPhase ==
            SchedulerPhase.persistentCallbacks ||
        !_update()) {
      _scheduleUpdate();
    }
  }

  /// Measures the headings after the next layout, once per frame, so a
  /// jump that builds new headings sees them laid out.
  void _scheduleUpdate() {
    if (_updateScheduled) return;
    _updateScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateScheduled = false;
      _update();
    });
  }

  /// Recomputes the current section from the scroll position and the
  /// measured headings, rebuilding only when it changes.
  ///
  /// Returns whether every heading could be measured.
  bool _update() {
    if (!mounted || !widget.controller.hasClients) return true;
    final position = widget.controller.position;
    var active = -1;
    var complete = true;
    if (position.hasContentDimensions &&
        position.pixels >= position.maxScrollExtent - 1 &&
        position.maxScrollExtent > 0) {
      active = widget.entries.length - 1;
    } else {
      var firstBelow = -1;
      for (var i = 0; i < widget.entries.length; i++) {
        final offset = _offsetOf(widget.entries[i]);
        if (offset == null) {
          complete = false;
          continue;
        }
        if (offset <= position.pixels + widget.activationOffset) {
          active = i;
        } else if (firstBelow < 0) {
          firstBelow = i;
        }
      }
      // Without a built heading above the activation line, the section
      // before the first built heading below it is the current one.
      if (active < 0) {
        if (firstBelow < 0) return complete;
        active = math.max(firstBelow - 1, 0);
      }
    }
    if (active != _active) setState(() => _active = active);
    return complete;
  }

  /// Reports [index] to [Oito2TableOfContents.onSelected] and scrolls its
  /// heading into view when it is built.
  void _select(int index) {
    widget.onSelected?.call(index);
    final context = widget.entries[index].target.currentContext;
    if (context == null) return;
    final reduced = MediaQuery.maybeDisableAnimationsOf(this.context) ?? false;
    Scrollable.ensureVisible(
      context,
      duration: reduced ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final indicator = semanticColorsOf(context).primaryText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.entries.length; i++)
          Semantics(
            selected: i == _active,
            child: InkWell(
              onTap: () => _select(i),
              child: Container(
                padding: EdgeInsetsDirectional.only(
                  start: Oito2Spacing.md + widget.entries[i].depth * 12.0,
                  end: Oito2Spacing.sm,
                  top: Oito2Spacing.xs + 2,
                  bottom: Oito2Spacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    start: BorderSide(
                      color: i == _active ? indicator : scheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  widget.entries[i].title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: i == _active ? indicator : scheme.onSurfaceVariant,
                    fontWeight: i == _active ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
