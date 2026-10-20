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

/// Shows [Oito2Format]: byte sizes, compact numbers and relative times in
/// the app language.
class FormatPage extends StatelessWidget {
  /// Creates the format page.
  const FormatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final format = Oito2Format.of(context);
    final now = DateTime.now();
    Widget row(String input, String output) => SizedBox(
      width: 420,
      child: Row(
        children: [
          Expanded(child: Text(input)),
          Text(output, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Byte sizes',
          children: [
            Column(
              children: [
                for (final bytes in [512, 1536, 2500000, 7340032000])
                  row('$bytes bytes', format.bytes(bytes)),
                row(
                  '1536 bytes, IEC units',
                  format.bytes(1536, units: Oito2ByteUnits.iec),
                ),
              ],
            ),
          ],
        ),
        ShowcaseSection(
          'Compact numbers',
          children: [
            Column(
              children: [
                for (final value in [999, 1234, 56789, 1250000])
                  row('$value', format.compactNumber(value)),
              ],
            ),
          ],
        ),
        ShowcaseSection(
          'Relative time',
          children: [
            Column(
              children: [
                for (final offset in const [
                  Duration(seconds: -20),
                  Duration(minutes: -3),
                  Duration(hours: 5),
                  Duration(days: -2),
                  Duration(days: 40),
                  Duration(days: -800),
                ])
                  row(
                    '$offset',
                    format.relativeTime(now.add(offset), now: now),
                  ),
              ],
            ),
          ],
        ),
        Text(
          'Switch the language in the settings to see the Portuguese forms.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
