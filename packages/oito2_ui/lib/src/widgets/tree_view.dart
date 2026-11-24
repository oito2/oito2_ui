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

import 'dart:async';

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show Drag;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/selection_controller.dart';
import '../collections/text_folding.dart';
import '../collections/tree_collection.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'context_menu.dart';
import 'highlighted_text.dart';
import 'progress.dart';
import 'row_drag.dart';
import 'table_column.dart';
import 'table_header.dart';
import 'toggles.dart';
import 'touch_target.dart';
import 'widget_helpers.dart';

/// The expanded, selected and checked nodes of an [Oito2TreeView], by
/// node value.
class Oito2TreeController extends ChangeNotifier {
  /// Creates a tree controller with the given initial [expanded],
  /// [selected] and [checked] node values.
  ///
  /// [selected] is ignored when [selectionMode] is
  /// [Oito2SelectionMode.none].
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

  /// An unmodifiable copy of the values of the open branches.
  Set<String> get expanded => Set.unmodifiable(_expanded);

  /// An unmodifiable copy of the values of the selected nodes.
  Set<String> get selected => Set.unmodifiable(_selected);

  /// An unmodifiable copy of the values of the checked leaves.
  Set<String> get checked => Set.unmodifiable(_checked);

  /// Whether the branch [value] is open.
  bool isExpanded(String value) => _expanded.contains(value);

  /// Whether [value] is selected.
  bool isSelected(String value) => _selected.contains(value);

  /// Opens the branch [value] when [expanded] is true, or closes it.
  void setExpanded(String value, bool expanded) {
    final changed = expanded ? _expanded.add(value) : _expanded.remove(value);
    if (changed) notifyListeners();
  }

  /// Opens exactly the branches in [values] and closes the others.
  void setExpandedValues(Iterable<String> values) {
    final next = values.toSet();
    if (setEquals(next, _expanded)) return;
    _expanded
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  /// Opens every branch of [collection], keeping the branches already
  /// open.
  void expandAll(Oito2TreeCollection<Object?> collection) {
    _expanded.addAll(collection.branchValues);
    notifyListeners();
  }

  /// Closes every branch.
  void collapseAll() {
    _expanded.clear();
    notifyListeners();
  }

  /// Makes [values] the selection: only the first one in single mode, and
  /// none in [Oito2SelectionMode.none].
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

  /// Adds [value] to the selection or removes it, in multiple mode; in
  /// the other modes it behaves as [setSelected] with [value] alone.
  void toggleSelected(String value) {
    if (selectionMode != Oito2SelectionMode.multiple) {
      setSelected([value]);
      return;
    }
    _selected.contains(value) ? _selected.remove(value) : _selected.add(value);
    notifyListeners();
  }

  /// The check state of [value] in [collection]: true or false, or null
  /// when only some of a branch's leaves are checked. A branch without
  /// leaves is unchecked.
  bool? checkStateOf(Oito2TreeCollection<Object?> collection, String value) {
    final node = collection.find(value);
    if (node == null || !node.isBranch) return _checked.contains(value);
    final leaves = collection.leavesOf(value);
    if (leaves.isEmpty) return false;
    final count = leaves.where(_checked.contains).length;
    return count == 0 ? false : (count == leaves.length ? true : null);
  }

  /// Checks [value], or every leaf of a branch, unless already fully
  /// checked, in which case it unchecks them. Does nothing when
  /// [collection] has no node [value].
  void toggleChecked(Oito2TreeCollection<Object?> collection, String value) {
    if (!collection.has(value)) return;
    final leaves = collection.leavesOf(value);
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
/// - Space toggles the check box of a [checkable] tree, or else the
///   selection of a multiple-selection one; Control+A (Command+A) selects
///   every shown, enabled node of a multiple-selection tree.
/// - The Menu key or Shift+F10 calls [onContextMenu] for the active row,
///   as a secondary click does for the row under the pointer.
/// - Enter, or a double click, calls [onActivate], or opens or closes a
///   branch when it is null.
/// - F2 starts an inline rename of the active node when [onRename] is
///   set; Enter or leaving the field confirms it and Escape cancels it.
/// - Typing letters jumps to the next shown label that starts with them.
/// - With [onMove], Alt with Up or Down moves the active node before its
///   previous sibling or after its next one, Alt with Right (Left in
///   right-to-left layouts) moves it into the branch above it as its last
///   child, and Alt with Left moves it out of its branch, after it.
///
/// With [onMove], rows can also be dragged: with a mouse once it moves a
/// few pixels, and with a touch after a long press when [onContextMenu]
/// is null; with [dragHandle], only a grip at the end of the label
/// drags, with any pointer, which leaves the long press to the context
/// menu. A drag carries the multiple selection when it starts on a
/// selected row, and that row alone otherwise. The pointer's place in the
/// row under it picks the drop: the top quarter of a branch drops before
/// it, the bottom quarter after it and the middle into it, as its last
/// child; a leaf takes the top or the bottom half. A drop after an open
/// branch with shown children goes in as its first child. A line between
/// the rows, at the depth the nodes will have, or a frame around the
/// target branch shows the drop; a closed branch held under the pointer
/// for 700 milliseconds opens, loading its children as a click does, and
/// the tree scrolls when the pointer nears its top or bottom edge. A drop
/// into a dragged node or one of its descendants, or one [canDrop]
/// refuses, shows a "no drop" sign and calls nothing; Escape cancels the
/// drag. The tree doesn't change [collection]: the app moves the nodes,
/// such as with [Oito2TreeCollection.move]. Rows can't be dragged or moved
/// while filtering or renaming.
///
/// A branch with no children yet and an [onLoadChildren] shows a spinner
/// while its children load the first time it opens. A non-empty [query]
/// shows only the matching nodes and their ancestors, all open, with the
/// match highlighted; branches can't be opened or closed while filtering.
///
/// A [checkable] tree derives a branch's check box from its leaves in
/// [Oito2TreeController.checked] by default. With [checkState], the app
/// owns the check states instead: the tree shows what it returns, and a
/// click or Space only calls [onCheckChanged], so a branch whose children
/// aren't loaded yet can show as checked or mixed.
///
/// With [columns], the tree is a tree grid: the first column holds the
/// indentation, disclosure, check box, icon and label of each row, the
/// other columns show cells aligned across every depth, and a header row
/// with the column labels stays above the rows.
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
    this.checkState,
    this.onCheckChanged,
    this.isPending,
    this.onContextMenu,
    this.columns,
    this.onColumnResized,
    this.showHeader = true,
    this.onMove,
    this.canDrop,
    this.rowDropTargetBuilder,
    this.dropHighlight,
    this.dragHandle = false,
  });

