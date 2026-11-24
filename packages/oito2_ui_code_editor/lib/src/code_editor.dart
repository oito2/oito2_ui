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
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';
import 'package:re_editor/re_editor.dart';

/// Returns the semantic colors of the closest theme, or colors derived
/// from its `ColorScheme` and the status palette when the theme has none.
Oito2SemanticColors _semanticColorsOf(BuildContext context) {
  final extension = Oito2SemanticColors.maybeOf(context);
  if (extension != null) return extension;
  final theme = Theme.of(context);
  final status = Oito2StatusPalette.of(theme.brightness);
  return Oito2SemanticColors(
    primaryText: theme.colorScheme.primary,
    errorText: theme.colorScheme.error,
    success: status.success,
    warning: status.warning,
    info: status.info,
    link: status.link,
  );
}

/// The kind of an [Oito2LineMarker], from the most to the least urgent.
enum Oito2LineMarkerType {
  /// An error.
  error,

  /// A warning.
  warning,

  /// Neutral information.
  info;

  /// The [Oito2InfoType] that gives this kind its icon, color and label.
  Oito2InfoType get infoType => switch (this) {
    error => Oito2InfoType.danger,
    warning => Oito2InfoType.warning,
    info => Oito2InfoType.information,
  };
}

/// A mark on a line of an [Oito2CodeEditor]: an icon in the gutter with
/// [message] as its tooltip and accessibility label.
@immutable
class Oito2LineMarker {
  /// Creates a marker of [type] with [message].
  const Oito2LineMarker({required this.type, required this.message});

  /// Creates an error marker with [message].
  const Oito2LineMarker.error(this.message) : type = Oito2LineMarkerType.error;

  /// Creates a warning marker with [message].
  const Oito2LineMarker.warning(this.message)
    : type = Oito2LineMarkerType.warning;

  /// Creates an information marker with [message].
  const Oito2LineMarker.info(this.message) : type = Oito2LineMarkerType.info;

  /// The kind of the marker.
  final Oito2LineMarkerType type;

  /// The text shown as the tooltip and announced by assistive
  /// technologies.
  final String message;

  @override
  bool operator ==(Object other) =>
      other is Oito2LineMarker &&
      other.type == type &&
      other.message == message;

  @override
  int get hashCode => Object.hash(type, message);
}

/// An editable code field with highlighting in the theme's
/// [Oito2SyntaxPalette], line numbers, highlighted lines and line markers.
///
/// Built on `re_editor`, whose [CodeLineEditingController] holds the text
/// and selection; it brings undo and redo, indentation with Tab and
/// Shift+Tab, line selection, moving and deleting lines, and the usual
/// cursor and selection keys. Its find, replace and save shortcuts are left
/// to the app, so Ctrl+F and Ctrl+S reach the widgets around the editor.
/// Since Tab indents, Ctrl+Tab and Ctrl+Shift+Tab move the focus to the
/// next and previous widgets.
///
/// The code is laid out left to right in every locale, in the bundled
/// JetBrains Mono at [Oito2CodeBlock.defaultTextStyle] (scaled with the
/// text scale), and long lines scroll horizontally.
///
/// With neither [minLines] nor [maxLines], the editor fills the height its
/// parent gives it, which must be bounded. Otherwise it is as tall as its
/// lines, at least [minLines] and at most [maxLines], scrolling beyond
/// that.
///
/// `re_editor` brings some limits. Web builds compiled with `--wasm` are
/// not supported, because one of its dependencies imports `dart:html`.
/// Each editor runs highlighting, code folding and search in three
/// background isolates on native platforms; on the web they run on the
/// main thread. The editor colors a token by the first segment of its
/// scope, so a class name such as `title.class` takes the function color,
/// while [Oito2CodeBlock] colors it by its full scope.
class Oito2CodeEditor extends StatefulWidget {
  /// Creates a code editor.
  const Oito2CodeEditor({
    super.key,
    this.controller,
    this.language,
    this.highlighter,
    this.readOnly = false,
    this.showLineNumbers = true,
    this.highlightedLines = const {},
    this.lineMarkers = const {},
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.minLines,
    this.maxLines,
    this.semanticLabel,
  }) : assert(minLines == null || minLines > 0),
       assert(maxLines == null || maxLines > 0),
       assert(minLines == null || maxLines == null || minLines <= maxLines);

