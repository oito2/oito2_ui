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

import '../l10n/oito2_localizations.dart';
import 'widget_helpers.dart';

/// A password text field with a button that shows or hides the text and
/// a warning while Caps Lock is on.
///
/// It fills from password managers through [autofillHints]; use
/// [AutofillHints.newPassword] for a field that sets a new password.
class Oito2PasswordField extends StatefulWidget {
  /// Creates a password field.
  const Oito2PasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints = const [AutofillHints.password],
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.showCapsLockWarning = true,
  });

  /// The text controller; one is created when null.
  final TextEditingController? controller;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// The field label.
  final String? labelText;

  /// The hint shown while the field is empty.
  final String? hintText;

  /// An error shown below the field.
  final String? errorText;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// The autofill hints for password managers.
  final Iterable<String>? autofillHints;

  /// The keyboard action button.
  final TextInputAction? textInputAction;

  /// Whether the field takes the focus when shown.
  final bool autofocus;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether a warning shows below the focused field while Caps Lock is
  /// on.
  final bool showCapsLockWarning;

  @override
  State<Oito2PasswordField> createState() => _Oito2PasswordFieldState();
}

class _Oito2PasswordFieldState extends State<Oito2PasswordField> {
  FocusNode? _ownFocusNode;
  bool _visible = false;
  bool _capsLock = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_checkCapsLock);
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void didUpdateWidget(Oito2PasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_checkCapsLock);
      _focusNode.addListener(_checkCapsLock);
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _focusNode.removeListener(_checkCapsLock);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    _checkCapsLock();
    return false;
  }

  void _checkCapsLock() {
    final on =
        widget.showCapsLockWarning &&
        _focusNode.hasFocus &&
        HardwareKeyboard.instance.lockModesEnabled.contains(
          KeyboardLockMode.capsLock,
        );
    if (on != _capsLock && mounted) setState(() => _capsLock = on);
  }

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final warning = semanticColorsOf(context).warning;
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      obscureText: !_visible,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        errorText: widget.errorText,
        helper: _capsLock
            ? Semantics(
                liveRegion: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(LucideIcons.triangle_alert, size: 14, color: warning),
                    Text(strings.capsLockOn, style: TextStyle(color: warning)),
                  ],
                ),
              )
            : null,
        suffixIcon: FieldIconButton(
          icon: _visible ? LucideIcons.eye_off : LucideIcons.eye,
          tooltip: _visible ? strings.hidePassword : strings.showPassword,
          onPressed: widget.enabled
              ? () => setState(() => _visible = !_visible)
              : null,
        ),
      ),
    );
  }
}
