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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

void main() {
  final cases = {
    'pointer': (
      const Oito2Platform(targetPlatform: TargetPlatform.linux, isWeb: false),
      Oito2Sizes.buttonHeight,
    ),
    'touch': (
      const Oito2Platform(targetPlatform: TargetPlatform.android, isWeb: false),
      Oito2Sizes.touchButtonHeight,
    ),
  };

  for (final MapEntry(key: name, value: (platform, height)) in cases.entries) {
    testWidgets('single-line controls are $height px tall on $name', (
      tester,
    ) async {
      final keys = <String, GlobalKey>{};
      Widget measured(String label, Widget child) => SizedBox(
        width: 240,
        child: KeyedSubtree(key: keys[label] = GlobalKey(), child: child),
      );
      final theme = Oito2Theme.light(platform: platform);
      await tester.pumpWidget(
        MaterialApp(
          // Measures the visual height, without the padded touch target.
          theme: theme.copyWith(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  measured('text field', const TextField()),
                  measured(
                    'labelled field',
                    const TextField(
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                  ),
                  measured(
                    'field with icons',
                    const TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(LucideIcons.mail),
                        suffixIcon: Icon(LucideIcons.x),
                      ),
                    ),
                  ),
                  measured(
                    'search field',
                    Oito2SearchField(
                      controller: TextEditingController(text: 'query'),
                    ),
                  ),
                  measured(
                    'date entry',
                    Oito2DateEntry(
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2030),
                    ),
                  ),
                  measured(
                    'button',
                    FilledButton(
                      style: FilledButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {},
                      child: const Text('Save'),
                    ),
                  ),
                  measured(
                    'segmented button',
                    SegmentedButton<int>(
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      segments: const [
                        ButtonSegment(value: 1, label: Text('Day')),
                        ButtonSegment(value: 2, label: Text('Week')),
                      ],
                      selected: const {1},
                      onSelectionChanged: (_) {},
                    ),
                  ),
                  measured(
                    'chip',
                    FilterChip(
                      label: const Text('Audio'),
                      selected: false,
                      onSelected: (_) {},
                    ),
                  ),
                  measured(
                    'selected chip',
                    FilterChip(
                      label: const Text('All'),
                      selected: true,
                      onSelected: (_) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      for (final MapEntry(key: label, value: key) in keys.entries) {
        final box = key.currentContext!.findRenderObject()! as RenderBox;
        expect(box.size.height, height, reason: label);
      }
    });
  }

  testWidgets('a field error line sits below the field height', (tester) async {
    final theme = Oito2Theme.light(
      platform: const Oito2Platform(
        targetPlatform: TargetPlatform.linux,
        isWeb: false,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: SizedBox(
            width: 240,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(LucideIcons.mail),
                errorText: 'Invalid address',
              ),
            ),
          ),
        ),
      ),
    );
    final field = tester.getRect(find.byType(TextField));
    final error = tester.getRect(find.text('Invalid address'));
    expect(field.height, greaterThan(Oito2Sizes.buttonHeight));
    expect(
      error.top,
      greaterThanOrEqualTo(field.top + Oito2Sizes.buttonHeight),
    );
  });
}
