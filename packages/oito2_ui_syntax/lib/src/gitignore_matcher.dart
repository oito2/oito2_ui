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

/// One rule of a gitignore file, as parsed by
/// [Oito2GitignoreMatcher.parse].
@immutable
class Oito2GitignoreRule {
  const Oito2GitignoreRule._(
    this._regex, {
    required this.line,
    required this.pattern,
    required this.negated,
    required this.directoryOnly,
    required this.anchored,
  });

  /// Returns the rule written on [line] as [raw], or null for a blank
  /// line or a comment.
  ///
  /// With [ignoreCase], letters match in any case.
  static Oito2GitignoreRule? _parse(
    int line,
    String raw, {
    required bool ignoreCase,
  }) {
    final written = trimTrailingSpaces(raw);
    if (written.isEmpty || written.startsWith('#')) return null;
    var text = written;
    final negated = text.startsWith('!');
    if (negated) text = text.substring(1);
    final directoryOnly = text.endsWith('/');
    if (directoryOnly) text = text.substring(0, text.length - 1);
    final anchored = text.contains('/');
    if (text.startsWith('/')) text = text.substring(1);
    final source = text.isEmpty ? null : _globToRegExp(text);
    return Oito2GitignoreRule._(
      source == null
          ? null
          : RegExp(
              '^${anchored ? '' : '(?:.*/)?'}$source\$',
              caseSensitive: !ignoreCase,
            ),
      line: line,
      pattern: written,
      negated: negated,
      directoryOnly: directoryOnly,
      anchored: anchored,
    );
  }

  /// The line of the rule in the gitignore text, counted from 1.
  final int line;

  /// The rule as written, without its unescaped trailing spaces, such as
  /// `!release.log` or `/build/`.
  final String pattern;

  /// Whether the rule starts with `!` and re-includes what it matches.
  final bool negated;

  /// Whether the rule ends with `/` and matches only directories.
  final bool directoryOnly;

  /// Whether the rule has a `/` at its start or in its middle and matches
  /// only paths relative to the gitignore file's directory; otherwise it
  /// matches a name at any depth.
  final bool anchored;

  final RegExp? _regex;

  /// Whether the pattern is well formed; a rule with an unclosed `[` or a
  /// trailing lone backslash matches nothing, as in git.
  bool get isValid => _regex != null;

  /// Returns whether the rule matches [path], a slash-separated path
  /// relative to the gitignore file's directory, which is a directory
  /// when [isDirectory].
  ///
  /// Only the path itself is compared: [Oito2GitignoreMatcher.match] also
  /// looks at the directories that hold it.
  bool matches(String path, {bool isDirectory = false}) =>
      (!directoryOnly || isDirectory) && (_regex?.hasMatch(path) ?? false);

  /// Returns [line] without its trailing spaces, keeping a space escaped
  /// with a backslash and dropping a carriage return.
  static String trimTrailingSpaces(String line) {
    var text = line.endsWith('\r') ? line.substring(0, line.length - 1) : line;
    var end = text.length;
    while (end > 0 && text[end - 1] == ' ') {
      var slashes = 0;
      while (end - 2 - slashes >= 0 && text[end - 2 - slashes] == r'\') {
        slashes++;
      }
      // An odd number of backslashes escapes the space.
      if (slashes.isOdd) break;
      end--;
    }
    return text.substring(0, end);
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2GitignoreRule &&
      other.line == line &&
      other.pattern == pattern &&
      other.negated == negated &&
      other.directoryOnly == directoryOnly &&
      other.anchored == anchored &&
      other._regex?.pattern == _regex?.pattern &&
      other._regex?.isCaseSensitive == _regex?.isCaseSensitive;

  @override
  int get hashCode => Object.hash(line, pattern, negated, directoryOnly);

  @override
  String toString() => 'Oito2GitignoreRule($line, $pattern)';
}

/// The rule that decides whether a path is ignored, returned by
/// [Oito2GitignoreMatcher.match].
@immutable
class Oito2GitignoreMatch {
  /// Creates a match of [rule] on [path].
  const Oito2GitignoreMatch(this.rule, this.path);

