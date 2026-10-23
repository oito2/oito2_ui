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

import 'package:material_ui/material_ui.dart';

import '../docs/doc_widgets.dart';

/// The packages whose changelogs the changelog page shows, in order.
const _packages = [
  'oito2_ui',
  'oito2_ui_window',
  'oito2_ui_settings',
  'oito2_ui_syntax',
  'oito2_ui_themes',
  'oito2_ui_extras',
  'oito2_ui_files',
];

/// A documentation page built from the Markdown file at [asset].
class MarkdownDocPage extends StatelessWidget {
  /// Creates a page for the Markdown [asset].
  const MarkdownDocPage({
    super.key,
    required this.title,
    required this.asset,
    this.description,
  });

  /// The page title.
  final String title;

  /// The lead paragraph.
  final String? description;

  /// The asset path of the Markdown file.
  final String asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(asset),
      builder: (context, snapshot) => DocPage(
        title: title,
        description: description,
        children: [
          if (snapshot.data case final source?)
            ...markdownWidgets(source)
          else if (snapshot.hasError)
            const DocNote('This page could not be loaded.')
          else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

/// The changelogs of every package, one section each.
class ChangelogPage extends StatelessWidget {
  /// Creates the changelog page.
  const ChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bundle = DefaultAssetBundle.of(context);
    return FutureBuilder<List<String>>(
      future: Future.wait([
        for (final package in _packages)
          bundle.loadString('assets/docs/changelog/$package.md'),
      ]),
      builder: (context, snapshot) => DocPage(
        title: 'Changelog',
        description:
            'The notable changes of each package, newest first. The '
            'packages follow semantic versioning.',
        children: [
          if (snapshot.data case final changelogs?)
            for (var i = 0; i < _packages.length; i++) ...[
              DocHeading(_packages[i]),
              // The package's own headings: versions, then kinds of change.
              ...markdownWidgets(
                changelogs[i],
                levelOffset: 1,
                skipIntro: true,
              ),
            ]
          else if (snapshot.hasError)
            const DocNote('The changelogs could not be loaded.')
          else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
