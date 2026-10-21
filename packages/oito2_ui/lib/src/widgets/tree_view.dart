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

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/selection_controller.dart';
import '../collections/text_folding.dart';
import '../collections/tree_collection.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'highlighted_text.dart';
import 'progress.dart';
import 'toggles.dart';
import 'widget_helpers.dart';

/// The expanded, selected and checked nodes of an [Oito2TreeView], by
/// node value.
class Oito2TreeController extends ChangeNotifier {
  /// Creates a tree controller.
  Oito2TreeController({
    this.selectionMode = Oito2SelectionMode.single,
    Iterable<String> expanded = const [],
    Iterable<String> selected = const [],
    Iterable<String> checked = const [],
  }) {
    _expanded.addAll(expanded);
    _selected.addAll(
      selectionMode == Oito2SelectionMode.none ? const [] : selected,
    );
    _checked.addAll(checked);
  }

  /// How many nodes can be selected.
  final Oito2SelectionMode selectionMode;

  final Set<String> _expanded = {};
  final Set<String> _selected = {};
  final Set<String> _checked = {};

  /// The open branches.
  Set<String> get expanded => Set.unmodifiable(_expanded);

  /// The selected nodes.
  Set<String> get selected => Set.unmodifiable(_selected);

  /// The checked leaves.
  Set<String> get checked => Set.unmodifiable(_checked);

  /// Whether [value] is open.
  bool isExpanded(String value) => _expanded.contains(value);

  /// Whether [value] is selected.
  bool isSelected(String value) => _selected.contains(value);

  /// Opens or closes [value].
  void setExpanded(String value, bool expanded) {
    final changed = expanded ? _expanded.add(value) : _expanded.remove(value);
    if (changed) notifyListeners();
  }

  /// Opens every branch of [collection].
  void expandAll(Oito2TreeCollection<Object?> collection) {
    _expanded.addAll(collection.branchValues);
    notifyListeners();
  }

  /// Closes every branch.
  void collapseAll() {
    _expanded.clear();
    notifyListeners();
  }

  /// Makes [values] the selection, keeping the first one in single mode.
  void setSelected(Iterable<String> values) {
    _selected.clear();
    switch (selectionMode) {
      case Oito2SelectionMode.none:
        break;
      case Oito2SelectionMode.single:
        if (values.isNotEmpty) _selected.add(values.first);
      case Oito2SelectionMode.multiple:
        _selected.addAll(values);
    }
    notifyListeners();
  }

  /// Adds [value] to the selection or removes it, in multiple mode.
  void toggleSelected(String value) {
    if (selectionMode != Oito2SelectionMode.multiple) {
      setSelected([value]);
      return;
    }
    _selected.contains(value) ? _selected.remove(value) : _selected.add(value);
    notifyListeners();
  }

  /// Whether [value] is checked: true or false, or null when only some of
  /// a branch's leaves are.
  bool? checkStateOf(Oito2TreeCollection<Object?> collection, String value) {
    final node = collection.find(value);
    if (node == null || !node.isBranch) return _checked.contains(value);
    final leaves = [
      for (final v in collection.descendantsOf(value))
        if (!(collection.find(v)?.isBranch ?? false)) v,
    ];
    if (leaves.isEmpty) return false;
    final count = leaves.where(_checked.contains).length;
    return count == 0 ? false : (count == leaves.length ? true : null);
  }

  /// Checks [value], or every leaf of a branch, unless already fully
  /// checked, in which case it unchecks them.
  void toggleChecked(Oito2TreeCollection<Object?> collection, String value) {
    final node = collection.find(value);
    if (node == null) return;
    final leaves = node.isBranch
        ? [
            for (final v in collection.descendantsOf(value))
              if (!(collection.find(v)?.isBranch ?? false)) v,
          ]
        : [value];
    final check = checkStateOf(collection, value) != true;
    check ? _checked.addAll(leaves) : _checked.removeAll(leaves);
    notifyListeners();
  }
}