  /// The text and selection; one holding no text is created when null.
  ///
  /// [CodeLineEditingController.fromText] creates one with text, and
  /// [CodeLineEditingController.text] reads and replaces it.
  final CodeLineEditingController? controller;

  /// The language name or alias, such as `dart` or `gitignore`; null or an
  /// unregistered name shows plain text.
  final String? language;

  /// The highlighter whose languages [language] is looked up in; defaults
  /// to [Oito2Highlighter.instance].
  final Oito2Highlighter? highlighter;

  /// Whether the text can't be changed; it can still be selected and
  /// copied.
  final bool readOnly;

  /// Whether line numbers are shown in the gutter.
  final bool showLineNumbers;

  /// The lines drawn on a tint of the primary color with a bar along their
  /// leading edge, counted from 1.
  final Set<int> highlightedLines;

  /// The markers shown in the gutter, by line number counted from 1.
  final Map<int, Oito2LineMarker> lineMarkers;

  /// Called with the whole text after every change to it; selection
  /// changes don't call it.
  final ValueChanged<String>? onChanged;

  /// The focus node of the editor; one is created when null.
  final FocusNode? focusNode;

  /// Whether the editor takes the focus when first shown.
  final bool autofocus;

  /// The least number of lines the editor is tall.
  final int? minLines;

  /// The most number of lines the editor is tall before it scrolls.
  final int? maxLines;

  /// The accessibility label; defaults to [Oito2Localizations.codeEditor].
  final String? semanticLabel;

  @override
  State<Oito2CodeEditor> createState() => _Oito2CodeEditorState();
}

class _Oito2CodeEditorState extends State<Oito2CodeEditor> {
  CodeLineEditingController? _ownedController;
  FocusNode? _ownedFocusNode;
  final _geometry = _ParagraphGeometry();
  late CodeLines _lines;
  bool _focused = false;

