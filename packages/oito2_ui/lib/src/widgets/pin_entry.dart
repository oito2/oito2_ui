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
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'widget_helpers.dart';

/// A code entry drawn as [length] one-character cells, such as a PIN or
/// a one-time code.
///
/// One text field sits under the cells, so typing, deleting, pasting a
/// whole code and one-time code autofill all work as in any field; a
/// pasted code fills the cells in order. When the last cell is filled the
/// entry calls [onCompleted] and gives up the focus.
class Oito2PinEntry extends StatefulWidget {
  /// Creates a code entry.
  const Oito2PinEntry({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.numeric = true,
    this.obscure = false,
    this.hasError = false,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.semanticLabel,
  }) : assert(length > 0);

  /// The number of characters.
  final int length;

  /// Called when the code changes.
  final ValueChanged<String>? onChanged;

  /// Called when every cell is filled.
  final ValueChanged<String>? onCompleted;

  /// Whether only digits are accepted.
  final bool numeric;

  /// Whether the characters show as dots.
  final bool obscure;

  /// Whether the cells show the error border.
  final bool hasError;

  /// The text controller; one is created when null.
  final TextEditingController? controller;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// Whether the entry takes the focus when shown.
  final bool autofocus;

  /// Whether the entry accepts input.
  final bool enabled;

  /// The accessibility label; defaults to a description of the code
  /// length.
  final String? semanticLabel;

  @override
  State<Oito2PinEntry> createState() => _Oito2PinEntryState();
}

class _Oito2PinEntryState extends State<Oito2PinEntry> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
    _focusNode.addListener(_refresh);
  }

  @override
  void didUpdateWidget(Oito2PinEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onText);
      _controller.addListener(_onText);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_refresh);
      _focusNode.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _focusNode.removeListener(_refresh);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  /// Keeps the caret at the end, so the active cell is always the next
  /// empty one.
  void _onText() {
    final value = _controller.value;
    final end = value.text.length;
    if (value.selection != TextSelection.collapsed(offset: end)) {
      _controller.selection = TextSelection.collapsed(offset: end);
    }
    _refresh();
  }

  void _onChanged(String text) {
    widget.onChanged?.call(text);
    if (text.length == widget.length) {
      widget.onCompleted?.call(text);
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantic = semanticColorsOf(context);
    final height = controlHeightOf(context) + 6;
    final text = _controller.text;
    final focused = _focusNode.hasFocus;
    final active = text.length.clamp(0, widget.length - 1);
    final style = theme.textTheme.titleLarge?.copyWith(
      color: widget.enabled
          ? scheme.onSurface
          : scheme.onSurface.withValues(alpha: 0.38),
    );

    Widget cell(int index) {
      final char = index < text.length ? text[index] : '';
      final isActive = focused && index == active;
      final color = widget.hasError
          ? semantic.errorText
          : isActive
          ? semantic.primaryText
          : scheme.outline;
      return Container(
        width: height - 4,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: Oito2Radius.mediumAll,
          border: Border.all(
            color: widget.enabled ? color : color.withValues(alpha: 0.38),
            width: isActive || widget.hasError
                ? Oito2Sizes.focusBorderWidth
                : 1,
          ),
        ),
        child: Text(
          char.isEmpty ? '' : (widget.obscure ? '•' : char),
          style: style,
        ),
      );
    }

    final cells = ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Oito2Spacing.sm,
        children: [for (var i = 0; i < widget.length; i++) cell(i)],
      ),
    );
    const clear = Color(0x00000000);
    final field = Semantics(
      label:
          widget.semanticLabel ??
          Oito2Localizations.of(context).codeEntry(widget.length),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        obscureText: widget.obscure,
        showCursor: false,
        enableInteractiveSelection: false,
        enableSuggestions: false,
        autocorrect: false,
        autofillHints: const [AutofillHints.oneTimeCode],
        keyboardType: widget.numeric
            ? TextInputType.number
            : TextInputType.visiblePassword,
        inputFormatters: [
          if (widget.numeric)
            FilteringTextInputFormatter.digitsOnly
          else
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          LengthLimitingTextInputFormatter(widget.length),
        ],
        onChanged: _onChanged,
        style: const TextStyle(color: clear, fontSize: 1),
        cursorColor: clear,
        decoration: bareInputDecoration(),
      ),
    );
    return Stack(
      children: [
        cells,
        Positioned.fill(child: field),
      ],
    );
  }
}
