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

/// Documents [Oito2StatusPage]: empty and error states, the compact
/// variant and scrolling in short panes.
class StatusPagePage extends StatelessWidget {
  /// Creates the status page page.
  const StatusPagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = BoxDecoration(
      border: Border.all(color: scheme.outlineVariant),
      borderRadius: Oito2Radius.mediumAll,
    );
    return DocPage(
      title: 'Status Page',
      description:
          'A centered message for a page or pane without content to show: '
          'an empty folder, no search results or a failed load.',
      source: 'lib/src/pages/status_page_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: Container(
            width: 480,
            height: 320,
            decoration: border,
            // #region preview
            child: Oito2StatusPage(
              icon: const Icon(LucideIcons.folder_open),
              title: const Text('No files yet'),
              description: const Text(
                'Drop files here or create one to get started.',
              ),
              actions: [
                FilledButton(onPressed: () {}, child: const Text('New file')),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2StatusPage` takes a `title` and an optional large `icon`, '
          'a `description`, a list of `actions` and extra content as '
          '`child`. It fills the space it is given and centers its content, '
          'which scrolls when the space is too short.',
        ),
        const DocText(
          'Use it in place of a list, a grid or a whole page that has '
          'nothing to show, and say what to do next in the description or '
          'with an action.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Error state', level: 3),
        ExamplePanel(
          region: 'error',
          child: Container(
            width: 480,
            height: 320,
            decoration: border,
            // #region error
            child: Oito2StatusPage(
              icon: const Icon(LucideIcons.cloud_off),
              title: const Text("Couldn't load the files"),
              description: const Text(
                'Check the connection and try again. Files saved on this '
                'device are still available.',
              ),
              actions: [
                FilledButton(onPressed: () {}, child: const Text('Retry')),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Open offline'),
                ),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Compact', level: 3),
        const DocText(
          '`compact` uses a smaller icon, title and spacing, for sidebars '
          'and small panes. This pane is short, so the content scrolls.',
        ),
        ExamplePanel(
          region: 'compact',
          child: Container(
            width: 240,
            height: 160,
            decoration: border,
            // #region compact
            child: Oito2StatusPage(
              compact: true,
              icon: const Icon(LucideIcons.search_x),
              title: const Text('No results'),
              description: const Text(
                'Try other words, check the spelling or clear the filters.',
              ),
              actions: [
                TextButton(onPressed: () {}, child: const Text('Clear')),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The title is read as a header. The icon is decorative unless '
          'you give it a `semanticLabel`; say the state in the title.',
        ),
        ...apiReferenceWidgets(['Oito2StatusPage']),
      ],
    );
  }
}
