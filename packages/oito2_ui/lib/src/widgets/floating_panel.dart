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

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/window_button_layout.dart';
import '../tokens/geometry.dart';
import '../window/title_bar.dart';
import '../window/window_controller.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// Drives an [Oito2FloatingPanel]'s title bar buttons.
class _PanelWindow implements Oito2WindowController {
  _PanelWindow(this._panel);

  final _Oito2FloatingPanelState _panel;

  @override
  final ValueNotifier<Oito2WindowState> state = ValueNotifier(
    const Oito2WindowState(),
  );

  @override
  Future<void> minimize() async => _panel._toggleMinimized();

  @override
  Future<void> toggleMaximize() async => _panel._toggleMaximized();

  @override
  Future<void> close() async => _panel.widget.onClose?.call();

  @override
  Future<void> startDrag() async => _panel._startDrag();

  @override
  Future<void> showMenu() async {}
}

/// A non-modal window inside the app, such as an inspector or a tool
/// palette, that the user moves, resizes, minimizes and maximizes.
///
/// Place it in a [Stack]; it covers the stack to know its bounds but only
/// takes pointer events on itself. Dragging the title bar moves it and a
/// double click maximizes or restores it; with [resizable] its right and
/// bottom edges and corner resize it. Minimizing leaves only the title
/// bar. With the focus on the title bar the arrow keys move the panel and
/// Shift with the arrows resizes it. The title bar keeps inside the
/// stack.
class Oito2FloatingPanel extends StatefulWidget {
  /// Creates a floating panel.
  const Oito2FloatingPanel({
    super.key,
    required this.title,
    required this.child,
    this.initialRect = const Rect.fromLTWH(40, 40, 360, 280),
    this.minSize = const Size(220, 140),
    this.resizable = true,
    this.onClose,
    this.onRectChanged,
    this.controlStyle = Oito2WindowControlStyle.gnome,
    this.keyboardStep = 16,
  });

  /// The panel title.
  final String title;

  /// The panel content.
  final Widget child;

  /// The position and size at start, in the stack's coordinates.
  final Rect initialRect;

  /// The smallest size.
  final Size minSize;

  /// Whether the edges resize the panel.
  final bool resizable;

  /// Called by the close button; the button is disabled when null.
  final VoidCallback? onClose;

  /// Called with the new rectangle after a move or a resize.
  final ValueChanged<Rect>? onRectChanged;

  /// The look of the title bar buttons.
  final Oito2WindowControlStyle controlStyle;

  /// The distance of one arrow key press.
  final double keyboardStep;

  @override
  State<Oito2FloatingPanel> createState() => _Oito2FloatingPanelState();
}

class _Oito2FloatingPanelState extends State<Oito2FloatingPanel> {
  late Rect _rect = widget.initialRect;
  late final _window = _PanelWindow(this);
  Size _bounds = Size.zero;
  bool _maximized = false;
  bool _minimized = false;
  bool _dragging = false;
  Offset _pointerDown = Offset.zero;
  Offset _pointer = Offset.zero;

  static const double _barHeight = Oito2Sizes.titleBarHeight;

  @override
  void dispose() {
    _window.state.dispose();
    super.dispose();
  }

  /// Moves the panel with the pressed pointer, starting with the distance
  /// it has already travelled.
  void _startDrag() {
    _dragging = true;
    _move(_pointer - _pointerDown);
  }

  void _toggleMinimized() => setState(() => _minimized = !_minimized);

  void _toggleMaximized() {
    setState(() {
      _maximized = !_maximized;
      if (_maximized) _minimized = false;
    });
    _window.state.value = _window.state.value.copyWith(isMaximized: _maximized);
  }

  /// Keeps the title bar inside the bounds and the size above the minimum.
  Rect _clamp(Rect rect) {
    final width = rect.width.clamp(widget.minSize.width, double.infinity);
    final height = rect.height.clamp(widget.minSize.height, double.infinity);
    final maxLeft = (_bounds.width - width).clamp(0.0, double.infinity);
    final maxTop = (_bounds.height - _barHeight).clamp(0.0, double.infinity);
    return Rect.fromLTWH(
      rect.left.clamp(0.0, maxLeft),
      rect.top.clamp(0.0, maxTop),
      width.clamp(0.0, _bounds.width),
      height,
    );
  }

