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

// Writes how oito2_ui_syntax tokenizes a fixed sample of every default
// language: the code, then each run of text with the scope of the token
// node that directly holds it and the palette role that scope maps to, as
// a JSON fixture for the sibling implementations.

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';
import 'package:re_highlight/re_highlight.dart';

import 'support.dart';

/// A sample of every default language, exercising its main token kinds.
const samples = <String, String>{
  'bash': r'''
#!/bin/bash
# Greets everyone
NAME="world"
for i in 1 2 3; do
  echo "Hello, $NAME #$i" > /dev/null
done
if [ -f ~/.bashrc ]; then source ~/.bashrc; fi
''',
  'c': r'''
#include <stdio.h>
/* Entry point */
int main(int argc, char **argv) {
  const double ratio = 0.5;
  printf("%d args\n", argc);
  return 0;
}
''',
  'cpp': r'''
#include <vector>
namespace demo {
template <typename T>
class Box : public Base {
 public:
  explicit Box(T value) : value_(value) {}
  auto get() const -> T { return value_; } // getter
 private:
  T value_ = nullptr;
};
}
''',
  'csharp': r'''
using System;
// A greeter
[Serializable]
public sealed class Greeter : IGreeter {
  public string Name { get; init; } = "world";
  public async Task<int> RunAsync() => await Task.FromResult(42);
  private bool _ready = true;
}
''',
  'css': r'''
/* Layout */
@media (min-width: 600px) {
  .card > h1#title:hover, a[href^="https"] {
    color: #3584e4;
    margin: 0 auto !important;
    font-family: "Inter", sans-serif;
  }
}
''',
  'dart': r'''
// A comment
@override
class Greeter extends Base {
  final int count = 42;
  String greet(String name) => 'Hello, $name';
  bool get ready => true;
}
''',
  'diff': r'''
diff --git a/a.txt b/a.txt
--- a/a.txt
+++ b/a.txt
@@ -1,3 +1,3 @@
 unchanged
-removed line
+added line
''',
  'dockerfile': r'''
# Build stage
FROM node:24-alpine AS build
WORKDIR /app
COPY package.json ./
RUN npm ci && npm run build
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "dist/index.js"]
''',
  'go': r'''
package main

import "fmt"

// Point is a position.
type Point struct{ X, Y int }

func (p *Point) Move(dx int) error {
	p.X += dx
	fmt.Println("moved", true, nil, 3.14)
	return nil
}
''',
  'html': r'''
<!DOCTYPE html>
<html lang="en">
<!-- A page -->
<head><style>body { color: red; }</style></head>
<body class="main" data-id='7'>
  <p>Hello &amp; welcome</p>
  <script>const x = 1;</script>
</body>
</html>
''',
  'ini': r'''
; Settings
[server]
host = "localhost"
port = 8080
enabled = true
path = /var/www
''',
  'java': r'''
package demo;
import java.util.List;
/** A greeter. */
@FunctionalInterface
public class Greeter<T> extends Base implements Runnable {
  private static final int MAX = 10;
  public String greet(String name) { return "Hi " + name; }
  @Override public void run() { if (MAX > 0L) throw new IllegalStateException(); }
}
''',
  'javascript': r'''
// Greets
import { readFile } from 'node:fs/promises';
export async function greet(name = 'world') {
  const re = /^h(i|ello)$/gi;
  let count = 0x1f + 1.5e3;
  console.log(`Hello, ${name}!`, null, undefined, true);
  return new Map([[1, 'a']]);
}
class Thing extends Base { static #secret = 1; get value() { return this.x; } }
''',
  'json': r'''
{
  "name": "oito2",
  "version": 1.5,
  "private": true,
  "tags": ["ui", null],
  "nested": { "a": -2e3 }
}
''',
  'kotlin': r'''
package demo
// A data class
@JvmInline
data class Point(val x: Int, var y: Double = 0.0) : Shape {
  fun move(dx: Int): Point = copy(x = x + dx)
  override fun toString() = "Point($x, ${y})"
}
val ok = true && null == null
''',
  'markdown': r'''
# Title

Some *emphasis*, **strong** and `code`.

- item one
- [a link](https://example.com)

> A quote

```dart
void main() {}
```
''',
  'php': r'''
<?php
namespace App;
// A controller
#[Route('/home')]
final class Home extends Controller {
  public function index(int $id = 0): string {
    $name = "user {$id}";
    return sprintf('%s', $name) ?? null;
  }
}
''',
  'plaintext': r'''
Just some plain text, with "quotes" and 42 numbers.
''',
  'python': r'''
# A comment
@dataclass
class Point(Base):
    """A point."""
    x: int = 0

    def move(self, dx: float) -> "Point":
        ready = True and None is None
        return f"moved {dx}" if ready else 0x1F
''',
  'rust': r'''
// A point
#[derive(Debug, Clone)]
pub struct Point<'a> { x: i32, name: &'a str }

impl Point<'_> {
    pub fn new(x: i32) -> Self { Self { x, name: "p" } }
}

fn main() { let v: Vec<u8> = vec![1, 2]; println!("{:?} {}", v, true); }
''',
  'scss': r'''
// Variables
$primary: #3584e4;
@mixin card($radius: 8px) { border-radius: $radius; }
.card {
  &:hover { color: darken($primary, 10%); }
  @include card(12px);
}
''',
  'shell': r'''
$ npm install --save-dev vitest
added 1 package in 2s
$ echo "done"
done
''',
  'sql': r'''
-- Active users
SELECT u.id, COUNT(*) AS total
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.active = TRUE AND u.name LIKE 'A%' AND o.total > 10.5
GROUP BY u.id
ORDER BY total DESC NULLS LAST;
''',
  'swift': r'''
import Foundation
// A shape
@MainActor
struct Circle: Shape {
  let radius: Double = 1.5
  func area() -> Double { return .pi * radius * radius }
  var label: String { "r=\(radius)" }
}
let ok = true, none: Int? = nil
''',
  'typescript': r'''
// Types
interface User { readonly id: number; name?: string }
type Id = string | number;
export enum Mode { Light = 'light', Dark = 'dark' }
export function find<T extends User>(users: T[], id: Id): T | undefined {
  return users.find((u) => u.id === id) as T;
}
@Component({ selector: 'app' }) class App { private count = 0; }
''',
  'xml': r'''
<?xml version="1.0" encoding="UTF-8"?>
<!-- Config -->
<config xmlns:x="urn:x" enabled="true">
  <item id="1">Value &lt; 10</item>
  <![CDATA[raw <text>]]>
</config>
''',
  'yaml': r'''
# Settings
name: oito2
version: 1.5
enabled: true
tags: [ui, "svelte"]
nested:
  key: &anchor value
  other: *anchor
  empty: null
''',
};

