// Copyright (C) 2026  oito2
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

/// Shows [Oito2HighlightedText] matching a query as you type.
class HighlightedTextPage extends StatefulWidget {
  /// Creates the highlighted text page.
  const HighlightedTextPage({super.key});

  @override
  State<HighlightedTextPage> createState() => _HighlightedTextPageState();
}

class _HighlightedTextPageState extends State<HighlightedTextPage> {
  late final _controller = TextEditingController(text: 'acao conf');
  late String _query = _controller.text;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _lines = [
    'Configurações de ação',
    'Confirm the action before deleting',
    'Ações rápidas e acessibilidade',
    'Keyboard configuration',
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Query: each word matches, ignoring case and accents',
          children: [
            SizedBox(
              width: 300,
              child: Oito2SearchField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Results',
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in _lines)
                  Oito2HighlightedText(line, query: _query),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
