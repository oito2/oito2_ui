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

import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../collections/tree_collection.dart';
import '../syntax/syntax_palette.dart';
import '../theme/color_theme.dart';
import '../theme/extensions/syntax_theme.dart';
import 'tree_view.dart';

/// A key and value of a node of an [Oito2JsonTreeView].
typedef Oito2JsonEntry = ({String key, Object? value});

/// Builds the tree of decoded JSON [data]: objects and lists become
/// branches, other values leaves. Node values are JSON paths, such as
/// `$.items[0].name`.
Oito2TreeCollection<Oito2JsonEntry> oito2JsonTree(
  Object? data, {
  String rootLabel = r'$',
}) {
  String child(String parent, Object key) => key is int
      ? '$parent[$key]'
      : RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$').hasMatch('$key')
      ? '$parent.$key'
      : '$parent[${jsonEncode(key)}]';

  Oito2TreeNode<Oito2JsonEntry> build(String path, String key, Object? value) {
    final entry = (key: key, value: value);
    final label = switch (value) {
      Map() || List() => key,
      _ => '$key: ${jsonEncode(value)}',
    };
    return Oito2TreeNode(
      value: path,
      label: label,
      data: entry,
      children: switch (value) {
        Map() => [
          for (final MapEntry(:key, :value) in value.entries)
            build(child(path, '$key'), '$key', value),
        ],
        List() => [
          for (var i = 0; i < value.length; i++)
            build(child(path, i), '$i', value[i]),
        ],
        _ => null,
      },
    );
  }

  return Oito2TreeCollection([build(r'$', rootLabel, data)]);
}

/// A tree view of decoded JSON [data], with keys, strings, numbers,
/// booleans and null in the theme's syntax colors, and the size of each
/// object and list.
///
/// Branches up to [expandDepth] levels deep start open. It has the
/// keyboard and filtering of [Oito2TreeView]; [query] filters by key and
/// value.
class Oito2JsonTreeView extends StatefulWidget {
  /// Creates a JSON tree view.
  const Oito2JsonTreeView({
    super.key,
    required this.data,
    this.expandDepth = 1,
    this.rootLabel = 'root',
    this.query = '',
    this.semanticLabel,
  });

  /// The decoded JSON: maps, lists, strings, numbers, booleans and null.
  final Object? data;

  /// The depth up to which branches start open.
  final int expandDepth;

  /// The label of the top node.
  final String rootLabel;

  /// The text that filters the nodes.
  final String query;

  /// The accessibility label of the tree.
  final String? semanticLabel;

  @override
  State<Oito2JsonTreeView> createState() => _Oito2JsonTreeViewState();
}

class _Oito2JsonTreeViewState extends State<Oito2JsonTreeView> {
  late Oito2TreeCollection<Oito2JsonEntry> _tree = _build();
  late final _controller = Oito2TreeController(
    expanded: _openUpTo(widget.expandDepth),
  );

  Oito2TreeCollection<Oito2JsonEntry> _build() =>
      oito2JsonTree(widget.data, rootLabel: widget.rootLabel);

  Iterable<String> _openUpTo(int depth) => [
    for (final entry in _tree.flatten())
      if (entry.node.isBranch && entry.depth < depth) entry.node.value,
  ];

  @override
  void didUpdateWidget(Oito2JsonTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.data, widget.data) ||
        oldWidget.rootLabel != widget.rootLabel) {
      _tree = _build();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette =
        Oito2SyntaxTheme.maybeOf(context) ??
        (theme.brightness == Brightness.dark
                ? Oito2ColorTheme.dark()
                : Oito2ColorTheme.light())
            .syntax;
    return Oito2TreeView<Oito2JsonEntry>(
      collection: _tree,
      controller: _controller,
      query: widget.query,
      semanticLabel: widget.semanticLabel,
      itemBuilder: (context, node) =>
          _JsonRow(entry: node.data!, palette: palette),
    );
  }
}

class _JsonRow extends StatelessWidget {
  const _JsonRow({required this.entry, required this.palette});

  final Oito2JsonEntry entry;
  final Oito2SyntaxPalette palette;

  @override
  Widget build(BuildContext context) {
    final value = entry.value;
    final (text, color) = switch (value) {
      Map() => ('{${value.length}}', palette.comment),
      List() => ('[${value.length}]', palette.comment),
      String() => (jsonEncode(value), palette.string),
      num() => ('$value', palette.number),
      bool() => ('$value', palette.keyword),
      null => ('null', palette.constant),
      _ => ('$value', palette.foreground),
    };
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: entry.key,
            style: TextStyle(color: palette.attribute),
          ),
          TextSpan(
            text: value is Map || value is List ? ' ' : ': ',
            style: TextStyle(color: palette.foreground),
          ),
          TextSpan(
            text: text,
            style: TextStyle(color: color),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
