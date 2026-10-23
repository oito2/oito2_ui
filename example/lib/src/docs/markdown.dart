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

/// A block of a Markdown document, as [parseMarkdown] reads it.
sealed class MdBlock {
  const MdBlock();
}

/// A `#` to `####` heading.
class MdHeading extends MdBlock {
  /// Creates a heading of [level] (1 to 4).
  const MdHeading(this.level, this.text);

  /// The number of `#` marks.
  final int level;

  /// The heading text.
  final String text;
}

/// A paragraph of inline text, its lines joined with spaces.
class MdParagraph extends MdBlock {
  /// Creates a paragraph.
  const MdParagraph(this.text);

  /// The paragraph text.
  final String text;
}

/// A bulleted or numbered list of inline items.
class MdList extends MdBlock {
  /// Creates a list.
  const MdList(this.items, {this.ordered = false});

  /// The item texts.
  final List<String> items;

  /// Whether the items are numbered.
  final bool ordered;
}

/// A fenced code block.
class MdCode extends MdBlock {
  /// Creates a code block in [language] (empty for none).
  const MdCode(this.language, this.code);

  /// The language after the opening fence.
  final String language;

  /// The code between the fences.
  final String code;
}

/// A pipe table: a header row and body rows of inline cells.
class MdTable extends MdBlock {
  /// Creates a table.
  const MdTable(this.header, this.rows);

  /// The header cells.
  final List<String> header;

  /// The body rows.
  final List<List<String>> rows;
}

/// A `>` quote, shown as a note.
class MdQuote extends MdBlock {
  /// Creates a quote.
  const MdQuote(this.text);

  /// The quoted text, its lines joined with spaces.
  final String text;
}

/// Parses the Markdown subset the showcase documents use: headings,
/// paragraphs, bulleted and numbered lists, fenced code, pipe tables and
/// quotes. Inline formatting is left in the texts for the renderer.
List<MdBlock> parseMarkdown(String source) {
  final lines = source.replaceAll('\r\n', '\n').split('\n');
  final blocks = <MdBlock>[];
  final paragraph = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(MdParagraph(paragraph.join(' ')));
    paragraph.clear();
  }

  final heading = RegExp(r'^(#{1,4})\s+(.*)$');
  final bullet = RegExp(r'^\s*[-*]\s+(.*)$');
  final numbered = RegExp(r'^\s*\d+\.\s+(.*)$');
  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final trimmed = line.trim();
    if (trimmed.startsWith('```')) {
      flushParagraph();
      final language = trimmed.substring(3).trim();
      final code = <String>[];
      i++;
      while (i < lines.length && !lines[i].trim().startsWith('```')) {
        code.add(lines[i]);
        i++;
      }
      blocks.add(MdCode(language, code.join('\n')));
      i++;
      continue;
    }
    if (trimmed.isEmpty) {
      flushParagraph();
      i++;
      continue;
    }
    if (heading.firstMatch(trimmed) case final match?) {
      flushParagraph();
      blocks.add(MdHeading(match.group(1)!.length, match.group(2)!.trim()));
      i++;
      continue;
    }
    if (trimmed.startsWith('|')) {
      flushParagraph();
      List<String> cells(String row) {
        var inner = row.trim();
        if (inner.startsWith('|')) inner = inner.substring(1);
        if (inner.endsWith('|')) inner = inner.substring(0, inner.length - 1);
        return [for (final cell in inner.split('|')) cell.trim()];
      }

      final header = cells(trimmed);
      final rows = <List<String>>[];
      i++;
      // The separator row under the header.
      if (i < lines.length && lines[i].contains('---')) i++;
      while (i < lines.length && lines[i].trim().startsWith('|')) {
        rows.add(cells(lines[i]));
        i++;
      }
      blocks.add(MdTable(header, rows));
      continue;
    }
    if (trimmed.startsWith('>')) {
      flushParagraph();
      final quote = <String>[];
      while (i < lines.length && lines[i].trim().startsWith('>')) {
        quote.add(lines[i].trim().substring(1).trim());
        i++;
      }
      blocks.add(MdQuote(quote.join(' ')));
      continue;
    }
    final isBullet = bullet.hasMatch(line);
    if (isBullet || numbered.hasMatch(line)) {
      flushParagraph();
      final pattern = isBullet ? bullet : numbered;
      final items = <String>[];
      while (i < lines.length) {
        final current = lines[i];
        if (pattern.firstMatch(current) case final match?) {
          items.add(match.group(1)!.trim());
        } else if (current.startsWith('  ') &&
            current.trim().isNotEmpty &&
            items.isNotEmpty) {
          // A continuation line of the last item.
          items[items.length - 1] += ' ${current.trim()}';
        } else {
          break;
        }
        i++;
      }
      blocks.add(MdList(items, ordered: !isBullet));
      continue;
    }
    paragraph.add(trimmed);
    i++;
  }
  flushParagraph();
  return blocks;
}

/// A run of inline text with its formatting, as [parseInline] reads it.
class MdInline {
  /// Creates a run.
  const MdInline(
    this.text, {
    this.code = false,
    this.bold = false,
    this.italic = false,
    this.link,
  });

  /// The text shown.
  final String text;

  /// Whether the run is code: `` `code` `` or a `[Symbol]` reference.
  final bool code;

  /// Whether the run is bold.
  final bool bold;

  /// Whether the run is italic.
  final bool italic;

  /// The target of a `[text](url)` link.
  final String? link;
}

/// Splits inline Markdown into runs: `` `code` ``, `**bold**`, `*italic*`,
/// `[text](url)` links, and `[Symbol]` references of doc comments, which
/// show as code.
List<MdInline> parseInline(String text) {
  final pattern = RegExp(
    r'`([^`]+)`|\*\*([^*]+)\*\*|\*([^*\s][^*]*)\*|\[([^\]]+)\]\(([^)]+)\)|\[([A-Za-z_][\w.<>?, ]*)\]',
  );
  final runs = <MdInline>[];
  var position = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > position) {
      runs.add(MdInline(text.substring(position, match.start)));
    }
    if (match.group(1) case final code?) {
      runs.add(MdInline(code, code: true));
    } else if (match.group(2) case final bold?) {
      runs.add(MdInline(bold, bold: true));
    } else if (match.group(3) case final italic?) {
      runs.add(MdInline(italic, italic: true));
    } else if (match.group(4) case final label?) {
      runs.add(MdInline(label, link: match.group(5)));
    } else {
      runs.add(MdInline(match.group(6)!, code: true));
    }
    position = match.end;
  }
  if (position < text.length) runs.add(MdInline(text.substring(position)));
  return runs;
}
