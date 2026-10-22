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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';
import 'anchored_panel.dart';
import 'widget_helpers.dart';

export 'anchored_panel.dart' show Oito2PopoverAlignment, Oito2PopoverPlacement;

/// Opens and closes an [Oito2Popover].
class Oito2PopoverController extends ChangeNotifier {
  bool _isOpen = false;

  /// Whether the popover is open.
  bool get isOpen => _isOpen;

  /// Opens the popover.
  void open() => _set(true);

  /// Closes the popover.
  void close() => _set(false);

  /// Opens the popover when closed and closes it when open.
  void toggle() => _set(!_isOpen);

  void _set(bool value) {
    if (_isOpen == value) return;
    _isOpen = value;
    notifyListeners();
  }
}

/// Builds the anchor or the content of an [Oito2Popover], with the
/// [controller] that opens and closes it.
typedef Oito2PopoverWidgetBuilder = Widget Function(
  BuildContext context,
  Oito2PopoverController controller,
);

/// The tap region groups of the popovers that enclose a widget, so a
/// nested popover keeps its ancestors open.
class _PopoverScope extends InheritedWidget {
  const _PopoverScope({required this.groups, required super.child});

  final List<Object> groups;

  static List<Object> groupsOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PopoverScope>()?.groups ??
      const [];

  @override
  bool updateShouldNotify(_PopoverScope oldWidget) =>
      !listEquals(oldWidget.groups, groups);
}

/// A non-modal panel anchored to a widget, such as a picker or a short
/// form.
///
/// [builder] builds the anchor and [popoverBuilder] the panel content;
/// both receive the controller, which a button in the anchor typically
/// toggles. The panel opens on the [placement] side, moving to the other
/// side when it doesn't fit, lines up with the anchor by [alignment], and
/// follows the anchor as it moves or scrolls.
///
/// The panel closes on Escape and, with [closeOnTapOutside], on a tap
/// outside the anchor and the panel. A popover opened from inside
/// another one keeps the outer one open. With [focusOnOpen] the first
/// focusable widget of the panel takes the focus when it opens; when it
/// closes with the focus inside, the focus returns to where it was.
class Oito2Popover extends StatefulWidget {
  /// Creates a popover.
  const Oito2Popover({
    super.key,
    required this.builder,
    required this.popoverBuilder,
    this.controller,
    this.placement = Oito2PopoverPlacement.bottom,
    this.alignment = Oito2PopoverAlignment.start,
    this.showArrow = false,
    this.matchAnchorWidth = false,
    this.maxWidth = 360,
    this.maxHeight = double.infinity,
    this.padding = const EdgeInsets.all(Oito2Spacing.md),
    this.closeOnTapOutside = true,
    this.focusOnOpen = true,
    this.onOpenChanged,
    this.semanticLabel,
  });

  /// Builds the anchor.
  final Oito2PopoverWidgetBuilder builder;

  /// Builds the panel content.
  final Oito2PopoverWidgetBuilder popoverBuilder;

  /// Opens and closes the panel; the popover keeps its own when null.
  final Oito2PopoverController? controller;

  /// The preferred side of the anchor.
  final Oito2PopoverPlacement placement;

  /// The alignment along the anchor's edge.
  final Oito2PopoverAlignment alignment;

  /// Whether the panel points at the anchor with an arrow.
  final bool showArrow;

  /// Whether a panel above or below takes the anchor's width.
  final bool matchAnchorWidth;

  /// The largest panel width.
  final double maxWidth;

  /// The largest panel height; the content scrolls itself beyond it.
  final double maxHeight;

  /// The space around the content inside the panel.
  final EdgeInsetsGeometry padding;

  /// Whether a tap outside the anchor and the panel closes the panel.
  final bool closeOnTapOutside;

  /// Whether the panel takes the focus when it opens.
  final bool focusOnOpen;

  /// Called when the panel opens or closes.
  final ValueChanged<bool>? onOpenChanged;

  /// The accessibility label of the panel.
  final String? semanticLabel;