  void _setRect(Rect rect) {
    final next = _clamp(rect);
    if (next == _rect) return;
    setState(() => _rect = next);
    widget.onRectChanged?.call(next);
  }

  void _move(Offset delta) {
    if (_maximized) return;
    _setRect(_rect.shift(delta));
  }

  void _resize(double dx, double dy) {
    if (_maximized || !widget.resizable) return;
    _setRect(
      Rect.fromLTWH(_rect.left, _rect.top, _rect.width + dx, _rect.height + dy),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final step = widget.keyboardStep;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final delta = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => Offset(-step, 0),
      LogicalKeyboardKey.arrowRight => Offset(step, 0),
      LogicalKeyboardKey.arrowUp => Offset(0, -step),
      LogicalKeyboardKey.arrowDown => Offset(0, step),
      _ => null,
    };
    if (delta == null) return KeyEventResult.ignored;
    shift ? _resize(delta.dx, delta.dy) : _move(delta);
    return KeyEventResult.handled;
  }

  Widget _edge({
    required MouseCursor cursor,
    required void Function(DragUpdateDetails) onDrag,
  }) {
    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        dragStartBehavior: DragStartBehavior.down,
        onPanUpdate: onDrag,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _bounds = constraints.biggest;
          final placed = _clamp(_rect);
          final rect = _maximized
              ? Offset.zero & _bounds
              : _minimized
              ? Rect.fromLTWH(
                  placed.left,
                  placed.top,
                  placed.width,
                  _barHeight + 2,
                )
              : placed;
          final bar = Oito2FocusBorder(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Oito2Radius.window),
            ),
            child: Focus(
              onKeyEvent: _onKey,
              child: Listener(
                onPointerDown: (e) {
                  _pointerDown = e.position;
                  _pointer = e.position;
                },
                onPointerMove: (e) {
                  _pointer = e.position;
                  if (_dragging) _move(e.delta);
                },
                onPointerUp: (_) => _dragging = false,
                onPointerCancel: (_) => _dragging = false,
                child: Oito2TitleBar(
                  title: Text(widget.title),
                  controller: _window,
                  onClose: widget.onClose,
                  controlStyle: widget.controlStyle,
                  buttonLayout: const Oito2WindowButtonLayout(
                    trailing: [
                      Oito2WindowButton.minimize,
                      Oito2WindowButton.maximize,
                      Oito2WindowButton.close,
                    ],
                  ),
                ),
              ),
            ),
          );
          final panel = Material(
            color: chromeColorsOf(context).dialog,
            elevation: 8,
            shadowColor: scheme.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: _maximized
                  ? BorderRadius.zero
                  : Oito2Radius.windowAll,
              side: BorderSide(color: scheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                bar,
                if (!_minimized) Expanded(child: widget.child),
              ],
            ),
          );
          const grip = 6.0;
          final canResize = widget.resizable && !_maximized && !_minimized;
          return Stack(
            children: [
              Positioned.fromRect(
                rect: rect,
                child: Semantics(
                  container: true,
                  explicitChildNodes: true,
                  label: widget.title,
                  child: Stack(
                    children: [
                      Positioned.fill(child: panel),
                      if (canResize) ...[
                        Positioned(
                          top: _barHeight,
                          right: 0,
                          bottom: grip,
                          width: grip,
                          child: _edge(
                            cursor: SystemMouseCursors.resizeLeftRight,
                            onDrag: (d) => _resize(d.delta.dx, 0),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: grip,
                          bottom: 0,
                          height: grip,
                          child: _edge(
                            cursor: SystemMouseCursors.resizeUpDown,
                            onDrag: (d) => _resize(0, d.delta.dy),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          width: grip * 2,
                          height: grip * 2,
                          child: _edge(
                            cursor: SystemMouseCursors.resizeDownRight,
                            onDrag: (d) => _resize(d.delta.dx, d.delta.dy),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
