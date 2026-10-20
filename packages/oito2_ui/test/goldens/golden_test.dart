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

@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'golden_helpers.dart';

/// Buttons, inputs, toggles, chips, progress, tiles and info boxes.
class _ComponentsScene extends StatelessWidget {
  const _ComponentsScene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.md,
          children: [
            Wrap(
              spacing: Oito2Spacing.sm,
              runSpacing: Oito2Spacing.sm,
              children: [
                FilledButton(onPressed: () {}, child: const Text('Filled')),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('Tonal'),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                TextButton(onPressed: () {}, child: const Text('Text')),
                const FilledButton(onPressed: null, child: Text('Disabled')),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.settings),
                ),
              ],
            ),
            const Row(
              spacing: Oito2Spacing.md,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      errorText: 'Invalid address',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Oito2CheckButton(
                    value: true,
                    onChanged: (_) {},
                    title: const Text('Check'),
                  ),
                ),
                Expanded(
                  child: Oito2RadioButton<int>(
                    value: 1,
                    groupValue: 1,
                    onChanged: (_) {},
                    title: const Text('Radio'),
                  ),
                ),
                Expanded(
                  child: Oito2SwitchButton(
                    value: true,
                    onChanged: (_) {},
                    title: const Text('Switch'),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: Oito2Spacing.sm,
              children: [
                FilterChip(
                  label: const Text('Selected'),
                  selected: true,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text('Chip'),
                  selected: false,
                  onSelected: (_) {},
                ),
                const Oito2PageIndicator(length: 4, page: 1),
              ],
            ),
            Slider(value: 0.4, onChanged: (_) {}),
            const LinearProgressIndicator(value: 0.6),
            Oito2BorderContainer(
              child: Oito2Tile(
                leading: const Icon(LucideIcons.wifi),
                title: const Text('Wi-Fi'),
                subtitle: const Text('Connected'),
                trailing: const Icon(LucideIcons.chevron_right),
                onTap: () {},
              ),
            ),
            const Oito2InfoBox(
              type: Oito2InfoType.warning,
              title: Text('Battery low'),
              subtitle: Text('Plug in the charger.'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page background, sidebar and mainbar chrome with an open dialog.
class _ChromeScene extends StatelessWidget {
  const _ChromeScene();

  @override
  Widget build(BuildContext context) {
    final chrome = Oito2ChromeColors.maybeOf(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(
        children: [
          const Oito2TitleBar(title: Text('oito2')),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 64, color: chrome.sidebar),
                const VerticalDivider(width: 1),
                Container(
                  width: 180,
                  color: chrome.mainbar,
                  padding: const EdgeInsets.all(Oito2Spacing.md),
                  child: Text('Mainbar', style: textTheme.titleSmall),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Center(
                    child: AlertDialog(
                      title: const Text('Discard changes?'),
                      content: const Text('Unsaved edits will be lost.'),
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Discard'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One title bar per window control style.
class _TitleBarsScene extends StatelessWidget {
  const _TitleBarsScene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        spacing: Oito2Spacing.sm,
        children: [
          for (final style in Oito2WindowControlStyle.values)
            if (style != Oito2WindowControlStyle.none)
              Oito2TitleBar(title: Text(style.name), controlStyle: style),
        ],
      ),
    );
  }
}

/// Every painted toggle state: check boxes, radios and switches, the
/// toggle buttons and the list tiles, with one control focused.
class _TogglesScene extends StatelessWidget {
  const _TogglesScene();

  @override
  Widget build(BuildContext context) {
    void noop(Object? _) {}
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.sm,
          children: [
            Row(
              children: [
                Oito2Checkbox(value: false, onChanged: noop),
                Oito2Checkbox(value: true, onChanged: noop),
                Oito2Checkbox(value: null, tristate: true, onChanged: noop),
                const Oito2Checkbox(value: true, onChanged: null),
                Oito2Checkbox(value: true, autofocus: true, onChanged: noop),
                const SizedBox(width: Oito2Spacing.lg),
                Oito2Radio<int>(value: 0, groupValue: 1, onChanged: noop),
                Oito2Radio<int>(value: 1, groupValue: 1, onChanged: noop),
                const Oito2Radio<int>(value: 1, groupValue: 1, onChanged: null),
              ],
            ),
            Row(
              children: [
                Oito2Switch(value: false, onChanged: noop),
                Oito2Switch(value: true, onChanged: noop),
                Oito2Switch(value: false, onOffShapes: true, onChanged: noop),
                Oito2Switch(value: true, onOffShapes: true, onChanged: noop),
                const Oito2Switch(value: true, onChanged: null),
              ],
            ),
            Row(
              children: [
                Oito2CheckButton(
                  value: true,
                  onChanged: noop,
                  title: const Text('Check button'),
                  subtitle: const Text('With a subtitle'),
                ),
                Oito2RadioButton<int>(
                  value: 1,
                  groupValue: 1,
                  onChanged: noop,
                  title: const Text('Radio button'),
                ),
                Oito2SwitchButton(
                  value: true,
                  onChanged: noop,
                  title: const Text('Switch button'),
                ),
              ],
            ),
            Oito2BorderContainer(
              child: Column(
                children: [
                  Oito2CheckboxListTile(
                    value: true,
                    onChanged: noop,
                    title: const Text('Check box tile'),
                  ),
                  Oito2RadioListTile<int>(
                    value: 1,
                    groupValue: 1,
                    onChanged: noop,
                    title: const Text('Radio tile'),
                  ),
                  Oito2SwitchListTile(
                    value: false,
                    onChanged: noop,
                    title: const Text('Switch tile'),
                    subtitle: const Text('Off'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress indicators (determinate and still indeterminate) and the icon,
/// back and close buttons.
class _ProgressButtonsScene extends StatelessWidget {
  const _ProgressButtonsScene();

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(Oito2Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Oito2Spacing.md,
            children: [
              const Row(
                spacing: Oito2Spacing.md,
                children: [
                  Oito2CircularProgressIndicator(value: 0),
                  Oito2CircularProgressIndicator(value: 0.3),
                  Oito2CircularProgressIndicator(value: 0.75),
                  Oito2CircularProgressIndicator(value: 1),
                  Oito2CircularProgressIndicator(),
                  Oito2CircularProgressIndicator(size: 16, strokeWidth: 2),
                ],
              ),
              const Oito2LinearProgressIndicator(value: 0.4),
              const Oito2LinearProgressIndicator(),
              Row(
                children: [
                  Oito2IconButton(
                    icon: const Icon(LucideIcons.settings),
                    onPressed: () {},
                  ),
                  Oito2IconButton(
                    icon: const Icon(LucideIcons.bold),
                    isSelected: true,
                    onPressed: () {},
                  ),
                  Oito2IconButton(
                    icon: const Icon(LucideIcons.italic),
                    isSelected: false,
                    onPressed: () {},
                  ),
                  const Oito2IconButton(
                    icon: Icon(LucideIcons.trash),
                    onPressed: null,
                  ),
                  const Oito2BackButton(),
                  const Oito2CloseButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shortcut labels in two notations, the shortcut recorder and
/// highlighted search text.
class _ShortcutsScene extends StatelessWidget {
  const _ShortcutsScene();

  @override
  Widget build(BuildContext context) {
    final palette = Oito2Shortcut.parse('Mod+Shift+P');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.md,
          children: [
            Row(
              spacing: Oito2Spacing.lg,
              children: [
                Oito2ShortcutLabel(palette, platform: TargetPlatform.linux),
                Oito2ShortcutLabel(palette, platform: TargetPlatform.macOS),
                Oito2ShortcutLabel(Oito2Shortcut.parse('G H')),
              ],
            ),
            Row(
              spacing: Oito2Spacing.md,
              children: [
                Oito2ShortcutRecorder(value: palette, onChanged: (_) {}),
                Oito2ShortcutRecorder(value: null, onChanged: (_) {}),
              ],
            ),
            const Oito2HighlightedText(
              'Configurações de ação e acessibilidade',
              query: 'acao config',
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  for (final MapEntry(key: name, value: colors) in goldenSchemes.entries) {
    testWidgets('components in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _ComponentsScene(),
        name: 'components_$name',
        colors: colors,
      );
    });

    testWidgets('chrome and dialog in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _ChromeScene(),
        name: 'chrome_$name',
        colors: colors,
        size: const Size(720, 360),
      );
    });
  }

  for (final MapEntry(key: name, value: colors) in goldenSchemes.entries) {
    testWidgets('toggles in $name', (tester) async {
      final strategy = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = strategy);
      await expectGoldenScene(
        tester,
        const _TogglesScene(),
        name: 'toggles_$name',
        colors: colors,
        size: const Size(640, 360),
      );
    });
  }

  for (final MapEntry(key: name, value: colors) in goldenSchemes.entries) {
    testWidgets('progress and buttons in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _ProgressButtonsScene(),
        name: 'progress_buttons_$name',
        colors: colors,
        size: const Size(480, 200),
      );
    });
  }

  for (final name in ['light', 'dark']) {
    testWidgets('shortcuts in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _ShortcutsScene(),
        name: 'shortcuts_$name',
        colors: goldenSchemes[name]!,
        size: const Size(560, 180),
      );
    });

    testWidgets('command palette in $name', (tester) async {
      await expectGoldenScene(
        tester,
        Oito2Commands(
          commands: [
            Oito2Command(
              id: 'theme',
              label: 'Toggle dark style',
              group: 'View',
              icon: LucideIcons.moon,
              shortcut: Oito2Shortcut.parse('Mod+Shift+L'),
              onInvoke: () {},
            ),
            Oito2Command(
              id: 'settings',
              label: 'Open settings',
              icon: LucideIcons.settings,
              shortcut: Oito2Shortcut.parse('Mod+,'),
              onInvoke: () {},
            ),
            Oito2Command(
              id: 'home',
              label: 'Go to the first page',
              group: 'Navigation',
              icon: LucideIcons.house,
              shortcut: Oito2Shortcut.parse('G H'),
              onInvoke: () {},
            ),
          ],
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => showOito2CommandPalette(context),
              );
              return const Scaffold();
            },
          ),
        ),
        name: 'command_palette_$name',
        colors: goldenSchemes[name]!,
        size: const Size(640, 400),
        wholeApp: true,
      );
    });
  }

  for (final name in ['light', 'dark']) {
    testWidgets('title bars in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _TitleBarsScene(),
        name: 'title_bars_$name',
        colors: goldenSchemes[name]!,
        size: const Size(480, 320),
      );
    });
  }
}
