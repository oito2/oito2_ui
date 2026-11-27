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

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'info.dart';
import 'widget_helpers.dart';

/// An inline message about the state of a page or a task, tinted by its
/// [type], with an icon, a [title], a [message], [actions] and an
/// optional dismiss button.
///
/// The icon carries the localized name of the type, such as "Warning",
/// for assistive technologies, and alerts of the [Oito2InfoType.warning]
/// and [Oito2InfoType.danger] types are live regions, announced when
/// they appear or change.
///
/// [compact] puts everything on one row, for narrow toolbars and panes.
/// Several alerts can be grouped and ordered by an [Oito2AlertStack].
class Oito2Alert extends StatelessWidget {
  /// Creates an alert.
  const Oito2Alert({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.icon,
    this.actions = const [],
    this.onDismiss,
    this.compact = false,
  });

  /// The kind of message, which picks the icon and the tint.
  final Oito2InfoType type;

  /// The headline, in the type color.
  final Widget? title;

  /// The message text.
  final Widget? message;

  /// Replaces the type icon; unlike the default icon, it carries no kind
  /// label for assistive technologies.
  final Widget? icon;

  /// Buttons that act on the message, usually [TextButton]s, shown below
  /// the message with their labels lined up with it, or before the
  /// dismiss button when [compact].
  final List<Widget> actions;

  /// Called when the dismiss button is pressed; the button shows only
  /// when this is set.
  final VoidCallback? onDismiss;

  /// Whether the alert shows on one row with less padding.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = Oito2Localizations.of(context);
    final (background, foreground) = infoColorsOf(context, type, 0.08);
    final title = this.title;
    final message = this.message;
    final onDismiss = this.onDismiss;
    final titleText = title == null
        ? null
        : DefaultTextStyle.merge(
            style: theme.textTheme.titleSmall?.copyWith(color: foreground),
            child: title,
          );
    final messageText = message == null
        ? null
        : DefaultTextStyle.merge(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            child: message,
          );
    final iconWidget = IconTheme.merge(
      data: IconThemeData(color: foreground, size: Oito2Sizes.iconSize),
      child: icon ?? Icon(type.icon, semanticLabel: type.labelIn(strings)),
    );
    // On touch platforms the button keeps the theme's padded 48-pixel tap
    // target; elsewhere it is compact and shrink-wrapped.
    final padded = padsTapTargets(context);
    final dismiss = onDismiss == null
        ? null
        : IconButton(
            tooltip: strings.dismiss,
            color: theme.colorScheme.onSurfaceVariant,
            visualDensity: padded ? null : VisualDensity.compact,
            style: padded
                ? null
                : IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
            onPressed: onDismiss,
            icon: const Icon(LucideIcons.x, size: 16),
          );
    final buttonStyle = theme.textButtonTheme.style;
    final direction = Directionality.of(context);
    // Below the message the buttons shrink to their labels and shift
    // toward the start edge by their start padding, so the labels line up
    // with the message while the focus ring keeps its padding.
    final buttonPadding =
        buttonStyle?.padding?.resolve(const {})?.resolve(direction) ??
        EdgeInsets.zero;
    final startShift = direction == TextDirection.ltr
        ? -buttonPadding.left
        : buttonPadding.right;
    final actionStyle = TextButton.styleFrom(
      foregroundColor: foreground,
      minimumSize: compact
          ? null
          : Size(0, buttonStyle?.minimumSize?.resolve(const {})?.height ?? 0),
    );
    Widget actionRow() => TextButtonTheme(
      data: TextButtonThemeData(style: actionStyle.merge(buttonStyle)),
      child: Wrap(
        spacing: Oito2Spacing.xs,
        runSpacing: Oito2Spacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: actions,
      ),
    );

