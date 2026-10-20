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

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/contrast.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/colors.dart';
import '../tokens/geometry.dart';
import 'info.dart';
import 'progress.dart';

/// Where an [Oito2Toaster] stacks its toasts.
enum Oito2ToasterPlacement {
  /// The top start corner.
  topStart(AlignmentDirectional.topStart),

  /// The top center.
  top(AlignmentDirectional.topCenter),

  /// The top end corner.
  topEnd(AlignmentDirectional.topEnd),

  /// The bottom start corner.
  bottomStart(AlignmentDirectional.bottomStart),

  /// The bottom center.
  bottom(AlignmentDirectional.bottomCenter),

  /// The bottom end corner.
  bottomEnd(AlignmentDirectional.bottomEnd);

  const Oito2ToasterPlacement(this.alignment);

  /// The alignment of the stack in the window.
  final AlignmentDirectional alignment;

  /// Whether the stack sits at the top edge.
  bool get isTop => alignment.y < 0;
}

/// A short notification shown by an [Oito2Toaster].
@immutable
class Oito2Toast {
  /// Creates a toast.
  const Oito2Toast({
    required this.title,
    this.description,
    this.type,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 4),
    this.loading = false,
    this.dismissible = true,
  });

  /// The message.
  final String title;

  /// An optional second line.
  final String? description;

  /// The kind of message, shown as a colored icon; none when null.
  final Oito2InfoType? type;

  /// The label of the action button, shown with [onAction].
  final String? actionLabel;

  /// Called by the action button, which also dismisses the toast.
  final VoidCallback? onAction;

  /// How long the toast stays; it stays until dismissed when null. The
  /// time doesn't run while the pointer or the focus is on a toast.
  final Duration? duration;

  /// Whether the toast shows a spinner instead of an icon and stays
  /// until it is updated or dismissed.
  final bool loading;

  /// Whether the toast has a dismiss button.
  final bool dismissible;
}

/// A shown toast, to update or dismiss it.
class Oito2ToastHandle {
  Oito2ToastHandle._(this._toaster, this._entry);

  final Oito2ToasterState _toaster;
  final _ToastEntry _entry;

  /// Whether the toast is still shown or waiting to be shown.
  bool get isActive => !_entry.closing && _toaster._entries.contains(_entry);

  /// Replaces the toast's content and restarts its time.
  void update(Oito2Toast toast) => _toaster._update(_entry, toast);

  /// Dismisses the toast.
  void dismiss() => _toaster._dismiss(_entry);
}

class _ToastEntry {
  _ToastEntry(this.toast);

  static int _nextId = 0;

  final int id = _nextId++;
  Oito2Toast toast;
  bool closing = false;
  Duration? remaining;
  DateTime? startedAt;
  Timer? timer;

  void stop() {
    final started = startedAt;
    if (timer != null && started != null && remaining != null) {
      remaining = remaining! - DateTime.now().difference(started);
    }
    timer?.cancel();
    timer = null;
    startedAt = null;
  }
}

/// Shows [Oito2Toast]s above [child], usually the whole app: wrap the
/// navigator in `MaterialApp.builder` with it, then call
/// `Oito2Toaster.of(context).show(...)`.
///
/// At most [maxVisible] toasts show at a time, the oldest nearest the
/// [placement] edge; newer ones wait for room. Each toast is announced
/// to assistive technologies, closes on Escape while focused, and its
/// time stops while the pointer or the focus is on the stack.
class Oito2Toaster extends StatefulWidget {
  /// Creates a toaster.
  const Oito2Toaster({
    super.key,
    required this.child,
    this.placement = Oito2ToasterPlacement.bottom,
    this.maxVisible = 3,
    this.maxWidth = 420,
  }) : assert(maxVisible > 0);

  /// The content below the toasts.
  final Widget child;

  /// Where the toasts stack.
  final Oito2ToasterPlacement placement;

  /// The number of toasts shown at a time.
  final int maxVisible;

  /// The largest toast width.
  final double maxWidth;

