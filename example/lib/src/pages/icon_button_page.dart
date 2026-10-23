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

/// Documents [Oito2IconButton] as a plain button and as a toggle, and the
/// [Oito2BackButton] and [Oito2CloseButton].
class IconButtonPage extends StatefulWidget {
  /// Creates the icon button page.
  const IconButtonPage({super.key});

  @override
  State<IconButtonPage> createState() => _IconButtonPageState();
}

class _IconButtonPageState extends State<IconButtonPage> {
  final Set<String> _styles = {'bold'};
  bool _muted = false;

  // #region toggle
  /// Returns a toggle button for the text style [name].
  Widget _toggle(String name, IconData icon) => Oito2IconButton(
    icon: Icon(icon),
    tooltip: name,
    isSelected: _styles.contains(name),
    onPressed: () => setState(
      () => _styles.contains(name) ? _styles.remove(name) : _styles.add(name),
    ),
  );
  // #endregion

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Icon Button',
      description:
          'A square button that shows an icon, as a plain button or as a '
          'toggle, sized to the oito2 control height.',
      source: 'lib/src/pages/icon_button_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: Oito2IconButton(
            icon: const Icon(LucideIcons.settings),
            tooltip: 'Settings',
            onPressed: () {},
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2IconButton` an `icon` and an `onPressed`. The '
          '`tooltip` is also the name assistive technologies read, so give '
          'every icon button one. A null `onPressed` disables the button.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Disabled', level: 3),
        const DocText(
          'Without `onPressed`, the button is dimmed and ignores presses, '
          'like the delete button here.',
        ),
        ExamplePanel(
          region: 'buttons',
          // #region buttons
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Oito2IconButton(
                icon: const Icon(LucideIcons.search),
                tooltip: 'Search',
                onPressed: () {},
              ),
              const Oito2IconButton(
                icon: Icon(LucideIcons.trash),
                tooltip: 'Delete',
                onPressed: null,
              ),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Toggles', level: 3),
        const DocText(
          'With a non-null `isSelected`, the button is a toggle: while '
          'selected it fills with the secondary container color. Flip the '
          'value in `onPressed`.',
        ),
        ExamplePanel(
          regions: const ['toggle', 'toggles'],
          // #region toggles
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toggle('bold', LucideIcons.bold),
              _toggle('italic', LucideIcons.italic),
              _toggle('underline', LucideIcons.underline),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Selected icon', level: 3),
        const DocText(
          'A toggle shows `selectedIcon`, when given, instead of `icon` '
          'while selected.',
        ),
        ExamplePanel(
          region: 'selected-icon',
          // #region selected-icon
          child: Oito2IconButton(
            icon: const Icon(LucideIcons.volume_2),
            selectedIcon: const Icon(LucideIcons.volume_x),
            tooltip: 'Mute',
            isSelected: _muted,
            onPressed: () => setState(() => _muted = !_muted),
          ),
          // #endregion
        ),
        const DocHeading('Back and close', level: 3),
        const DocText(
          '`Oito2BackButton` shows a chevron pointing to the start side, and '
          '`Oito2CloseButton` an "x", with the localized "Back" and "Close" '
          'tooltips. Without `onPressed`, both pop the closest `Navigator` '
          'route.',
        ),
        ExamplePanel(
          region: 'back-close',
          // #region back-close
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Oito2BackButton(onPressed: () {}),
              Oito2CloseButton(onPressed: () {}),
            ],
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The `tooltip` labels the button for assistive technologies, and a '
          'toggle also reports its selected state. The focus ring shows in '
          'keyboard navigation.',
        ),
        ...apiReferenceWidgets([
          'Oito2IconButton',
          'Oito2BackButton',
          'Oito2CloseButton',
        ]),
      ],
    );
  }
}
