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

// #region segments
/// Returns the breadcrumb segments of the absolute [path], starting at a
/// "Computer" root.
List<Oito2BreadcrumbItem<String>> _segments(String path) {
  final parts = path.split('/').where((part) => part.isNotEmpty).toList();
  return [
    const Oito2BreadcrumbItem(
      label: 'Computer',
      icon: LucideIcons.hard_drive,
      value: '/',
    ),
    for (var i = 0; i < parts.length; i++)
      Oito2BreadcrumbItem(
        label: parts[i],
        value: '/${parts.take(i + 1).join('/')}',
      ),
  ];
}
// #endregion

/// Documents [Oito2Breadcrumb]: a folder path with segments that navigate,
/// collapse when narrow and turn into a text field.
class BreadcrumbPage extends StatefulWidget {
  /// Creates the breadcrumb page.
  const BreadcrumbPage({super.key});

  @override
  State<BreadcrumbPage> createState() => _BreadcrumbPageState();
}

class _BreadcrumbPageState extends State<BreadcrumbPage> {
  String _path = '/home/ana/Documents/Projects/oito2/reports';
  double _width = 320;

  @override
  Widget build(BuildContext context) {
    final items = _segments(_path);
    final small = Theme.of(context).textTheme.bodySmall;
    return DocPage(
      title: 'Breadcrumb',
      description:
          'A path bar: the folders from the root to the current one, as '
          'buttons that go back up, with the hidden ones in a menu and a '
          'text field to type a path.',
      source: 'lib/src/pages/breadcrumb_page.dart',
      children: [
        ExamplePanel(
          regions: const ['segments', 'preview'],
          child: SizedBox(
            width: 560,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.sm,
              children: [
                // #region preview
                Oito2Breadcrumb<String>(
                  items: items,
                  path: _path,
                  onSelected: (index) =>
                      setState(() => _path = items[index].value!),
                  onSubmitted: (text) => setState(
                    () => _path = text.startsWith('/') ? text : '/$text',
                  ),
                ),
                // #endregion
                Text('Current folder: $_path', style: small),
              ],
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'List the segments from the root to the current location as '
          '`Oito2BreadcrumbItem`s, each with a `label`, an optional `icon` '
          'and a `value`, such as the folder path. Every segment but the '
          'last is a button that calls `onSelected` with its index; the '
          'last one is the current location.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'With `onSubmitted`, the edit button at the end, or a click on the '
          'empty area of the bar, turns it into a text field holding `path`, '
          'or the labels joined by `pathSeparator`. Enter submits the text; '
          'Escape, or moving the focus away, cancels.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Overflow', level: 3),
        DocText(
          'When the segments don\'t fit, the ones after the first collapse '
          'into a "…" button, as few as needed, and the button opens a menu '
          'with them. Very narrow, the first one collapses too. Width: '
          '${_width.round()} pixels.',
        ),
        ExamplePanel(
          region: 'overflow',
          child: Column(
            spacing: Oito2Spacing.sm,
            children: [
              SizedBox(
                width: 320,
                child: Slider(
                  value: _width,
                  min: 120,
                  max: 560,
                  onChanged: (value) => setState(() => _width = value),
                ),
              ),
              // #region overflow
              SizedBox(
                width: _width,
                child: Oito2Breadcrumb<String>(
                  items: items,
                  onSelected: (index) =>
                      setState(() => _path = items[index].value!),
                ),
              ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The bar reads as "Path". Each segment button reads its label, the '
          'last segment reads as the current location, and the "…" button '
          'reads "Show hidden path segments" and whether its menu is open. '
          'The chevrons point toward the end of the reading direction.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus into and out of the bar.'],
            ['`←` / `→`', 'Moves between the segment buttons.'],
            ['`Enter` / `Space`', 'Opens the focused segment or menu.'],
            ['`Enter` in the field', 'Submits the typed path.'],
            ['`Escape` in the field', 'Cancels the edit.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2Breadcrumb', 'Oito2BreadcrumbItem']),
      ],
    );
  }
}
