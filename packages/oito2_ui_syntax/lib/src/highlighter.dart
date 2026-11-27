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

import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:re_highlight/languages/bash.dart';
import 'package:re_highlight/languages/c.dart';
import 'package:re_highlight/languages/cpp.dart';
import 'package:re_highlight/languages/csharp.dart';
import 'package:re_highlight/languages/css.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/languages/diff.dart';
import 'package:re_highlight/languages/dockerfile.dart';
import 'package:re_highlight/languages/go.dart';
import 'package:re_highlight/languages/ini.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/kotlin.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/languages/php.dart';
import 'package:re_highlight/languages/plaintext.dart';
import 'package:re_highlight/languages/python.dart';
import 'package:re_highlight/languages/rust.dart';
import 'package:re_highlight/languages/scss.dart';
import 'package:re_highlight/languages/shell.dart';
import 'package:re_highlight/languages/sql.dart';
import 'package:re_highlight/languages/swift.dart';
import 'package:re_highlight/languages/typescript.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/re_highlight.dart';

import 'highlighter_theme.dart';
import 'languages/gitignore.dart';

/// The languages [Oito2Highlighter] registers by default, keyed by name.
///
/// All come from `re_highlight` except `gitignore` ([langGitignore]),
/// written for this package, which also answers to the `ignore` and
/// `dockerignore` aliases.
///
/// `re_highlight` ships about 190 more grammars under
/// `package:re_highlight/languages/`; pass them to [Oito2Highlighter] to
/// add them. Only the grammars referenced are compiled into the app.
final Map<String, Mode> oito2DefaultLanguages = {
  'bash': langBash,
  'c': langC,
  'cpp': langCpp,
  'csharp': langCsharp,
  'css': langCss,
  'dart': langDart,
  'diff': langDiff,
  'dockerfile': langDockerfile,
  'gitignore': langGitignore,
  'go': langGo,
  'html': langXml,
  'ini': langIni,
  'java': langJava,
  'javascript': langJavascript,
  'json': langJson,
  'kotlin': langKotlin,
  'markdown': langMarkdown,
  'php': langPhp,
  'plaintext': langPlaintext,
  'python': langPython,
  'rust': langRust,
  'scss': langScss,
  'shell': langShell,
  'sql': langSql,
  'swift': langSwift,
  'typescript': langTypescript,
  'xml': langXml,
  'yaml': langYaml,
};

/// Turns source code into a [TextSpan] colored with a
/// [Oito2SyntaxPalette].
///
/// Tokenizing runs synchronously in pure Dart, with no native code and no
/// asset loading.
class Oito2Highlighter {
  /// Creates a highlighter that knows [languages] (by default
  /// [oito2DefaultLanguages]).
  Oito2Highlighter({Map<String, Mode>? languages})
    : _highlight = Highlight()
        ..registerLanguages(languages ?? oito2DefaultLanguages),
      languages = Set.unmodifiable((languages ?? oito2DefaultLanguages).keys);

  final Highlight _highlight;

  /// The names of the registered languages.
  final Set<String> languages;

  /// Whether [language] is registered, by name or by one of its aliases
  /// (such as `js` or `yml`), in any letter case.
  bool supports(String language) => _highlight.getLanguage(language) != null;

  /// Returns the grammar registered for [language], a name or alias in any
  /// letter case, or null when none is.
  Mode? modeOf(String language) => _highlight.getLanguage(language);

  /// The token styles of up to 16 palettes, so highlighting doesn't rebuild
  /// them on every call; the oldest entry is evicted first.
  static final _themes = <Oito2SyntaxPalette, Map<String, TextStyle>>{};

  /// The cached token styles of [palette], built on first use.
  static Map<String, TextStyle> _themeFor(Oito2SyntaxPalette palette) {
    final cached = _themes[palette];
    if (cached != null) return cached;
    if (_themes.length >= 16) _themes.remove(_themes.keys.first);
    return _themes[palette] = Oito2HighlighterTheme.fromPalette(palette);
  }

  /// A shared highlighter with the default languages.
  static final Oito2Highlighter instance = Oito2Highlighter();

  /// Returns [code] highlighted as [language] with [palette], on top of
  /// [style] (whose color is replaced by the palette foreground).
  ///
  /// [language] is a registered name or alias, in any letter case. When it
  /// isn't registered, or is null and [autoDetect] is false, the code is
  /// returned unhighlighted in the foreground color. With [autoDetect], a
  /// null [language] is guessed among the registered ones.
  TextSpan highlight(
    String code, {
    required Oito2SyntaxPalette palette,
    String? language,
    TextStyle? style,
    bool autoDetect = false,
  }) {
    final base = (style ?? const TextStyle()).copyWith(
      color: palette.foreground,
    );
    final HighlightResult result;
    if (language != null && supports(language)) {
      result = _highlight.highlight(
        code: code,
        language: language.toLowerCase(),
      );
    } else if (language == null && autoDetect) {
      result = _highlight.highlightAuto(code);
    } else {
      return TextSpan(text: code, style: base);
    }
    final renderer = TextSpanRenderer(base, _themeFor(palette));
    result.render(renderer);
    return renderer.span ?? TextSpan(text: code, style: base);
  }

