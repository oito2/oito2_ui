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
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';
import '../docs/markdown.dart';

/// The packages whose changelogs the changelog page shows, in order.
const changelogPackages = [
  'oito2_ui',
  'oito2_ui_window',
  'oito2_ui_settings',
  'oito2_ui_syntax',
  'oito2_ui_code_editor',
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
            const Center(
              child: Oito2CircularProgressIndicator(
                semanticsLabel: 'Loading the page',
              ),
            ),
        ],
      ),
    );
  }
}

/// The changelogs of every package, one section each, with every version
/// collapsed until it is opened.
class ChangelogPage extends StatefulWidget {
  /// Creates the changelog page.
  const ChangelogPage({super.key});

  @override
  State<ChangelogPage> createState() => _ChangelogPageState();
}

/// Loads and parses the changelogs once.
class _ChangelogPageState extends State<ChangelogPage> {
  Future<List<List<_ChangelogVersion>>>? _changelogs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bundle = DefaultAssetBundle.of(context);
    _changelogs ??= Future.wait([
      for (final package in changelogPackages)
        bundle
            .loadString('assets/docs/changelog/$package.md')
            .then(_changelogVersions),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<_ChangelogVersion>>>(
      future: _changelogs,
      builder: (context, snapshot) => DocPage(
        title: 'Changelog',
        description:
            'The notable changes of each package, newest first; open a '
            'version to read its changes. The packages follow semantic '
            'versioning.',
        children: [
          if (snapshot.data case final changelogs?)
            for (var i = 0; i < changelogPackages.length; i++) ...[
              DocHeading(changelogPackages[i]),
              for (final version in changelogs[i])
                _ChangelogVersionView(version),
            ]
          else if (snapshot.hasError)
            const DocNote('The changelogs could not be loaded.')
          else
            const Center(
              child: Oito2CircularProgressIndicator(
                semanticsLabel: 'Loading the changelogs',
              ),
            ),
        ],
      ),
    );
  }
}

/// A version of a changelog: the title of its `##` heading and the blocks
/// under it.
typedef _ChangelogVersion = ({String title, List<MdBlock> blocks});

/// Returns the versions of the changelog [source], in order; the blocks
/// before the first `##` heading are left out.
List<_ChangelogVersion> _changelogVersions(String source) {
  final versions = <_ChangelogVersion>[];
  for (final block in parseMarkdown(source)) {
    if (block case MdHeading(level: 2, :final text)) {
      versions.add((title: headingText(text), blocks: []));
    } else if (versions.isNotEmpty) {
      versions.last.blocks.add(block);
    }
  }
  return versions;
}

/// A collapsed section of one changelog version, whose changes are built
/// only once it is opened.
class _ChangelogVersionView extends StatelessWidget {
  const _ChangelogVersionView(this.version);

  final _ChangelogVersion version;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.sm),
      child: Oito2Expandable(
        header: Text(version.title),
        child: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: markdownBlockWidgets(version.blocks, levelOffset: 1),
          ),
        ),
      ),
    );
  }
}