    final Widget body;
    if (compact) {
      body = Row(
        spacing: Oito2Spacing.sm,
        children: [
          iconWidget,
          Expanded(
            child: Wrap(
              spacing: Oito2Spacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [?titleText, ?messageText],
            ),
          ),
          if (actions.isNotEmpty) actionRow(),
          ?dismiss,
        ],
      );
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Oito2Spacing.md,
        children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: iconWidget),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.xs,
              children: [
                ?titleText,
                ?messageText,
                if (actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: Oito2Spacing.xs),
                    child: Transform.translate(
                      offset: Offset(startShift, 0),
                      child: actionRow(),
                    ),
                  ),
              ],
            ),
          ),
          ?dismiss,
        ],
      );
    }
    return Semantics(
      container: true,
      liveRegion: type == Oito2InfoType.danger || type == Oito2InfoType.warning,
      child: Container(
        padding: compact
            ? const EdgeInsetsDirectional.fromSTEB(
                Oito2Spacing.md,
                Oito2Spacing.xs,
                Oito2Spacing.xs,
                Oito2Spacing.xs,
              )
            : EdgeInsetsDirectional.fromSTEB(
                Oito2Spacing.md,
                Oito2Spacing.md,
                dismiss == null ? Oito2Spacing.md : Oito2Spacing.sm,
                Oito2Spacing.md,
              ),
        constraints: BoxConstraints(minHeight: compact ? 40 : 0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: Oito2Radius.mediumAll,
          border: Border.all(color: foreground.withValues(alpha: 0.5)),
        ),
        child: body,
      ),
    );
  }
}

/// A column of [Oito2Alert]s ordered by urgency.
///
/// The alerts are sorted by the [Oito2InfoType.severity] of their type,
/// the most urgent first, and keep the order of [alerts] within a type.
/// At most [maxVisible] show; a button below them shows the others, and
/// hides them again. Alerts added to or removed from [alerts] grow in and
/// shrink out, at once when animations are disabled.
///
/// Every alert needs a distinct key, which tells the stack which alert
/// came, went or stayed when [alerts] changes. Remove an alert from
/// [alerts] in its [Oito2Alert.onDismiss] to dismiss it.
class Oito2AlertStack extends StatefulWidget {
  /// Creates an alert stack.
  Oito2AlertStack({
    super.key,
    required this.alerts,
    this.maxVisible = 3,
    this.spacing = Oito2Spacing.sm,
  }) : assert(maxVisible > 0, 'maxVisible must be positive'),
       assert(
         alerts.every((alert) => alert.key != null) &&
             alerts.map((alert) => alert.key).toSet().length == alerts.length,
         'Every alert of an Oito2AlertStack needs a distinct key',
       );

  /// The alerts, in the order they were added.
  final List<Oito2Alert> alerts;

  /// How many alerts show before the rest are hidden behind the "show
  /// more" button.
  final int maxVisible;

  /// The gap between alerts.
  final double spacing;

  /// Returns which alerts a stack shows, for alerts of [types] given in
  /// the order they were added.
  ///
  /// The alerts are sorted by the [Oito2InfoType.severity] of their type,
  /// the most urgent first, and then by the order they were added. The
  /// first [maxVisible] show, or all of them when [expanded]. The alerts
  /// at the indexes in [leaving] are shrinking out: one before the cut
  /// still shows but takes no place, and none counts as hidden.
  ///
  /// Returns the indexes of [types] that show, in display order, and how
  /// many alerts the button below the stack reveals, 0 when it doesn't
  /// show.
  static ({List<int> visible, int hidden}) arrange(
    List<Oito2InfoType> types, {
    required int maxVisible,
    bool expanded = false,
    Set<int> leaving = const {},
  }) {
    final sorted = List.generate(types.length, (index) => index)
      ..sort((a, b) {
        final bySeverity = types[b].severity.compareTo(types[a].severity);
        return bySeverity != 0 ? bySeverity : a.compareTo(b);
      });
    final visible = <int>[];
    var count = 0;
    for (final index in sorted) {
      final fits = expanded || count < maxVisible;
      if (!leaving.contains(index)) count++;
      if (fits) visible.add(index);
    }
    return (visible: visible, hidden: math.max(0, count - maxVisible));
  }

  @override
  State<Oito2AlertStack> createState() => _Oito2AlertStackState();
}

/// An alert of a stack: its latest widget, the order it was added in and
/// whether it is leaving.
class _StackEntry {
  _StackEntry(this.alert, this.order);

