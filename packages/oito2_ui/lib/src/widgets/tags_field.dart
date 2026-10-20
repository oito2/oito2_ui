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

import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/list_collection.dart';
import '../collections/text_folding.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'options_view.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// A field of tags shown as chips, with a text input after them.
///
/// Enter or a [delimiters] character adds the typed text as a tag; a
/// pasted list is split on the delimiters. A tag is refused when it is
/// empty, repeated (unless [allowDuplicates]), past [maxTags] or rejected
/// by [validator].
///
/// Backspace or the start arrow in the empty input moves to the last tag;
/// the arrow keys move between tags, and Backspace or Delete removes the
/// focused one. With [suggestions], matching items not yet added show
/// below the input as it is typed.
class Oito2TagsField extends StatefulWidget {
  /// Creates a tags field.
  const Oito2TagsField({
    super.key,
    required this.tags,
    required this.onChanged,
    this.delimiters = const [','],
    this.maxTags,
    this.validator,
    this.allowDuplicates = false,
    this.labelText,
    this.hintText,
    this.suggestions,
    this.focusNode,
  });

  /// The tags, in order.
  final List<String> tags;

  /// Called with the new tag list; the field is read-only when null.
  final ValueChanged<List<String>>? onChanged;

  /// The characters that end a tag while typing or pasting.
  final List<String> delimiters;

  /// The largest number of tags.
  final int? maxTags;

  /// Whether a tag is accepted.
  final bool Function(String tag)? validator;

  /// Whether the same tag can be added twice.
  final bool allowDuplicates;

  /// The field label.
  final String? labelText;

  /// The hint shown in the empty input.
  final String? hintText;

  /// The tags offered while typing.
  final Oito2ListCollection<String>? suggestions;

  /// The focus node of the text input; one is created when null.
  final FocusNode? focusNode;

  @override
  State<Oito2TagsField> createState() => _Oito2TagsFieldState();
}

class _Oito2TagsFieldState extends State<Oito2TagsField> {
  final _controller = TextEditingController();
  final List<FocusNode> _tagNodes = [];
  FocusNode? _ownFocusNode;
  bool _hasFocus = false;

  FocusNode get _input => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  bool get _enabled => widget.onChanged != null;

  bool get _full =>
      widget.maxTags != null && widget.tags.length >= widget.maxTags!;

