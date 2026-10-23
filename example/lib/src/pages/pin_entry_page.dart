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

/// Shows [Oito2PinEntry] for a one-time code and a masked PIN.
class PinEntryPage extends StatefulWidget {
  /// Creates the PIN entry page.
  const PinEntryPage({super.key});

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  String _status = 'Type or paste 6 digits';
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'One-time code (123456 is right)',
          children: [
            Oito2PinEntry(
              hasError: _error,
              onChanged: (_) => setState(() => _error = false),
              onCompleted: (code) => setState(() {
                _error = code != '123456';
                _status = _error ? 'Wrong code' : 'Verified';
              }),
            ),
            Text(_status),
          ],
        ),
        const ShowcaseSection(
          'Masked 4-digit PIN',
          children: [Oito2PinEntry(length: 4, obscure: true)],
        ),
      ],
    );
  }
}
