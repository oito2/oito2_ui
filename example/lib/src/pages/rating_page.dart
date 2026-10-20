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

/// Shows [Oito2Rating] with whole and half values.
class RatingPage extends StatefulWidget {
  /// Creates the rating page.
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _whole = 3;
  double _half = 2.5;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Whole stars: hover to preview, arrows or digits to change',
          children: [
            Oito2Rating(
              value: _whole,
              semanticLabel: 'Quality',
              onChanged: (v) => setState(() => _whole = v),
            ),
            Text('$_whole'),
          ],
        ),
        ShowcaseSection(
          'Half stars, larger',
          children: [
            Oito2Rating(
              value: _half,
              allowHalf: true,
              size: 32,
              onChanged: (v) => setState(() => _half = v),
            ),
            Text('$_half'),
          ],
        ),
        const ShowcaseSection(
          'Read-only',
          children: [Oito2Rating(value: 4, onChanged: null)],
        ),
      ],
    );
  }
}
