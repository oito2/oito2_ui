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

/// The languages [Oito2Highlighter] registers by default, keyed by name.
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

  /// A shared highlighter with the default languages.
  static final Oito2Highlighter instance = Oito2Highlighter();

  /// Returns [code] highlighted as [language] with [palette], on top of
  /// [style] (whose color is replaced by the palette foreground).
  ///
  /// When [language] isn't registered, or is null and [autoDetect] is
  /// false, the code is returned unhighlighted in the foreground color.
  /// With [autoDetect], a null [language] is guessed among the registered
  /// ones.
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
    if (language != null && languages.contains(language)) {
      result = _highlight.highlight(code: code, language: language);
    } else if (language == null && autoDetect) {
      result = _highlight.highlightAuto(code);
    } else {
      return TextSpan(text: code, style: base);
    }
    final renderer = TextSpanRenderer(
      base,
      Oito2HighlighterTheme.fromPalette(palette),
    );
    result.render(renderer);
    return renderer.span ?? TextSpan(text: code, style: base);
  }
}