  /// The nodes of the tree.
  final Oito2TreeCollection<T> collection;

  /// The open, selected and checked nodes.
  final Oito2TreeController controller;

  /// Builds a row's content; the node label by default.
  final Oito2TreeItemBuilder<T>? itemBuilder;

  /// Builds the icon before the label, given whether the node is open;
  /// no icon shows when it returns null.
  final Widget? Function(Oito2TreeNode<T> node, bool expanded)? iconBuilder;

  /// Called on Enter or a double click on a node; when null, those open
  /// or close a branch instead.
  final ValueChanged<Oito2TreeNode<T>>? onActivate;

  /// Loads the children of an empty branch the first time it opens; the
  /// app adds them to [collection].
  ///
  /// When the future fails, the error is reported through
  /// [FlutterError.reportError] and the branch closes; opening it again
  /// retries the load.
  final Future<void> Function(Oito2TreeNode<T> node)? onLoadChildren;

  /// Called with a node and its new, trimmed label when a rename is
  /// confirmed with a non-empty label that differs from the old one; F2
  /// renames nothing when null.
  final void Function(Oito2TreeNode<T> node, String label)? onRename;

  /// Whether the rows have tristate check boxes, tracked in
  /// [Oito2TreeController.checked].
  final bool checkable;

  /// The text that filters the nodes; blank shows the whole tree.
  final String query;

  /// The row height; defaults to the control height.
  final double? rowHeight;

  /// The indent of each level, in logical pixels.
  final double indent;

  /// The accessibility label of the tree.
  final String? semanticLabel;

  /// Whether the tree takes the focus when shown.
  final bool autofocus;

  /// Returns the check state of a node in a [checkable] tree: true, false,
  /// or null for mixed; when set, it replaces the states derived from
  /// [Oito2TreeController.checked], which the tree then leaves untouched.
  ///
  /// It is called only for the rows being built, so it must be cheap.
  final bool? Function(Oito2TreeNode<T> node)? checkState;

  /// Called with a node and its next check state when its check box is
  /// clicked or Space is pressed on it, while [checkState] is set: true
  /// when it is unchecked or mixed, false when it is checked. Nothing else
  /// changes; the app updates what [checkState] returns.
  final void Function(Oito2TreeNode<T> node, bool checked)? onCheckChanged;

  /// Whether a node has a change not applied yet; such rows show a small
  /// dot after the label and a "pending change" hint to assistive
  /// technologies.
  final bool Function(Oito2TreeNode<T> node)? isPending;

  /// Called with a node, a global position and whether the keyboard
  /// asked for the menu: on a secondary click or a long press on its row,
  /// with the pointer position and `byKeyboard` false, and on the Menu key
  /// or Shift+F10 for the active row, with the bottom-start corner of that
  /// row and `byKeyboard` true.
  ///
  /// The row becomes active first and is selected: alone in a single
  /// selection, and in a multiple selection unless it is already part of
  /// it. Disabled rows don't call it. An [Oito2ContextMenuRegion] with an
  /// [Oito2ContextMenuController] around the tree can open its menu at
  /// the position, focusing its first item when `byKeyboard` is true.
  final void Function(
    Oito2TreeNode<T> node,
    Offset globalPosition,
    bool byKeyboard,
  )?
  onContextMenu;

  /// The columns of a tree grid; null or empty shows the plain tree.
  ///
  /// The first column shows the tree's own row content, or what its
  /// [Oito2TableColumn.cellBuilder] builds in place of the label when
  /// [itemBuilder] is null. Columns wider in total than the tree scroll
  /// sideways.
  final List<Oito2TableColumn<Oito2TreeNode<T>>>? columns;

  /// Called with a column id and its new width when a resize of that
  /// column ends; the app can keep the width and pass it back as an
  /// [Oito2ColumnWidth.fixed] width.
  final void Function(String id, double width)? onColumnResized;

  /// Whether a tree with [columns] shows the header row.
  final bool showHeader;

  /// Called when nodes are dragged to a new place, or the active node is
  /// moved with the keyboard or an accessibility action, with the moved
  /// nodes in tree order, the value of their new parent (null for the top
  /// level) and their index among its children counted after the moved
  /// nodes are taken out of their places, as
  /// [Oito2TreeCollection.move] takes it; rows can't be moved when null.
  ///
  /// Only the topmost of the dragged nodes are given: a node brings its
  /// descendants along. Drops that leave the tree unchanged call nothing.
  final void Function(List<Oito2TreeNode<T>> nodes, String? parent, int index)?
  onMove;

  /// Returns whether [onMove] may move the nodes to the parent and index
  /// it would receive; every place but a dragged node and its descendants
  /// is allowed when null.
  ///
  /// It is called as the pointer moves during a drag, so it must be cheap.
  final bool Function(List<Oito2TreeNode<T>> nodes, String? parent, int index)?
  canDrop;

