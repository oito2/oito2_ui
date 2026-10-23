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

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_model.dart';
import 'api_reference.g.dart';
import 'markdown.dart';

/// The widest the text column of a documentation page grows.
const double _contentWidth = 820;

/// The page width from which the table of contents shows beside the
/// content.
const double _tocBreakpoint = 1080;

/// A documentation page: a title, a lead paragraph and [children] in a
/// scrolling column, with an [Oito2TableOfContents] of its [DocHeading]s
/// beside it on wide screens.
///
/// With [source], the asset path of the page's Dart file, the
/// [ExamplePanel]s below show the code of the regions they name.
class DocPage extends StatefulWidget {
  /// Creates a documentation page.
  const DocPage({
    super.key,
    required this.title,
    required this.children,
    this.description,
    this.source,
  });

  /// The page title.
  final String title;

  /// The lead paragraph under the title, in inline Markdown.
  final String? description;

  /// The asset path of the Dart file whose `// #region` blocks the example
  /// panels show.
  final String? source;

  /// The page content; its direct [DocHeading] children make the table of
  /// contents.
  final List<Widget> children;

  @override
  State<DocPage> createState() => _DocPageState();
}

class _DocPageState extends State<DocPage> {
  final _scroll = ScrollController();
  final Map<int, GlobalKey> _keys = {};
  Future<Map<String, String>>? _regions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final source = widget.source;
    if (source != null && _regions == null) {
      _regions = DefaultAssetBundle.of(context)
          .loadString(source)
          .then(sourceRegions);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(int index) => _keys.putIfAbsent(index, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = <Oito2TocEntry>[];
    final body = <Widget>[];
    for (var i = 0; i < widget.children.length; i++) {
      final child = widget.children[i];
      if (child is DocHeading && child.level <= 3) {
        final key = _keyFor(i);
        entries.add(
          Oito2TocEntry(title: child.text, target: key, depth: child.level - 2),
        );
        body.add(KeyedSubtree(key: key, child: child));
      } else {
        body.add(child);
      }
    }
    final description = widget.description;
    final content = SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(
        Oito2Spacing.xl,
        Oito2Spacing.xl,
        Oito2Spacing.xl,
        Oito2Spacing.xxl * 2,
      ),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectionArea(
                child: Text(
                  widget.title,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: Oito2Spacing.sm),
                DocText(description, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: Oito2Spacing.md),
              ...body,
            ],
          ),
        ),
      ),
    );
    final page = _DocRegions(
      regions: _regions,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _tocBreakpoint || entries.isEmpty) {
            return content;
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              SizedBox(
                width: 220,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    0,
                    Oito2Spacing.xl,
                    Oito2Spacing.lg,
                    Oito2Spacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: Oito2Spacing.sm),
                        child: Text(
                          'On this page',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      // Long pages list more sections than fit the height.
                      Flexible(
                        child: SingleChildScrollView(
                          child: Oito2TableOfContents(
                            entries: entries,
                            controller: _scroll,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    return page;
  }
}

/// Gives [ExamplePanel]s the code regions of their page's source.
class _DocRegions extends InheritedWidget {
  const _DocRegions({required this.regions, required super.child});

  final Future<Map<String, String>>? regions;

  static Future<Map<String, String>>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DocRegions>()?.regions;

  @override
  bool updateShouldNotify(_DocRegions oldWidget) =>
      regions != oldWidget.regions;
}

/// Returns the regions of [source] by name: the lines between
/// `// #region <name>` and `// #endregion`, without their common
/// indentation and without the comma that ends the last line.
Map<String, String> sourceRegions(String source) {
  final regions = <String, String>{};
  final start = RegExp(r'^\s*// #region (\S+)\s*$');
  final end = RegExp(r'^\s*// #endregion\s*$');
  String? name;
  final lines = <String>[];
  for (final line in source.split('\n')) {
    if (start.firstMatch(line) case final match?) {
      name = match.group(1);
      lines.clear();
    } else if (name != null && end.hasMatch(line)) {
      regions[name] = _dedent(lines);
      name = null;
    } else if (name != null) {
      lines.add(line);
    }
  }
  return regions;
}

/// Joins [lines] without their common indentation, without the argument
/// name that starts the first one (such as `child:`) and without a comma
/// ending the last one.
String _dedent(List<String> lines) {
  final indents = [
    for (final line in lines)
      if (line.trim().isNotEmpty) line.length - line.trimLeft().length,
  ];
  final indent = indents.isEmpty ? 0 : indents.reduce((a, b) => a < b ? a : b);
  final text = [
    for (final line in lines)
      line.length >= indent ? line.substring(indent) : line.trimLeft(),
  ].join('\n').trimRight().replaceFirst(RegExp(r'^[a-zA-Z]\w*: '), '');
  return text.endsWith(',') ? text.substring(0, text.length - 1) : text;
}

/// A section heading of a [DocPage]; levels 2 and 3 are listed in its
/// table of contents.
class DocHeading extends StatelessWidget {
  /// Creates a heading of [level] (2 to 4).
  const DocHeading(this.text, {super.key, this.level = 2});

  /// The heading text.
  final String text;

  /// The heading level, from 2 for sections.
  final int level;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = switch (level) {
      <= 2 => textTheme.headlineSmall,
      3 => textTheme.titleLarge,
      _ => textTheme.titleMedium,
    };
    return Padding(
      padding: EdgeInsets.only(
        top: level <= 2 ? Oito2Spacing.xl : Oito2Spacing.lg,
        bottom: Oito2Spacing.sm,
      ),
      child: Semantics(
        header: true,
        child: SelectionArea(child: Text(text, style: style)),
      ),
    );
  }
}

/// A paragraph of inline Markdown: `code`, `[Symbol]` references, bold,
/// italic and links.
class DocText extends StatelessWidget {
  /// Creates a paragraph.
  const DocText(this.text, {super.key, this.style});

  /// The inline Markdown text.
  final String text;

  /// The text style; defaults to the medium body style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.sm),
      child: SelectionArea(
        child: Text.rich(
          inlineSpan(context, text),
          style: style ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// Returns [text], in inline Markdown, as styled spans.
InlineSpan inlineSpan(BuildContext context, String text) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final link = theme.extension<Oito2SemanticColors>()?.primaryText;
  return TextSpan(
    children: [
      for (final run in parseInline(text))
        if (run.code)
          TextSpan(
            text: run.text,
            style: TextStyle(
              fontFamily: Oito2CodeBlock.fontFamily,
              fontFamilyFallback: Oito2CodeBlock.monospaceFallback,
              fontSize: 13,
              backgroundColor: scheme.surfaceContainerHigh,
            ),
          )
        else if (run.link case final url?)
          TextSpan(
            text: run.text,
            style: TextStyle(color: link, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchUrl(Uri.parse(url)),
          )
        else
          TextSpan(
            text: run.text,
            style: TextStyle(
              fontWeight: run.bold ? FontWeight.w600 : null,
              fontStyle: run.italic ? FontStyle.italic : null,
            ),
          ),
    ],
  );
}

/// A block of code with a copy button.
class DocCode extends StatelessWidget {
  /// Creates a code block of [code] in [language].
  const DocCode(this.code, {super.key, this.language = 'dart'});

  /// The code.
  final String code;

  /// The language name for highlighting.
  final String language;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.md),
      child: Oito2BorderContainer(
        borderRadius: Oito2Radius.mediumAll,
        child: Oito2CodeBlock(
          code: code,
          language: language,
          padding: const EdgeInsets.all(Oito2Spacing.md),
        ),
      ),
    );
  }
}

/// A working example in a card, centered, with the code of [region], or
/// of [regions] one after the other, of the page's source under it.
class ExamplePanel extends StatelessWidget {
  /// Creates an example panel.
  const ExamplePanel({
    super.key,
    required this.child,
    this.region,
    this.regions = const [],
    this.minHeight = 120,
    this.padding = const EdgeInsets.all(Oito2Spacing.xl),
  });

  /// The example.
  final Widget child;

  /// The `// #region` of the page's source to show under the example.
  final String? region;

  /// More regions shown after [region], separated by a blank line, such
  /// as the data an example uses and the widget that shows it.
  final List<String> regions;

  /// The smallest height of the example area.
  final double minHeight;

  /// The space around the example.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final names = [?region, ...regions];
    final sources = _DocRegions.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.lg),
      child: Oito2BorderContainer(
        borderRadius: Oito2Radius.largeAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Padding(
                padding: padding,
                child: Center(child: child),
              ),
            ),
            if (names.isNotEmpty && sources != null)
              FutureBuilder<Map<String, String>>(
                future: sources,
                builder: (context, snapshot) {
                  final found = [
                    for (final name in names) ?snapshot.data?[name],
                  ];
                  if (found.isEmpty) return const SizedBox.shrink();
                  final code = found.join('\n\n');
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      border: Border(
                        top: BorderSide(color: scheme.outlineVariant),
                      ),
                    ),
                    child: Oito2CodeBlock(
                      code: code,
                      language: 'dart',
                      padding: const EdgeInsets.all(Oito2Spacing.md),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// A highlighted note, such as a tip or a caveat.
class DocNote extends StatelessWidget {
  /// Creates a note of [text] in inline Markdown.
  const DocNote(this.text, {super.key, this.type = Oito2InfoType.information});

  /// The note text.
  final String text;

  /// The kind of note.
  final Oito2InfoType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.md),
      child: Oito2InfoBox(
        type: type,
        subtitle: Text.rich(inlineSpan(context, text)),
      ),
    );
  }
}

/// A table of inline Markdown cells, scrolling sideways when narrow.
class DocTable extends StatelessWidget {
  /// Creates a table with a [header] row and body [rows].
  const DocTable({super.key, required this.header, required this.rows});

  /// The header cells.
  final List<String> header;

  /// The body rows.
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget cell(String text, {bool head = false}) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Oito2Spacing.md,
        vertical: Oito2Spacing.sm,
      ),
      child: Text.rich(
        inlineSpan(context, text),
        style: head ? theme.textTheme.labelLarge : theme.textTheme.bodyMedium,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.md),
      child: Oito2BorderContainer(
        borderRadius: Oito2Radius.mediumAll,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
          border: TableBorder(
            horizontalInside: BorderSide(color: scheme.outlineVariant),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(color: scheme.surfaceContainerLow),
              children: [for (final text in header) cell(text, head: true)],
            ),
            for (final row in rows)
              TableRow(
                children: [
                  for (var i = 0; i < header.length; i++)
                    cell(i < row.length ? row[i] : ''),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Returns the widgets of a Markdown document for a [DocPage]: `##` and
/// `###` headings become [DocHeading]s, code fences [DocCode], tables
/// [DocTable] and quotes [DocNote]. A leading `#` title is skipped, since
/// the page shows its own. [levelOffset] lowers every heading by that many
/// levels, for documents shown under a heading of the page; with
/// [skipIntro], the paragraphs before the first `##` heading are left out.
/// Link brackets in headings, as in `## [1.0.0]`, are dropped.
List<Widget> markdownWidgets(
  String source, {
  int levelOffset = 0,
  bool skipIntro = false,
}) {
  final widgets = <Widget>[];
  var intro = skipIntro;
  for (final block in parseMarkdown(source)) {
    if (intro && block is! MdHeading) continue;
    if (block is MdHeading && block.level > 1) intro = false;
    switch (block) {
      case MdHeading(level: 1):
        break;
      case MdHeading(:final level, :final text):
        widgets.add(
          DocHeading(
            text.replaceAllMapped(
              RegExp(r'\[([^\]]+)\](\([^)]*\))?'),
              (match) => match.group(1)!,
            ),
            level: level + levelOffset,
          ),
        );
      case MdParagraph(:final text):
        widgets.add(DocText(text));
      case MdList(:final items, :final ordered):
        widgets.add(_DocList(items: items, ordered: ordered));
      case MdCode(:final language, :final code):
        widgets.add(
          DocCode(code, language: language.isEmpty ? 'plaintext' : language),
        );
      case MdTable(:final header, :final rows):
        widgets.add(DocTable(header: header, rows: rows));
      case MdQuote(:final text):
        widgets.add(DocNote(text));
    }
  }
  return widgets;
}

/// A bulleted or numbered list of inline Markdown items.
class _DocList extends StatelessWidget {
  const _DocList({required this.items, required this.ordered});

  final List<String> items;
  final bool ordered;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.sm),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: Oito2Spacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(ordered ? '${i + 1}.' : '•', style: style),
                    ),
                    Expanded(
                      child: Text.rich(
                        inlineSpan(context, items[i]),
                        style: style,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Returns the API reference of the declarations named [names] for a
/// [DocPage]: under an "API reference" heading, each declaration's
/// summary, constructors with their parameters, properties, methods and
/// enum values, from the generated [apiReference].
List<Widget> apiReferenceWidgets(List<String> names) {
  return [
    const DocHeading('API reference'),
    for (final name in names)
      if (apiReference[name] case final entry?) ...[
        DocHeading(name, level: 3),
        _ApiEntryView(name: name, entry: entry),
      ],
  ];
}

/// One declaration of the API reference.
class _ApiEntryView extends StatelessWidget {
  const _ApiEntryView({required this.name, required this.entry});

  final String name;
  final ApiEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final summary = entry.doc.split('\n\n').first.replaceAll('\n', ' ');
    final children = <Widget>[
      Text(
        '${entry.kind} · package:${entry.package}',
        style: theme.textTheme.labelMedium?.copyWith(color: muted),
      ),
      const SizedBox(height: Oito2Spacing.xs),
      if (summary.isNotEmpty) DocText(summary),
      if (entry.signature.isNotEmpty) DocCode(entry.signature),
    ];
    for (final constructor in entry.constructors) {
      if (constructor.parameters.isEmpty && entry.constructors.length == 1) {
        continue;
      }
      children.add(
        _ApiList(
          title: entry.constructors.length == 1
              ? 'Parameters'
              : constructor.name,
          subtitle: entry.constructors.length == 1 ? null : constructor.doc,
          rows: [
            for (final parameter in constructor.parameters)
              _ApiRow(
                name: parameter.name,
                type: parameter.type,
                badge: parameter.isRequired ? 'required' : null,
                defaultValue: parameter.defaultValue,
                doc: parameter.doc,
              ),
          ],
        ),
      );
    }
    if (entry.properties.isNotEmpty) {
      children.add(
        _ApiList(
          title: 'Properties',
          rows: [
            for (final property in entry.properties)
              _ApiRow(
                name: property.name,
                type: property.signature,
                doc: property.doc,
              ),
          ],
        ),
      );
    }
    if (entry.methods.isNotEmpty) {
      children.add(
        _ApiList(
          title: 'Methods',
          rows: [
            for (final method in entry.methods)
              _ApiRow(name: method.signature, doc: method.doc),
          ],
        ),
      );
    }
    if (entry.values.isNotEmpty) {
      children.add(
        _ApiList(
          title: 'Values',
          rows: [
            for (final value in entry.values)
              _ApiRow(name: value.name, doc: value.doc),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// One row of an [_ApiList].
class _ApiRow {
  const _ApiRow({
    required this.name,
    required this.doc,
    this.type = '',
    this.badge,
    this.defaultValue = '',
  });

  final String name;
  final String type;
  final String? badge;
  final String defaultValue;
  final String doc;
}

/// A titled, bordered list of parameters or members: the name and type on
/// one line, the default value and the description under them.
class _ApiList extends StatelessWidget {
  const _ApiList({required this.title, required this.rows, this.subtitle});

  final String title;
  final String? subtitle;
  final List<_ApiRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final code = TextStyle(
      fontFamily: Oito2CodeBlock.fontFamily,
      fontFamilyFallback: Oito2CodeBlock.monospaceFallback,
      fontSize: 13,
    );
    final subtitle = this.subtitle;
    return Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          if (subtitle != null && subtitle.isNotEmpty)
            DocText(subtitle.replaceAll('\n', ' ')),
          const SizedBox(height: Oito2Spacing.xs),
          Oito2BorderContainer(
            borderRadius: Oito2Radius.mediumAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rows.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Oito2Spacing.md,
                      vertical: Oito2Spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: i == 0
                          ? null
                          : Border(
                              top: BorderSide(color: scheme.outlineVariant),
                            ),
                    ),
                    child: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Oito2Spacing.xxs,
                        children: [
                          Wrap(
                            spacing: Oito2Spacing.sm,
                            runSpacing: Oito2Spacing.xxs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                rows[i].name,
                                style: code.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (rows[i].type.isNotEmpty)
                                Text(
                                  rows[i].type,
                                  style: code.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              if (rows[i].badge case final badge?)
                                Oito2InfoBadge(
                                  label: Text(badge),
                                  type: Oito2InfoType.important,
                                ),
                            ],
                          ),
                          if (rows[i].defaultValue.isNotEmpty)
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'Default: '),
                                  TextSpan(
                                    text: rows[i].defaultValue,
                                    style: code,
                                  ),
                                ],
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          if (rows[i].doc.isNotEmpty)
                            Text.rich(
                              inlineSpan(
                                context,
                                rows[i].doc
                                    .replaceAll('\n\n', ' ')
                                    .replaceAll('\n', ' ')
                                    .replaceAll(' ', '\n\n'),
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
