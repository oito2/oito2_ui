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

import 'package:material_ui/material_ui.dart';

import '../collections/text_folding.dart';
import 'widget_helpers.dart';

/// Text with the matches of a search query emphasized, such as search
/// results that show why each item matched.
///
/// Each word of [query] is matched separately, ignoring case and accents
/// ("acao" matches "Ação"); overlapping matches merge. Matches use
/// [highlightStyle], which defaults to bold text in the text-safe primary
/// tone.
class Oito2HighlightedText extends StatelessWidget {
  /// Creates highlighted text.
  const Oito2HighlightedText(
    this.text, {
    super.key,
    required this.query,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  /// The full text.
  final String text;

  /// The search query; its words are highlighted.
  final String query;

  /// The style of the text; defaults to the ambient text style.
  final TextStyle? style;

  /// The style merged into the matches.
  final TextStyle? highlightStyle;

  /// The maximum number of lines.
  final int? maxLines;

  /// How overflowing text is shown.
  final TextOverflow? overflow;

  /// The horizontal alignment.
  final TextAlign? textAlign;

  /// The ranges of [text] that match the words of [query], ignoring case
  /// and accents, sorted and merged where they overlap or touch.
  static List<TextRange> matches(String text, String query) {
    final (folded: haystack, :starts) = foldTextWithOffsets(text);
    final ranges = <TextRange>[];
    for (final word in foldText(query).split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      for (
        var i = haystack.indexOf(word);
        i >= 0;
        i = haystack.indexOf(word, i + 1)
      ) {
        // Back to indexes of [text], which may differ in length.
        ranges.add(TextRange(start: starts[i], end: starts[i + word.length]));
      }
    }
    ranges.sort((a, b) => a.start - b.start);
    final merged = <TextRange>[];
    for (final range in ranges) {
      if (merged.isNotEmpty && range.start <= merged.last.end) {
        final last = merged.removeLast();
        merged.add(
          TextRange(
            start: last.start,
            end: range.end > last.end ? range.end : last.end,
          ),
        );
      } else {
        merged.add(range);
      }
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final emphasis =
        highlightStyle ??
        TextStyle(
          fontWeight: FontWeight.w700,
          color: semanticColorsOf(context).primaryText,
        );
    final spans = <TextSpan>[];
    var position = 0;
    for (final range in matches(text, query)) {
      if (range.start > position) {
        spans.add(TextSpan(text: text.substring(position, range.start)));
      }
      spans.add(TextSpan(text: range.textInside(text), style: emphasis));
      position = range.end;
    }
    if (position < text.length) {
      spans.add(TextSpan(text: text.substring(position)));
    }
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
