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
import '../tokens/geometry.dart';
import '../widgets/icon_buttons.dart';
import '../widgets/utilities.dart';
import 'shortcut.dart';

/// Shows a keyboard shortcut as key caps, in the notation of the
/// platform: `⇧⌘K` on macOS and iOS, `Ctrl` `Shift` `K` elsewhere.
///
/// Assistive technologies read the shortcut as text, such as
/// "Ctrl+Shift+K".
class Oito2ShortcutLabel extends StatelessWidget {
  /// Creates a shortcut label.
  const Oito2ShortcutLabel(this.shortcut, {super.key, this.platform});

  /// The shortcut.
  final Oito2Shortcut shortcut;

  /// The notation; defaults to the theme platform.
  final TargetPlatform? platform;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = platform ?? theme.platform;
    final apple =
        target == TargetPlatform.macOS || target == TargetPlatform.iOS;
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    Widget cap(String text) => Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(
        horizontal: Oito2Spacing.xs,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: Oito2Radius.smallAll,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
    return Semantics(
      label: shortcut.label(target),
      excludeSemantics: true,
      child: Wrap(
        spacing: Oito2Spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final chord in shortcut.chords)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.xxs,
              children: apple
                  ? [cap(chord.label(target))]
                  : [for (final part in chord.parts(target)) cap(part)],
            ),
        ],
      ),
    );
  }
}

/// A field that records a single-chord keyboard shortcut, as in keyboard
/// settings.
///
/// Clicking it, or pressing Enter or Space while it has focus, starts
/// recording; the next key with its modifiers becomes the shortcut. Escape
/// cancels, and Backspace or Delete without modifiers clears the shortcut.
/// A Command (Apple platforms) or Control (elsewhere) chord is stored with
/// the platform-neutral primary modifier, so it reads naturally on every
/// platform.
class Oito2ShortcutRecorder extends StatefulWidget {
  /// Creates a shortcut recorder.
  const Oito2ShortcutRecorder({
    super.key,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  /// The recorded shortcut, or null.
  final Oito2Shortcut? value;

  /// Called with the new shortcut, or null when it is cleared; null
  /// disables the recorder.
  final ValueChanged<Oito2Shortcut?>? onChanged;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// Whether the recorder takes focus when first shown.
  final bool autofocus;

  @override
  State<Oito2ShortcutRecorder> createState() => _Oito2ShortcutRecorderState();
}

class _Oito2ShortcutRecorderState extends State<Oito2ShortcutRecorder> {
  FocusNode? _ownNode;
  bool _recording = false;

  FocusNode get _node =>
      widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'Recorder'));

  @override
  void dispose() {
    _ownNode?.dispose();
    super.dispose();
  }

  void _start() {
    if (widget.onChanged == null) return;
    setState(() => _recording = true);
    _node.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (!_recording) {
      if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
        _start();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (Oito2KeyChord.isModifierKey(key)) return KeyEventResult.handled;
    final chord = Oito2KeyChord.fromEvent(event);
    final plain = !chord.hasCommandModifier && !chord.shift;
    if (plain && key == LogicalKeyboardKey.escape) {
      setState(() => _recording = false);
    } else if (plain &&
        (key == LogicalKeyboardKey.backspace ||
            key == LogicalKeyboardKey.delete)) {
      setState(() => _recording = false);
      widget.onChanged?.call(null);
    } else {
      setState(() => _recording = false);
      widget.onChanged?.call(Oito2Shortcut([_withPrimary(chord)]));
    }
    return KeyEventResult.handled;
  }

  /// Stores the platform's primary modifier as [Oito2KeyChord.primary].
  Oito2KeyChord _withPrimary(Oito2KeyChord chord) {
    final platform = Theme.of(context).platform;
    final apple =
        platform == TargetPlatform.macOS || platform == TargetPlatform.iOS;
    final isPrimary = apple ? chord.meta : chord.control;
    if (!isPrimary) return chord;
    return Oito2KeyChord(
      chord.key,
      primary: true,
      control: apple && chord.control,
      shift: chord.shift,
      alt: chord.alt,
      meta: !apple && chord.meta,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = Oito2Localizations.of(context);
    final enabled = widget.onChanged != null;
    final value = widget.value;
    final hintStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final content = _recording
        ? Text(l10n.pressShortcut, style: hintStyle)
        : value == null
        ? Text(l10n.noShortcut, style: hintStyle)
        : Oito2ShortcutLabel(value);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Oito2Spacing.xs,
      children: [
        Oito2FocusBorder(
          child: Focus(
            focusNode: _node,
            autofocus: widget.autofocus,
            canRequestFocus: enabled,
            onKeyEvent: _onKey,
            onFocusChange: (focused) {
              if (!focused && _recording) setState(() => _recording = false);
            },
            child: Semantics(
              button: true,
              enabled: enabled,
              label: _recording
                  ? l10n.pressShortcut
                  : value?.label(theme.platform) ?? l10n.noShortcut,
              excludeSemantics: true,
              onTap: enabled ? _start : null,
              child: GestureDetector(
                onTap: enabled ? _start : null,
                child: Container(
                  height: Oito2Sizes.buttonHeight,
                  constraints: const BoxConstraints(minWidth: 140),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Oito2Spacing.md,
                  ),
                  alignment: AlignmentDirectional.centerStart,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: Oito2Radius.mediumAll,
                    border: Border.all(
                      color: _recording
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: _recording ? 2 : 1,
                    ),
                  ),
                  child: content,
                ),
              ),
            ),
          ),
        ),
        if (value != null && enabled)
          Oito2IconButton(
            icon: const Icon(LucideIcons.x),
            tooltip: l10n.clearShortcut,
            onPressed: () => widget.onChanged?.call(null),
          ),
      ],
    );
  }
}