  CodeLineEditingController get _controller =>
      widget.controller ?? (_ownedController ??= CodeLineEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownedFocusNode ??= FocusNode(debugLabel: 'Oito2CodeEditor'));

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onValue);
    _lines = _controller.codeLines;
    _focusNode.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(Oito2CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController = oldWidget.controller ?? _ownedController;
    if (!identical(oldController, _controller)) {
      oldController?.removeListener(_onValue);
      _controller.addListener(_onValue);
      _lines = _controller.codeLines;
    }
    final oldFocus = oldWidget.focusNode ?? _ownedFocusNode;
    if (!identical(oldFocus, _focusNode)) {
      oldFocus?.removeListener(_onFocus);
      _focusNode.addListener(_onFocus);
      _focused = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onValue);
    _focusNode.removeListener(_onFocus);
    _ownedController?.dispose();
    _ownedFocusNode?.dispose();
    _geometry.dispose();
    super.dispose();
  }

  /// Reports text changes to [Oito2CodeEditor.onChanged] and rebuilds for
  /// the line count and the semantics value.
  void _onValue() {
    final lines = _controller.codeLines;
    if (identical(lines, _lines) || lines == _lines) return;
    _lines = lines;
    widget.onChanged?.call(_controller.text);
    if (mounted) setState(() {});
  }

  void _onFocus() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  /// Returns the height of one line of code in [style].
  static double _lineHeight(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final height = painter.preferredLineHeight;
    painter.dispose();
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = Oito2SyntaxTheme.of(context);
    final strings = Oito2Localizations.of(context);
    final indicator = _semanticColorsOf(context).primaryText;
    final base = Oito2CodeBlock.defaultTextStyle;
    final fontSize = MediaQuery.textScalerOf(context).scale(base.fontSize!);
    final style = base.copyWith(fontSize: fontSize);
    final highlighter = widget.highlighter ?? Oito2Highlighter.instance;
    final language = widget.language;
    final mode = language == null ? null : highlighter.modeOf(language);
    final readOnly = widget.readOnly;

    const padding = EdgeInsets.symmetric(
      horizontal: Oito2Spacing.md,
      vertical: Oito2Spacing.sm,
    );
    double? height;
    final minLines = widget.minLines;
    final maxLines = widget.maxLines;
    if (minLines != null || maxLines != null) {
      var lines = _controller.lineCount;
      if (minLines != null && lines < minLines) lines = minLines;
      if (maxLines != null && lines > maxLines) lines = maxLines;
      height = lines * _lineHeight(style) + padding.vertical;
    }

    final lineColors = Oito2LineHighlight.of(context);
    Widget editor = CodeEditor(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      readOnly: readOnly,
      showCursorWhenReadOnly: false,
      wordWrap: false,
      padding: padding,
      style: CodeEditorStyle(
        fontSize: fontSize,
        fontFamily: base.fontFamily,
        fontFamilyFallback: base.fontFamilyFallback,
        fontHeight: base.height,
        textColor: palette.foreground,
        selectionColor: scheme.primary.withValues(alpha: 0.35),
        highlightColor: scheme.primary.withValues(alpha: 0.35),
        cursorColor: indicator,
        chunkIndicatorColor: palette.comment,
        codeTheme: mode == null
            ? null
            : CodeHighlightTheme(
                languages: {language!.toLowerCase(): mode.themeMode},
                theme: Oito2HighlighterTheme.fromPalette(palette),
              ),
      ),
      shortcutsActivatorsBuilder: const _Oito2CodeShortcutsActivatorsBuilder(),
      scrollbarBuilder: (context, child, details) => Scrollbar(
        controller: details.controller,
        scrollbarOrientation: details.direction == AxisDirection.down
            ? ScrollbarOrientation.right
            : ScrollbarOrientation.bottom,
        child: child,
      ),
      indicatorBuilder: (context, controller, chunkController, notifier) {
        _geometry.attach(notifier);
        return _Gutter(
          controller: controller,
          notifier: notifier,
          geometry: _geometry,
          showLineNumbers: widget.showLineNumbers,
          markers: widget.lineMarkers,
          textStyle: style.copyWith(color: palette.comment),
          focusedTextStyle: style.copyWith(color: palette.foreground),
        );
      },
    );
    if (widget.highlightedLines.isNotEmpty) {
      editor = Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ParagraphHighlightPainter(
                geometry: _geometry,
                lines: widget.highlightedLines,
                colors: lineColors,
              ),
            ),
          ),
          editor,
        ],
      );
    }

    final border = _focused
        ? Border.all(
            color: indicator,
            width: Oito2Sizes.focusBorderWidth,
            strokeAlign: BorderSide.strokeAlignOutside,
          )
        : Border.all(color: scheme.outline);
    return Semantics(
      container: true,
      textField: true,
      multiline: true,
      readOnly: readOnly,
      focused: _focused,
      label: widget.semanticLabel ?? strings.codeEditor,
      value: _controller.text,
      // Tab indents inside the editor, so Ctrl+Tab and Ctrl+Shift+Tab move
      // the focus out of it.
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.tab, control: true):
              NextFocusIntent(),
          SingleActivator(LogicalKeyboardKey.tab, control: true, shift: true):
              PreviousFocusIntent(),
        },
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: Oito2Radius.mediumAll,
              border: border,
            ),
            child: ClipRRect(
              borderRadius: Oito2Radius.mediumAll,
              child: ColoredBox(
                color: scheme.surfaceContainer,
                child: SizedBox(height: height, child: editor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The shortcuts of `re_editor` without find, replace and save, which an
/// editor without those features leaves to the widgets around it.
class _Oito2CodeShortcutsActivatorsBuilder
    extends CodeShortcutsActivatorsBuilder {
  const _Oito2CodeShortcutsActivatorsBuilder();

  static const _left = {
    CodeShortcutType.find,
    CodeShortcutType.findToggleMatchCase,
    CodeShortcutType.findToggleRegex,
    CodeShortcutType.replace,
    CodeShortcutType.save,
  };

  @override
  List<ShortcutActivator>? build(CodeShortcutType type) => _left.contains(type)
      ? null
      : const DefaultCodeShortcutsActivatorsBuilder().build(type);
}

/// The lines the editor shows, as reported to its gutter, so widgets
/// outside the gutter can follow them.
class _ParagraphGeometry extends ChangeNotifier {
  CodeIndicatorValueNotifier? _source;

  /// Follows [source], the notifier the editor hands to its gutter.
  void attach(CodeIndicatorValueNotifier source) {
    if (identical(source, _source)) return;
    _source?.removeListener(notifyListeners);
    _source = source..addListener(notifyListeners);
  }

  /// The lines on screen, with their offsets from the top of the editor.
  List<CodeLineRenderParagraph> get paragraphs =>
      _source?.value?.paragraphs ?? const [];

  @override
  void dispose() {
    _source?.removeListener(notifyListeners);
    super.dispose();
  }
}

/// Paints the highlighted lines that are on screen across the editor.
class _ParagraphHighlightPainter extends CustomPainter {
  _ParagraphHighlightPainter({
    required this.geometry,
    required this.lines,
    required this.colors,
  }) : super(repaint: geometry);

  final _ParagraphGeometry geometry;
  final Set<int> lines;
  final Oito2LineHighlight colors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final paragraph in geometry.paragraphs) {
      if (!lines.contains(paragraph.index + 1)) continue;
      colors.paint(
        canvas,
        Rect.fromLTWH(0, paragraph.top, size.width, paragraph.height),
        TextDirection.ltr,
      );
    }
  }

  @override
  bool shouldRepaint(_ParagraphHighlightPainter oldDelegate) =>
      !identical(oldDelegate.geometry, geometry) ||
      !setEquals(oldDelegate.lines, lines) ||
      oldDelegate.colors != colors;
}

/// The gutter of the editor: the line markers, then the line numbers.
class _Gutter extends StatelessWidget {
  const _Gutter({
    required this.controller,
    required this.notifier,
    required this.geometry,
    required this.showLineNumbers,
    required this.markers,
    required this.textStyle,
    required this.focusedTextStyle,
  });

  final CodeLineEditingController controller;
  final CodeIndicatorValueNotifier notifier;
  final _ParagraphGeometry geometry;
  final bool showLineNumbers;
  final Map<int, Oito2LineMarker> markers;
  final TextStyle textStyle;
  final TextStyle focusedTextStyle;

  @override
  Widget build(BuildContext context) {
    final hasMarkers = markers.isNotEmpty;
    if (!showLineNumbers && !hasMarkers) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: Oito2Spacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasMarkers)
            SizedBox(
              width: _MarkerFlowDelegate.width,
              child: _Markers(markers: markers, geometry: geometry),
            ),
          if (showLineNumbers)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: Oito2Spacing.xs),
              // A press on a number selects its line.
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: DefaultCodeLineNumber(
                  controller: controller,
                  notifier: notifier,
                  textStyle: textStyle,
                  focusedTextStyle: focusedTextStyle,
                  minNumberCount: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The marker icons, each next to its line while the line is on screen.
class _Markers extends StatelessWidget {
  const _Markers({required this.markers, required this.geometry});

  final Map<int, Oito2LineMarker> markers;
  final _ParagraphGeometry geometry;

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final colors = _semanticColorsOf(context);
    final lines = markers.keys.toList()..sort();
    return Flow(
      delegate: _MarkerFlowDelegate(geometry: geometry, lines: lines),
      children: [
        for (final line in lines)
          _MarkerIcon(
            line: line,
            marker: markers[line]!,
            color: markers[line]!.type.infoType.colorIn(colors),
            label: strings.lineMessage(
              line,
              markers[line]!.type.infoType.labelIn(strings),
              markers[line]!.message,
            ),
          ),
      ],
    );
  }
}

class _MarkerIcon extends StatelessWidget {
  const _MarkerIcon({
    required this.line,
    required this.marker,
    required this.color,
    required this.label,
  });

  final int line;
  final Oito2LineMarker marker;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: marker.message,
        child: Center(
          child: Icon(
            marker.type.infoType.icon,
            size: _MarkerFlowDelegate.iconSize,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Places the marker of line `lines[i]` beside that line while it is on
/// screen, and hides it otherwise.
class _MarkerFlowDelegate extends FlowDelegate {
  _MarkerFlowDelegate({required this.geometry, required this.lines})
    : super(repaint: geometry);

  static const double iconSize = 14;
  static const double width = 18;

  final _ParagraphGeometry geometry;
  final List<int> lines;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    final paragraphs = geometry.paragraphs;
    final lineHeight = paragraphs.isEmpty
        ? width
        : paragraphs.first.preferredLineHeight;
    return BoxConstraints.tight(Size(width, lineHeight));
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final tops = {
      for (final paragraph in geometry.paragraphs)
        paragraph.index + 1: paragraph.top,
    };
    for (var i = 0; i < lines.length; i++) {
      final top = tops[lines[i]];
      if (top == null) continue;
      context.paintChild(i, transform: Matrix4.translationValues(0, top, 0));
    }
  }

  @override
  bool shouldRelayout(_MarkerFlowDelegate oldDelegate) => true;

  @override
  bool shouldRepaint(_MarkerFlowDelegate oldDelegate) =>
      !identical(oldDelegate.geometry, geometry) ||
      !listEquals(oldDelegate.lines, lines);
}