  /// Returns the tokens of [code] as [language], to be colored later with
  /// [Oito2HighlightTokens.toSpan].
  ///
  /// [language] is a registered name or alias, in any letter case; with
  /// [autoDetect], a null [language] is guessed among the registered ones.
  /// Returns null when [language] isn't registered, or is null and
  /// [autoDetect] is false.
  ///
  /// The highlighter and the result can be sent to another isolate, so
  /// this can run off the UI thread, as `Oito2CodeBlock` does for long
  /// code.
  Oito2HighlightTokens? tokenize(
    String code, {
    String? language,
    bool autoDetect = false,
  }) {
    final HighlightResult result;
    if (language != null && supports(language)) {
      result = _highlight.highlight(
        code: code,
        language: language.toLowerCase(),
      );
    } else if (language == null && autoDetect) {
      result = _highlight.highlightAuto(code);
    } else {
      return null;
    }
    final collector = _TokenCollector();
    result.render(collector);
    return collector.finish(code);
  }
}

/// The tokens of a piece of code: consecutive runs of text, each with the
/// highlight.js scope of the innermost token it belongs to, or none.
///
/// Made by [Oito2Highlighter.tokenize]. The tokens hold no colors, so the
/// same tokens are colored with any palette by [toSpan], and they can be
/// sent between isolates.
final class Oito2HighlightTokens {
  Oito2HighlightTokens._(this.code, this._ends, this._scopes, this._names);

  /// The tokenized code.
  final String code;

  /// The end offset of every run, in UTF-16 code units, in order.
  final Int32List _ends;

  /// The index in [_names] of the scope of every run, or -1 for none.
  final Int32List _scopes;

  /// The distinct scopes the runs refer to.
  final List<String> _names;

  /// The number of runs.
  int get length => _ends.length;

  /// Returns the text of run [index], counted from 0.
  String textAt(int index) =>
      code.substring(index == 0 ? 0 : _ends[index - 1], _ends[index]);

  /// Returns the highlight.js scope of run [index], counted from 0, such as
  /// `keyword` or `title.function`, or null for plain text.
  String? scopeAt(int index) {
    final scope = _scopes[index];
    return scope < 0 ? null : _names[scope];
  }

  /// Returns the code colored with [palette] on top of [style] (whose
  /// color is replaced by the palette foreground), drawn the same as
  /// [Oito2Highlighter.highlight] draws it.
  ///
  /// The span is flat: one child per run, each with its scope style or
  /// none, under a parent with the base style.
  TextSpan toSpan({required Oito2SyntaxPalette palette, TextStyle? style}) {
    final base = (style ?? const TextStyle()).copyWith(
      color: palette.foreground,
    );
    if (length == 0) return TextSpan(text: code, style: base);
    final theme = Oito2Highlighter._themeFor(palette);
    final styles = [for (final name in _names) theme[name]];
    return TextSpan(
      style: base,
      children: [
        for (var i = 0; i < length; i++)
          TextSpan(
            text: textAt(i),
            style: _scopes[i] < 0 ? null : styles[_scopes[i]],
          ),
      ],
    );
  }
}

/// Walks a `re_highlight` token tree into the runs of
/// [Oito2HighlightTokens], joining neighboring runs of the same scope.
class _TokenCollector implements HighlightRenderer {
  final _ends = <int>[];
  final _scopes = <int>[];
  final _names = <String>[];
  final _indexOf = <String, int>{};
  final _open = <String?>[];
  int _offset = 0;

  @override
  void addText(String text) {
    if (text.isEmpty) return;
    final name = _open.isEmpty ? null : _open.last;
    final scope = name == null
        ? -1
        : _indexOf.putIfAbsent(name, () {
            _names.add(name);
            return _names.length - 1;
          });
    _offset += text.length;
    if (_scopes.isNotEmpty && _scopes.last == scope) {
      _ends.last = _offset;
    } else {
      _ends.add(_offset);
      _scopes.add(scope);
    }
  }

  @override
  void openNode(DataNode node) => _open.add(node.scope);

  @override
  void closeNode(DataNode node) => _open.removeLast();

  /// Returns the collected runs of [code], or a single plain run when the
  /// tree doesn't cover [code] exactly.
  Oito2HighlightTokens finish(String code) {
    if (_offset != code.length) {
      return Oito2HighlightTokens._(
        code,
        Int32List.fromList([if (code.isNotEmpty) code.length]),
        Int32List.fromList([if (code.isNotEmpty) -1]),
        const [],
      );
    }
    return Oito2HighlightTokens._(
      code,
      Int32List.fromList(_ends),
      Int32List.fromList(_scopes),
      List.unmodifiable(_names),
    );
  }
}
