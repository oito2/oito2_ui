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

import 'package:re_highlight/re_highlight.dart';

/// The grammar of gitignore files, also registered for the `ignore` and
/// `dockerignore` aliases of the same pattern syntax.
///
/// Scopes, all single-word so editors that keep only the first segment of
/// a scope color them the same:
///
/// * `comment`: a line starting with `#`.
/// * `keyword`: the negation `!` at the start of a pattern, the leading
///   `/` that anchors it to the root and the trailing `/` that limits it
///   to directories.
/// * `meta`: the wildcards `**`, `*` and `?`.
/// * `regexp`: a character class such as `[a-z]` or `[!0-9]`.
/// * `symbol`: an escaped character such as `\#`, `\!`, `\ ` or `\*`.
/// * `deletion`: unescaped trailing spaces, which git ignores.
///
/// Every mode has zero relevance and auto-detection is off, so the
/// grammar is used only when asked for by name.
final Mode langGitignore = Mode(
  name: 'gitignore',
  aliases: ['ignore', 'dockerignore'],
  disableAutodetect: true,
  contains: <Mode>[
    Mode(scope: 'comment', begin: r'^#', end: r'$', relevance: 0),
    Mode(scope: 'keyword', begin: r'^!', relevance: 0),
    Mode(scope: 'symbol', begin: r'\\.', relevance: 0),
    Mode(scope: 'keyword', begin: r'(?:^|(?<=^!))/', relevance: 0),
    Mode(scope: 'keyword', begin: r'/(?=[ \t]*$)', relevance: 0),
    Mode(
      scope: 'regexp',
      begin: r'\[(?=[^\]\n]*\])',
      end: r'\]',
      contains: <Mode>[Mode(scope: 'symbol', begin: r'\\.', relevance: 0)],
      relevance: 0,
    ),
    Mode(scope: 'meta', begin: r'\*\*|\*|\?', relevance: 0),
    Mode(scope: 'deletion', begin: r'[ \t]+$', relevance: 0),
  ],
);
