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

/// Documents [Oito2CircularProgressIndicator] and
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
    final scheme = Theme.of(context).colorScheme;
    return DocPage(
      title: 'Progress',
      description:
          'Circular and linear indicators of how far a task has gone, or '
          'that it is still running.',
      source: 'lib/src/pages/progress_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2CircularProgressIndicator(semanticsLabel: 'Loading'),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give a `value` from 0 to 1 for determinate progress, or leave it '
          'null while the amount is unknown. `semanticsLabel` says what is '
          'progressing.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'Without a value, the circular indicator spins an arc of changing '
          'length and the linear one glides a short segment back and '
          'forth. Both stand still when animations are disabled.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Determinate', level: 3),
        const DocText(
          'With a `value`, the circular ring fills clockwise from the top '
          'and the linear bar fills from the start side, mirrored in '
          'right-to-left layouts. The linear indicator fills the available '
          'width, or 160 pixels when the width is unbounded. Drag the '
          'slider to change the value.',
        ),
        ExamplePanel(
          region: 'determinate',
          child: SizedBox(
            width: 320,
            child: Column(
              spacing: Oito2Spacing.lg,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _value,
                        onChanged: (v) => setState(() => _value = v),
                      ),
                    ),
                    Text('${(_value * 100).round()}%'),
                  ],
                ),
                // #region determinate
                Oito2CircularProgressIndicator(
                  value: _value,
                  semanticsLabel: 'Download',
                ),
                Oito2LinearProgressIndicator(
                  value: _value,
                  semanticsLabel: 'Download',
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Indeterminate', level: 3),
        const DocText(
          'Leave `value` null while the task can\'t tell how far it is.',
        ),
        const ExamplePanel(
          region: 'indeterminate',
          child: SizedBox(
            width: 320,
            child: Column(
              spacing: Oito2Spacing.lg,
              children: [
                // #region indeterminate
                Oito2CircularProgressIndicator(semanticsLabel: 'Loading'),
                Oito2LinearProgressIndicator(semanticsLabel: 'Loading'),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Size, thickness and color', level: 3),
        const DocText(
          '`size` sets the circular diameter, 32 pixels by default, and '
          '`strokeWidth` the ring thickness; `height` sets the linear bar '
          'height. `color` and `trackColor` replace the progress and track '
          'colors.',
        ),
        ExamplePanel(
          region: 'style',
          child: SizedBox(
            width: 320,
            child: Column(
              spacing: Oito2Spacing.lg,
              children: [
                // #region style
                const Oito2CircularProgressIndicator(size: 16, strokeWidth: 2),
                Oito2LinearProgressIndicator(
                  value: 0.7,
                  height: 10,
                  color: scheme.tertiary,
                  trackColor: scheme.tertiaryContainer,
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Theming', level: 3),
        const DocText(
          'Without values of their own, the indicators read the '
          '`Oito2ProgressIndicatorThemeData` extension of the theme, then '
          'fall back to the primary color, or its text-safe tone when the '
          'primary lacks contrast with the surfaces, over the highest '
          'surface container tone, with a 4-pixel stroke and a 6-pixel bar.',
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read `semanticsLabel` and, for '
          'determinate progress, the value as a percentage, such as "40%". '
          '`semanticsValue` replaces that value text, for example with '
          '"3 of 8 files".',
        ),
        ...apiReferenceWidgets([
          'Oito2CircularProgressIndicator',
          'Oito2LinearProgressIndicator',
          'Oito2ProgressIndicatorThemeData',
        ]),
      ],
    );
  }
}
