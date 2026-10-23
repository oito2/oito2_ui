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

const _desktops = ['GNOME', 'KDE Plasma', 'Xfce', 'COSMIC', 'Cinnamon'];

/// The Text fields section of the Material theme page: text fields in
/// their states, with decorations, and the Material menus and search
/// that share their look.
class ThemeTextFieldsView extends StatelessWidget {
  /// Creates the text fields section.
  const ThemeTextFieldsView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget field(Widget child) => SizedBox(width: 260, child: child);
    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'States',
          children: [
            field(
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Your full name',
                ),
              ),
            ),
            field(
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  helperText: 'Letters and numbers only',
                ),
              ),
            ),
            field(
              const TextField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  errorText: 'Enter a valid address',
                ),
              ),
            ),
            field(
              const TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Disabled',
                  hintText: 'Not editable',
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Decorations',
          children: [
            field(
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(LucideIcons.search),
                ),
              ),
            ),
            field(
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: Icon(LucideIcons.eye),
                ),
              ),
            ),
            field(
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Price',
                  prefixText: r'$ ',
                  suffixText: 'USD',
                ),
              ),
            ),
            field(
              const TextField(
                maxLength: 40,
                decoration: InputDecoration(labelText: 'Title'),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Multiline',
          children: [
            field(
              const TextField(
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          'Menus and search',
          children: [
            DropdownMenu<String>(
              width: 220,
              initialSelection: 'GNOME',
              label: const Text('Desktop'),
              dropdownMenuEntries: [
                for (final name in _desktops)
                  DropdownMenuEntry(value: name, label: name),
              ],
            ),
            field(
              Autocomplete<String>(
                optionsBuilder: (value) => _desktops.where(
                  (d) => d.toLowerCase().contains(value.text.toLowerCase()),
                ),
                fieldViewBuilder: (context, controller, focusNode, submit) =>
                    TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onSubmitted: (_) => submit(),
                      decoration: const InputDecoration(
                        labelText: 'Autocomplete',
                      ),
                    ),
              ),
            ),
            SizedBox(
              width: 300,
              child: SearchAnchor.bar(
                barHintText: 'Search desktops',
                suggestionsBuilder: (context, controller) => [
                  for (final name in _desktops)
                    if (name.toLowerCase().contains(
                      controller.text.toLowerCase(),
                    ))
                      ListTile(
                        title: Text(name),
                        onTap: () => controller.closeView(name),
                      ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