  /// Wraps the row of each node, as built, such as in a [DragTarget] for
  /// the app's own drags or a file drop target, to receive drops from
  /// outside the tree on a row; the row is returned unchanged when null.
  ///
  /// Only the rows in view are built and wrapped. The tree's own row drags
  /// don't use [DragTarget]s, so they never reach these targets.
  final Widget Function(
    BuildContext context,
    Oito2TreeNode<T> node,
    Widget row,
  )?
  rowDropTargetBuilder;

  /// The value of a node to mark as the target of a drop from outside the
  /// tree, with the frame of a drop into a branch, such as while a
  /// [rowDropTargetBuilder] target is hovered; none when null.
  final String? dropHighlight;

  /// Whether only a grip drags a row, instead of the whole row, when
  /// [onMove] is set.
  ///
  /// The grip sits at the end of the row's label, inside the first column
  /// of a tree grid, so the other columns stay aligned with the header.
  /// Any pointer drags it at once, and on touch platforms it is padded to
  /// a 48-pixel touch target as far as the row height allows; a long
  /// press on the row stays free for [onContextMenu].
  final bool dragHandle;

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
  final _listKey = GlobalKey();
  final _horizontalScroll = ScrollController();

  /// The column widths of a tree grid.
  final _columnWidths = TableColumnWidths();

  /// The row drag in progress, or null.
  _TreeDrag<T>? _drag;

  /// The label that follows the pointer during a drag.
  final _feedback = DragFeedback();

  /// Scrolls the rows while a drag nears the top or bottom edge.
  late final _autoScroll = DragAutoScroller(_updateDrop);

  /// Opens the closed branch [_openBranch] after a drag rests on it.
  Timer? _openTimer;
  String? _openBranch;

  /// Whether rows can be moved: [Oito2TreeView.onMove] is set and the tree
  /// is neither filtering nor renaming.
  bool get _canMove =>
      widget.onMove != null && !_filtering && _renaming == null;

  /// Whether the rows show the drag grip of [Oito2TreeView.dragHandle].
  bool get _handle => widget.onMove != null && widget.dragHandle;

  Oito2TreeController get _controller => widget.controller;
  bool get _filtering => widget.query.trim().isNotEmpty;

  /// Whether the app owns the check states through
  /// [Oito2TreeView.checkState].
  bool get _controlled => widget.checkable && widget.checkState != null;

  /// The columns of a tree grid, or null for a plain tree.
  List<Oito2TableColumn<Oito2TreeNode<T>>>? get _columns {
    final columns = widget.columns;
    return columns == null || columns.isEmpty ? null : columns;
  }

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
    _columnWidths.update(oldWidget.columns, widget.columns);
    if (_drag != null && !_canMove) _stopDrag(rebuild: false);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _focusNode.dispose();
    _scroll.dispose();
    _horizontalScroll.dispose();
    _typeTimer?.cancel();
    _clicks.cancel();
    _openTimer?.cancel();
    _autoScroll.stop();
    _feedback.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  /// Makes the first selected row, or else the first row, active when the
  /// tree gains focus without an active row.
  void _onFocus() {
    if (_focusNode.hasFocus && _active == null && _entries.isNotEmpty) {
      final selected = _entries.where(
        (e) => _controller.isSelected(e.node.value),
      );
      _active = (selected.isEmpty ? _entries.first : selected.first).node.value;
    }
    _refresh();
  }

  /// The search result for [_filteredQuery] over [_filteredSource], reused
  /// while neither changes.
  Oito2TreeCollection<T>? _filtered;
  String? _filteredQuery;
  Oito2TreeCollection<T>? _filteredSource;

  /// The check state of every node, filled once per build when the tree is
  /// checkable.
  final Map<String, bool?> _checkStates = {};

  /// The rows to show: the open part of the tree, or every node of the
  /// search result while filtering.
  List<Oito2TreeEntry<T>> _computeEntries() {
    if (!_filtering) return widget.collection.visible(_controller.expanded);
    final query = widget.query.trim();
    var filtered = _filtered;
    if (filtered == null ||
        _filteredQuery != query ||
        !identical(_filteredSource, widget.collection)) {
      filtered = _filtered = widget.collection.search(query);
      _filteredQuery = query;
      _filteredSource = widget.collection;
    }
    return filtered.visible(filtered.branchValues.toSet());
  }

  /// Fills [_checkStates] in one pass: a branch is checked when all of its
  /// leaves are, unchecked when none or it has no leaves, and mixed
  /// otherwise.
  void _computeCheckStates() {
    _checkStates.clear();
    if (!widget.checkable || _controlled) return;
    (int, int) visit(Oito2TreeNode<T> node) {
      final children = node.children;
      if (children == null) {
        final checked = _controller.checkStateOf(widget.collection, node.value);
        _checkStates[node.value] = checked;
        return (checked == true ? 1 : 0, 1);
      }
      var checked = 0;
      var leaves = 0;
      for (final child in children) {
        final (c, l) = visit(child);
        checked += c;
        leaves += l;
      }
      _checkStates[node.value] = leaves == 0 || checked == 0
          ? false
          : checked == leaves
          ? true
          : null;
      return (checked, leaves);
    }

    widget.collection.roots.forEach(visit);
  }

  /// The row index of the node [value], or -1 when it isn't shown.
  int _indexOf(String? value) =>
      _entries.indexWhere((e) => e.node.value == value);

  double get _rowHeight => widget.rowHeight ?? controlHeightOf(context);

  /// The space above the first row and below the last one.
  static const _listPadding = Oito2Spacing.xs;

  /// Scrolls the row at [index] fully into view, with the list padding
  /// around it.
  void _reveal(int index) {
    if (!_scroll.hasClients || index < 0) return;
    final top = _listPadding + index * _rowHeight;
    final bottom = top + _rowHeight;
    final position = _scroll.position;
    if (top - _listPadding < position.pixels) {
      _scroll.jumpTo(math.max(0.0, top - _listPadding));
    } else if (bottom + _listPadding >
        position.pixels + position.viewportDimension) {
      _scroll.jumpTo(
        math.min(
          position.maxScrollExtent,
          bottom + _listPadding - position.viewportDimension,
        ),
      );
    }
  }