  /// The closest toaster.
  static Oito2ToasterState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'No Oito2Toaster above this context.');
    return state!;
  }

  /// The closest toaster, or null when there is none.
  static Oito2ToasterState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<Oito2ToasterState>();

  @override
  State<Oito2Toaster> createState() => Oito2ToasterState();
}

/// The state of an [Oito2Toaster], which shows the toasts.
class Oito2ToasterState extends State<Oito2Toaster> {
  final List<_ToastEntry> _entries = [];
  late final OverlayEntry _content = OverlayEntry(
    maintainState: true,
    builder: (_) => widget.child,
  );
  late final OverlayEntry _layer = OverlayEntry(builder: _buildLayer);
  bool _hovered = false;
  bool _focused = false;

  bool get _paused => _hovered || _focused;

  /// Shows [toast] and returns its handle.
  Oito2ToastHandle show(Oito2Toast toast) {
    final entry = _ToastEntry(toast);
    setState(() => _entries.add(entry));
    _layer.markNeedsBuild();
    _syncTimers();
    return Oito2ToastHandle._(this, entry);
  }

  /// Shows [loading] until [future] completes, then replaces it with the
  /// toast from [success] or [error], and returns [future].
  Future<T> promise<T>(
    Future<T> future, {
    required Oito2Toast loading,
    required Oito2Toast Function(T value) success,
    required Oito2Toast Function(Object error) error,
  }) {
    final handle = show(loading);
    future.then(
      (value) {
        if (mounted && handle.isActive) handle.update(success(value));
      },
      onError: (Object e) {
        if (mounted && handle.isActive) handle.update(error(e));
      },
    );
    return future;
  }

  /// Dismisses every toast.
  void dismissAll() {
    for (final entry in _entries) {
      entry
        ..stop()
        ..closing = true;
    }
    _refresh();
  }

  void _update(_ToastEntry entry, Oito2Toast toast) {
    if (!_entries.contains(entry) || entry.closing) return;
    entry
      ..stop()
      ..toast = toast
      ..remaining = null;
    _refresh();
  }

  void _dismiss(_ToastEntry entry) {
    if (!_entries.contains(entry) || entry.closing) return;
    entry
      ..stop()
      ..closing = true;
    _refresh();
  }

  void _removed(_ToastEntry entry) {
    if (!mounted) return;
    _entries.remove(entry);
    _refresh();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
    _layer.markNeedsBuild();
    _syncTimers();
  }

  List<_ToastEntry> get _visible =>
      _entries.take(widget.maxVisible).toList(growable: false);

  /// Runs the time of the visible toasts that have one, unless paused.
  void _syncTimers() {
    for (final entry in _visible) {
      final duration = entry.toast.duration;
      if (entry.closing || entry.toast.loading || duration == null) continue;
      entry.remaining ??= duration;
      if (_paused) {
        entry.stop();
      } else if (entry.timer == null) {
        entry
          ..startedAt = DateTime.now()
          ..timer = Timer(entry.remaining!, () => _dismiss(entry));
      }
    }
  }

  void _setPaused({bool? hovered, bool? focused}) {
    _hovered = hovered ?? _hovered;
    _focused = focused ?? _focused;
    _syncTimers();
  }

