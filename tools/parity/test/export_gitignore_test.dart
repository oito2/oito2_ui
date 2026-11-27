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

// Writes how Oito2GitignoreMatcher reads fixed gitignore texts and which
// rule decides each of a set of paths, as a JSON fixture.

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';

import 'support.dart';

/// A path asked about: its text and whether it is a directory.
typedef Query = (String path, bool isDirectory);

/// A gitignore text, whether it ignores the case, and the paths matched
/// against it.
typedef RuleSet = ({
  String name,
  String text,
  bool ignoreCase,
  List<Query> paths,
});

final ruleSets = <RuleSet>[
  (
    name: 'git documentation: hello.* and doc/frotz/',
    text: 'hello.*\ndoc/frotz/\nfrotz/\n',
    ignoreCase: false,
    paths: [
      ('hello.txt', false),
      ('src/hello.c', false),
      ('hello', false),
      ('doc/frotz', true),
      ('doc/frotz', false),
      ('a/doc/frotz', true),
      ('frotz', true),
      ('a/frotz', true),
      ('a/frotz/file', false),
    ],
  ),
  (
    name: 'git documentation: foo/* matches only direct children',
    text: 'foo/*\n',
    ignoreCase: false,
    paths: [
      ('foo/test.json', false),
      ('foo/bar', true),
      ('foo/bar/hello.c', false),
      ('a/foo/test.json', false),
      ('foo', true),
    ],
  ),
  (
    name: 'git documentation: exclude everything except foo/bar',
    text:
        '# exclude everything except directory foo/bar\n'
        '/*\n'
        '!/foo\n'
        '/foo/*\n'
        '!/foo/bar\n',
    ignoreCase: false,
    paths: [
      ('README.md', false),
      ('src', true),
      ('src/main.c', false),
      ('foo', true),
      ('foo/baz', false),
      ('foo/qux', true),
      ('foo/qux/file', false),
      ('foo/bar', true),
      ('foo/bar/file', false),
    ],
  ),
  (
    name: 'git documentation: objects, archives and Documentation/*.html',
    text:
        '# ignore objects and archives, anywhere in the tree.\n'
        '*.[oa]\n'
        '\n'
        'Documentation/*.html\n'
        '!Documentation/foo.html\n',
    ignoreCase: false,
    paths: [
      ('main.o', false),
      ('lib/libz.a', false),
      ('main.c', false),
      ('Documentation/git.html', false),
      ('Documentation/foo.html', false),
      ('Documentation/ppc/ppc.html', false),
      ('tools/Documentation/git.html', false),
    ],
  ),
  (
    name: 'double asterisks',
    text:
        '**/logs\n'
        '**/cache/tmp\n'
        'abc/**\n'
        'a/**/b\n'
        'x**y\n'
        '/**/deep.txt\n',
    ignoreCase: false,
    paths: [
      ('logs', true),
      ('src/logs', true),
      ('src/logs/today.log', false),
      ('cache/tmp', false),
      ('src/cache/tmp', true),
      ('abc', true),
      ('abc/file', false),
      ('abc/sub/file', false),
      ('a/b', false),
      ('a/x/b', false),
      ('a/x/y/b', false),
      ('z/a/b', false),
      ('xay', false),
      ('xa/by', false),
      ('deep.txt', false),
      ('one/two/deep.txt', false),
    ],
  ),
  (
    name: 'anchoring and directory-only rules',
    text:
        '/build\n'
        'out/\n'
        'src/gen\n'
        '/dist/\n'
        'node_modules\n',
    ignoreCase: false,
    paths: [
      ('build', true),
      ('build', false),
      ('app/build', true),
      ('out', true),
      ('out', false),
      ('app/out', true),
      ('app/out/a.js', false),
      ('src/gen', true),
      ('app/src/gen', true),
      ('dist', true),
      ('dist', false),
      ('dist/', false),
      ('./dist/app.js', false),
      ('node_modules', true),
      ('a/b/node_modules/x/index.js', false),
    ],
  ),
  (
    name: 'negation',
    text:
        '*.log\n'
        '!important.log\n'
        'logs/\n'
        '!logs/keep.log\n'
        'tmp/*\n'
        '!tmp/.gitkeep\n',
    ignoreCase: false,
    paths: [
      ('debug.log', false),
      ('important.log', false),
      ('sub/important.log', false),
      ('logs', true),
      ('logs/keep.log', false),
      ('logs/other.txt', false),
      ('tmp/file', false),
      ('tmp/.gitkeep', false),
      ('readme.md', false),
    ],
  ),
  (
    name: 'character classes',
    text:
        'file[0-9].txt\n'
        '[!a]*.bak\n'
        '[^b]*.old\n'
        '[[:digit:]][[:upper:]].dat\n'
        '[a-]x\n'
        '[]]y\n'
        'r[z-a]\n'
        'q[[:alpha:][:digit:]]\n'
        's[/]t\n',
    ignoreCase: false,
    paths: [
      ('file1.txt', false),
      ('fileA.txt', false),
      ('b.bak', false),
      ('a.bak', false),
      ('a.old', false),
      ('b.old', false),
      ('1A.dat', false),
      ('1a.dat', false),
      ('ax', false),
      ('-x', false),
      ('bx', false),
      (']y', false),
      ('rz', false),
      ('qx', false),
      ('q5', false),
      ('q-', false),
      ('s/t', false),
    ],
  ),
  (
    name: 'escapes, comments and trailing spaces',
    text:
        '# a comment\n'
        r'\#hash'
        '\n'
        r'\!bang'
        '\n'
        r'star\*'
        '\n'
        'question\\?\n'
        'trailing   \n'
        'kept\\ \n'
        'two\\\\  \n'
        '  leading\n',
    ignoreCase: false,
    paths: [
      ('# a comment', false),
      ('#hash', false),
      ('!bang', false),
      ('star*', false),
      ('starx', false),
      ('question?', false),
      ('questionx', false),
      ('trailing', false),
      ('trailing   ', false),
      ('kept ', false),
      ('kept', false),
      (r'two\', false),
      ('  leading', false),
      ('leading', false),
    ],
  ),
  (
    name: 'invalid rules match nothing',
    text:
        '[unclosed\n'
        'end\\\n'
        '[[:nope:]]\n'
        '[[:digit:\n'
        '/\n'
        '!\n'
        'valid\n',
    ignoreCase: false,
    paths: [
      ('[unclosed', false),
      ('unclosed', false),
      ('end', false),
      (r'end\', false),
      ('n', false),
      ('valid', false),
    ],
  ),
  (
    name: 'carriage returns and a byte order mark',
    text: '\u{FEFF}*.tmp\r\n!keep.tmp\r\nbin/\r\n',
    ignoreCase: false,
    paths: [
      ('a.tmp', false),
      ('keep.tmp', false),
      ('bin', true),
      ('bin/tool', false),
    ],
  ),
  (
    name: 'ignoring the case',
    text: '*.LOG\nBuild/\n!Keep.log\n[A-C]x\n',
    ignoreCase: true,
    paths: [
      ('debug.log', false),
      ('DEBUG.Log', false),
      ('keep.LOG', false),
      ('build', true),
      ('BUILD/out', false),
      ('bx', false),
      ('Bx', false),
      ('dx', false),
    ],
  ),
  (
    name: 'pathological patterns take linear time',
    text:
        '*a*a*a*a*a*b\n'
        '**/a/**/a/**/a/**/a/**/b\n'
        '*x*x*x*x*x*x*x*x*x*x*y/\n',
    ignoreCase: false,
    paths: [
      (longName, false),
      ('${longName}b', false),
      (deepPath, false),
      ('$deepPath/b', false),
      ('${'x' * 120}y', true),
      ('${'x' * 120}y', false),
      ('${'x' * 120}z', true),
    ],
  ),
];

/// A name of 200 "a" characters.
final longName = 'a' * 200;

/// A path of 200 directories named "a".
final deepPath = List.filled(200, 'a').join('/');

/// Lines whose trailing spaces [Oito2GitignoreRule.trimTrailingSpaces]
/// drops.
const trimCases = [
  '',
  'plain',
  'spaces   ',
  'escaped\\ ',
  'escaped\\  ',
  'double\\\\ ',
  'triple\\\\\\ ',
  'tab\t',
  'crlf \r',
  '   ',
];

/// Returns the fields of [rule] as a JSON object.
Map<String, Object> exportRule(Oito2GitignoreRule rule) => {
  'line': rule.line,
  'pattern': rule.pattern,
  'negated': rule.negated,
  'directoryOnly': rule.directoryOnly,
  'anchored': rule.anchored,
  'isValid': rule.isValid,
};

/// Returns the rules of [set] and the decision for each of its paths.
Map<String, Object?> exportSet(RuleSet set) {
  final matcher = Oito2GitignoreMatcher.parse(
    set.text,
    ignoreCase: set.ignoreCase,
  );
  return {
    'name': set.name,
    'text': set.text,
    'ignoreCase': set.ignoreCase,
    'rules': [for (final rule in matcher.rules) exportRule(rule)],
    'paths': [
      for (final (path, isDirectory) in set.paths)
        () {
          final match = matcher.match(path, isDirectory: isDirectory);
          return {
            'path': path,
            'isDirectory': isDirectory,
            'isIgnored': matcher.isIgnored(path, isDirectory: isDirectory),
            'match': match == null
                ? null
                : {
                    'line': match.rule.line,
                    'pattern': match.rule.pattern,
                    'negated': match.rule.negated,
                    'path': match.path,
                  },
          };
        }(),
    ],
  };
}

void main() {
  test('exports the gitignore decisions', () {
    final file = writeFixture('gitignore.json', {
      'trimTrailingSpaces': [
        for (final line in trimCases)
          {'line': line, 'result': Oito2GitignoreRule.trimTrailingSpaces(line)},
      ],
      'ruleSets': [for (final set in ruleSets) exportSet(set)],
    });
    expect(file.existsSync(), isTrue);
  });
}