  /// Makes the node [value] active and reveals it; a single-selection tree
  /// selects it, and with [extend] a multiple-selection tree selects the
  /// enabled rows from the anchor to it.
  void _activate(String value, {bool extend = false}) {
    setState(() => _active = value);
    final mode = _controller.selectionMode;
    if (mode == Oito2SelectionMode.single) {
      _controller.setSelected([value]);
      _anchor = value;
    } else if (mode == Oito2SelectionMode.multiple && extend) {
      final to = _indexOf(value);
      var from = _indexOf(_anchor);
      // Falls back to the target when the anchor is no longer shown.
      if (from < 0) {
        from = to;
        _anchor = value;
      }
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

  /// Opens or closes the branch [node], loading its children through
  /// [Oito2TreeView.onLoadChildren] the first time an empty branch opens.
  void _setExpanded(Oito2TreeNode<T> node, bool expanded) {
    if (!node.isBranch || _filtering) return;
    _controller.setExpanded(node.value, expanded);
    if (expanded) _load(node);
  }

  /// Whether [node] is an empty branch whose children
  /// [Oito2TreeView.onLoadChildren] hasn't loaded and isn't loading.
  bool _needsLoad(Oito2TreeNode<T> node) =>
      widget.onLoadChildren != null &&
      (node.children?.isEmpty ?? false) &&
      !_loaded.contains(node.value) &&
      !_loading.contains(node.value);

  /// Loads the children of [node] through [Oito2TreeView.onLoadChildren]
  /// when it needs them; a failed load is reported and closes the branch.
  Future<void> _load(Oito2TreeNode<T> node) async {
    final load = widget.onLoadChildren;
    if (load == null || !_needsLoad(node)) return;
    setState(() => _loading.add(node.value));
    var loaded = false;
    try {
      await load(node);
      loaded = true;
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'oito2_ui',
          context: ErrorDescription('while loading tree children'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading.remove(node.value);
          if (loaded) {
            _loaded.add(node.value);
          } else {
            _controller.setExpanded(node.value, false);
          }
        });
      }
    }
  }

  /// Whether a load of the open, empty branches is scheduled.
  bool _loadsScheduled = false;

