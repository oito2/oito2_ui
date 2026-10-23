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
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'options_view.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// The look of the tags of an [Oito2TagsField].
enum Oito2TagsFieldStyle {
  /// Tags filled with the secondary container color.
  filled,

  /// Tags on a neutral fill with medium-weight text; the focused tag takes
  /// a faint accent fill and accent text.
  subtle,
}

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
/// below the input as it is typed. With [clearable], a button at the end
/// removes every tag at once.
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
    this.style = Oito2TagsFieldStyle.filled,
    this.clearable = false,
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

  /// The look of the tags.
  final Oito2TagsFieldStyle style;

  /// Whether a button at the end of the field removes every tag while the
  /// field is editable and has tags.
  final bool clearable;

  @override
  State<Oito2TagsField> createState() => _Oito2TagsFieldState();
}

class _Oito2TagsFieldState extends State<Oito2TagsField>
    with OwnedFocusNodeMixin {
  final _controller = TextEditingController();
  final List<FocusNode> _tagNodes = [];
  bool _hasFocus = false;

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  FocusNode get _input => effectiveFocusNode;

  bool get _enabled => widget.onChanged != null;

  bool get _full =>
      widget.maxTags != null && widget.tags.length >= widget.maxTags!;

  @override
  void dispose() {
    for (final node in _tagNodes) {
      node.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  @override
  void didUpdateWidget(Oito2TagsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
  }

  /// Keeps one focus node per tag. Removed nodes are disposed after the
  /// frame, once the chips that used them are gone.
  void _syncNodes() {
    while (_tagNodes.length < widget.tags.length) {
      _tagNodes.add(FocusNode(debugLabel: 'Oito2TagsField tag'));
    }
    final removed = <FocusNode>[];
    while (_tagNodes.length > widget.tags.length) {
      removed.add(_tagNodes.removeLast());
    }
    if (removed.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final node in removed) {
        node.dispose();
      }
    });
  }

  bool _accepts(String tag, List<String> tags) =>
      tag.isNotEmpty &&
      (widget.allowDuplicates || !tags.contains(tag)) &&
      (widget.maxTags == null || tags.length < widget.maxTags!) &&
      (widget.validator?.call(tag) ?? true);

  /// Adds the accepted tags of [raw] and returns the refused texts, which
  /// stay in the field.
  List<String> _add(Iterable<String> raw) {
    if (!_enabled) return [...raw];
    final tags = [...widget.tags];
    final refused = <String>[];
    for (final text in raw) {
      final tag = text.trim();
      if (_accepts(tag, tags)) {
        tags.add(tag);
      } else if (tag.isNotEmpty) {
        refused.add(tag);
      }
    }
    if (tags.length > widget.tags.length) widget.onChanged!(tags);
    return refused;
  }

  /// Puts [text] in the field with the caret at its end.
  void _setText(String text) => _controller.value = TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );

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

  void _clear() {
    if (!_enabled) return;
    _controller.clear();
    widget.onChanged!(const []);
    _input.requestFocus();
  }

  void _onTextChanged(String text) {
    final pattern = RegExp(widget.delimiters.map(RegExp.escape).join('|'));
    if (widget.delimiters.isEmpty || !text.contains(pattern)) return;
    final parts = text.split(pattern);
    final refused = _add(parts.take(parts.length - 1));
    // A single tag refused as its delimiter is typed stays to be fixed, as
    // with Enter; refused repeats of a pasted list are dropped.
    _setText(
      parts.length == 2 && refused.isNotEmpty
          ? refused.single + parts.last
          : parts.last,
    );
  }

  void _submit() {
    if (_add([_controller.text]).isEmpty) _controller.clear();
    _input.requestFocus();
  }

  KeyEventResult _onInputKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final selection = _controller.selection;
    final atStart = selection.isCollapsed && selection.baseOffset == 0;
    final back = readingArrowsOf(context).back;
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
    final key = event.logicalKey;
    final (:back, :forward) = readingArrowsOf(context);
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
    return suggestions.suggestions(text.trim(), exclude: widget.tags.toSet());
  }

  Widget _tag(int index) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tag = widget.tags[index];
    final strings = Oito2Localizations.of(context);
    final node = _tagNodes[index];
    final (fill, foreground, weight) = switch (widget.style) {
      Oito2TagsFieldStyle.filled => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        null,
      ),
      Oito2TagsFieldStyle.subtle when node.hasFocus => (
        semanticColorsOf(context).primaryText.withValues(alpha: 0.12),
        semanticColorsOf(context).primaryText,
        FontWeight.w500,
      ),
      Oito2TagsFieldStyle.subtle => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
        FontWeight.w500,
      ),
    };
    return Oito2FocusBorder(
      borderRadius: Oito2Radius.smallAll,
      child: Focus(
        focusNode: node,
        onFocusChange: (_) => setState(() {}),
        onKeyEvent: (_, event) => _onTagKey(index, event),
        child: Semantics(
          label: tag,
          hint: _enabled ? strings.removeTagHint : null,
          child: Container(
            padding: EdgeInsetsDirectional.only(
              start: Oito2Spacing.sm,
              end: _enabled ? Oito2Spacing.xxs : Oito2Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: Oito2Radius.smallAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Text(
                    tag,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: foreground,
                      fontWeight: weight,
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
                            color: foreground,
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
            suffixIcon: widget.clearable && _enabled && widget.tags.isNotEmpty
                ? IconButton(
                    onPressed: _clear,
                    tooltip: Oito2Localizations.of(context).clear,
                    icon: const Icon(LucideIcons.x),
                  )
                : null,
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