  /// The last rule that matches [path].
  final Oito2GitignoreRule rule;

  /// The path [rule] matches: the path asked about, or a directory that
  /// holds it and is ignored, since nothing inside an ignored directory
  /// can be re-included.
  final String path;

  /// Whether the path asked about is ignored: false when [rule] is a
  /// negated rule that re-includes it.
  bool get isIgnored => !rule.negated;

  @override
  bool operator ==(Object other) =>
      other is Oito2GitignoreMatch && other.rule == rule && other.path == path;

  @override
  int get hashCode => Object.hash(rule, path);

  @override
  String toString() => 'Oito2GitignoreMatch(${rule.line}, $path)';
}

/// Tells whether paths are ignored by the rules of a gitignore file,
/// following git's documented semantics.
///
/// [parse] reads the rules: blank lines and lines starting with `#` are
/// skipped; trailing spaces are dropped unless escaped with a backslash;
/// a leading `!` negates the rule, and a backslash makes `#` and `!`
/// literal; a trailing `/` matches only directories; a `/` at the start
/// or in the middle anchors the rule to the gitignore file's directory,
/// otherwise it matches a name at any depth. In a pattern, `*` matches
/// anything but `/`, `?` one character but `/`, and `[...]` one character
/// of a class with ranges, `!` or `^` negation and POSIX classes such as
/// `[:digit:]`. A leading `**/` matches in all directories, a trailing
/// `/**` everything inside, and a middle `/**/` zero or more directories;
/// other runs of asterisks act as `*`.
///
/// [match] finds the rule that decides a path: the last matching rule
/// wins, and a file inside an ignored directory can't be re-included.
@immutable
class Oito2GitignoreMatcher {
  /// Creates a matcher with [rules], in the order they were written.
  Oito2GitignoreMatcher(Iterable<Oito2GitignoreRule> rules)
    : rules = List.unmodifiable(rules);

  /// Returns a matcher with the rules written in [text], one a line.
  ///
  /// With [ignoreCase], letters match in any case, as with git's
  /// `core.ignoreCase`.
  factory Oito2GitignoreMatcher.parse(String text, {bool ignoreCase = false}) {
    final lines = text.split('\n');
    if (lines.first.startsWith('﻿')) {
      lines.first = lines.first.substring(1);
    }
    return Oito2GitignoreMatcher([
      for (var i = 0; i < lines.length; i++)
        ?Oito2GitignoreRule._parse(i + 1, lines[i], ignoreCase: ignoreCase),
    ]);
  }

  /// The rules, in the order they were written, without blank lines and
  /// comments.
  final List<Oito2GitignoreRule> rules;

  /// Returns the rule that decides whether [path] is ignored, or null when
  /// no rule matches it.
  ///
  /// [path] is slash-separated and relative to the gitignore file's
  /// directory; it is a directory when [isDirectory] or when it ends with
  /// `/`. The directories that hold it are checked first, from the
  /// outermost: when one is ignored, the result is its rule and its
  /// [Oito2GitignoreMatch.path].
  Oito2GitignoreMatch? match(String path, {bool isDirectory = false}) {
    final directory = isDirectory || path.endsWith('/');
    final parts = path.split('/').where((part) => part.isNotEmpty).toList();
    if (parts.isNotEmpty && parts.first == '.') parts.removeAt(0);
    for (var depth = 1; depth <= parts.length; depth++) {
      final sub = parts.take(depth).join('/');
      final last = depth == parts.length;
      final rule = _lastMatch(sub, isDirectory: !last || directory);
      if (rule == null) continue;
      if (last || !rule.negated) return Oito2GitignoreMatch(rule, sub);
    }
    return null;
  }

  /// Returns whether [path] is ignored, as decided by [match].
  bool isIgnored(String path, {bool isDirectory = false}) =>
      match(path, isDirectory: isDirectory)?.isIgnored ?? false;