  /// Schedules, after the frame, the load of every shown open branch that
  /// is still empty, however it was opened, such as from the controller;
  /// does nothing while filtering or without
  /// [Oito2TreeView.onLoadChildren].
  void _scheduleLoads() {
    if (_loadsScheduled ||
        widget.onLoadChildren == null ||
        _filtering ||
        !_openEmptyBranches().any((_) => true)) {
      return;
    }
    _loadsScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadsScheduled = false;
      if (!mounted || _filtering) return;
      _openEmptyBranches().toList().forEach(_load);
    });
  }

  /// The open branches that need a load and whose ancestors are all open,
  /// so that they are shown.
  Iterable<Oito2TreeNode<T>> _openEmptyBranches() sync* {
    final collection = widget.collection;
    for (final value in _controller.expanded) {
      final node = collection.find(value);
      if (node == null || !_needsLoad(node)) continue;
      if (collection.ancestorsOf(value).every(_controller.isExpanded)) {
        yield node;
      }
    }
  }

  /// Runs the primary action of [node]: [Oito2TreeView.onActivate], or
  /// opening or closing a branch.
  void _primary(Oito2TreeNode<T> node) {
    final activate = widget.onActivate;
    if (activate != null) {
      activate(node);
    } else if (node.isBranch) {
      _setExpanded(node, !_controller.isExpanded(node.value));
    }
  }

  /// The check state shown for [node]: the one from
  /// [Oito2TreeView.checkState] in a controlled tree, or else the one
  /// derived from the controller.
  bool? _checkStateOf(Oito2TreeNode<T> node) =>
      _controlled ? widget.checkState!(node) : _checkStates[node.value];

  /// Reports the next check state of [node] through
  /// [Oito2TreeView.onCheckChanged] in a controlled tree, or else toggles
  /// it in the controller.
  void _toggleCheck(Oito2TreeNode<T> node) {
    if (_controlled) {
      widget.onCheckChanged?.call(node, _checkStateOf(node) != true);
    } else {
      _controller.toggleChecked(widget.collection, node.value);
    }
  }

  /// Toggles the check box of [node], or else its selection in a
  /// multiple-selection tree.
  void _toggleSpace(Oito2TreeNode<T> node) {
    if (widget.checkable) {
      _toggleCheck(node);
    } else if (_controller.selectionMode == Oito2SelectionMode.multiple) {
      _controller.toggleSelected(node.value);
    }
  }

  /// Handles the tree's keyboard navigation and commands.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (_renaming != null) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (_drag != null) {
      if (event.logicalKey == LogicalKeyboardKey.escape) _stopDrag();
      return KeyEventResult.handled;
    }
    if (_entries.isEmpty) return KeyEventResult.ignored;
    final keyboard = HardwareKeyboard.instance;
    final shift = keyboard.isShiftPressed;
    final command = keyboard.isControlPressed || keyboard.isMetaPressed;
    final key = event.logicalKey;
    final index = _indexOf(_active);
    final current = index < 0 ? null : _entries[index];

    String? step(int from, int delta) {
      for (var i = from + delta; i >= 0 && i < _entries.length; i += delta) {
        if (!_entries[i].node.disabled) return _entries[i].node.value;
      }
      return null;
    }

    final (back: closeKey, forward: openKey) = readingArrowsOf(context);
    if (keyboard.isAltPressed && _canMove && current != null) {
      final move = switch (key) {
        LogicalKeyboardKey.arrowUp => _KeyMove.up,
        LogicalKeyboardKey.arrowDown => _KeyMove.down,
        _ when key == openKey => _KeyMove.indent,
        _ when key == closeKey => _KeyMove.outdent,
        _ => null,
      };
      if (move != null) {
        _moveBy(current.node, move);
        return KeyEventResult.handled;
      }
    }
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
    } else if (widget.onContextMenu != null &&
        current != null &&
        (key == LogicalKeyboardKey.contextMenu ||
            (key == LogicalKeyboardKey.f10 && shift))) {
      if (event is KeyDownEvent) {
        _reveal(index);
        final corner = _rowCorner(index);
        if (corner != null) {
          _showContextMenu(current.node, corner, byKeyboard: true);
        }
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

  /// Adds [character] to the typed prefix, which resets after a pause,
  /// and activates the next enabled row after [index] whose label starts
  /// with it; repeating one character cycles through its matches.
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

  /// Whether [node] shows as open; every branch is open while filtering.
  bool _isOpen(Oito2TreeNode<T> node) =>
      _filtering || _controller.isExpanded(node.value);

  /// Focuses the tree and activates [node], toggling it with Control or
  /// Command and extending the selection with Shift in a
  /// multiple-selection tree.
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

  /// The horizontal space around each row.
  static const _rowMargin = Oito2Spacing.xs;

  /// The global position of the bottom-start corner of the row at
  /// [index], or null before the list is laid out.
  Offset? _rowCorner(int index) {
    final box = _listKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !_scroll.hasClients) return null;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final y = _listPadding + (index + 1) * _rowHeight - _scroll.offset;
    final x = rtl ? box.size.width - _rowMargin : _rowMargin;
    return box.localToGlobal(Offset(x, y));
  }

  /// Makes [node] active and selected, keeping a multiple selection that
  /// already holds it, and calls [Oito2TreeView.onContextMenu] with
  /// [position] and [byKeyboard]; does nothing for a disabled node.
  void _showContextMenu(
    Oito2TreeNode<T> node,
    Offset position, {
    bool byKeyboard = false,
  }) {
    final callback = widget.onContextMenu;
    if (callback == null || node.disabled) return;
    _focusNode.requestFocus();
    setState(() => _active = node.value);
    _anchor = node.value;
    switch (_controller.selectionMode) {
      case Oito2SelectionMode.none:
        break;
      case Oito2SelectionMode.single:
        _controller.setSelected([node.value]);
      case Oito2SelectionMode.multiple:
        if (!_controller.isSelected(node.value)) {
          _controller.setSelected([node.value]);
        }
    }
    callback(node, position, byKeyboard);
  }

  /// Grows the column at [index] by [delta] in screen coordinates.
  void _resizeColumn(int index, double delta) {
    final columns = _columns;
    if (columns == null) return;
    setState(() {
      _columnWidths.resize(
        columns[index],
        index,
        delta,
        Directionality.of(context),
      );
    });
  }

  /// Reports the width of the column at [index] through
  /// [Oito2TreeView.onColumnResized].
  void _endResize(int index) {
    final columns = _columns;
    if (columns == null) return;
    final width = _columnWidths.widthOf(columns[index], index);
    if (width != null) widget.onColumnResized?.call(columns[index].id, width);
  }

  /// The place [move] takes [node] to among the nodes of the tree, as the
  /// parent value, the index after [node] is taken out and the branch it
  /// goes into, or null when it can't go that way.
  ({String? parent, int index, Oito2TreeNode<T>? into})? _keyMoveTarget(
    Oito2TreeNode<T> node,
    _KeyMove move,
  ) {
    final collection = widget.collection;
    final value = node.value;
    final path = collection.indexPathOf(value);
    if (path == null) return null;
    final parent = collection.parentOf(value);
    final siblings = collection.siblingsOf(value);
    final i = path.last;
    switch (move) {
      case _KeyMove.up:
        return i == 0 ? null : (parent: parent, index: i - 1, into: null);
      case _KeyMove.down:
        return i >= siblings.length - 1
            ? null
            : (parent: parent, index: i + 1, into: null);
      case _KeyMove.indent:
        if (i == 0 || !siblings[i - 1].isBranch) return null;
        final into = siblings[i - 1];
        return (
          parent: into.value,
          index: into.children?.length ?? 0,
          into: into,
        );
      case _KeyMove.outdent:
        if (parent == null) return null;
        return (
          parent: collection.parentOf(parent),
          index: collection.indexPathOf(parent)!.last + 1,
          into: null,
        );
    }
  }

  /// Moves [node] the way of [move] through [Oito2TreeView.onMove] when
  /// [Oito2TreeView.canDrop] allows it, opens the branch it goes into and
  /// announces the result; announces that it can't move when [canDrop]
  /// refuses, and does nothing when it can't go that way.
  void _moveBy(Oito2TreeNode<T> node, _KeyMove move) {
    final onMove = widget.onMove;
    if (onMove == null || node.disabled || !_canMove) return;
    final target = _keyMoveTarget(node, move);
    if (target == null) return;
    final (:parent, :index, :into) = target;
    final strings = Oito2Localizations.of(context);
    if (!(widget.canDrop?.call([node], parent, index) ?? true)) {
      announceTo(context, strings.cantDropHere);
      return;
    }
    onMove([node], parent, index);
    if (into != null) _setExpanded(into, true);
    final parentNode = parent == null ? null : widget.collection.find(parent);
    announceTo(
      context,
      parentNode == null
          ? strings.movedToTopLevel(node.label, index + 1)
          : strings.movedInto(node.label, parentNode.label, index + 1),
    );
    final value = node.value;
    setState(() => _active = value);
    _anchor = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reveal(_indexOf(value));
    });
  }

  /// The accessibility actions that move [node], for the ways it can go,
  /// or null when rows can't be moved.
  Map<CustomSemanticsAction, VoidCallback>? _moveActions(
    Oito2TreeNode<T> node,
  ) {
    if (!_canMove || node.disabled) return null;
    final strings = Oito2Localizations.of(context);
    return {
      for (final (move, label) in [
        (_KeyMove.up, strings.moveUp),
        (_KeyMove.down, strings.moveDown),
        (_KeyMove.indent, strings.indentItem),
        (_KeyMove.outdent, strings.outdentItem),
      ])
        if (_keyMoveTarget(node, move) != null)
          CustomSemanticsAction(label: label): () => _moveBy(node, move),
    };
  }

  /// The nodes a drag that starts on [node] carries: the topmost enabled
  /// nodes of a multiple selection that holds it, in tree order, or else
  /// [node] alone.
  List<Oito2TreeNode<T>> _dragNodes(Oito2TreeNode<T> node) {
    final selected = _controller.selected;
    if (_controller.selectionMode != Oito2SelectionMode.multiple ||
        !selected.contains(node.value) ||
        selected.length < 2) {
      return [node];
    }
    final collection = widget.collection;
    return [
      for (final e in collection.flatten())
        if (selected.contains(e.node.value) &&
            !e.node.disabled &&
            !collection.ancestorsOf(e.node.value).any(selected.contains))
          e.node,
    ];
  }

  /// Starts dragging the nodes [_dragNodes] gives for [node] from the
  /// global position [global], unless rows can't be moved, [node] is
  /// disabled or a drag is already in progress.
  Drag? _startDrag(Oito2TreeNode<T> node, Offset global) {
    if (!_canMove || node.disabled || _drag != null) return null;
    final nodes = _dragNodes(node);
    _focusNode.requestFocus();
    setState(() {
      _active = node.value;
      _drag = _TreeDrag(nodes, global);
    });
    _feedback.show(
      context,
      nodes.length == 1
          ? nodes.first.label
          : Oito2Localizations.of(context).dragItemCount(nodes.length),
      global,
    );
    _updateDrop();
    return RowDrag(onUpdate: _dragTo, onEnd: _endDrag);
  }

  /// Follows the pointer of the drag to [global]: updates the drop and
  /// scrolls near the edges.
  void _dragTo(Offset global) {
    final drag = _drag;
    if (drag == null) return;
    drag.pointer = global;
    _feedback.move(global);
    _updateDrop();
    _autoScroll.update(
      global,
      _listKey.currentContext?.findRenderObject() as RenderBox?,
      _scroll.hasClients ? _scroll.position : null,
      edge: _rowHeight,
    );
  }

  /// Ends the drag: when the pointer was released over an allowed drop
  /// that changes the tree, calls [Oito2TreeView.onMove].
  void _endDrag(bool dropped) {
    final drag = _drag;
    if (drag == null) return;
    final drop = drag.drop;
    _stopDrag();
    if (dropped && drop != null && drop.valid && !drop.noop) {
      widget.onMove?.call(drag.nodes, drop.parent, drop.index);
    }
  }

  /// Ends the drag without moving anything, rebuilding unless [rebuild] is
  /// false, as when the tree is about to build anyway.
  void _stopDrag({bool rebuild = true}) {
    _autoScroll.stop();
    _openTimer?.cancel();
    _openTimer = null;
    _openBranch = null;
    _feedback.hide();
    if (_drag == null) return;
    _drag = null;
    if (rebuild && mounted) setState(() {});
  }

  /// Recomputes the drop of the drag for its pointer, shows whether it is
  /// allowed and starts or stops the timer that opens the closed branch
  /// under the pointer.
  void _updateDrop() {
    final drag = _drag;
    if (drag == null || !mounted) return;
    final drop = _dropAt(drag);
    _feedback.allowed = drop != null && drop.valid;
    if (drop != drag.drop) setState(() => drag.drop = drop);
    final branch = drop != null && drop.placement == DropPlacement.inside
        ? drop.row
        : null;
    final closed =
        branch != null &&
        !_controller.isExpanded(branch) &&
        !drag.values.contains(branch) &&
        !widget.collection.ancestorsOf(branch).any(drag.values.contains);
    final next = closed ? branch : null;
    if (next == _openBranch) return;
    _openTimer?.cancel();
    _openBranch = next;
    _openTimer = next == null
        ? null
        : Timer(const Duration(milliseconds: 700), () {
            _openTimer = null;
            final node = widget.collection.find(next);
            if (!mounted || _drag == null || node == null) return;
            _setExpanded(node, true);
            WidgetsBinding.instance.addPostFrameCallback((_) => _updateDrop());
          });
  }

  /// The drop for the pointer of [drag], or null when the pointer is
  /// outside the rows' area.
  _TreeDrop? _dropAt(_TreeDrag<T> drag) {
    final box = _listKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !_scroll.hasClients) return null;
    if (_entries.isEmpty) return null;
    final local = box.globalToLocal(drag.pointer);
    if (local.dx < 0 ||
        local.dy < 0 ||
        local.dx > box.size.width ||
        local.dy > box.size.height) {
      return null;
    }
    final height = _rowHeight;
    final y = local.dy + _scroll.offset - _listPadding;
    final int row;
    final double fraction;
    if (y < 0) {
      (row, fraction) = (0, 0);
    } else if (y >= _entries.length * height) {
      (row, fraction) = (_entries.length - 1, 1);
    } else {
      row = (y / height).floor();
      fraction = (y - row * height) / height;
    }
    final entry = _entries[row];
    final node = entry.node;
    final collection = widget.collection;
    final placement = node.isBranch
        ? (fraction < 0.25
              ? DropPlacement.before
              : fraction > 0.75
              ? DropPlacement.after
              : DropPlacement.inside)
        : (fraction < 0.5 ? DropPlacement.before : DropPlacement.after);
    String? parent;
    int gap;
    var depth = entry.depth;
    switch (placement) {
      case DropPlacement.before:
        parent = collection.parentOf(node.value);
        gap = entry.indexPath.last;
      case DropPlacement.inside:
        parent = node.value;
        gap = node.children?.length ?? 0;
      case DropPlacement.after:
        if (node.isBranch &&
            row + 1 < _entries.length &&
            _entries[row + 1].depth > entry.depth) {
          parent = node.value;
          gap = 0;
          depth = entry.depth + 1;
        } else {
          parent = collection.parentOf(node.value);
          gap = entry.indexPath.last + 1;
        }
    }
    final values = drag.values;
    final siblings = parent == null
        ? collection.roots
        : collection.childrenOf(parent);
    var index = gap;
    for (var k = 0; k < gap && k < siblings.length; k++) {
      if (values.contains(siblings[k].value)) index--;
    }
    final intoMoved =
        parent != null &&
        (values.contains(parent) ||
            collection.ancestorsOf(parent).any(values.contains));
    var noop = false;
    if (!intoMoved) {
      final before = [for (final s in siblings) s.value];
      final after = [
        for (final s in siblings)
          if (!values.contains(s.value)) s.value,
      ]..insertAll(index, [for (final n in drag.nodes) n.value]);
      noop = listEquals(before, after);
    }
    final valid =
        !intoMoved &&
        (noop || (widget.canDrop?.call(drag.nodes, parent, index) ?? true));
    return (
      row: node.value,
      placement: placement,
      depth: depth,
      parent: parent,
      index: index,
      valid: valid,
      noop: noop,
    );
  }

  /// Builds the row of [entry]: disclosure, check box, icon and label, or
  /// the rename field, followed by the cells of the other columns in a
  /// tree grid.
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
    final bool? checkState = widget.checkable ? _checkStateOf(node) : false;
    final pending = widget.isPending?.call(node) ?? false;
    final columns = _columns;
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
          : MouseRegion(
              cursor: _filtering || _drag != null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _filtering ? null : () => _setExpanded(node, !open),
                child: AnimatedRotation(
                  turns: open ? (rtl ? -0.25 : 0.25) : 0,
                  duration:
                      MediaQuery.maybeDisableAnimationsOf(context) ?? false
                      ? Duration.zero
                      : const Duration(milliseconds: 150),
                  child: Icon(
                    rtl ? LucideIcons.chevron_left : LucideIcons.chevron_right,
                    size: 16,
                  ),
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
        onDiscarded: () {
          if (mounted && _renaming == value) {
            setState(() => _renaming = null);
          }
        },
      );
    } else {
      final cell = columns?.first.cellBuilder;
      label =
          widget.itemBuilder?.call(context, node) ??
          cell?.call(context, node) ??
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
    final content = Row(
      spacing: Oito2Spacing.xs,
      children: [
        disclosure,
        if (widget.checkable)
          ExcludeFocus(
            child: Oito2Checkbox(
              value: checkState,
              tristate: true,
              onChanged: node.disabled ? null : (_) => _toggleCheck(node),
            ),
          ),
        ?icon,
        Expanded(child: label),
        if (pending)
          Container(
            key: const ValueKey('oito2-tree-pending'),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: semanticColorsOf(context).warning,
              shape: BoxShape.circle,
            ),
          ),
        if (_handle)
          Oito2TouchTarget(
            child: RowDragHandle(
              onStart: _canMove && !node.disabled
                  ? (global) => _startDrag(node, global)
                  : null,
              dragging: _drag != null,
            ),
          ),
      ],
    );

    Widget semantics(Widget child) => Semantics(
      selected: selected,
      enabled: !node.disabled,
      focused: active,
      expanded: node.isBranch ? open : null,
      checked: widget.checkable ? checkState ?? false : null,
      mixed: widget.checkable && checkState == null ? true : null,
      label: node.label,
      hint: pending ? Oito2Localizations.of(context).pendingChange : null,
      excludeSemantics: _renaming != value,
      onTap: node.disabled ? null : () => _tap(node),
      customSemanticsActions: _moveActions(node),
      child: child,
    );

    Widget frame(Widget child, EdgeInsetsDirectional padding) => MouseRegion(
      cursor: node.disabled || _drag != null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          _tap(node);
          if (!node.disabled && _clicks.click(value)) _primary(node);
        },
        onSecondaryTapUp: widget.onContextMenu == null
            ? null
            : (details) => _showContextMenu(node, details.globalPosition),
        onLongPressStart: widget.onContextMenu == null
            ? null
            : (details) => _showContextMenu(node, details.globalPosition),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: _rowMargin),
          padding: padding,
          decoration: BoxDecoration(
            color: selected ? scheme.secondaryContainer : null,
            borderRadius: Oito2Radius.smallAll,
          ),
          // Drawn over the row so that it takes no room from the cells.
          foregroundDecoration: BoxDecoration(
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
              child: child,
            ),
          ),
        ),
      ),
    );

    if (columns == null) {
      return _decorate(
        context,
        node,
        semantics(
          frame(
            content,
            EdgeInsetsDirectional.only(
              start: Oito2Spacing.xs + entry.depth * widget.indent,
              end: Oito2Spacing.sm,
            ),
          ),
        ),
      );
    }
    // The first cell keeps the room its fixed parts need, clipped when the
    // column is narrower.
    final indent = entry.depth * widget.indent;
    final needed =
        indent +
        20 +
        (widget.checkable ? kMinInteractiveDimension + Oito2Spacing.xs : 0) +
        (icon == null ? 0 : 16 + Oito2Spacing.xs) +
        Oito2Spacing.xs +
        24 +
        (_handle
            ? (padsTapTargets(context) ? Oito2Sizes.minTouchTarget : 24) +
                  Oito2Spacing.xs
            : 0);
    return _decorate(
      context,
      node,
      frame(
        Row(
          children: [
            SizedBox(
              width: _columnWidths.widths[0],
              child: semantics(
                ClipRect(
                  child: OverflowBox(
                    alignment: AlignmentDirectional.centerStart,
                    minWidth: 0,
                    maxWidth: math.max(_columnWidths.widths[0], needed),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(start: indent),
                      child: content,
                    ),
                  ),
                ),
              ),
            ),
            for (var i = 1; i < columns.length; i++)
              SizedBox(
                width: _columnWidths.widths[i],
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: Oito2Spacing.xs,
                    end: Oito2Spacing.sm,
                  ),
                  child: Align(
                    alignment: columns[i].alignment,
                    child: columns[i].cellBuilder?.call(context, node),
                  ),
                ),
              ),
          ],
        ),
        const EdgeInsetsDirectional.only(
          start: Oito2Spacing.xs,
          end: Oito2Spacing.sm,
        ),
      ),
    );
  }

  /// Adds to the [row] of [node] the start of row drags, the mark of the
  /// drop on it and the app's [Oito2TreeView.rowDropTargetBuilder].
  Widget _decorate(BuildContext context, Oito2TreeNode<T> node, Widget row) {
    var result = row;
    if (widget.onMove != null) {
      result = RowDragDetector(
        onStart: _canMove && !node.disabled && !widget.dragHandle
            ? (global) => _startDrag(node, global)
            : null,
        longPress: widget.onContextMenu == null,
        child: result,
      );
    }
    if (widget.onMove != null ||
        widget.dropHighlight != null ||
        widget.rowDropTargetBuilder != null) {
      final drop = _drag?.drop;
      final Widget? mark;
      if (widget.dropHighlight == node.value ||
          (drop != null &&
              drop.row == node.value &&
              drop.valid &&
              !drop.noop &&
              drop.placement == DropPlacement.inside)) {
        mark = const DropInsideFrame(
          margin: EdgeInsets.symmetric(horizontal: _rowMargin),
        );
      } else if (drop != null &&
          drop.row == node.value &&
          drop.valid &&
          !drop.noop) {
        mark = DropLine(
          placement: drop.placement,
          start: _rowMargin + Oito2Spacing.xs + drop.depth * widget.indent,
        );
      } else {
        mark = null;
      }
      result = Stack(fit: StackFit.passthrough, children: [result, ?mark]);
    }
    return widget.rowDropTargetBuilder?.call(context, node, result) ?? result;
  }

  @override
  Widget build(BuildContext context) {
    _entries = _computeEntries();
    _computeCheckStates();
    _scheduleLoads();
    if (_active != null && _indexOf(_active) < 0) _active = null;
    if (_anchor != null && _indexOf(_anchor) < 0) _anchor = null;
    final drag = _drag;
    final list = Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _onKey,
      child: MouseRegion(
        cursor: drag == null
            ? MouseCursor.defer
            : drag.drop?.valid ?? false
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.noDrop,
        child: ListView.builder(
          key: _listKey,
          controller: _scroll,
          itemExtent: _rowHeight,
          padding: const EdgeInsets.symmetric(vertical: _listPadding),
          itemCount: _entries.length,
          itemBuilder: (context, index) => _row(context, _entries[index]),
        ),
      ),
    );
    final columns = _columns;
    return Semantics(
      label: widget.semanticLabel,
      container: true,
      explicitChildNodes: true,
      child: columns == null
          ? list
          : TableColumnsView(
              controller: _horizontalScroll,
              // Margins on both sides, and the row's start and end padding.
              chrome: 2 * _rowMargin + Oito2Spacing.xs + Oito2Spacing.sm,
              resolve: (available) => _columnWidths.resolve(columns, available),
              header: !widget.showHeader
                  ? null
                  : (context) => TableHeader(
                      columns: columns,
                      widths: _columnWidths.widths,
                      height: _rowHeight,
                      margin: const EdgeInsets.symmetric(
                        horizontal: _rowMargin,
                      ),
                      padding: const EdgeInsetsDirectional.only(
                        start: Oito2Spacing.xs,
                        end: Oito2Spacing.sm,
                      ),
                      onResize: _resizeColumn,
                      onResizeEnd: _endResize,
                    ),
              body: list,
            ),
    );
  }
}

