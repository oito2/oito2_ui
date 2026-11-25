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
import 'form.dart';
import 'touch_target.dart';
import 'widget_helpers.dart';

/// A code entry drawn as [length] one-character cells, such as a PIN or
/// a one-time code.
///
/// One text field sits under the cells, so typing, deleting, pasting a
/// whole code and one-time code autofill all work as in any field; a
/// pasted code fills the cells in order. When the last cell is filled the
/// entry calls [onCompleted] and gives up the focus.
///
/// The error of [validator] or [required] shows below the cells after the
/// entry loses focus, or at once after its [Oito2Form] found errors.
class Oito2PinEntry extends StatefulWidget {
  /// Creates a code entry.
  ///
  /// Throws an [AssertionError] in debug mode when [length] is not greater
  /// than zero.
  const Oito2PinEntry({
    super.key,
    this.participatesInForm = true,
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
    this.validator,
    this.required = false,
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

  /// Checks the code and returns an error message, or null to accept it.
  final String? Function(String code)? validator;

  /// Whether an empty entry shows the localized "This field is required"
  /// error.
  final bool required;

  /// Whether the field registers with the closest [Oito2Form], taking
  /// part in its validation, error summary and dirty state; true by
  /// default. When false, the field shows its own errors as outside a
  /// form.
  final bool participatesInForm;

  @override
  State<Oito2PinEntry> createState() => _Oito2PinEntryState();
}

class _Oito2PinEntryState extends State<Oito2PinEntry>
    with
        OwnedFocusNodeMixin,
        OwnedControllerMixin<Oito2PinEntry, TextEditingController>,
        Oito2FormFieldMixin {
  /// Whether the validation error shows, once the entry lost focus.
  bool _showError = false;

  /// The code while the entry has no unsaved changes.
  late String _cleanText;

  /// The code the form was last told about.
  late String _notifiedText;

  @override
  void initState() {
    super.initState();
    _cleanText = _notifiedText = _controller.text;
  }

  @override
  bool get participatesInForm => widget.participatesInForm;

  @override
  String get formFieldLabel =>
      widget.semanticLabel ??
      Oito2Localizations.of(context).codeEntry(widget.length);

  @override
  FocusNode get formFieldFocusNode => _focusNode;

  @override
  String? get formFieldError {
    final text = _controller.text;
    if (widget.required && text.isEmpty) {
      return Oito2Localizations.of(context).fieldRequired;
    }
    return widget.validator?.call(text);
  }

  @override
  bool get isFormFieldDirty => _controller.text != _cleanText;

  @override
  void showFormFieldError() {
    if (mounted) setState(() => _showError = true);
  }

  @override
  void markFormFieldClean() => _cleanText = _controller.text;

  @override
  void resetFormField() {
    setState(() => _showError = false);
    if (_controller.text == _cleanText) return;
    _controller.text = _cleanText;
    widget.onChanged?.call(_cleanText);
  }

  @override
  TextEditingController? get widgetController => widget.controller;

  @override
  TextEditingController createOwnedController() => TextEditingController();

  @override
  void onControllerChange() => _onText();

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  @override
  void onEffectiveFocusChange() {
    if (!_focusNode.hasFocus) _showError = true;
    _refresh();
  }

  TextEditingController get _controller => effectiveController;

  FocusNode get _focusNode => effectiveFocusNode;

  /// Rebuilds the cells when the state is still mounted.
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
    if (value.text != _notifiedText) {
      _notifiedText = value.text;
      notifyFormFieldChanged();
    }
  }

  /// Reports [text], and when every cell is filled reports the completed
  /// code and releases the focus.
  void _onChanged(String text) {
    widget.onChanged?.call(text);
    // Cells hold user-perceived characters, so an emoji fills one cell.
    if (text.characters.length == widget.length) {
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
    final chars = _controller.text.characters.toList();
    final focused = _focusNode.hasFocus;
    final error = _showError || formShowsErrors ? formFieldError : null;
    final hasError = widget.hasError || error != null;
    final active = chars.length.clamp(0, widget.length - 1);
    final style = theme.textTheme.titleLarge?.copyWith(
      color: widget.enabled
          ? scheme.onSurface
          : scheme.onSurface.withValues(alpha: 0.38),
    );

    Widget cell(int index) {
      final char = index < chars.length ? chars[index] : '';
      final isActive = focused && index == active;
      final color = hasError
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
            width: isActive || hasError ? Oito2Sizes.focusBorderWidth : 1,
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
    final entry = Oito2TouchTarget(
      child: Stack(
        children: [
          cells,
          Positioned.fill(child: field),
        ],
      ),
    );
    if (error == null) return entry;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        entry,
        Padding(
          padding: const EdgeInsets.only(top: Oito2Spacing.xs),
          child: Semantics(
            liveRegion: true,
            child: Text(
              error,
              style:
                  theme.inputDecorationTheme.errorStyle ??
                  theme.textTheme.bodySmall?.copyWith(
                    color: semantic.errorText,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