/// Builds the content of an [Oito2TreeView] row after its disclosure and
/// check box.
typedef Oito2TreeItemBuilder<T> = Widget Function(
  BuildContext context,
  Oito2TreeNode<T> node,
);

/// A tree of the nodes of [collection], with open, selected and checked
/// nodes kept in [controller].
///
/// Only the rows in view are built, so it handles large trees. The tree
/// takes the focus as a whole and marks its active row:
///
/// - Up, Down, Home and End move the active row; a single-selection tree
///   selects it, and Shift extends a multiple selection.
/// - Right opens a branch or moves to its first child; Left closes it or
///   moves to the parent.
/// - Space toggles the selection of a multiple-selection tree, or the
///   check box of a [checkable] one; Control+A selects every shown node.
/// - Enter, or a double click, calls [onActivate], or opens or closes a
///   branch when it is null.
/// - F2 renames the active node through [onRename].
/// - Typing letters jumps to the next shown label that starts with them.
///
/// A branch with no children yet and an [onLoadChildren] shows a spinner
/// while its children load the first time it opens. A non-empty [query]
/// shows only the matching nodes and their ancestors, all open, with the
/// match highlighted.
class Oito2TreeView<T> extends StatefulWidget {
  /// Creates a tree view.
  const Oito2TreeView({
    super.key,
    required this.collection,
    required this.controller,
    this.itemBuilder,
    this.iconBuilder,
    this.onActivate,
    this.onLoadChildren,
    this.onRename,
    this.checkable = false,
    this.query = '',
    this.rowHeight,
    this.indent = 16,
    this.semanticLabel,
    this.autofocus = false,
  });

  /// The nodes.
  final Oito2TreeCollection<T> collection;

  /// The open, selected and checked nodes.
  final Oito2TreeController controller;

  /// Builds a row's content; the node label by default.
  final Oito2TreeItemBuilder<T>? itemBuilder;

  /// Builds the icon before the label, given whether the node is open.
  final Widget? Function(Oito2TreeNode<T> node, bool expanded)? iconBuilder;

  /// Called on Enter or a double click on a node.
  final ValueChanged<Oito2TreeNode<T>>? onActivate;

  /// Loads the children of an empty branch the first time it opens; the
  /// app adds them to [collection].
  final Future<void> Function(Oito2TreeNode<T> node)? onLoadChildren;

  /// Called with a node and its new label after a rename.
  final void Function(Oito2TreeNode<T> node, String label)? onRename;

  /// Whether the rows have check boxes.
  final bool checkable;

  /// The text that filters the nodes.
  final String query;

  /// The row height; defaults to the control height.
  final double? rowHeight;

  /// The indent of each level.
  final double indent;

  /// The accessibility label of the tree.
  final String? semanticLabel;

  /// Whether the tree takes the focus when shown.
  final bool autofocus;

  @override
  State<Oito2TreeView<T>> createState() => _Oito2TreeViewState<T>();
}

class _Oito2TreeViewState<T> extends State<Oito2TreeView<T>> {
  final _focusNode = FocusNode(debugLabel: 'Oito2TreeView');
  final _scroll = ScrollController();
  final Set<String> _loading = {};
  final Set<String> _loaded = {};
  String? _active;
  String? _anchor;
  String? _renaming;
  String _typed = '';
  Timer? _typeTimer;
  List<Oito2TreeEntry<T>> _entries = const [];
  final _clicks = DoubleClickDetector();

