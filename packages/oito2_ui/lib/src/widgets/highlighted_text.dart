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
/// Each word of [query] and of [queries] is matched separately, ignoring
/// case and accents ("acao" matches "Ação"); overlapping matches merge.
/// [splitWords], [ignoreCase], [wholeWords] and [matchAll] change how terms
/// match. Matches use [highlightStyle], which defaults to bold text in the
/// text-safe primary tone.
class Oito2HighlightedText extends StatelessWidget {
  /// Creates highlighted text.
  const Oito2HighlightedText(
    this.text, {
    super.key,
    required this.query,
    this.queries = const [],
    this.splitWords = true,
    this.ignoreCase = true,
    this.wholeWords = false,
    this.matchAll = true,
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

  /// More queries highlighted along with [query].
  final List<String> queries;

  /// Whether each word of a query matches on its own; when false, each
  /// query matches as a whole phrase.
  final bool splitWords;

  /// Whether matching ignores case and accents; when false, matches must
  /// have the same case and accents.
  final bool ignoreCase;

  /// Whether a term matches only whole words, not the start, middle or end
  /// of a longer word.
  final bool wholeWords;

  /// Whether every occurrence of a term is highlighted; when false, only
  /// its first occurrence.
  final bool matchAll;

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

  /// The ranges of [text] that match [query] and [queries], sorted and
  /// merged where they overlap or touch. The options work as on the
  /// widget: by default each word matches everywhere, ignoring case and
  /// accents.
  static List<TextRange> matches(
    String text,
    String query, {
    List<String> queries = const [],
    bool splitWords = true,
    bool ignoreCase = true,
    bool wholeWords = false,
    bool matchAll = true,
  }) {
    final String haystack;
    final List<int> starts;
    if (ignoreCase) {
      (folded: haystack, :starts) = foldTextWithOffsets(text);
    } else {
      haystack = text;
      starts = List.generate(text.length + 1, (i) => i);
    }
    final terms = <String>[];
    for (final raw in [query, ...queries]) {
      final term = ignoreCase ? foldText(raw) : raw;
      terms.addAll(splitWords ? term.split(RegExp(r'\s+')) : [term.trim()]);
    }
    bool isWordChar(int index) =>
        index >= 0 &&
        index < haystack.length &&
        _wordChar.hasMatch(haystack[index]);
    final ranges = <TextRange>[];
    for (final term in terms) {
      if (term.isEmpty) continue;
      for (
        var i = haystack.indexOf(term);
        i >= 0;
        i = haystack.indexOf(term, i + 1)
      ) {
        final end = i + term.length;
        if (wholeWords && (isWordChar(i - 1) || isWordChar(end))) continue;
        // Back to indexes of [text], which may differ in length.
        ranges.add(TextRange(start: starts[i], end: starts[end]));
        if (!matchAll) break;
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
    for (final range in matches(
      text,
      query,
      queries: queries,
      splitWords: splitWords,
      ignoreCase: ignoreCase,
      wholeWords: wholeWords,
      matchAll: matchAll,
    )) {
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

final _wordChar = RegExp(r'[\p{L}\p{N}_]', unicode: true);
