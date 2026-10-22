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

import 'text_folding.dart';

/// A node of an [Oito2TreeCollection]: a unique [value], a [label], an
/// optional payload and, for branches, its [children].
@immutable
class Oito2TreeNode<T> {
  /// Creates a node; give [children] (possibly empty) to make a branch.
  const Oito2TreeNode({
    required this.value,
    this._label,
    this.data,
    this.children,
    this.disabled = false,
  });

  /// The unique value of the node in its tree.
  final String value;

  final String? _label;

  /// The display label; defaults to [value].
  String get label => _label ?? value;

  /// The payload, such as the file or record the node shows.
  final T? data;

  /// The child nodes of a branch; null for a leaf.
  final List<Oito2TreeNode<T>>? children;

  /// Whether the node can't be selected or focused.
  final bool disabled;

  /// Whether the node can have children.
  bool get isBranch => children != null;

  /// Returns a copy with the given fields replaced.
  Oito2TreeNode<T> copyWith({
    String? label,
    T? data,
    List<Oito2TreeNode<T>>? children,
    bool? disabled,
  }) {
    return Oito2TreeNode(
      value: value,
      label: label ?? _label,
      data: data ?? this.data,
      children: children ?? this.children,
      disabled: disabled ?? this.disabled,
    );
  }
}

/// A node with its position in a flattened [Oito2TreeCollection].
typedef Oito2TreeEntry<T> = ({
  Oito2TreeNode<T> node,
  int depth,
  List<int> indexPath,
});

/// An immutable tree of [Oito2TreeNode]s with the queries a tree view
/// needs: lookups by value and index path, parents and siblings, the
/// visible order for a set of expanded branches, filtering and copies with
/// nodes inserted, removed, moved or replaced.
///
/// An index path lists the child indexes from the top level down, such as
/// `[0, 2]` for the third child of the first top-level node.
@immutable
class Oito2TreeCollection<T> {
  /// Creates a tree with the top-level [roots].
  ///
  /// Throws an [ArgumentError] when two nodes share a value.
  Oito2TreeCollection(Iterable<Oito2TreeNode<T>> roots)
    : roots = List.unmodifiable(roots) {
    void index(List<Oito2TreeNode<T>> nodes, List<int> path, String? parent) {
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final nodePath = List<int>.unmodifiable([...path, i]);
        if (_paths.containsKey(node.value)) {
          throw ArgumentError.value(node.value, 'roots', 'Duplicate value');
        }
        _paths[node.value] = nodePath;
        _parents[node.value] = parent;
        index(node.children ?? const [], nodePath, node.value);
      }
    }

