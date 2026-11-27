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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'highlighter.dart';
import 'line_highlight.dart';

/// A read-only, selectable block of highlighted code on the theme's
/// container surface, with optional line numbers, highlighted lines and a
/// copy button.
///
/// The colors come from the theme's [Oito2SyntaxTheme], or from the oito2
/// base scheme of the current brightness when the theme has none. Long
/// lines scroll horizontally instead of wrapping.
///
/// Highlighting runs on the UI thread, so code longer than
/// [maxHighlightLength] shows as plain text in the foreground color.
class Oito2CodeBlock extends StatefulWidget {
  /// Creates a code block.
  const Oito2CodeBlock({
    super.key,
    required this.code,
    this.language,
    this.highlighter,
    this.showLineNumbers = false,
    this.highlightedLines = const {},
    this.showCopyButton = true,
    this.textStyle,
    this.padding = const EdgeInsets.all(Oito2Spacing.lg),
    this.maxHighlightLength = defaultMaxHighlightLength,
  }) : assert(maxHighlightLength >= 0);

  /// The source code.
  final String code;

  /// The language name or alias, such as `dart`; null or an unregistered
  /// name shows plain text.
  final String? language;

  /// The highlighter; defaults to [Oito2Highlighter.instance].
  final Oito2Highlighter? highlighter;

  /// Whether line numbers are shown.
  final bool showLineNumbers;

  /// The lines drawn on a tint of the primary color with a bar along
  /// their leading edge, counted from 1; numbers outside the code are
  /// ignored.
  ///
  /// The tint is drawn behind the text only, so the semantics of the
  /// block don't change.
  final Set<int> highlightedLines;

  /// Whether the copy button is shown.
  final bool showCopyButton;

  /// The code text style; defaults to [Oito2CodeBlock.defaultTextStyle].
  final TextStyle? textStyle;

  /// Space around the code.
  final EdgeInsetsGeometry padding;

  /// The longest code, in UTF-16 code units, that is highlighted; longer
  /// code shows as plain text in the foreground color.
  ///
  /// Defaults to [defaultMaxHighlightLength]. Highlighting takes time in
  /// proportion to the length of the code and blocks the UI meanwhile, so
  /// raise it only for code known to be short enough on the slowest
  /// target device.
  final int maxHighlightLength;

  /// The default [maxHighlightLength]: 20 000 code units, which
  /// highlight in about 50 milliseconds on a desktop computer.
  static const int defaultMaxHighlightLength = 20000;

  /// The family name of JetBrains Mono as bundled by this package,
  /// including the package prefix.
  static const String fontFamily = 'packages/oito2_ui_syntax/JetBrains Mono';

  /// System monospace families used for glyphs the bundled font lacks, in
  /// order.
  static const List<String> monospaceFallback = [
    'Cascadia Code',
    'Fira Code',
    'Ubuntu Mono',
    'DejaVu Sans Mono',
    'Noto Sans Mono',
    'Liberation Mono',
    'Consolas',
    'Menlo',
    'monospace',
  ];

  /// The default code text style: 13-point bundled JetBrains Mono with
  /// 1.45 line height.
  static const TextStyle defaultTextStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: monospaceFallback,
    fontSize: 13,
    height: 1.45,
  );

  @override
  State<Oito2CodeBlock> createState() => _Oito2CodeBlockState();
}

class _Oito2CodeBlockState extends State<Oito2CodeBlock> {
  @override
  void initState() {
    super.initState();
    _registerFontLicense();
  }

  Object? _key;
  TextSpan? _span;

  /// The highlighted code, or the plain code when it is longer than
  /// [Oito2CodeBlock.maxHighlightLength], computed again only when an
  /// input changes.
  TextSpan _highlighted(Oito2SyntaxPalette palette, TextStyle style) {
    final highlighter = widget.highlighter ?? Oito2Highlighter.instance;
    final code = widget.code;
    final plain = code.length > widget.maxHighlightLength;
    final key = (code, widget.language, palette, style, highlighter, plain);
    if (key != _key || _span == null) {
      _key = key;
      _span = plain
          ? TextSpan(
              text: code,
              style: style.copyWith(color: palette.foreground),
            )
          : highlighter.highlight(
              code,
              language: widget.language,
              palette: palette,
              style: style,
            );
    }
    return _span!;
  }

  /// Returns the height of one line of code in [style] at [scaler].
  static double _lineHeight(TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: ' ', style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    final height = painter.preferredLineHeight;
    painter.dispose();
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.code;
    final textStyle = widget.textStyle;
    final showLineNumbers = widget.showLineNumbers;
    final showCopyButton = widget.showCopyButton;
    final padding = widget.padding;
    final theme = Theme.of(context);
    final palette = Oito2SyntaxTheme.of(context);
    final style = Oito2CodeBlock.defaultTextStyle.merge(textStyle);
    final span = _highlighted(palette, style);
    final lineCount = '\n'.allMatches(code).length + 1;
    final highlightedLines = {
      for (final line in widget.highlightedLines)
        if (line >= 1 && line <= lineCount) line,
    };
    final direction = Directionality.of(context);

    return Oito2BorderContainer(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: Oito2Radius.mediumAll,
      child: Stack(
        children: [
          if (highlightedLines.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: FixedLineHighlightPainter(
                  lines: highlightedLines,
                  top: padding.resolve(direction).top,
                  lineHeight: _lineHeight(
                    style,
                    MediaQuery.textScalerOf(context),
                  ),
                  colors: Oito2LineHighlight.of(context),
                  direction: direction,
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLineNumbers) ...[
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
                if (showCopyButton)
                  const SizedBox(width: Oito2Sizes.buttonHeight),
              ],
            ),
          ),
          if (showCopyButton)
            PositionedDirectional(
              top: Oito2Spacing.xs,
              end: Oito2Spacing.xs,
              child: Oito2CopyButton(text: code),
            ),
        ],
      ),
    );
  }
}

bool _fontLicenseRegistered = false;

/// Lists the license of the bundled JetBrains Mono font, the SIL Open Font
/// License, in the app's license page, once.
void _registerFontLicense() {
  if (_fontLicenseRegistered) return;
  _fontLicenseRegistered = true;
  LicenseRegistry.addLicense(() async* {
    // An app bundles the file under the package prefix; the package's own
    // tests bundle it without.
    for (final key in const [
      'packages/oito2_ui_syntax/assets/fonts/jetbrains_mono/OFL.txt',
      'assets/fonts/jetbrains_mono/OFL.txt',
    ]) {
      try {
        final text = await rootBundle.loadString(key);
        yield LicenseEntryWithLineBreaks(const ['JetBrains Mono'], text);
        return;
      } on Object {
        continue;
      }
    }
  });
}
