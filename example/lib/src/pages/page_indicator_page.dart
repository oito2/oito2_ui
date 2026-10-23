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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2PageIndicator] with dots and, when narrow, as a counter.
class PageIndicatorPage extends StatefulWidget {
  /// Creates the page indicator page.
  const PageIndicatorPage({super.key});

  @override
  State<PageIndicatorPage> createState() => _PageIndicatorPageState();
}

class _PageIndicatorPageState extends State<PageIndicatorPage> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Dots',
          children: [
            Oito2PageIndicator(
              length: 6,
              page: _page % 6,
              onTap: (i) => setState(() => _page = i),
            ),
          ],
        ),
        ShowcaseSection(
          'Layouts with 12 pages, showing the page only: fixed, stepped and '
          'bounded in 160 px',
          children: [
            // Without onTap the dots keep their size; interactive dots are
            // 24-pixel targets, which 12 of don't fit in 160 pixels.
            for (final layout in Oito2PageIndicatorLayout.values)
              SizedBox(
                width: 160,
                child: Oito2PageIndicator(
                  length: 12,
                  page: _page % 12,
                  layout: layout,
                ),
              ),
          ],
        ),
        ShowcaseSection(
          'Counter when the dots do not fit',
          children: [
            SizedBox(
              width: 72,
              child: Oito2PageIndicator(
                length: 24,
                page: _page,
                onTap: (i) => setState(() => _page = i),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