  /// Returns the last rule that matches [path] itself, or null.
  Oito2GitignoreRule? _lastMatch(String path, {required bool isDirectory}) {
    for (var i = rules.length - 1; i >= 0; i--) {
      if (rules[i].matches(path, isDirectory: isDirectory)) return rules[i];
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2GitignoreMatcher && listEquals(other.rules, rules);

  @override
  int get hashCode => Object.hashAll(rules);
}

/// The POSIX character classes a bracket expression may hold, as regular
/// expression class bodies.
const _posixClasses = {
  'alnum': 'a-zA-Z0-9',
  'alpha': 'a-zA-Z',
  'blank': r' \t',
  'cntrl': r'\x00-\x1f\x7f',
  'digit': '0-9',
  'graph': r'\x21-\x7e',
  'lower': 'a-z',
  'print': r'\x20-\x7e',
  'punct': r'!-\/:-@\[-`{-~',
  'space': r' \t\n\r\f\v',
  'upper': 'A-Z',
  'xdigit': '0-9a-fA-F',
};

/// Returns [c] escaped for use inside a regular expression class.
String _classChar(String c) => r'\]^-['.contains(c) ? '\\$c' : RegExp.escape(c);

/// Returns [glob] as a regular expression source, or null when it has an
/// unclosed `[`, an unknown POSIX class or a trailing lone backslash.
String? _globToRegExp(String glob) {
  final out = StringBuffer();
  var i = 0;
  while (i < glob.length) {
    final c = glob[i];
    if (c == r'\') {
      if (i + 1 == glob.length) return null;
      out.write(RegExp.escape(glob[i + 1]));
      i += 2;
    } else if (c == '*') {
      var end = i;
      while (end < glob.length && glob[end] == '*') {
        end++;
      }
      final atStart = i == 0 || glob[i - 1] == '/';
      final atEnd = end == glob.length || glob[end] == '/';
      if (end - i == 2 && atStart && atEnd) {
        if (end == glob.length) {
          // A trailing "**" matches everything inside.
          out.write('.*');
          i = end;
        } else {
          // "**/" matches zero or more directories.
          out.write('(?:.*/)?');
          i = end + 1;
        }
      } else {
        out.write('[^/]*');
        i = end;
      }
    } else if (c == '?') {
      out.write('[^/]');
      i++;
    } else if (c == '[') {
      final parsed = _bracket(glob, i);
      if (parsed == null) return null;
      out.write(parsed.source);
      i = parsed.end;
    } else {
      out.write(RegExp.escape(c));
      i++;
    }
  }
  return out.toString();
}

/// Returns the bracket expression of [glob] that opens at [start] as a
/// regular expression that never matches `/`, with the index after its
/// closing `]`, or null when it is unclosed or names an unknown POSIX
/// class.
({String source, int end})? _bracket(String glob, int start) {
  var i = start + 1;
  var negated = false;
  if (i < glob.length && (glob[i] == '!' || glob[i] == '^')) {
    negated = true;
    i++;
  }
  final body = StringBuffer();
  var first = true;
  while (i < glob.length) {
    var c = glob[i];
    if (c == ']' && !first) {
      final source = negated ? '[^/$body]' : '(?!/)[$body]';
      return (source: source, end: i + 1);
    }
    first = false;
    if (c == '[' && i + 1 < glob.length && glob[i + 1] == ':') {
      final close = glob.indexOf(':]', i + 2);
      if (close < 0) return null;
      final name = _posixClasses[glob.substring(i + 2, close)];
      if (name == null) return null;
      body.write(name);
      i = close + 2;
      continue;
    }
    if (c == r'\') {
      if (i + 1 == glob.length) return null;
      i++;
      c = glob[i];
    }
    i++;
    if (i + 1 < glob.length && glob[i] == '-' && glob[i + 1] != ']') {
      var to = glob[i + 1];
      i += 2;
      if (to == r'\') {
        if (i == glob.length) return null;
        to = glob[i];
        i++;
      }
      if (to.codeUnitAt(0) < c.codeUnitAt(0)) continue;
      body.write('${_classChar(c)}-${_classChar(to)}');
    } else {
      body.write(_classChar(c));
    }
  }
  return null;
}
