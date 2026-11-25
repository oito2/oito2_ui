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
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'form.dart';
import 'touch_target.dart';
import 'widget_helpers.dart';

/// A search text field with a search icon and a clear button that appears
/// while it has text.
///
/// Pressing Escape clears the text; pressing it again on an empty field
/// calls [onEscape]. The hint and the clear button tooltip come from
/// `MaterialLocalizations`, so they follow the app language.
///
/// The error of [validator] or [required] shows under the field after it
/// loses focus, or at once after its [Oito2Form] found errors.
class Oito2SearchField extends StatefulWidget {
  /// Creates a search field.
  const Oito2SearchField({
    super.key,
    this.participatesInForm = false,
    this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onEscape,
    this.autofocus = false,
    this.prefixIcon,
    this.validator,
    this.required = false,
  });

  /// Controls the text; one is created when null.
  final TextEditingController? controller;

  /// The focus node of the text field.
  final FocusNode? focusNode;

  /// The hint; defaults to the localized "Search".
  final String? hintText;

  /// Called whenever the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text.
  final ValueChanged<String>? onSubmitted;

  /// Called after the clear button or Escape empties the field.
  final VoidCallback? onClear;

  /// Called when Escape is pressed on an empty field.
  final VoidCallback? onEscape;

  /// Whether the field takes focus when shown.
  final bool autofocus;

  /// The widget before the text; defaults to a search icon.
  final Widget? prefixIcon;

  /// Checks the text and returns an error message, or null to accept it.
  final String? Function(String text)? validator;

  /// Whether an empty field shows the localized "This field is required"
  /// error.
  final bool required;

  /// Whether the field registers with the closest [Oito2Form], taking
  /// part in its validation, error summary and dirty state; false by
  /// default, since a search usually filters the screen rather than
  /// holding form data. When false, the field shows its own errors as
  /// outside a form.
  final bool participatesInForm;

  @override
  State<Oito2SearchField> createState() => _Oito2SearchFieldState();
}

class _Oito2SearchFieldState extends State<Oito2SearchField>
    with
        OwnedFocusNodeMixin,
        OwnedControllerMixin<Oito2SearchField, TextEditingController>,
        Oito2FormFieldMixin {
  /// Whether the validation error shows, once the field lost focus.
  bool _showError = false;

  /// The text while the field has no unsaved changes.
  late String _cleanText;

  /// The text the form was last told about.
  late String _notifiedText;

  @override
  void initState() {
    super.initState();
    _cleanText = _notifiedText = _controller.text;
  }

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  @override
  void onEffectiveFocusChange() {
    if (!effectiveFocusNode.hasFocus && !_showError && mounted) {
      setState(() => _showError = true);
    }
  }

  @override
  bool get participatesInForm => widget.participatesInForm;

  @override
  String? get formFieldLabel =>
      widget.hintText ?? MaterialLocalizations.of(context).searchFieldLabel;

  @override
  FocusNode get formFieldFocusNode => effectiveFocusNode;

  @override
  String? get formFieldError {
    final text = _controller.text;
    if (widget.required && text.trim().isEmpty) {
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

  TextEditingController get _controller => effectiveController;

  /// Rebuilds for the clear button and tells the form when the text
  /// changed.
  void _onText() {
    setState(() {});
    final text = _controller.text;
    if (text != _notifiedText) {
      _notifiedText = text;
      notifyFormFieldChanged();
    }
  }

  /// Empties the field and reports the empty text and the clearing.
  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  /// Handles Escape: clears a field with text, or calls `onEscape` on an
  /// empty one.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      if (_controller.text.isNotEmpty) {
        _clear();
      } else {
        widget.onEscape?.call();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final hasText = _controller.text.isNotEmpty;
    return Focus(
      onKeyEvent: _onKey,
      canRequestFocus: false,
      skipTraversal: true,
      child: Oito2TouchTarget(
        child: TextField(
          controller: _controller,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.hintText ?? localizations.searchFieldLabel,
            errorText: _showError || formShowsErrors ? formFieldError : null,
            prefixIcon:
                widget.prefixIcon ??
                const Icon(LucideIcons.search, size: Oito2Sizes.iconSize),
            suffixIcon: hasText
                ? FieldIconButton(
                    tooltip: localizations.clearButtonTooltip,
                    onPressed: _clear,
                    icon: LucideIcons.x,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// A title bar element that switches between a [title] and a search
/// field, with a toggle button, as in GNOME apps.
///
/// The element keeps the same size in both states: a box [fieldWidth]
/// wide and as tall as a field, with the toggle button at its start.
/// While the search is closed, the [title] follows the button; while it
/// is open, the search field fills the box and the button serves as its
/// search icon. Only the content fades, so the surrounding layout never
/// moves.
///
/// Escape on an empty field closes the search and returns focus to the
/// toggle button. The toggle button reports its pressed state to
/// assistive technologies.
class Oito2SearchTitleField extends StatefulWidget {
  /// Creates a search title field.
  const Oito2SearchTitleField({
    super.key,
    required this.title,
    required this.searchActive,
    required this.onSearchActiveChanged,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.hintText,
    this.fieldWidth = 260,
    this.toggleLabel,
  });

  /// Shown while the search is closed.
  final Widget title;

  /// Whether the search field is shown.
  final bool searchActive;

  /// Called to open or close the search.
  final ValueChanged<bool> onSearchActiveChanged;

  /// Called whenever the search text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the search text.
  final ValueChanged<String>? onSubmitted;

  /// Controls the search text.
  final TextEditingController? controller;

  /// The search hint; defaults to the localized "Search".
  final String? hintText;

  /// The width of the element, in both states.
  final double fieldWidth;

  /// The tooltip of the toggle button; defaults to the localized
  /// "Search".
  final String? toggleLabel;

  @override
  State<Oito2SearchTitleField> createState() => _Oito2SearchTitleFieldState();
}

class _Oito2SearchTitleFieldState extends State<Oito2SearchTitleField> {
  final _toggleFocusNode = FocusNode(debugLabel: 'Oito2SearchTitleField');

  @override
  void dispose() {
    _toggleFocusNode.dispose();
    super.dispose();
  }

  /// Asks to close the search and moves the focus to the toggle button.
  void _close() {
    widget.onSearchActiveChanged(false);
    _toggleFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final label =
        widget.toggleLabel ??
        MaterialLocalizations.of(context).searchFieldLabel;
    final buttonSize =
        Theme.of(context).iconButtonTheme.style?.minimumSize
            ?.resolve({})
            ?.height ??
        Oito2Sizes.buttonHeight;
    return SizedBox(
      width: widget.fieldWidth,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            layoutBuilder: (current, previous) => Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [...previous, ?current],
            ),
            child: widget.searchActive
                ? Oito2SearchField(
                    key: const ValueKey('search'),
                    controller: widget.controller,
                    hintText: widget.hintText,
                    autofocus: true,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    onEscape: _close,
                    prefixIcon: SizedBox(width: buttonSize),
                  )
                : Padding(
                    key: const ValueKey('title'),
                    padding: EdgeInsetsDirectional.only(
                      start: buttonSize + Oito2Spacing.sm,
                    ),
                    child: widget.title,
                  ),
          ),
          IconButton(
            focusNode: _toggleFocusNode,
            tooltip: label,
            isSelected: widget.searchActive,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => widget.searchActive
                ? _close()
                : widget.onSearchActiveChanged(true),
            icon: const Icon(LucideIcons.search),
          ),
        ],
      ),
    );
  }
}