    index(this.roots, const [], null);
  }

  /// Builds a tree from slash-separated [paths], such as file paths: each
  /// segment becomes a branch and the last one a leaf. Node values are
  /// the paths up to each node and labels the segment names.
  factory Oito2TreeCollection.fromPaths(
    Iterable<String> paths, {
    String separator = '/',
  }) {
    final children = <String, List<String>>{'': []};
    final leaves = <String>{};
    for (final path in paths) {
      final parts = path.split(separator).where((p) => p.isNotEmpty).toList();
      var parent = '';
      for (var i = 0; i < parts.length; i++) {
        final value = parent.isEmpty
            ? parts[i]
            : '$parent$separator${parts[i]}';
        final siblings = children.putIfAbsent(parent, () => []);
        if (!siblings.contains(value)) siblings.add(value);
        if (i == parts.length - 1) leaves.add(value);
        children.putIfAbsent(value, () => []);
        parent = value;
      }
    }
    Oito2TreeNode<T> build(String value) {
      final kids = children[value]!;
      return Oito2TreeNode<T>(
        value: value,
        label: value.split(separator).last,
        children: kids.isEmpty && leaves.contains(value)
            ? null
            : [for (final kid in kids) build(kid)],
      );
    }

    return Oito2TreeCollection([for (final root in children['']!) build(root)]);
  }

  /// The top-level nodes.
  final List<Oito2TreeNode<T>> roots;

  final Map<String, List<int>> _paths = {};
  final Map<String, String?> _parents = {};

  /// Whether a node has [value].
  bool has(String? value) => _paths.containsKey(value);

  /// The index path of the node with [value], or null.
  List<int>? indexPathOf(String value) => _paths[value];

  /// The node at [indexPath], or null when the path doesn't exist.
  Oito2TreeNode<T>? nodeAt(List<int> indexPath) {
    List<Oito2TreeNode<T>>? level = roots;
    Oito2TreeNode<T>? node;
    for (final index in indexPath) {
      if (level == null || index < 0 || index >= level.length) return null;
      node = level[index];
      level = node.children;
    }
    return node;
  }

  /// The node with [value], or null.
  Oito2TreeNode<T>? find(String? value) {
    final path = _paths[value];
    return path == null ? null : nodeAt(path);
  }

  /// The value of the parent of [value], or null for a top-level node.
  String? parentOf(String value) => _parents[value];

  /// The children of [value]; empty for a leaf or a missing node.
  List<Oito2TreeNode<T>> childrenOf(String value) =>
      find(value)?.children ?? const [];

  /// The nodes that share a parent with [value], including it.
  List<Oito2TreeNode<T>> siblingsOf(String value) {
    final parent = parentOf(value);
    return parent == null ? roots : childrenOf(parent);
  }

  /// The values of the ancestors of [value], from the top level down.
  List<String> ancestorsOf(String value) {
    final result = <String>[];
    for (var p = parentOf(value); p != null; p = parentOf(p)) {
      result.insert(0, p);
    }
    return result;
  }

  /// The depth of [value]: 0 at the top level.
  int depthOf(String value) => (_paths[value]?.length ?? 1) - 1;

  /// Every node in depth-first order with its depth and index path.
  List<Oito2TreeEntry<T>> flatten() => _flatten(null);

  /// The nodes a tree view shows when the branches in [expanded] are open,
  /// in display order.
  List<Oito2TreeEntry<T>> visible(Set<String> expanded) => _flatten(expanded);

  List<Oito2TreeEntry<T>> _flatten(Set<String>? expanded) {
    final result = <Oito2TreeEntry<T>>[];
    void walk(List<Oito2TreeNode<T>> nodes, List<int> path) {
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final nodePath = [...path, i];
        result.add((node: node, depth: path.length, indexPath: nodePath));
        if (expanded == null || expanded.contains(node.value)) {
          walk(node.children ?? const [], nodePath);
        }
      }
    }

    walk(roots, const []);
    return result;
  }

  /// The values of every node, in depth-first order.
  List<String> get values => [for (final e in flatten()) e.node.value];

  /// The values of every branch.
  List<String> get branchValues => [
    for (final e in flatten())
      if (e.node.isBranch) e.node.value,
  ];

  /// The values of every node below [value].
  List<String> descendantsOf(String value) {
    final result = <String>[];
    void walk(List<Oito2TreeNode<T>> nodes) {
      for (final node in nodes) {
        result.add(node.value);
        walk(node.children ?? const []);
      }
    }

    walk(childrenOf(value));
    return result;
  }

  /// The values of the leaves below [value], or [value] itself when it is
  /// a leaf; empty for an unknown value.
  List<String> leavesOf(String value) {
    final node = find(value);
    if (node == null) return const [];
    if (!node.isBranch) return [value];
    return [
      for (final v in descendantsOf(value))
        if (!(find(v)?.isBranch ?? false)) v,
    ];
  }

  /// The enabled visible node after [value] for the [expanded] branches,
  /// or null at the end.
  String? nextVisible(String value, Set<String> expanded) =>
      _step(value, expanded, 1);

  /// The enabled visible node before [value] for the [expanded] branches,
  /// or null at the start.
  String? previousVisible(String value, Set<String> expanded) =>
      _step(value, expanded, -1);

  String? _step(String value, Set<String> expanded, int step) {
    final list = visible(expanded);
    var index = list.indexWhere((e) => e.node.value == value);
    if (index < 0) return null;
    for (index += step; index >= 0 && index < list.length; index += step) {
      if (!list[index].node.disabled) return list[index].node.value;
    }
    return null;
  }

  /// A tree with the nodes for which [test] returns true and their
  /// ancestors; branches keep only matching descendants.
  Oito2TreeCollection<T> filter(bool Function(Oito2TreeNode<T> node) test) {
    List<Oito2TreeNode<T>> keep(List<Oito2TreeNode<T>> nodes) => [
      for (final node in nodes)
        if (test(node))
          node
        else if (keep(node.children ?? const []) case final kids
            when kids.isNotEmpty)
          node.copyWith(children: kids),
    ];

    return Oito2TreeCollection(keep(roots));
  }

  /// A tree with the nodes whose label contains [query], ignoring case and
  /// accents, and their ancestors.
  Oito2TreeCollection<T> search(String query) {
    final needle = foldText(query);
    return filter((node) => foldText(node.label).contains(needle));
  }

  /// A tree with [nodes] inserted among the children of [parentValue] (the
  /// top level when null) at [index], or at the end when [index] is null.
  ///
  /// Throws an [ArgumentError] when [parentValue] isn't in the tree.
  Oito2TreeCollection<T> insert(
    String? parentValue,
    List<Oito2TreeNode<T>> nodes, {
    int? index,
  }) {
    if (parentValue != null && !has(parentValue)) {
      throw ArgumentError.value(parentValue, 'parentValue', 'Unknown node');
    }
    List<Oito2TreeNode<T>> into(List<Oito2TreeNode<T>> list) {
      final copy = [...list];
      copy.insertAll(index ?? copy.length, nodes);
      return copy;
    }

    if (parentValue == null) return Oito2TreeCollection(into(roots));
    return _mapNode(
      parentValue,
      (node) => node.copyWith(children: into(node.children ?? const [])),
    );
  }

  /// A tree without the nodes in [values] and their descendants.
  Oito2TreeCollection<T> remove(Iterable<String> values) {
    final set = values.toSet();
    List<Oito2TreeNode<T>> prune(List<Oito2TreeNode<T>> nodes) => [
      for (final node in nodes)
        if (!set.contains(node.value))
          node.isBranch ? node.copyWith(children: prune(node.children!)) : node,
    ];
    return Oito2TreeCollection(prune(roots));
  }

  /// A tree with the nodes in [values] moved, in tree order, among the
  /// children of [parentValue] (the top level when null) at [index], or
  /// at the end when [index] is null. [index] counts the children left
  /// after the moved nodes are taken out.
  ///
  /// Throws an [ArgumentError] when [parentValue] isn't in the tree, or is
  /// one of the moved nodes or a descendant of one.
  Oito2TreeCollection<T> move(
    Iterable<String> values,
    String? parentValue, {
    int? index,
  }) {
    final set = values.toSet();
    if (parentValue != null) {
      if (!has(parentValue)) {
        throw ArgumentError.value(parentValue, 'parentValue', 'Unknown node');
      }
      if (set.contains(parentValue) ||
          ancestorsOf(parentValue).any(set.contains)) {
        throw ArgumentError.value(
          parentValue,
          'parentValue',
          'A node cannot move into itself or its descendants',
        );
      }
    }
    final moved = [
      for (final e in flatten())
        if (set.contains(e.node.value) &&
            !ancestorsOf(e.node.value).any(set.contains))
          e.node,
    ];
    return remove(set).insert(parentValue, moved, index: index);
  }

  /// A tree with the node [value] replaced by [replacement].
  Oito2TreeCollection<T> replace(String value, Oito2TreeNode<T> replacement) =>
      _mapNode(value, (_) => replacement);

  Oito2TreeCollection<T> _mapNode(
    String value,
    Oito2TreeNode<T> Function(Oito2TreeNode<T> node) change,
  ) {
    List<Oito2TreeNode<T>> map(List<Oito2TreeNode<T>> nodes) => [
      for (final node in nodes)
        if (node.value == value)
          change(node)
        else if (node.isBranch)
          node.copyWith(children: map(node.children!))
        else
          node,
    ];
    return Oito2TreeCollection(map(roots));
  }
}
