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

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2BusyButton] and [Oito2BusyLabel] on filled, outlined
/// and icon buttons.
class BusyButtonPage extends StatefulWidget {
  /// Creates the busy button page.
  const BusyButtonPage({super.key});

  @override
  State<BusyButtonPage> createState() => _BusyButtonPageState();
}

class _BusyButtonPageState extends State<BusyButtonPage> {
  bool _held = true;

  // #region state
  bool _saving = false;
  Timer? _timer;

  /// Marks the save as running for two seconds, standing for a call to a
  /// server.
  void _save() {
    setState(() => _saving = true);
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saving = false);
    });
  }
  // #endregion

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Busy Button',
      description:
          'A busy state for any button while its action runs: a spinner in '
          'place of the icon or label, at the same width, with input '
          'ignored.',
      source: 'lib/src/pages/busy_button_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          regions: const ['state'],
          // #region preview
          child: Oito2BusyButton(
            busy: _saving,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Oito2BusyLabel(child: Icon(LucideIcons.save)),
              label: const Text('Save'),
            ),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Wrap any button in `Oito2BusyButton` and set `busy` while its '
          'action runs. The button keeps its colors, size and focus, but '
          'ignores clicks, taps, Enter and Space, and the progress cursor '
          'shows over it. Inside the button, wrap the icon or the label in '
          '`Oito2BusyLabel`: it stays laid out but hidden, and a spinner in '
          'the color of the button takes its place.',
        ),
        const DocText(
          'Keep `onPressed` set while busy: a null `onPressed` would show '
          'the button disabled and move the focus away from it.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Buttons', level: 3),
        const DocText(
          'Without an icon, wrap the label: the spinner shows centered '
          'where the text was. Turn the switch off to see the buttons idle.',
        ),
        ExamplePanel(
          region: 'buttons',
          child: Column(
            spacing: Oito2Spacing.lg,
            children: [
              Oito2SwitchButton(
                value: _held,
                onChanged: (value) => setState(() => _held = value),
                title: const Text('Busy'),
              ),
              Wrap(
                spacing: Oito2Spacing.sm,
                runSpacing: Oito2Spacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // #region buttons
                  Oito2BusyButton(
                    busy: _held,
                    child: FilledButton(
                      onPressed: () {},
                      child: const Oito2BusyLabel(child: Text('Apply')),
                    ),
                  ),
                  Oito2BusyButton(
                    busy: _held,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Oito2BusyLabel(
                        child: Icon(LucideIcons.refresh_cw),
                      ),
                      label: const Text('Synchronize'),
                    ),
                  ),
                  Oito2BusyButton(
                    busy: _held,
                    child: Oito2IconButton(
                      tooltip: 'Upload',
                      onPressed: () {},
                      icon: const Oito2BusyLabel(
                        child: Icon(LucideIcons.upload),
                      ),
                    ),
                  ),
                  // #endregion
                ],
              ),
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'While busy, assistive technologies read the button with '
          '"Loading" as its value and offer no tap action; the label is '
          'still read, since it only hides from view. The spinner stands '
          'still when the system asks to reduce motion.',
        ),
        ...apiReferenceWidgets(['Oito2BusyButton', 'Oito2BusyLabel']),
      ],
    );
  }
}
