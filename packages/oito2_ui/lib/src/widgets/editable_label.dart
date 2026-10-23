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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'utilities.dart';
import 'widget_helpers.dart';

/// A text label that turns into a field to rename it in place.
///
/// A double click, Enter or F2 starts editing with the text selected.
/// Enter or leaving the field keeps the change, calling [onSubmitted]
/// with the trimmed text when it changed and isn't empty; Escape
/// restores the text. [onSubmitted] null makes the label read-only.
class Oito2EditableLabel extends StatefulWidget {
  /// Creates an editable label.
  const Oito2EditableLabel({
    super.key,
    required this.text,
    required this.onSubmitted,
    this.style,
    this.placeholder,
    this.focusNode,
  });

  /// The label text.
  final String text;

  /// Called with the new, trimmed text after a change; null makes the
  /// label read-only.
  final ValueChanged<String>? onSubmitted;

  /// The text style; defaults to `bodyLarge`.
  final TextStyle? style;

  /// The text shown in the placeholder color while [text] is empty.
  final String? placeholder;

  /// The focus node of the label; one is created when null.
  final FocusNode? focusNode;

  @override
  State<Oito2EditableLabel> createState() => _Oito2EditableLabelState();
}

/// Switches [Oito2EditableLabel] between the label and the editing field
/// and moves the focus between them.
class _Oito2EditableLabelState extends State<Oito2EditableLabel>
    with OwnedFocusNodeMixin {
  final _controller = TextEditingController();
  final _fieldFocus = FocusNode(debugLabel: 'Oito2EditableLabel field');
  bool _editing = false;

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  FocusNode get _labelFocus => effectiveFocusNode;

  @override
  void initState() {
    super.initState();
    _fieldFocus.addListener(_onFieldFocus);
  }

  @override
  void dispose() {
    _fieldFocus
      ..removeListener(_onFieldFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Starts editing with the whole text selected and focuses the field
  /// after it is built; does nothing when read-only or already editing.
  void _start() {
    if (widget.onSubmitted == null || _editing) return;
    _controller.value = TextEditingValue(
      text: widget.text,
      selection: TextSelection(baseOffset: 0, extentOffset: widget.text.length),
    );
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _editing) _fieldFocus.requestFocus();
    });
  }

  /// Ends editing, submitting the trimmed text when [keep] is true and it
  /// is a non-empty change, and returns the focus to the label when the
  /// field had it.
  void _finish({required bool keep}) {
    if (!_editing) return;
    final text = _controller.text.trim();
    final refocus = _fieldFocus.hasFocus;
    setState(() => _editing = false);
    if (keep && text.isNotEmpty && text != widget.text) {
      widget.onSubmitted?.call(text);
    }
    if (refocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _labelFocus.requestFocus();
      });
    }
  }

  /// Keeps the change when the field loses focus.
  void _onFieldFocus() {
    if (!_fieldFocus.hasFocus) _finish(keep: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge?.merge(widget.style);
    if (_editing) {
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              _finish(keep: false),
        },
        child: TextField(
          controller: _controller,
          focusNode: _fieldFocus,
          style: style,
          onSubmitted: (_) => _finish(keep: true),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: Oito2Spacing.xs,
              vertical: Oito2Spacing.xs,
            ),
            constraints: BoxConstraints(),
          ),
        ),
      );
    }
    final empty = widget.text.isEmpty;
    final readOnly = widget.onSubmitted == null;
    return Semantics(
      label: empty ? widget.placeholder : widget.text,
      hint: readOnly ? null : Oito2Localizations.of(context).editText,
      onTap: readOnly ? null : _start,
      excludeSemantics: true,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter): _start,
          const SingleActivator(LogicalKeyboardKey.f2): _start,
        },
        child: Oito2FocusBorder(
          borderRadius: Oito2Radius.smallAll,
          child: Focus(
            focusNode: _labelFocus,
            canRequestFocus: !readOnly,
            child: GestureDetector(
              onDoubleTap: _start,
              child: MouseRegion(
                cursor: readOnly ? MouseCursor.defer : SystemMouseCursors.text,
                child: Padding(
                  padding: const EdgeInsets.all(Oito2Spacing.xs),
                  child: Text(
                    empty ? (widget.placeholder ?? '') : widget.text,
                    style: empty
                        ? style?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        : style,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
