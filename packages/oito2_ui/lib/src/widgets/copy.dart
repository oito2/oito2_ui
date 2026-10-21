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

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import 'icon_buttons.dart';
import 'swap.dart';
import 'widget_helpers.dart';

/// An icon button that copies [text] to the clipboard.
///
/// After a copy the icon turns into a check mark and the tooltip into
/// "Copied" for [feedbackDuration], and assistive technologies hear the
/// change.
class Oito2CopyButton extends StatefulWidget {
  /// Creates a copy button.
  const Oito2CopyButton({
    super.key,
    required this.text,
    this.tooltip,
    this.onCopied,
    this.feedbackDuration = const Duration(milliseconds: 1500),
  });

  /// The text copied.
  final String text;

  /// The tooltip before copying; defaults to the localized "Copy".
  final String? tooltip;

  /// Called after each copy.
  final VoidCallback? onCopied;

  /// How long the copied state shows.
  final Duration feedbackDuration;

  @override
  State<Oito2CopyButton> createState() => _Oito2CopyButtonState();
}

class _Oito2CopyButtonState extends State<Oito2CopyButton> {
  bool _copied = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    widget.onCopied?.call();
    _timer?.cancel();
    _timer = Timer(widget.feedbackDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = _copied
        ? Oito2Localizations.of(context).copied
        : widget.tooltip ?? MaterialLocalizations.of(context).copyButtonLabel;
    return Semantics(
      liveRegion: _copied,
      child: Oito2IconButton(
        tooltip: tooltip,
        onPressed: _copy,
        icon: Oito2Swap(
          swapped: _copied,
          effect: Oito2SwapEffect.scale,
          off: const Icon(LucideIcons.copy),
          on: Icon(LucideIcons.check, color: semanticColorsOf(context).success),
        ),
      ),
    );
  }
}

/// A read-only field showing [value], such as a link or a token, with an
/// [Oito2CopyButton] at its end.
class Oito2CopyField extends StatefulWidget {
  /// Creates a copy field.
  const Oito2CopyField({
    super.key,
    required this.value,
    this.labelText,
    this.obscure = false,
    this.onCopied,
  });

  /// The text shown and copied.
  final String value;

  /// The field label.
  final String? labelText;

  /// Whether the value shows as dots, such as for a secret.
  final bool obscure;

  /// Called after each copy.
  final VoidCallback? onCopied;

  @override
  State<Oito2CopyField> createState() => _Oito2CopyFieldState();
}

class _Oito2CopyFieldState extends State<Oito2CopyField> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(Oito2CopyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      obscureText: widget.obscure,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: Oito2CopyButton(
          text: widget.value,
          onCopied: widget.onCopied,
        ),
      ),
    );
  }
}
