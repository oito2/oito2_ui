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

import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import 'form.dart';
import 'widget_helpers.dart';

/// The form lifecycle of a field whose value is the text of a
/// [TextEditingController].
///
/// The mixin keeps the clean text (the text at start, at the last
/// [markFormFieldClean], or of a controller that replaced the previous
/// one), answers [isFormFieldDirty] against it, puts it back on
/// [resetFormField] and tells the form about text changes through
/// [notifyIfTextChanged]. [formFieldError] returns the localized
/// "This field is required" error for an empty required field and the
/// [fieldValidator] error otherwise.
mixin TextFormFieldStateMixin<W extends StatefulWidget>
    on
        State<W>,
        OwnedControllerMixin<W, TextEditingController>,
        Oito2FormFieldMixin<W> {
  /// Whether the validation error shows under the field, set once the
  /// field loses focus or the form asks for it.
  bool showsValidationError = false;

  /// The text while the field has no unsaved changes.
  late String _cleanText;

  /// The text the form was last told about.
  late String _notifiedText;

  /// Whether an empty field is invalid.
  bool get fieldRequired;

  /// Whether a text of only whitespace counts as empty for
  /// [fieldRequired].
  bool get requiredTrimsText;

  /// Checks the text and returns an error message, or null to accept it.
  String? Function(String text)? get fieldValidator;

  /// Called with the clean text when [resetFormField] changes the text.
  ValueChanged<String>? get onTextReset;

  @override
  void initState() {
    super.initState();
    _cleanText = _notifiedText = effectiveController.text;
  }

  @override
  String? get formFieldError {
    final text = effectiveController.text;
    final empty = requiredTrimsText ? text.trim().isEmpty : text.isEmpty;
    if (fieldRequired && empty) {
      return Oito2Localizations.of(context).fieldRequired;
    }
    return fieldValidator?.call(text);
  }

  @override
  bool get isFormFieldDirty => effectiveController.text != _cleanText;

  @override
  void showFormFieldError() {
    if (mounted) setState(() => showsValidationError = true);
  }

  @override
  void markFormFieldClean() => _cleanText = effectiveController.text;

  @override
  void resetFormField() {
    setState(() => showsValidationError = false);
    if (effectiveController.text == _cleanText) return;
    effectiveController.text = _cleanText;
    onTextReset?.call(_cleanText);
  }

  /// Takes the text of the new controller as the clean text and tells the
  /// form that the value may have changed.
  @override
  void didChangeController(TextEditingController previous) {
    super.didChangeController(previous);
    _cleanText = _notifiedText = effectiveController.text;
    notifyFormFieldChanged();
  }

  /// Tells the form when the text differs from the text it was last told
  /// about.
  void notifyIfTextChanged() {
    final text = effectiveController.text;
    if (text == _notifiedText) return;
    _notifiedText = text;
    notifyFormFieldChanged();
  }
}
