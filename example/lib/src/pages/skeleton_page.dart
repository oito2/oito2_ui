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

/// Documents [Oito2Skeleton] and [Oito2SkeletonSwitcher]: text lines,
/// circles, rectangles and swapping in the loaded content.
class SkeletonPage extends StatefulWidget {
  /// Creates the skeleton page.
  const SkeletonPage({super.key});

  @override
  State<SkeletonPage> createState() => _SkeletonPageState();
}

class _SkeletonPageState extends State<SkeletonPage> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Skeleton',
      description:
          'Placeholder shapes shown while content loads, in the shape of '
          'the content to come.',
      source: 'lib/src/pages/skeleton_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 320,
            // #region preview
            child: Row(
              spacing: Oito2Spacing.md,
              children: [
                Oito2Skeleton.circle(),
                Expanded(child: Oito2Skeleton.text(lines: 2)),
              ],
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2Skeleton` has three shapes: `text` with a number of '
          '`lines`, the last one shorter, `circle` for avatars and icons, '
          'and `rect` for images and cards. They are filled with the '
          "scheme's highest surface container tone and pulse gently; they "
          'stand still when the system asks to reduce motion.',
        ),
        const DocText(
          'Text lines and rectangles without a `width` fill the available '
          'width, or 200 pixels when it is unbounded.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Shapes', level: 3),
        const ExamplePanel(
          region: 'shapes',
          child: SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Oito2Spacing.lg,
              children: [
                // #region shapes
                Oito2Skeleton.text(lines: 3),
                Oito2Skeleton.circle(size: 48),
                Oito2Skeleton.rect(height: 96),
                Oito2Skeleton.rect(
                  width: 120,
                  height: 32,
                  borderRadius: Oito2Radius.smallAll,
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Swapping in the content', level: 3),
        const DocText(
          '`Oito2SkeletonSwitcher` shows the `skeleton` while `loading` and '
          'fades to the `child` once it is not.',
        ),
        ExamplePanel(
          region: 'switcher',
          child: SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.lg,
              children: [
                Oito2SwitchButton(
                  value: _loading,
                  onChanged: (value) => setState(() => _loading = value),
                  title: const Text('Loading'),
                ),
                // #region switcher
                Oito2SkeletonSwitcher(
                  loading: _loading,
                  skeleton: const Row(
                    spacing: Oito2Spacing.md,
                    children: [
                      Oito2Skeleton.circle(),
                      Expanded(child: Oito2Skeleton.text(lines: 2)),
                    ],
                  ),
                  child: const Row(
                    spacing: Oito2Spacing.md,
                    children: [
                      Oito2Avatar(name: 'Ada Lovelace'),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ada Lovelace'),
                            Text('Analytical Engine'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'A skeleton has no semantics of its own. While loading, '
          '`Oito2SkeletonSwitcher` reads the whole placeholder once as '
          '"Loading", or as its `semanticLabel`, and then the content.',
        ),
        ...apiReferenceWidgets(['Oito2Skeleton', 'Oito2SkeletonSwitcher']),
      ],
    );
  }
}