/// The inline field of a node being renamed: Enter or leaving it keeps
/// the text, Escape cancels.
class _RenameField extends StatefulWidget {
  const _RenameField({
    required this.initial,
    required this.onDone,
    required this.onDiscarded,
  });

  final String initial;

  /// Called once with the new text, or null when cancelled.
  final ValueChanged<String?> onDone;

  /// Called after the frame in which the field is removed without having
  /// reported through [onDone], such as when its row is filtered out,
  /// removed or scrolled away.
  final VoidCallback onDiscarded;

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
    if (!_done) {
      _done = true;
      // The tree may still be building, so it learns after the frame.
      final discarded = widget.onDiscarded;
      WidgetsBinding.instance.addPostFrameCallback((_) => discarded());
    }
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Reports [text] through [_RenameField.onDone] the first time only.
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

/// A way the keyboard or an accessibility action moves a tree node.
enum _KeyMove {
  /// Before the previous sibling.
  up,

  /// After the next sibling.
  down,

  /// Into the previous sibling, a branch, as its last child.
  indent,

  /// Out of the parent, right after it.
  outdent,
}

/// Where a drag would drop: the row it marks, before, into or after it,
/// with the depth of the line; the parent and the index the nodes would
/// get; whether the drop is allowed; and whether it would leave the tree
/// unchanged.
typedef _TreeDrop = ({
  String row,
  DropPlacement placement,
  int depth,
  String? parent,
  int index,
  bool valid,
  bool noop,
});

/// A drag of tree rows: the dragged [nodes], the pointer and the drop
/// under it.
class _TreeDrag<T> {
  _TreeDrag(this.nodes, this.pointer)
    : values = {for (final node in nodes) node.value};

  /// The dragged nodes, the topmost ones in tree order.
  final List<Oito2TreeNode<T>> nodes;

  /// The values of [nodes].
  final Set<String> values;

  /// The global pointer position.
  Offset pointer;

  /// The drop under [pointer], or null when it is outside the rows.
  _TreeDrop? drop;
}
