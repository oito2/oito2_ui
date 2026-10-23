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

/// Shows an [Oito2Tour] over a small toolbar.
class TourPage extends StatefulWidget {
  /// Creates the tour page.
  const TourPage({super.key});

  @override
  State<TourPage> createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> {
  final _search = GlobalKey();
  final _create = GlobalKey();
  final _settings = GlobalKey();
  late final _controller = Oito2TourController(
    steps: [
      const Oito2TourStep(
        title: 'Welcome',
        description: 'This short tour shows the toolbar.',
      ),
      Oito2TourStep(
        target: _search,
        title: 'Search',
        description: 'Find any file by name.',
      ),
      Oito2TourStep(
        target: _create,
        title: 'Create',
        description: 'Tap the button to go on.',
        waitForTap: true,
      ),
      Oito2TourStep(
        target: _settings,
        title: 'Settings',
        description: 'Change the theme and the language here.',
        placement: Oito2PopoverPlacement.start,
      ),
    ],
  );
  String _result = 'Not started';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Oito2Tour(
      controller: _controller,
      onFinished: (completed) =>
          setState(() => _result = completed ? 'Completed' : 'Skipped'),
      child: ShowcasePageBody(
        children: [
          ShowcaseSection(
            'Toolbar',
            children: [
              SizedBox(
                key: _search,
                width: 220,
                child: const Oito2SearchField(hintText: 'Search files'),
              ),
              FilledButton.icon(
                key: _create,
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
                label: const Text('Create'),
              ),
              Oito2IconButton(
                key: _settings,
                tooltip: 'Settings',
                onPressed: () {},
                icon: const Icon(LucideIcons.settings),
              ),
            ],
          ),
          ShowcaseSection(
            'Tour',
            children: [
              OutlinedButton(
                onPressed: _controller.start,
                child: const Text('Start the tour'),
              ),
              Text(_result),
            ],
          ),
        ],
      ),
    );
  }
}
