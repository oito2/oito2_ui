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

/// Documents [Oito2Watermark] behind an empty state.
class WatermarkPage extends StatelessWidget {
  /// Creates the watermark page.
  const WatermarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DocPage(
      title: 'Watermark',
      description:
          'Places a faint decorative widget, such as a large icon, behind '
          'content like an empty state.',
      source: 'lib/src/pages/watermark_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 420,
            height: 200,
            child: Oito2BorderContainer(
              // #region preview
              child: Oito2Watermark(
                watermark: const Icon(LucideIcons.inbox, size: 120),
                child: Center(
                  child: Text('No messages', style: textTheme.titleMedium),
                ),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2Watermark` the decorative `watermark` and the `child` '
          'drawn over it. The watermark covers the area the child takes, so '
          'to watermark a whole area give the child the full size, for '
          'example with `Center` or `Align`.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'By default the watermark sits at the center of the end side, '
          '`AlignmentDirectional.centerEnd`, 20 pixels from the edges, at '
          '10% opacity.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Alignment and opacity', level: 3),
        const DocText(
          '`alignment` places the watermark, `padding` keeps it away from '
          'the edges and `opacity`, from 0 to 1, sets how faint it is.',
        ),
        ExamplePanel(
          region: 'alignment',
          child: SizedBox(
            width: 420,
            height: 200,
            child: Oito2BorderContainer(
              // #region alignment
              child: Oito2Watermark(
                watermark: const Icon(LucideIcons.cloud_off, size: 96),
                alignment: Alignment.center,
                padding: EdgeInsets.zero,
                opacity: 0.2,
                child: Center(
                  child: Text('You are offline', style: textTheme.titleMedium),
                ),
              ),
              // #endregion
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The watermark is hidden from assistive technologies and ignores '
          'pointer events, so it never hides or blocks the content. Say '
          'what it shows in the content itself when it matters.',
        ),
        ...apiReferenceWidgets(['Oito2Watermark']),
      ],
    );
  }
}
