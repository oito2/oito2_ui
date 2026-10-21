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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2Pagination] with a page size and in compact form.
class PaginationPage extends StatefulWidget {
  /// Creates the pagination page.
  const PaginationPage({super.key});

  @override
  State<PaginationPage> createState() => _PaginationPageState();
}

class _PaginationPageState extends State<PaginationPage> {
  int _page = 4;
  int _size = 20;
  int _small = 1;

  int get _count => (480 / _size).ceil();

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          '480 items',
          children: [
            Oito2Pagination(
              page: _page.clamp(1, _count),
              pageCount: _count,
              pageSize: _size,
              pageSizes: const [10, 20, 50, 100],
              onChanged: (p) => setState(() => _page = p),
              onPageSizeChanged: (s) => setState(() {
                _size = s;
                _page = 1;
              }),
            ),
          ],
        ),
        ShowcaseSection(
          'Compact, below 420 pixels',
          children: [
            SizedBox(
              width: 300,
              child: Oito2Pagination(
                page: _small,
                pageCount: 8,
                onChanged: (p) => setState(() => _small = p),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
