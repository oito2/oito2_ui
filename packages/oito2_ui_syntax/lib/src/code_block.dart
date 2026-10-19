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
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'highlighter.dart';

/// A read-only, selectable block of highlighted code on the theme's
/// container surface, with optional line numbers and a copy button.
///
/// The colors come from the theme's [Oito2SyntaxTheme], or from the oito2
/// base scheme of the current brightness when the theme has none. Long
/// lines scroll horizontally instead of wrapping.
class Oito2CodeBlock extends StatefulWidget {
  /// Creates a code block.
  const Oito2CodeBlock({
    super.key,
    required this.code,
    this.language,
    this.highlighter,
    this.showLineNumbers = false,
    this.showCopyButton = true,
    this.textStyle,
    this.padding = const EdgeInsets.all(Oito2Spacing.lg),
  });

  /// The source code.
  final String code;

  /// The language name, such as `dart`; null shows plain text.
  final String? language;

  /// The highlighter; defaults to [Oito2Highlighter.instance].
  final Oito2Highlighter? highlighter;

  /// Whether line numbers are shown.
  final bool showLineNumbers;

  /// Whether the copy button is shown.
  final bool showCopyButton;

  /// The code text style; defaults to [Oito2CodeBlock.defaultTextStyle].
  final TextStyle? textStyle;

  /// Space around the code.
  final EdgeInsetsGeometry padding;

  /// Monospace families tried in order; `monospace` lets the system pick
  /// its default monospace font.
  static const List<String> monospaceFallback = [
    'JetBrains Mono',
    'Cascadia Code',
    'Fira Code',
    'Ubuntu Mono',
    'DejaVu Sans Mono',
    'Noto Sans Mono',
    'Liberation Mono',
    'Consolas',
    'Menlo',
  ];

  /// The default code text style: 13-point monospace with 1.45 line
  /// height.
  static const TextStyle defaultTextStyle = TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: monospaceFallback,
    fontSize: 13,
    height: 1.45,
  );

  @override
  State<Oito2CodeBlock> createState() => _Oito2CodeBlockState();
}

class _Oito2CodeBlockState extends State<Oito2CodeBlock> {
  bool _copied = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette =
        Oito2SyntaxTheme.maybeOf(context) ??
        (theme.brightness == Brightness.dark
                ? Oito2ColorTheme.dark()
                : Oito2ColorTheme.light())
            .syntax;
    final style = Oito2CodeBlock.defaultTextStyle.merge(widget.textStyle);
    final span = (widget.highlighter ?? Oito2Highlighter.instance).highlight(
      widget.code,
      language: widget.language,
      palette: palette,
      style: style,
    );
    final lineCount = '\n'.allMatches(widget.code).length + 1;
    final localizations = MaterialLocalizations.of(context);

    return Oito2BorderContainer(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: Oito2Radius.mediumAll,
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: widget.padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showLineNumbers) ...[
                  ExcludeSemantics(
                    child: Text(
                      [for (var i = 1; i <= lineCount; i++) '$i'].join('\n'),
                      textAlign: TextAlign.end,
                      style: style.copyWith(color: palette.comment),
                    ),
                  ),
                  const SizedBox(width: Oito2Spacing.lg),
                ],
                SelectableText.rich(span),
                if (widget.showCopyButton)
                  const SizedBox(width: Oito2Sizes.buttonHeight),
              ],
            ),
          ),
          if (widget.showCopyButton)
            PositionedDirectional(
              top: Oito2Spacing.xs,
              end: Oito2Spacing.xs,
              child: IconButton(
                tooltip: localizations.copyButtonLabel,
                onPressed: _copy,
                icon: Icon(_copied ? LucideIcons.check : LucideIcons.copy),
              ),
            ),
        ],
      ),
    );
  }
}
