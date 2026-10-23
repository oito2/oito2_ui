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

/// Shows [Oito2CheckboxListTile], [Oito2RadioListTile] and
/// [Oito2SwitchListTile] in a tile list.
class ToggleListTilePage extends StatefulWidget {
  /// Creates the toggle list tile page.
  const ToggleListTilePage({super.key});

  @override
  State<ToggleListTilePage> createState() => _ToggleListTilePageState();
}

class _ToggleListTilePageState extends State<ToggleListTilePage> {
  bool _thumbnails = true;
  String _view = 'grid';
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Toggle list tiles',
          children: [
            SizedBox(
              width: 480,
              child: Oito2BorderContainer(
                child: Column(
                  children: [
                    Oito2CheckboxListTile(
                      value: _thumbnails,
                      onChanged: (v) =>
                          setState(() => _thumbnails = v ?? false),
                      title: const Text('Show thumbnails'),
                      secondary: const Icon(LucideIcons.image),
                    ),
                    for (final (value, label) in const [
                      ('grid', 'Grid view'),
                      ('list', 'List view'),
                    ])
                      Oito2RadioListTile<String>(
                        value: value,
                        groupValue: _view,
                        onChanged: (v) => setState(() => _view = v ?? 'grid'),
                        title: Text(label),
                      ),
                    Oito2SwitchListTile(
                      value: _hidden,
                      onChanged: (v) => setState(() => _hidden = v),
                      title: const Text('Hidden files'),
                      subtitle: const Text(
                        'Files whose name starts with a dot',
                      ),
                    ),
                    const Oito2SwitchListTile(
                      value: false,
                      onChanged: null,
                      title: Text('Unavailable option'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
