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

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';

/// Returns whether [path] is ignored by the rules in [text]; a path
/// ending in `/` is a directory.
bool _ignored(String text, String path, {bool ignoreCase = false}) =>
    Oito2GitignoreMatcher.parse(text, ignoreCase: ignoreCase).isIgnored(path);

/// Returns the only rule written in [pattern].
Oito2GitignoreRule _rule(String pattern) =>
    Oito2GitignoreMatcher.parse(pattern).rules.single;

void main() {
  group('Oito2GitignoreMatcher.parse', () {
    test('skips blank lines and comments and numbers lines from 1', () {
      final matcher = Oito2GitignoreMatcher.parse(
        '# comment\n\n*.log\n   \n!keep.log\r\n',
      );
      expect([for (final r in matcher.rules) r.line], [3, 5]);
      expect(
        [for (final r in matcher.rules) r.pattern],
        ['*.log', '!keep.log'],
      );
      expect(matcher.rules[1].negated, isTrue);
      expect(matcher.rules[0].negated, isFalse);
    });

    test('drops trailing spaces unless escaped', () {
      expect(_rule('dist   ').pattern, 'dist');
      expect(_rule(r'name\ ').pattern, r'name\ ');
      expect(_rule(r'name\  ').pattern, r'name\ ');
      expect(_rule(r'name\\ ').pattern, r'name\\');
      expect(_ignored(r'name\ ', 'name '), isTrue);
      expect(_ignored(r'name\ ', 'name'), isFalse);
      expect(_ignored('name ', 'name'), isTrue);
    });

    test('a backslash makes "#" and "!" literal', () {
      expect(_ignored(r'\#notes#', '#notes#'), isTrue);
      expect(_rule(r'\!important').negated, isFalse);
      expect(_ignored(r'\!important', '!important'), isTrue);
      expect(_ignored(r'\!important', 'important'), isFalse);
    });

    test('reads anchoring and directory slashes', () {
      expect(_rule('foo').anchored, isFalse);
      expect(_rule('foo/').anchored, isFalse);
      expect(_rule('foo/').directoryOnly, isTrue);
      expect(_rule('/foo').anchored, isTrue);
      expect(_rule('doc/frotz').anchored, isTrue);
      expect(_rule('**/foo').anchored, isTrue);
    });

    test('a pattern with an unclosed bracket or trailing backslash is '
        'invalid and matches nothing', () {
      for (final pattern in ['cache[0-9.tmp', r'foo\', '[[:nope:]]']) {
        final rule = _rule(pattern);
        expect(rule.isValid, isFalse, reason: pattern);
        expect(rule.matches('cache1.tmp'), isFalse);
      }
      expect(_rule('a[0-9]').isValid, isTrue);
    });

    test('trimTrailingSpaces keeps escaped spaces', () {
      expect(Oito2GitignoreRule.trimTrailingSpaces('a  '), 'a');
      expect(Oito2GitignoreRule.trimTrailingSpaces('a\r'), 'a');
      expect(Oito2GitignoreRule.trimTrailingSpaces(r'a\  '), r'a\ ');
    });
  });

  group('patterns from the git documentation', () {
    test('"hello.*" matches any file or directory named hello.*', () {
      expect(_ignored('hello.*', 'hello.txt'), isTrue);
      expect(_ignored('hello.*', 'a/b/hello.c'), isTrue);
      expect(_ignored('hello.*', 'hello'), isFalse);
    });

    test('"foo/" matches a directory foo and paths beneath it', () {
      expect(_ignored('foo/', 'foo/'), isTrue);
      expect(_ignored('foo/', 'a/foo/'), isTrue);
      expect(_ignored('foo/', 'foo/bar.txt'), isTrue);
      expect(_ignored('foo/', 'foo'), isFalse);
    });

    test('"doc/frotz/" is anchored, "frotz/" is not', () {
      expect(_ignored('doc/frotz/', 'doc/frotz/'), isTrue);
      expect(_ignored('doc/frotz/', 'a/doc/frotz/'), isFalse);
      expect(_ignored('frotz/', 'frotz/'), isTrue);
      expect(_ignored('frotz/', 'a/frotz/'), isTrue);
    });

    test('"doc/frotz" and "/doc/frotz" have the same effect', () {
      for (final pattern in ['doc/frotz', '/doc/frotz']) {
        expect(_ignored(pattern, 'doc/frotz'), isTrue);
        expect(_ignored(pattern, 'a/doc/frotz'), isFalse);
      }
      expect(_ignored('/foo', 'foo'), isTrue);
      expect(_ignored('/foo', 'a/foo'), isFalse);
    });

    test('"foo/*" matches one level below foo', () {
      final rule = _rule('foo/*');
      expect(rule.matches('foo/test.json'), isTrue);
      expect(rule.matches('foo/bar', isDirectory: true), isTrue);
      expect(rule.matches('foo/bar/hello.c'), isFalse);
      // The file is still ignored because its directory is.
      final match = Oito2GitignoreMatcher.parse('foo/*')
          .match('foo/bar/hello.c');
      expect(match?.path, 'foo/bar');
      expect(match?.isIgnored, isTrue);
    });

    test('"*" and "?" do not match a slash', () {
      expect(_rule('a*c').matches('ab/c'), isFalse);
      expect(_rule('a?c').matches('abc'), isTrue);
      expect(_rule('a?c').matches('a/c'), isFalse);
    });

    test('a leading "**/" matches in all directories', () {
      expect(_ignored('**/foo', 'foo'), isTrue);
      expect(_ignored('**/foo', 'a/b/foo'), isTrue);
      expect(_ignored('**/foo/bar', 'foo/bar'), isTrue);
      expect(_ignored('**/foo/bar', 'x/foo/bar'), isTrue);
      expect(_ignored('**/foo/bar', 'x/foo/baz'), isFalse);
    });

    test('a trailing "/**" matches everything inside', () {
      expect(_ignored('abc/**', 'abc/x'), isTrue);
      expect(_ignored('abc/**', 'abc/x/y/z.txt'), isTrue);
      expect(_rule('abc/**').matches('abc', isDirectory: true), isFalse);
      expect(_ignored('abc/**', 'x/abc/y'), isFalse);
    });

    test('a middle "/**/" matches zero or more directories', () {
      for (final path in ['a/b', 'a/x/b', 'a/x/y/b']) {
        expect(_ignored('a/**/b', path), isTrue, reason: path);
      }
      expect(_ignored('a/**/b', 'a/bc'), isFalse);
    });

    test('other runs of asterisks act as a single asterisk', () {
      expect(_rule('a**b').matches('axyb'), isTrue);
      expect(_rule('a**b').matches('ax/yb'), isFalse);
      expect(_rule('***/x').matches('a/x'), isTrue);
      expect(_rule('***/x').matches('a/b/x'), isFalse);
    });

    test('excludes everything except the directory foo/bar', () {
      const rules = '/*\n!/foo\n/foo/*\n!/foo/bar\n';
      expect(_ignored(rules, 'foo/bar/file.txt'), isFalse);
      expect(_ignored(rules, 'foo/bar/'), isFalse);
      expect(_ignored(rules, 'foo/baz.txt'), isTrue);
      expect(_ignored(rules, 'top.txt'), isTrue);
      expect(_ignored(rules, 'foo/'), isFalse);
    });
  });

  group('Oito2GitignoreMatcher.match', () {
    test('the last matching rule wins', () {
      final matcher = Oito2GitignoreMatcher.parse('*.html\n!foo.html\n');
      expect(matcher.isIgnored('bar.html'), isTrue);
      expect(matcher.isIgnored('foo.html'), isFalse);
      final match = matcher.match('foo.html')!;
      expect(match.rule.line, 2);
      expect(match.rule.pattern, '!foo.html');
      expect(match.isIgnored, isFalse);
      expect(matcher.match('readme.md'), isNull);
    });

    test('a file in an ignored directory cannot be re-included', () {
      final matcher = Oito2GitignoreMatcher.parse('build/\n!build/keep.txt\n');
      final match = matcher.match('build/keep.txt')!;
      expect(match.isIgnored, isTrue);
      expect(match.path, 'build');
      expect(match.rule.line, 1);
    });

    test('re-includes a file when only files were excluded', () {
      final matcher = Oito2GitignoreMatcher.parse('build/*\n!build/keep.txt');
      expect(matcher.isIgnored('build/keep.txt'), isFalse);
      expect(matcher.isIgnored('build/out.o'), isTrue);
    });

    test('directory-only rules need isDirectory or a trailing slash', () {
      final matcher = Oito2GitignoreMatcher.parse('logs/');
      expect(matcher.isIgnored('logs'), isFalse);
      expect(matcher.isIgnored('logs', isDirectory: true), isTrue);
      expect(matcher.isIgnored('logs/'), isTrue);
      expect(matcher.isIgnored('logs/today.txt'), isTrue);
    });

    test('accepts a leading "./" and repeated slashes', () {
      final matcher = Oito2GitignoreMatcher.parse('/build');
      expect(matcher.isIgnored('./build'), isTrue);
      expect(matcher.isIgnored('build//x'), isTrue);
      expect(matcher.isIgnored(''), isFalse);
    });

    test('matches letters in any case with ignoreCase', () {
      expect(_ignored('*.LOG', 'a.log'), isFalse);
      expect(_ignored('*.LOG', 'a.log', ignoreCase: true), isTrue);
    });
  });

  group('robustness', () {
    test('drops a leading byte order mark', () {
      final matcher = Oito2GitignoreMatcher.parse('\u{FEFF}build/');
      expect(matcher.rules.single.pattern, 'build/');
      expect(matcher.isIgnored('build/'), isTrue);
    });

    test('patterns with many asterisks take time linear in the path', () {
      final matcher = Oito2GitignoreMatcher.parse(
        '${'*a' * 6}b\n'
        '**/a/**/a/**/a/**/a/**/b\n',
      );
      expect(matcher.isIgnored('a' * 200), isFalse);
      expect(matcher.isIgnored(List.filled(200, 'a').join('/')), isFalse);
      expect(matcher.isIgnored('${'a' * 200}b'), isTrue);
      expect(matcher.isIgnored('${List.filled(200, 'a').join('/')}/b'), isTrue);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('a line break in a name is an ordinary character', () {
      expect(_ignored('foo', 'a\nb/foo'), isTrue);
      expect(_ignored('a/**', 'a/b\nc'), isTrue);
      expect(_ignored('a?b', 'a\nb'), isTrue);
    });
  });

  group('bracket expressions', () {
    test('match ranges and lists', () {
      final rule = _rule('file[0-9a].txt');
      expect(rule.matches('file7.txt'), isTrue);
      expect(rule.matches('filea.txt'), isTrue);
      expect(rule.matches('fileb.txt'), isFalse);
    });

    test('negate with "!" or "^"', () {
      for (final pattern in ['[!a]*.c', '[^a]*.c']) {
        final rule = _rule(pattern);
        expect(rule.matches('b.c'), isTrue, reason: pattern);
        expect(rule.matches('a.c'), isFalse, reason: pattern);
      }
    });

    test('never match a slash', () {
      expect(_rule('a[/]b').matches('a/b'), isFalse);
      expect(_rule('a[!x]b').matches('a/b'), isFalse);
    });

    test('take a leading "]", a trailing "-" and escapes literally', () {
      expect(_rule('[]]x').matches(']x'), isTrue);
      expect(_rule('[a-]x').matches('-x'), isTrue);
      expect(_rule('[a-]x').matches('ax'), isTrue);
      expect(_rule(r'[\]]x').matches(']x'), isTrue);
      expect(_rule('[^]]x').matches('ax'), isTrue);
      expect(_rule('[^]]x').matches(']x'), isFalse);
    });

    test('support POSIX classes', () {
      final rule = _rule('v[[:digit:]][[:alpha:]]');
      expect(rule.matches('v1a'), isTrue);
      expect(rule.matches('vaa'), isFalse);
    });
  });
}