  Oito2TreeController get _controller => widget.controller;
  bool get _filtering => widget.query.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _focusNode.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(Oito2TreeView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _focusNode.dispose();
    _scroll.dispose();
    _typeTimer?.cancel();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onFocus() {
    if (_focusNode.hasFocus && _active == null && _entries.isNotEmpty) {
      final selected = _entries.where(
        (e) => _controller.isSelected(e.node.value),
      );
      _active = (selected.isEmpty ? _entries.first : selected.first).node.value;
    }
    _refresh();
  }

  List<Oito2TreeEntry<T>> _computeEntries() {
    if (!_filtering) return widget.collection.visible(_controller.expanded);
    final filtered = widget.collection.search(widget.query.trim());
    return filtered.visible(filtered.branchValues.toSet());
  }

  int _indexOf(String? value) =>
      _entries.indexWhere((e) => e.node.value == value);

  double get _rowHeight => widget.rowHeight ?? controlHeightOf(context);

  void _reveal(int index) {
    if (!_scroll.hasClients || index < 0) return;
    final top = index * _rowHeight;
    final bottom = top + _rowHeight;
    final position = _scroll.position;
    if (top < position.pixels) {
      _scroll.jumpTo(top);
    } else if (bottom > position.pixels + position.viewportDimension) {
      _scroll.jumpTo(bottom - position.viewportDimension);
    }
  }

  void _activate(String value, {bool extend = false}) {
    setState(() => _active = value);
    final mode = _controller.selectionMode;
    if (mode == Oito2SelectionMode.single) {
      _controller.setSelected([value]);
      _anchor = value;
    } else if (mode == Oito2SelectionMode.multiple && extend) {
      final from = _indexOf(_anchor ?? value);
      final to = _indexOf(value);
      final range = from <= to
          ? _entries.sublist(from, to + 1)
          : _entries.sublist(to, from + 1);
      _controller.setSelected([
        for (final e in range)
          if (!e.node.disabled) e.node.value,
      ]);
    } else if (!extend) {
      _anchor = value;
    }
    _reveal(_indexOf(value));
  }

  Future<void> _setExpanded(Oito2TreeNode<T> node, bool expanded) async {
    if (!node.isBranch || _filtering) return;
    _controller.setExpanded(node.value, expanded);
    final load = widget.onLoadChildren;
    if (expanded &&
        load != null &&
        (node.children?.isEmpty ?? false) &&
        !_loaded.contains(node.value) &&
        !_loading.contains(node.value)) {
      setState(() => _loading.add(node.value));
      try {
        await load(node);
      } finally {
        if (mounted) {
          setState(() {
            _loading.remove(node.value);
            _loaded.add(node.value);
          });
        }
      }
    }
  }

  void _primary(Oito2TreeNode<T> node) {
    final activate = widget.onActivate;
    if (activate != null) {
      activate(node);
    } else if (node.isBranch) {
      _setExpanded(node, !_controller.isExpanded(node.value));
    }
  }

  void _toggleSpace(Oito2TreeNode<T> node) {
    if (widget.checkable) {
      _controller.toggleChecked(widget.collection, node.value);
    } else if (_controller.selectionMode == Oito2SelectionMode.multiple) {
      _controller.toggleSelected(node.value);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (_renaming != null) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (_entries.isEmpty) return KeyEventResult.ignored;
    final keyboard = HardwareKeyboard.instance;
    final shift = keyboard.isShiftPressed;
    final command = keyboard.isControlPressed || keyboard.isMetaPressed;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    final index = _indexOf(_active);
    final current = index < 0 ? null : _entries[index];

    String? step(int from, int delta) {
      for (var i = from + delta; i >= 0 && i < _entries.length; i += delta) {
        if (!_entries[i].node.disabled) return _entries[i].node.value;
      }
      return null;
    }

    final openKey = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final closeKey = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    if (key == LogicalKeyboardKey.arrowDown) {
      final next = current == null ? step(-1, 1) : step(index, 1);
      if (next != null) _activate(next, extend: shift);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      final previous = current == null
          ? step(_entries.length, -1)
          : step(index, -1);
      if (previous != null) _activate(previous, extend: shift);
    } else if (key == LogicalKeyboardKey.home) {
      final first = step(-1, 1);
      if (first != null) _activate(first, extend: shift);
    } else if (key == LogicalKeyboardKey.end) {
      final last = step(_entries.length, -1);
      if (last != null) _activate(last, extend: shift);
    } else if (key == openKey && current != null) {
      final node = current.node;
      if (node.isBranch && !_isOpen(node)) {
        _setExpanded(node, true);
      } else if (node.isBranch && index + 1 < _entries.length) {
        final child = _entries[index + 1];
        if (child.depth > current.depth) _activate(child.node.value);
      }
    } else if (key == closeKey && current != null) {
      final node = current.node;
      if (node.isBranch && _isOpen(node) && !_filtering) {
        _setExpanded(node, false);
      } else {
        final parent = widget.collection.parentOf(node.value);
        if (parent != null && _indexOf(parent) >= 0) _activate(parent);
      }
    } else if (key == LogicalKeyboardKey.enter && current != null) {
      _primary(current.node);
    } else if (key == LogicalKeyboardKey.space && current != null) {
      _toggleSpace(current.node);
    } else if (key == LogicalKeyboardKey.keyA &&
        command &&
        _controller.selectionMode == Oito2SelectionMode.multiple) {
      _controller.setSelected([
        for (final e in _entries)
          if (!e.node.disabled) e.node.value,
      ]);
    } else if (key == LogicalKeyboardKey.f2 &&
        current != null &&
        widget.onRename != null &&
        !current.node.disabled) {
      setState(() => _renaming = current.node.value);
    } else {
      final character = event.character;
      if (character == null ||
          command ||
          character.trim().isEmpty ||
          character.codeUnitAt(0) < 0x20) {
        return KeyEventResult.ignored;
      }
      _typeAhead(character, index);
    }
    return KeyEventResult.handled;
  }

  void _typeAhead(String character, int index) {
    _typeTimer?.cancel();
    _typeTimer = Timer(const Duration(milliseconds: 600), () => _typed = '');
    final repeat = _typed == character;
    _typed = repeat ? character : _typed + character;
    final needle = foldText(_typed);
    final start = repeat || _typed.length == 1 ? index + 1 : index;
    for (var n = 0; n < _entries.length; n++) {
      final entry = _entries[(start + n) % _entries.length];
      if (!entry.node.disabled &&
          foldText(entry.node.label).startsWith(needle)) {
        _activate(entry.node.value);
        return;
      }
    }
  }

  bool _isOpen(Oito2TreeNode<T> node) =>
      _filtering || _controller.isExpanded(node.value);

  void _tap(Oito2TreeNode<T> node) {
    if (node.disabled) return;
    _focusNode.requestFocus();
    final keyboard = HardwareKeyboard.instance;
    final multiple = _controller.selectionMode == Oito2SelectionMode.multiple;
    if (multiple && (keyboard.isControlPressed || keyboard.isMetaPressed)) {
      setState(() => _active = node.value);
      _controller.toggleSelected(node.value);
      _anchor = node.value;
    } else if (multiple && keyboard.isShiftPressed) {
      _activate(node.value, extend: true);
    } else {
      setState(() => _active = node.value);
      _anchor = node.value;
      if (_controller.selectionMode != Oito2SelectionMode.none) {
        _controller.setSelected([node.value]);
      }
    }
  }

  Widget _row(BuildContext context, Oito2TreeEntry<T> entry) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final node = entry.node;
    final value = node.value;
    final open = _isOpen(node);
    final selected = _controller.isSelected(value);
    final active = _active == value && _focusNode.hasFocus;
    final keyboard =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final loading = _loading.contains(value);
    final foreground = node.disabled
        ? scheme.onSurface.withValues(alpha: 0.38)
        : selected
        ? scheme.onSecondaryContainer
        : scheme.onSurface;
    final checkState = widget.checkable
        ? _controller.checkStateOf(widget.collection, value)
        : false;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    final disclosure = SizedBox(
      width: 20,
      child: !node.isBranch
          ? null
          : loading
          ? Center(
              child: Oito2CircularProgressIndicator(
                size: 14,
                strokeWidth: 2,
                semanticsLabel: Oito2Localizations.of(context).loading,
              ),
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _filtering ? null : () => _setExpanded(node, !open),
              child: AnimatedRotation(
                turns: open ? (rtl ? -0.25 : 0.25) : 0,
                duration: MediaQuery.maybeDisableAnimationsOf(context) ?? false
                    ? Duration.zero
                    : const Duration(milliseconds: 150),
                child: Icon(
                  rtl ? LucideIcons.chevron_left : LucideIcons.chevron_right,
                  size: 16,
                ),
              ),
            ),
    );
    final Widget label;
    if (_renaming == value) {
      label = _RenameField(
        initial: node.label,
        onDone: (text) {
          setState(() => _renaming = null);
          if (text != null && text.isNotEmpty && text != node.label) {
            widget.onRename?.call(node, text);
          }
          _focusNode.requestFocus();
        },
      );
    } else {
      label =
          widget.itemBuilder?.call(context, node) ??
          (_filtering
              ? Oito2HighlightedText(
                  node.label,
                  query: widget.query.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(node.label, maxLines: 1, overflow: TextOverflow.ellipsis));
    }
    final icon = widget.iconBuilder?.call(node, open);
    return Semantics(
      selected: selected,
      enabled: !node.disabled,
      focused: active,
      expanded: node.isBranch ? open : null,
      checked: widget.checkable ? checkState ?? false : null,
      mixed: widget.checkable && checkState == null ? true : null,
      label: node.label,
      excludeSemantics: _renaming != value,
      onTap: node.disabled ? null : () => _tap(node),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          _tap(node);
          if (!node.disabled &&
              _clicks.click(
                value,
                SchedulerBinding.instance.currentSystemFrameTimeStamp,
              )) {
            _primary(node);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Oito2Spacing.xs),
          padding: EdgeInsetsDirectional.only(
            start: Oito2Spacing.xs + entry.depth * widget.indent,
            end: Oito2Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? scheme.secondaryContainer : null,
            borderRadius: Oito2Radius.smallAll,
            border: active && keyboard
                ? Border.all(
                    color: semanticColorsOf(context).primaryText,
                    width: Oito2Sizes.focusBorderWidth,
                  )
                : null,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: foreground, size: 16),
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
              child: Row(
                spacing: Oito2Spacing.xs,
                children: [
                  disclosure,
                  if (widget.checkable)
                    ExcludeFocus(
                      child: Oito2Checkbox(
                        value: checkState,
                        tristate: true,
                        onChanged: node.disabled
                            ? null
                            : (_) => _controller.toggleChecked(
                                widget.collection,
                                value,
                              ),
                      ),
                    ),
                  ?icon,
                  Expanded(child: label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _entries = _computeEntries();
    if (_active != null && _indexOf(_active) < 0) _active = null;
    return Semantics(
      label: widget.semanticLabel,
      container: true,
      explicitChildNodes: true,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onKeyEvent: _onKey,
        child: ListView.builder(
          controller: _scroll,
          itemExtent: _rowHeight,
          padding: const EdgeInsets.symmetric(vertical: Oito2Spacing.xs),
          itemCount: _entries.length,
          itemBuilder: (context, index) => _row(context, _entries[index]),
        ),
      ),
    );
  }
}

/// The inline field of a node being renamed: Enter or leaving it keeps
/// the text, Escape cancels.
class _RenameField extends StatefulWidget {
  const _RenameField({required this.initial, required this.onDone});

  final String initial;

  /// Called once with the new text, or null when cancelled.
  final ValueChanged<String?> onDone;

  @override
  State<_RenameField> createState() => _RenameFieldState();
}

class _RenameFieldState extends State<_RenameField> {
  late final _controller = TextEditingController(text: widget.initial)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initial.length,
    );
  final _focus = FocusNode();
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _finish(_controller.text.trim());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _finish(String? text) {
    if (_done) return;
    _done = true;
    widget.onDone(text);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => _finish(null),
      },
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        onSubmitted: (text) => _finish(text.trim()),
        decoration: bareInputDecoration(),
      ),
    );
  }
}
