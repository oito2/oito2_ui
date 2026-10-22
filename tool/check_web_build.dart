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

// Checks the showcase's web build: the base path, the content security
// policy, that every file index.html links to exists, and that the engine
// and fonts come from the site itself.
//
// Usage: dart run tool/check_web_build.dart <build/web> <base href>

import 'dart:io';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('Usage: check_web_build.dart <build dir> <base href>');
    exit(64);
  }
  final root = Directory(args[0]);
  final base = args[1];
  final problems = <String>[];

  File file(String path) => File('${root.path}/$path');

  final index = file('index.html');
  if (!index.existsSync()) {
    stderr.writeln('${index.path} is missing.');
    exit(1);
  }
  final html = index.readAsStringSync();

  if (!html.contains('<base href="$base">')) {
    problems.add('index.html does not set <base href="$base">.');
  }
  if (!html.contains('http-equiv="Content-Security-Policy"')) {
    problems.add('index.html has no Content-Security-Policy.');
  }

  // Links resolve against the base path, which maps to the build folder.
  final links = RegExp(r'''(?:href|src)="([^"]+)"''').allMatches(html);
  for (final match in links) {
    final link = match.group(1)!;
    if (link == base ||
        link.startsWith('http:') ||
        link.startsWith('https:') ||
        link.startsWith('data:') ||
        link.startsWith('#')) {
      continue;
    }
    final path = link.startsWith(base) ? link.substring(base.length) : link;
    if (!file(path).existsSync()) problems.add('$link is missing.');
  }

  final bootstrap = file('flutter_bootstrap.js');
  if (!bootstrap.existsSync()) {
    problems.add('flutter_bootstrap.js is missing.');
  } else if (!bootstrap.readAsStringSync().contains('fontFallbackBaseUrl')) {
    problems.add('flutter_bootstrap.js keeps the font fallback on a CDN.');
  }
  if (!file('canvaskit/canvaskit.wasm').existsSync()) {
    problems.add(
      'CanvasKit is not bundled; build with --no-web-resources-cdn.',
    );
  }

  if (problems.isEmpty) {
    stdout.writeln('The web build in ${root.path} is complete.');
    return;
  }
  problems.forEach(stderr.writeln);
  exit(1);
}
