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

/// Shows [Oito2CircularProgressIndicator] and
/// [Oito2LinearProgressIndicator], determinate and indeterminate.
class ProgressPage extends StatefulWidget {
  /// Creates the progress page.
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  double _value = 0.4;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Value',
          children: [
            SizedBox(
              width: 320,
              child: Slider(
                value: _value,
                onChanged: (v) => setState(() => _value = v),
              ),
            ),
            Text('${(_value * 100).round()}%'),
          ],
        ),
        ShowcaseSection(
          'Circular',
          children: [
            Oito2CircularProgressIndicator(
              value: _value,
              semanticsLabel: 'Download',
            ),
            const Oito2CircularProgressIndicator(semanticsLabel: 'Loading'),
            const Oito2CircularProgressIndicator(size: 16, strokeWidth: 2),
          ],
        ),
        ShowcaseSection(
          'Linear',
          children: [
            SizedBox(
              width: 320,
              child: Oito2LinearProgressIndicator(
                value: _value,
                semanticsLabel: 'Download',
              ),
            ),
            const SizedBox(
              width: 320,
              child: Oito2LinearProgressIndicator(semanticsLabel: 'Loading'),
            ),
          ],
        ),
      ],
    );
  }
}