  @override
  void didUpdateWidget(Oito2Toaster oldWidget) {
    super.didUpdateWidget(oldWidget);
    _content.markNeedsBuild();
    _layer.markNeedsBuild();
    _syncTimers();
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.timer?.cancel();
    }
    super.dispose();
  }

  Widget _buildLayer(BuildContext context) {
    final placement = widget.placement;
    final visible = _visible;
    return SafeArea(
      child: Align(
        alignment: placement.alignment,
        child: Padding(
          padding: const EdgeInsets.all(Oito2Spacing.md),
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: Oito2Localizations.of(context).notifications,
            child: MouseRegion(
              onEnter: (_) => _setPaused(hovered: true),
              onExit: (_) => _setPaused(hovered: false),
              child: Focus(
                canRequestFocus: false,
                skipTraversal: true,
                onFocusChange: (focused) => _setPaused(focused: focused),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.maxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: switch (placement) {
                      Oito2ToasterPlacement.topStart ||
                      Oito2ToasterPlacement.bottomStart =>
                        CrossAxisAlignment.start,
                      Oito2ToasterPlacement.topEnd ||
                      Oito2ToasterPlacement.bottomEnd => CrossAxisAlignment.end,
                      _ => CrossAxisAlignment.center,
                    },
                    verticalDirection: placement.isTop
                        ? VerticalDirection.down
                        : VerticalDirection.up,
                    children: [
                      for (final entry in visible)
                        _ToastView(
                          key: ValueKey(entry.id),
                          toast: entry.toast,
                          closing: entry.closing,
                          fromTop: placement.isTop,
                          onDismiss: () => _dismiss(entry),
                          onRemoved: () => _removed(entry),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(initialEntries: [_content, _layer]);
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    super.key,
    required this.toast,
    required this.closing,
    required this.fromTop,
    required this.onDismiss,
    required this.onRemoved,
  });

  final Oito2Toast toast;
  final bool closing;
  final bool fromTop;
  final VoidCallback onDismiss;
  final VoidCallback onRemoved;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _controller.duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 220);
    if (_controller.isDismissed && !widget.closing) _controller.forward();
  }

  @override
  void didUpdateWidget(_ToastView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.closing && !oldWidget.closing) {
      _controller.reverse().whenComplete(() {
        if (mounted) widget.onRemoved();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _typeColor(Oito2InfoType type, ColorScheme scheme) {
    final inverse = scheme.brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    final status = Oito2StatusPalette.of(inverse);
    final color = switch (type) {
      Oito2InfoType.information => status.info,
      Oito2InfoType.success => status.success,
      Oito2InfoType.warning => status.warning,
      Oito2InfoType.danger => status.error,
      Oito2InfoType.important => scheme.inversePrimary,
    };
    return Oito2Contrast.ensure(color, [
      scheme.inverseSurface,
    ], Oito2Contrast.nonTextAA);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final toast = widget.toast;
    final foreground = scheme.onInverseSurface;
    final actionColor = Oito2Contrast.ensure(scheme.inversePrimary, [
      scheme.inverseSurface,
    ], Oito2Contrast.textAA);
    final type = toast.type;
    final leading = toast.loading
        ? Oito2CircularProgressIndicator(size: 18, color: foreground)
        : type == null
        ? null
        : Icon(type.icon, size: 18, color: _typeColor(type, scheme));
    final description = toast.description;

    Widget content = Material(
      color: scheme.inverseSurface,
      elevation: 6,
      shadowColor: scheme.shadow,
      shape: const RoundedRectangleBorder(borderRadius: Oito2Radius.largeAll),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          Oito2Spacing.lg,
          Oito2Spacing.sm,
          Oito2Spacing.sm,
          Oito2Spacing.sm,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground),
          child: DefaultTextStyle.merge(
            style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.sm,
              children: [
                ?leading,
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Oito2Spacing.xs,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toast.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (description != null)
                          Text(
                            description,
                            style: TextStyle(
                              color: foreground.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (toast.actionLabel != null && toast.onAction != null)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: actionColor),
                    onPressed: () {
                      toast.onAction!();
                      widget.onDismiss();
                    },
                    child: Text(toast.actionLabel!),
                  ),
                if (toast.dismissible)
                  IconButton(
                    tooltip: Oito2Localizations.of(context).dismiss,
                    color: foreground,
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: widget.onDismiss,
                    icon: const Icon(LucideIcons.x, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    content = Semantics(
      container: true,
      liveRegion: true,
      child: CallbackShortcuts(
        bindings: {
          if (toast.dismissible)
            const SingleActivator(LogicalKeyboardKey.escape): widget.onDismiss,
        },
        child: content,
      ),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return SizeTransition(
      sizeFactor: curved,
      alignment: widget.fromTop ? Alignment.bottomCenter : Alignment.topCenter,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: Offset(0, widget.fromTop ? -0.3 : 0.3),
            end: Offset.zero,
          ).animate(curved),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Oito2Spacing.xs),
            child: content,
          ),
        ),
      ),
    );
  }
}
