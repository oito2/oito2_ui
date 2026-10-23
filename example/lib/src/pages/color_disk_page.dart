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

/// Documents [Oito2ColorDisk] in a group whose arrow-key focus stays
/// inside an [Oito2EdgeFocusInterceptor], larger, and disabled.
class ColorDiskPage extends StatefulWidget {
  /// Creates the color disk page.
  const ColorDiskPage({super.key});

  @override
  State<ColorDiskPage> createState() => _ColorDiskPageState();
}

class _ColorDiskPageState extends State<ColorDiskPage> {
  Oito2AccentColor _accent = Oito2AccentColor.blue;
  Oito2AccentColor _large = Oito2AccentColor.green;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Color Disk',
      description:
          'A round color swatch that can be selected, as in accent color '
          'pickers.',
      source: 'lib/src/pages/color_disk_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2EdgeFocusInterceptor(
            child: Wrap(
              spacing: Oito2Spacing.xs,
              children: [
                for (final accent in Oito2AccentColor.values)
                  Oito2ColorDisk(
                    color: accent.color,
                    label: accent.name,
                    selected: _accent == accent,
                    onPressed: () => setState(() => _accent = accent),
                  ),
              ],
            ),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give each `Oito2ColorDisk` its `color`, a `label` that names the '
          'color, whether it is `selected`, and an `onPressed` that selects '
          'it. A ring in the disk\'s own color surrounds the selected disk; '
          'a fainter one shows while the pointer hovers a disk or the '
          'keyboard focus is on it. A null `onPressed` disables the disk.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'Wrap a group of disks in an `Oito2EdgeFocusInterceptor`: the '
          'arrow keys then move the focus between the disks and stop at the '
          'edges of the group, while `Tab` still leaves it.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Size', level: 3),
        const DocText(
          '`size` sets the disk diameter, 20 by default, without its ring.',
        ),
        ExamplePanel(
          region: 'size',
          // #region size
          child: Oito2EdgeFocusInterceptor(
            child: Wrap(
              spacing: Oito2Spacing.sm,
              children: [
                for (final accent in const [
                  Oito2AccentColor.green,
                  Oito2AccentColor.orange,
                  Oito2AccentColor.purple,
                ])
                  Oito2ColorDisk(
                    color: accent.color,
                    label: accent.name,
                    size: 32,
                    selected: _large == accent,
                    onPressed: () => setState(() => _large = accent),
                  ),
              ],
            ),
          ),
          // #endregion
        ),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'Without `onPressed`, the disk shows its color and selection but '
          'ignores taps.',
        ),
        ExamplePanel(
          region: 'disabled',
          // #region disabled
          child: Oito2ColorDisk(
            color: Oito2AccentColor.slate.color,
            label: 'slate',
            selected: true,
            onPressed: null,
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Assistive technologies read each disk as a button named by its '
          '`label`, selected or not; the label is also the tooltip. When '
          'the color is close to the surface, the ring is adjusted to stand '
          'out from it.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the next disk.'],
            [
              'Arrow keys',
              'Move the focus between the disks; inside an '
                  '`Oito2EdgeFocusInterceptor`, they stop at the edges of '
                  'the group.',
            ],
            ['`Space` / `Enter`', 'Selects the focused disk.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2ColorDisk', 'Oito2EdgeFocusInterceptor']),
      ],
    );
  }
}