/// Collects the runs of text of a highlight result with the scope of the
/// token node that directly holds each one, as the oito2_ui_syntax text
/// span renderer colors them.
class RunCollector implements HighlightRenderer {
  final List<Map<String, Object?>> runs = [];
  final List<DataNode> _stack = [];

  @override
  void addText(String text) {
    final scope = _stack.isEmpty ? null : _stack.last.scope;
    final role = scope == null
        ? null
        : Oito2HighlighterTheme.scopeRoles[scope]?.name;
    runs.add({'text': text, 'scope': scope, 'role': role});
  }

  @override
  void openNode(DataNode node) => _stack.add(node);

  @override
  void closeNode(DataNode node) => _stack.removeLast();
}

/// Returns the runs of [code] highlighted as [language] by [highlight].
List<Map<String, Object?>> runsOf(
  Highlight highlight,
  String code,
  String language,
) {
  final collector = RunCollector();
  highlight.highlight(code: code, language: language).render(collector);
  return collector.runs;
}

void main() {
  test('exports the syntax tokenization', () {
    final highlight = Highlight()..registerLanguages(oito2DefaultLanguages);
    final languages = oito2DefaultLanguages.keys.toList()..sort();
    expect(samples.keys.toSet(), languages.toSet());
    final file = writeFixture('syntax.json', {
      'scopeRoles': {
        for (final MapEntry(key: scope, value: role)
            in Oito2HighlighterTheme.scopeRoles.entries)
          scope: role.name,
      },
      'languages': languages,
      'samples': [
        for (final language in languages)
          {
            'language': language,
            'code': samples[language],
            'runs': runsOf(highlight, samples[language]!, language),
          },
      ],
    });
    expect(file.existsSync(), isTrue);
  });
}