  @override
  State<Oito2Popover> createState() => _Oito2PopoverState();
}

class _Oito2PopoverState extends State<Oito2Popover>
    with OwnedControllerMixin<Oito2Popover, Oito2PopoverController> {
  final _portal = OverlayPortalController();
  final _scope = FocusScopeNode(debugLabel: 'Oito2Popover');
  FocusNode? _previousFocus;
  List<Object> _parentGroups = const [];

  @override
  Oito2PopoverController? get widgetController => widget.controller;

  @override
  Oito2PopoverController createOwnedController() => Oito2PopoverController();

  @override
  void onControllerChange() => _sync();

  Oito2PopoverController get _controller => effectiveController;

  @override
  void initState() {
    super.initState();
    if (_controller.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  @override
  void didChangeController(Oito2PopoverController previous) {
    // Showing or hiding the overlay isn't allowed during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    final open = _controller.isOpen;
    if (open == _portal.isShowing) return;
    if (open) {
      _previousFocus = FocusManager.instance.primaryFocus;
      _portal.show();
      if (widget.focusOnOpen) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _focusPanel());
      }
    } else {
      final hadFocus = _scope.hasFocus;
      _portal.hide();
      if (hadFocus && (_previousFocus?.context?.mounted ?? false)) {
        _previousFocus!.requestFocus();
      }
      _previousFocus = null;
    }
    setState(() {});
    widget.onOpenChanged?.call(open);
  }

  void _focusPanel() {
    if (!mounted || !_portal.isShowing) return;
    final first = _scope.traversalDescendants.firstOrNull;
    first != null ? first.requestFocus() : _scope.requestFocus();
  }

  Map<ShortcutActivator, VoidCallback> get _bindings => _portal.isShowing
      ? {const SingleActivator(LogicalKeyboardKey.escape): _controller.close}
      : const {};

  Widget _buildPanel(BuildContext context, OverlayChildLayoutInfo info) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final groups = [..._parentGroups, this];
    final anchor = MatrixUtils.transformRect(
      info.childPaintTransform,
      Offset.zero & info.childSize,
    );
    // The panel lays out again whenever the anchor moves; the content is
    // built once per build of the popover and reused in between.
    if (_contentBuild != _builds) {
      _contentBuild = _builds;
      _content = widget.popoverBuilder(context, _controller);
    }
    Widget content = Padding(padding: widget.padding, child: _content);
    content = Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: ClipRRect(
        borderRadius: Oito2Radius.mediumAll,
        child: Material(
          type: MaterialType.transparency,
          child: DefaultTextStyle.merge(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
            child: content,
          ),
        ),
      ),
    );
    content = FocusScope(
      node: _scope,
      child: CallbackShortcuts(bindings: _bindings, child: content),
    );
    for (final group in groups.reversed) {
      content = TapRegion(groupId: group, child: content);
    }
    return _PopoverScope(
      groups: groups,
      child: AnchoredPanel(
        anchor: anchor,
        placement: widget.placement,
        alignment: widget.alignment,
        textDirection: Directionality.of(this.context),
        color: scheme.surfaceContainer,
        borderColor: scheme.outlineVariant,
        shadowColor: scheme.shadow,
        arrowSize: widget.showArrow ? const Size(14, 7) : null,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        matchAnchorWidth: widget.matchAnchorWidth,
        radius: Oito2Radius.medium,
        child: content,
      ),
    );
  }

  /// Counts the builds of the popover, which rebuild the panel content.
  int _builds = 0;
  int _contentBuild = -1;
  Widget? _content;

  @override
  Widget build(BuildContext context) {
    _builds++;
    _parentGroups = _PopoverScope.groupsOf(context);
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _portal,
      overlayChildBuilder: _buildPanel,
      child: TapRegion(
        groupId: this,
        onTapOutside: widget.closeOnTapOutside
            ? (_) => _controller.close()
            : null,
        child: CallbackShortcuts(
          bindings: _bindings,
          child: widget.builder(context, _controller),
        ),
      ),
    );
  }
}