  @override
  void dispose() {
    for (final node in _tagNodes) {
      node.dispose();
    }
    _ownFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _syncNodes() {
    while (_tagNodes.length < widget.tags.length) {
      _tagNodes.add(FocusNode(debugLabel: 'Oito2TagsField tag'));
    }
    while (_tagNodes.length > widget.tags.length) {
      _tagNodes.removeLast().dispose();
    }
  }

  bool _accepts(String tag, List<String> tags) =>
      tag.isNotEmpty &&
      (widget.allowDuplicates || !tags.contains(tag)) &&
      (widget.maxTags == null || tags.length < widget.maxTags!) &&
      (widget.validator?.call(tag) ?? true);

  /// Adds the accepted tags of [raw] and reports whether any was added.
  bool _add(Iterable<String> raw) {
    if (!_enabled) return false;
    final tags = [...widget.tags];
    for (final text in raw) {
      final tag = text.trim();
      if (_accepts(tag, tags)) tags.add(tag);
    }
    if (tags.length == widget.tags.length) return false;
    widget.onChanged!(tags);
    return true;
  }

  void _remove(int index) {
    if (!_enabled) return;
    widget.onChanged!([...widget.tags]..removeAt(index));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (index > 0 && index - 1 < _tagNodes.length) {
        _tagNodes[index - 1].requestFocus();
      } else {
        _input.requestFocus();
      }
    });
  }

  void _onTextChanged(String text) {
    final pattern = RegExp(widget.delimiters.map(RegExp.escape).join('|'));
    if (widget.delimiters.isEmpty || !text.contains(pattern)) return;
    final parts = text.split(pattern);
    _add(parts.take(parts.length - 1));
    _controller.text = parts.last;
  }

  void _submit() {
    if (_add([_controller.text])) _controller.clear();
    _input.requestFocus();
  }

  KeyEventResult _onInputKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final selection = _controller.selection;
    final atStart = selection.isCollapsed && selection.baseOffset == 0;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final back = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    final key = event.logicalKey;
    if (_tagNodes.isNotEmpty &&
        atStart &&
        (key == back ||
            (key == LogicalKeyboardKey.backspace &&
                _controller.text.isEmpty))) {
      _tagNodes.last.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onTagKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    final back = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    final forward = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      _remove(index);
      return KeyEventResult.handled;
    }
    if (key == back) {
      if (index > 0) _tagNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    if (key == forward) {
      index + 1 < _tagNodes.length
          ? _tagNodes[index + 1].requestFocus()
          : _input.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  List<String> _options(String text) {
    final suggestions = widget.suggestions;
    if (suggestions == null || text.trim().isEmpty) return const [];
    final needle = foldText(text.trim());
    return [
      for (final item in suggestions.items)
        if (!suggestions.isDisabled(item) &&
            !widget.tags.contains(suggestions.labelOf(item)) &&
            foldText(suggestions.labelOf(item)).contains(needle))
          item,
    ];
  }

  Widget _tag(int index) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tag = widget.tags[index];
    final strings = Oito2Localizations.of(context);
    return Oito2FocusBorder(
      borderRadius: Oito2Radius.smallAll,
      child: Focus(
        focusNode: _tagNodes[index],
        onKeyEvent: (_, event) => _onTagKey(index, event),
        child: Semantics(
          label: tag,
          child: Container(
            padding: EdgeInsetsDirectional.only(
              start: Oito2Spacing.sm,
              end: _enabled ? Oito2Spacing.xxs : Oito2Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: Oito2Radius.smallAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Text(
                    tag,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
                if (_enabled)
                  Semantics(
                    button: true,
                    label: strings.removeItem(tag),
                    onTap: () => _remove(index),
                    excludeSemantics: true,
                    child: Tooltip(
                      message: strings.removeItem(tag),
                      excludeFromSemantics: true,
                      child: InkResponse(
                        onTap: () => _remove(index),
                        canRequestFocus: false,
                        radius: 12,
                        child: Padding(
                          padding: const EdgeInsets.all(Oito2Spacing.xs),
                          child: Icon(
                            LucideIcons.x,
                            size: 14,
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback? onFieldSubmitted,
  ) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onInputKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 80),
        child: IntrinsicWidth(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: !_enabled || _full,
            onChanged: _onTextChanged,
            onSubmitted: (_) {
              onFieldSubmitted?.call();
              if (_controller.text.isNotEmpty) _submit();
            },
            decoration: bareInputDecoration(
              hintText: widget.tags.isEmpty ? widget.hintText : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    final suggestions = widget.suggestions;
    Widget input;
    if (suggestions == null) {
      input = _buildInput(context, _controller, _input, null);
    } else {
      input = RawAutocomplete<String>(
        textEditingController: _controller,
        focusNode: _input,
        displayStringForOption: suggestions.labelOf,
        optionsBuilder: (value) => _options(value.text),
        onSelected: (option) {
          _add([suggestions.labelOf(option)]);
          _controller.clear();
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) =>
            _buildInput(context, controller, focusNode, onFieldSubmitted),
        optionsViewBuilder: (context, onSelected, options) =>
            AutocompleteOptionsView<String>(
              options: options.toList(),
              collection: suggestions,
              query: _controller.text,
              onSelected: onSelected,
              maxHeight: 240,
              width: 280,
            ),
      );
    }
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) => setState(() => _hasFocus = focused),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _input.requestFocus,
        child: InputDecorator(
          isFocused: _hasFocus,
          isEmpty: widget.tags.isEmpty && _controller.text.isEmpty,
          decoration: InputDecoration(
            labelText: widget.labelText,
            enabled: _enabled,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Oito2Spacing.sm,
              vertical: Oito2Spacing.xs + 1,
            ),
          ),
          child: Wrap(
            spacing: Oito2Spacing.xs,
            runSpacing: Oito2Spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < widget.tags.length; i++) _tag(i),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 24),
                child: Align(
                  widthFactor: 1,
                  heightFactor: 1,
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Oito2Spacing.xs,
                    ),
                    child: input,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
