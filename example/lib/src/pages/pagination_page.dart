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

/// Documents [Oito2Pagination]: a page size selector, the compact form,
/// more pages around the current one and the page list function.
class PaginationPage extends StatefulWidget {
  /// Creates the pagination page.
  const PaginationPage({super.key});

  @override
  State<PaginationPage> createState() => _PaginationPageState();
}

class _PaginationPageState extends State<PaginationPage> {
  int _preview = 1;
  int _page = 4;
  int _size = 20;
  int _small = 1;
  int _wide = 10;

  int get _count => (480 / _size).ceil();

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Pagination',
      description:
          'Moves between the pages of a long list with previous and next '
          'buttons, page numbers and an optional page size selector.',
      source: 'lib/src/pages/pagination_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2Pagination(
            page: _preview,
            pageCount: 10,
            onChanged: (page) => setState(() => _preview = page),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2Pagination` is controlled: pass the current `page` and the '
          '`pageCount`, and update the page in `onChanged`. Pages count '
          'from 1. A null `onChanged` disables every button.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'The page numbers keep the first and last pages and the pages next '
          'to the current one, with an ellipsis for the others. An ellipsis '
          'never stands for a single page, and the number of buttons stays '
          'the same for a given `pageCount`, so they do not shift as the '
          'page changes.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Page size', level: 3),
        const DocText(
          'With `pageSizes` and `onPageSizeChanged`, an "Items per page" '
          'selector follows the buttons, showing `pageSize`. Here 480 items '
          'are split by the chosen size, and changing it returns to the '
          'first page.',
        ),
        ExamplePanel(
          region: 'page-size',
          // #region page-size
          child: Oito2Pagination(
            page: _page.clamp(1, _count),
            pageCount: _count,
            pageSize: _size,
            pageSizes: const [10, 20, 50, 100],
            onChanged: (page) => setState(() => _page = page),
            onPageSizeChanged: (size) => setState(() {
              _size = size;
              _page = 1;
            }),
          ),
          // #endregion
        ),
        const DocHeading('Compact', level: 3),
        const DocText(
          'Narrower than `compactWidth`, 420 pixels by default, only the '
          'previous and next buttons remain, around "Page 1 of 8". A page '
          'size selector wraps below them.',
        ),
        ExamplePanel(
          region: 'compact',
          child: SizedBox(
            width: 300,
            // #region compact
            child: Oito2Pagination(
              page: _small,
              pageCount: 8,
              onChanged: (page) => setState(() => _small = page),
            ),
            // #endregion
          ),
        ),
        const DocHeading('More page numbers', level: 3),
        const DocText(
          '`siblingCount` sets how many pages show on each side of the '
          'current one, and `boundaryCount` how many at each end; both are '
          '1 by default.',
        ),
        ExamplePanel(
          region: 'siblings',
          // #region siblings
          child: Oito2Pagination(
            page: _wide,
            pageCount: 20,
            siblingCount: 2,
            boundaryCount: 2,
            onChanged: (page) => setState(() => _wide = page),
          ),
          // #endregion
        ),
        const DocHeading('Page list', level: 3),
        const DocText(
          '`oito2PaginationItems` returns the page numbers a pagination '
          'shows, with null for each ellipsis, for building a custom one.',
        ),
        ExamplePanel(
          region: 'items',
          // #region items
          child: Text(
            oito2PaginationItems(
              _wide,
              20,
            ).map((page) => page?.toString() ?? '…').join('  '),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each page button is labeled "Page 4" and the current one is '
          'reported as selected; the ellipses are hidden from assistive '
          'technologies. The previous and next buttons are named by their '
          'tooltips, and the page size selector is labeled "Items per '
          'page".',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next button.'],
            ['`Enter` / `Space`', 'Activates the focused button.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2Pagination', 'oito2PaginationItems']),
      ],
    );
  }
}
