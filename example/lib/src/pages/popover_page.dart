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

/// Shows [Oito2Popover] placements, an arrow, a form and nesting.
class PopoverPage extends StatefulWidget {
  /// Creates the popover page.
  const PopoverPage({super.key});

  @override
  State<PopoverPage> createState() => _PopoverPageState();
}

class _PopoverPageState extends State<PopoverPage> {
  bool _arrow = true;

  /// A button labeled [label] that opens and closes the popover of
  /// [controller].
  Widget _anchor(String label, Oito2PopoverController controller) =>
      OutlinedButton(onPressed: controller.toggle, child: Text(label));

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Placement',
          children: [
            Oito2CheckButton(
              value: _arrow,
              onChanged: (v) => setState(() => _arrow = v ?? false),
              title: const Text('Show the arrow'),
            ),
            for (final placement in Oito2PopoverPlacement.values)
              Oito2Popover(
                placement: placement,
                alignment: Oito2PopoverAlignment.center,
                showArrow: _arrow,
                builder: (context, c) => _anchor(placement.name, c),
                popoverBuilder: (context, _) =>
                    Text('Opened on the ${placement.name} side.'),
              ),
          ],
        ),
        ShowcaseSection(
          'A short form',
          children: [
            Oito2Popover(
              semanticLabel: 'Rename',
              builder: (context, c) => _anchor('Rename', c),
              popoverBuilder: (context, controller) => SizedBox(
                width: 260,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: Oito2Spacing.sm,
                  children: [
                    const TextField(
                      decoration: InputDecoration(hintText: 'New name'),
                    ),
                    FilledButton(
                      onPressed: controller.close,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
            Oito2Popover(
              matchAnchorWidth: true,
              builder: (context, c) => SizedBox(
                width: 240,
                child: _anchor('As wide as its anchor', c),
              ),
              popoverBuilder: (context, _) =>
                  const Text('This panel takes the button width.'),
            ),
          ],
        ),
        ShowcaseSection(
          'Nested',
          children: [
            Oito2Popover(
              builder: (context, c) => _anchor('Outer', c),
              popoverBuilder: (context, _) => Oito2Popover(
                placement: Oito2PopoverPlacement.end,
                builder: (context, c) => _anchor('Open inner', c),
                popoverBuilder: (context, _) =>
                    const Text('The outer panel stays open.'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
