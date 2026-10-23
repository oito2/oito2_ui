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

/// The specification names the name lookup example resolves.
const _lookups = [
  'dialog-warning',
  'edit-copy-symbolic',
  'folder-documents',
  'unknown-name',
];

/// Documents [Oito2FreedesktopIcons]: every value with its freedesktop
/// name, filtered by a search query, and the lookup by name.
class FreedesktopIconsPage extends StatefulWidget {
  /// Creates the freedesktop icons page.
  const FreedesktopIconsPage({super.key});

  @override
  State<FreedesktopIconsPage> createState() => _FreedesktopIconsPageState();
}

class _FreedesktopIconsPageState extends State<FreedesktopIconsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // #region search-data
    final words = _query.toLowerCase().split(' ').where((w) => w.isNotEmpty);
    final icons = [
      for (final icon in Oito2FreedesktopIcons.values)
        if (words.every(icon.iconName.contains)) icon,
    ];
    // #endregion
    final small = Theme.of(context).textTheme.bodySmall;
    return DocPage(
      title: 'Freedesktop Icons',
      description:
          'Icons named after the freedesktop.org Icon Naming Specification, '
          'drawn with the Lucide icons of oito2_ui.',
      source: 'lib/src/pages/freedesktop_icons_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.lg,
            children: [
              Icon(Oito2FreedesktopIcons.documentOpen.icon),
              Icon(Oito2FreedesktopIcons.documentSave.icon),
              Icon(Oito2FreedesktopIcons.editCopy.icon),
              Icon(Oito2FreedesktopIcons.userTrash.icon),
              Icon(Oito2FreedesktopIcons.dialogWarning.icon),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Each `Oito2FreedesktopIcons` value holds its specification name '
          'in `iconName`, such as `document-open`, and the glyph that draws '
          'it in `icon`, an `IconData` for `Icon`.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'Use these names when an icon comes from a Linux integration, '
          'such as a `.desktop` file, a notification or a tray item. For '
          'icons chosen in code, `LucideIcons` offers the whole set.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Lookup by name', level: 3),
        const DocText(
          '`byName` turns a specification name into an icon, or null when '
          'nothing matches. It ignores trailing `-symbolic`, `-rtl` and '
          '`-ltr` suffixes, and, as the specification does, falls back to '
          'the name without its last dash-separated part: '
          '`folder-documents` to `folder`.',
        ),
        ExamplePanel(
          region: 'lookup',
          child: SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                // #region lookup
                for (final name in _lookups)
                  Row(
                    spacing: Oito2Spacing.sm,
                    children: [
                      Icon(
                        Oito2FreedesktopIcons.byName(name)?.icon ??
                            LucideIcons.circle_question_mark,
                      ),
                      Flexible(
                        child: Text(name, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('All icons', level: 3),
        DocText(
          'The ${Oito2FreedesktopIcons.values.length} names, filtered by '
          'every word typed in the search field. Hover an icon to see its '
          'enum value.',
        ),
        ExamplePanel(
          regions: const ['search-data', 'search'],
          child: Column(
            spacing: Oito2Spacing.md,
            children: [
              SizedBox(
                width: 300,
                child: Oito2SearchField(
                  hintText: 'document-open',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Text('${icons.length} icons', style: small),
              // #region search
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Oito2Spacing.sm,
                runSpacing: Oito2Spacing.md,
                children: [
                  for (final icon in icons)
                    Tooltip(
                      message: 'Oito2FreedesktopIcons.${icon.name}',
                      child: SizedBox(
                        width: 140,
                        child: Column(
                          spacing: Oito2Spacing.xs,
                          children: [
                            Icon(icon.icon),
                            Oito2HighlightedText(
                              icon.iconName,
                              query: _query,
                              style: small,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // #endregion
            ],
          ),
        ),
        ...apiReferenceWidgets(['Oito2FreedesktopIcons']),
      ],
    );
  }
}
