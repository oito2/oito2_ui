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
import 'info.dart';
import 'password_strength.dart';
import 'touch_target.dart';
import 'widget_helpers.dart';

/// A password text field with a button that shows or hides the text and
/// a warning while Caps Lock is on.
///
/// It fills from password managers through [autofillHints]; use
/// [AutofillHints.newPassword] for a field that sets a new password.
///
/// With [showStrength], a meter below the field rates the password while
/// it isn't empty: four segments tinted from the danger to the success
/// tone, the level name and the first suggestion that would make it
/// stronger. [Oito2PasswordStrength.estimate] rates it on the device by
/// default; [strengthEstimator] replaces it. Assistive technologies hear
/// the level when it changes, not on every key.
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
    this.showStrength = false,
    this.strengthEstimator,
    this.strengthUserInputs = const [],
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

  /// Whether a strength meter shows below the field while it isn't
  /// empty.
  final bool showStrength;

  /// Rates the password for the strength meter; when null,
  /// [Oito2PasswordStrength.estimate] rates it with
  /// [strengthUserInputs].
  final Oito2PasswordStrength Function(String password)? strengthEstimator;

  /// Words the default estimator treats as easy to guess, such as the
  /// user's name and email.
  final Iterable<String> strengthUserInputs;

  @override
  State<Oito2PasswordField> createState() => _Oito2PasswordFieldState();
}

class _Oito2PasswordFieldState extends State<Oito2PasswordField>
    with
        OwnedFocusNodeMixin,
        OwnedControllerMixin<Oito2PasswordField, TextEditingController> {
  bool _visible = false;
  bool _capsLock = false;

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  FocusNode get _focusNode => effectiveFocusNode;

  @override
  void onEffectiveFocusChange() => _checkCapsLock();

  @override
  TextEditingController? get widgetController => widget.controller;

  @override
  TextEditingController createOwnedController() => TextEditingController();

  @override
  void onControllerChange() {
    if (widget.showStrength && effectiveController.text != _ratedText) {
      setState(() {});
    }
  }

  @override
  void didChangeController(TextEditingController previous) => setState(() {});

  /// The text [_strength] was computed for.
  String? _ratedText;

  /// The rating of [_ratedText].
  Oito2PasswordStrength _strength = const Oito2PasswordStrength(0);

  /// Returns the rating of the current text, computed again only when the
  /// text changed.
  Oito2PasswordStrength _rate() {
    final text = effectiveController.text;
    if (text != _ratedText) {
      _ratedText = text;
      _strength =
          widget.strengthEstimator?.call(text) ??
          Oito2PasswordStrength.estimate(
            text,
            userInputs: widget.strengthUserInputs,
          );
    }
    return _strength;
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  /// Rechecks Caps Lock on every key event without handling the event.
  bool _onKey(KeyEvent event) {
    _checkCapsLock();
    return false;
  }

  /// Shows the warning while the field has the focus and Caps Lock is on.
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
    final capsWarning = _capsLock
        ? Semantics(
            liveRegion: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Icon(
                  LucideIcons.triangle_exclamation_point,
                  size: 14,
                  color: warning,
                ),
                Text(strings.capsLockOn, style: TextStyle(color: warning)),
              ],
            ),
          )
        : null;
    final errorText = widget.errorText;
    // The decorator hides the helper while an error shows, so the Caps Lock
    // warning joins the error in that case.
    final combinedError = capsWarning != null && errorText != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                errorText,
                style: Theme.of(context).inputDecorationTheme.errorStyle,
              ),
              capsWarning,
            ],
          )
        : null;
    final field = Oito2TouchTarget(
      child: TextField(
        controller: effectiveController,
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
          errorText: combinedError == null ? errorText : null,
          error: combinedError,
          helper: combinedError == null ? capsWarning : null,
          suffixIcon: FieldIconButton(
            icon: _visible ? LucideIcons.eye_off : LucideIcons.eye,
            tooltip: _visible ? strings.hidePassword : strings.showPassword,
            onPressed: widget.enabled
                ? () => setState(() => _visible = !_visible)
                : null,
          ),
        ),
      ),
    );
    if (!widget.showStrength) return field;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        field,
        if (effectiveController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _StrengthMeter(strength: _rate()),
          ),
      ],
    );
  }
}

/// The four-segment meter, level name and first suggestion of a
/// password [strength].
class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.strength});

  final Oito2PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = Oito2Localizations.of(context);
    final type = switch (strength.level) {
      0 || 1 => Oito2InfoType.danger,
      2 => Oito2InfoType.warning,
      _ => Oito2InfoType.success,
    };
    final tone = type.colorIn(semanticColorsOf(context));
    final (_, text) = infoColorsOf(context, type, 0);
    final filled = strength.level < 1 ? 1 : strength.level;
    final level = strength.labelIn(strings);
    final hint = strength.hints.isEmpty
        ? null
        : strength.hints.first.labelIn(strings);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Row(
          spacing: 4,
          children: [
            for (var i = 0; i < 4; i++)
              Expanded(
                child: AnimatedContainer(
                  duration: motionDuration(
                    context,
                    const Duration(milliseconds: 150),
                  ),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < filled
                        ? tone
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            // Only the level is a live region, so the announcement
            // repeats when the level changes, not on every key.
            Semantics(
              liveRegion: true,
              label: '${strings.passwordStrength}: $level',
              excludeSemantics: true,
              child: Text(
                level,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hint != null)
              Expanded(
                child: Text(
                  hint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