  Oito2Alert alert;
  final int order;
  bool leaving = false;
}

class _Oito2AlertStackState extends State<Oito2AlertStack> {
  final Map<Key, _StackEntry> _entries = {};
  int _nextOrder = 0;
  bool _expanded = false;
  bool _built = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(Oito2AlertStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  /// Adds the new alerts, updates the kept ones and marks the removed
  /// ones as leaving.
  void _sync() {
    final keys = <Key>{};
    for (final alert in widget.alerts) {
      final key = alert.key!;
      keys.add(key);
      final entry = _entries[key];
      if (entry == null) {
        _entries[key] = _StackEntry(alert, _nextOrder++);
      } else {
        entry
          ..alert = alert
          ..leaving = false;
      }
    }
    for (final MapEntry(:key, value: entry) in _entries.entries) {
      if (!keys.contains(key)) entry.leaving = true;
    }
  }

  /// Drops the entry of [key] once its exit animation ends.
  void _remove(Key key) {
    if (!mounted) return;
    final entry = _entries[key];
    if (entry == null || !entry.leaving) return;
    setState(() => _entries.remove(key));
  }

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final entries = _entries.entries.toList()
      ..sort((a, b) => a.value.order.compareTo(b.value.order));
    final (:visible, :hidden) = Oito2AlertStack.arrange(
      [for (final item in entries) item.value.alert.type],
      maxVisible: widget.maxVisible,
      expanded: _expanded,
      leaving: {
        for (final (index, item) in entries.indexed)
          if (item.value.leaving) index,
      },
    );
    final shown = [for (final index in visible) entries[index]];
    final shownKeys = {for (final item in shown) item.key};
    for (final item in entries) {
      // A hidden alert that leaves has nothing to animate.
      if (item.value.leaving && !shownKeys.contains(item.key)) {
        _entries.remove(item.key);
      }
    }
    final animateIn = _built;
    _built = true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, MapEntry(:key, value: entry)) in shown.indexed)
          _StackChild(
            key: key,
            leaving: entry.leaving,
            animateIn: animateIn,
            gap: index == 0 ? 0 : widget.spacing,
            onRemoved: () => _remove(key),
            child: entry.alert,
          ),
        if (hidden > 0)
          Padding(
            padding: EdgeInsets.only(top: widget.spacing / 2),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded ? LucideIcons.chevron_up : LucideIcons.chevron_down,
                  size: 16,
                ),
                label: Text(
                  _expanded ? strings.showFewer : strings.showMore(hidden),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// One alert of a stack, with the [gap] above it: grows and fades in when
/// first shown after the stack's first build, and shrinks and fades out
/// when [leaving] turns true, then calls [onRemoved].
class _StackChild extends StatefulWidget {
  const _StackChild({
    super.key,
    required this.leaving,
    required this.animateIn,
    required this.gap,
    required this.onRemoved,
    required this.child,
  });

  final bool leaving;
  final bool animateIn;
  final double gap;
  final VoidCallback onRemoved;
  final Widget child;

  @override
  State<_StackChild> createState() => _StackChildState();
}

class _StackChildState extends State<_StackChild>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 200);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
    value: widget.animateIn ? 0 : 1,
  );
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = motionDuration(context, _duration);
    if (widget.leaving) {
      _leave();
    } else if (!_controller.isCompleted && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_StackChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.leaving && !oldWidget.leaving) {
      _leave();
    } else if (!widget.leaving && oldWidget.leaving) {
      _controller.forward();
    }
  }

  /// Runs the exit animation, then reports the removal unless the alert
  /// came back meanwhile.
  void _leave() {
    _controller.reverse().whenComplete(() {
      if (mounted && widget.leaving && _controller.isDismissed) {
        widget.onRemoved();
      }
    });
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.leaving,
      child: SizeTransition(
        sizeFactor: _curved,
        alignment: Alignment.topCenter,
        child: FadeTransition(
          opacity: _curved,
          child: Padding(
            padding: EdgeInsets.only(top: widget.gap),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
