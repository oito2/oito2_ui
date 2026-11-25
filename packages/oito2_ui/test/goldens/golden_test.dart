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

@Tags(['golden'])
library;

import 'dart:async';

import 'package:flutter/services.dart';
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
                    icon: const Icon(LucideIcons.letter_b),
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

final _goldenDesktops = Oito2ListCollection(
  const [
    ('gnome', 'GNOME', 'GTK'),
    ('xfce', 'Xfce', 'GTK'),
    ('kde', 'KDE Plasma', 'Qt'),
    ('lxqt', 'LXQt', 'Qt'),
  ],
  valueOf: (d) => d.$1,
  labelOf: (d) => d.$2,
  groupOf: (d) => d.$3,
  isDisabled: (d) => d.$1 == 'lxqt',
);

/// The select, a list tile list, an expansion panel and a tab bar.
class _MenusListsScene extends StatelessWidget {
  const _MenusListsScene();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(Oito2Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Oito2Spacing.md,
            children: [
              Row(
                spacing: Oito2Spacing.md,
                children: [
                  Oito2Select(
                    collection: _goldenDesktops,
                    value: 'kde',
                    onChanged: (_) {},
                  ),
                  Oito2Select(
                    collection: _goldenDesktops,
                    value: null,
                    placeholder: const Text('Desktop'),
                    onChanged: (_) {},
                  ),
                  const Expanded(
                    child: Oito2TabBar(
                      tabs: [
                        Oito2Tab(label: Text('General')),
                        Oito2Tab(label: Text('Appearance')),
                        Oito2Tab(label: Text('About')),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Oito2Spacing.md,
                children: [
                  Expanded(
                    child: Oito2TileList(
                      children: [
                        Oito2ListTile.square(
                          leading: const Icon(LucideIcons.wifi),
                          titleText: 'Wi-Fi',
                          subtitleText: 'Connected',
                          trailing: const Icon(LucideIcons.chevron_right),
                          onTap: () {},
                        ),
                        Oito2ListTile.square(
                          leading: const Icon(LucideIcons.bluetooth),
                          titleText: 'Bluetooth',
                          selected: true,
                          onTap: () {},
                        ),
                        Oito2ListTile.square(
                          leading: const Icon(LucideIcons.plane),
                          titleText: 'Airplane mode',
                          enabled: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Oito2ExpansionPanel(
                      initiallyExpanded: {0},
                      headers: [Text('Privacy'), Text('Storage')],
                      children: [
                        Text('Location services are off.'),
                        Text('12 GB used of 64 GB.'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated icons at their final frame, placeholders and freedesktop icons.
class _IconsScene extends StatelessWidget {
  const _IconsScene();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.md,
          children: [
            Wrap(
              spacing: Oito2Spacing.md,
              children: [
                for (final data in const [
                  Oito2AnimatedIcons.ok,
                  Oito2AnimatedIcons.okFilled,
                  Oito2AnimatedIcons.heart,
                  Oito2AnimatedIcons.heartFilled,
                  Oito2AnimatedIcons.star,
                  Oito2AnimatedIcons.starFilled,
                  Oito2AnimatedIcons.starHalfFilled,
                  Oito2AnimatedIcons.compass,
                  Oito2AnimatedIcons.compassFilled,
                  Oito2AnimatedIcons.noNetwork,
                ])
                  Oito2AnimatedIcon(
                    data,
                    size: 32,
                    mode: Oito2AnimationMode.still,
                  ),
              ],
            ),
            Oito2AnimatedIcon(
              Oito2AnimatedIcons.heartFilled,
              size: 32,
              color: primary,
              mode: Oito2AnimationMode.still,
            ),
            const Row(
              spacing: Oito2Spacing.md,
              children: [
                Oito2PlaceholderIcon(size: 32),
                Oito2PlaceholderIcon(),
                Oito2PlaceholderIcon(
                  size: 72,
                  borderRadius: Oito2Radius.largeAll,
                ),
              ],
            ),
            Wrap(
              spacing: Oito2Spacing.md,
              children: [
                for (final icon in Oito2FreedesktopIcons.values.take(12))
                  Icon(icon.icon),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Two open popovers, one with an arrow, over a stack of toasts.
class _OverlaysScene extends StatefulWidget {
  const _OverlaysScene();

  @override
  State<_OverlaysScene> createState() => _OverlaysSceneState();
}

class _OverlaysSceneState extends State<_OverlaysScene> {
  final _toaster = GlobalKey<Oito2ToasterState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _toaster.currentState!
        ..show(
          Oito2Toast(
            title: 'File saved',
            type: Oito2InfoType.success,
            actionLabel: 'Open',
            onAction: () {},
            duration: null,
          ),
        )
        ..show(
          const Oito2Toast(
            title: 'Connection lost',
            description: 'Changes are kept on this device.',
            type: Oito2InfoType.warning,
            duration: null,
          ),
        );
    });
  }

  Widget _popover(String label, Oito2PopoverPlacement placement, bool arrow) {
    return Oito2Popover(
      controller: Oito2PopoverController()..open(),
      placement: placement,
      showArrow: arrow,
      focusOnOpen: false,
      builder: (context, _) =>
          OutlinedButton(onPressed: () {}, child: Text(label)),
      popoverBuilder: (context, _) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Oito2Spacing.xs,
        children: [Text('Share link'), Text('Anyone with the link can view.')],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Oito2Toaster(
      key: _toaster,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(Oito2Spacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _popover('Plain', Oito2PopoverPlacement.bottom, false),
              _popover('Arrow', Oito2PopoverPlacement.bottom, true),
            ],
          ),
        ),
      ),
    );
  }
}

/// A modal end sheet, opened once after the first frame.
class _SheetScene extends StatefulWidget {
  const _SheetScene();

  @override
  State<_SheetScene> createState() => _SheetSceneState();
}

class _SheetSceneState extends State<_SheetScene> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showOito2Sheet<void>(
        context,
        builder: (_) => Oito2Sheet(
          title: const Text('Filters'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Oito2CheckboxListTile(
                value: true,
                onChanged: (_) {},
                title: const Text('Images'),
              ),
              Oito2CheckboxListTile(
                value: false,
                onChanged: (_) {},
                title: const Text('Documents'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Page')));
  }
}

/// A tour step pointing at a button.
class _TourScene extends StatefulWidget {
  const _TourScene();

  @override
  State<_TourScene> createState() => _TourSceneState();
}

class _TourSceneState extends State<_TourScene> {
  final _target = GlobalKey();
  late final _controller = Oito2TourController(
    steps: [
      Oito2TourStep(
        target: _target,
        title: 'Create a project',
        description: 'Start here to set up your first project.',
      ),
      const Oito2TourStep(title: 'Done'),
    ],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.start());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Oito2Tour(
        controller: _controller,
        child: Padding(
          padding: const EdgeInsets.all(Oito2Spacing.xl),
          child: Align(
            alignment: Alignment.topLeft,
            child: FilledButton(
              key: _target,
              onPressed: () {},
              child: const Text('New project'),
            ),
          ),
        ),
      ),
    );
  }
}

/// Number, password, code, editable label, tags, rating and angle inputs.
class _EntriesScene extends StatelessWidget {
  const _EntriesScene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.md,
          children: [
            Row(
              spacing: Oito2Spacing.md,
              children: [
                SizedBox(
                  width: 180,
                  child: Oito2NumberEntry(
                    value: 12,
                    onChanged: (_) {},
                    labelText: 'Copies',
                  ),
                ),
                const SizedBox(
                  width: 220,
                  child: Oito2PasswordField(labelText: 'Password'),
                ),
              ],
            ),
            Row(
              spacing: Oito2Spacing.lg,
              children: [
                Oito2PinEntry(
                  length: 4,
                  controller: TextEditingController(text: '42'),
                ),
                Oito2EditableLabel(text: 'Project notes', onSubmitted: (_) {}),
              ],
            ),
            SizedBox(
              width: 360,
              child: Oito2TagsField(
                tags: const ['flutter', 'dart', 'linux'],
                onChanged: (_) {},
                hintText: 'Add tag',
              ),
            ),
            Row(
              spacing: Oito2Spacing.xl,
              children: [
                Oito2Rating(value: 3.5, allowHalf: true, onChanged: (_) {}),
                Oito2AngleSlider(value: 135, onChanged: (_) {}, size: 72),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A list box, a color picker and a calendar range with week numbers.
class _PickersScene extends StatelessWidget {
  const _PickersScene();

  @override
  Widget build(BuildContext context) {
    final fruits = Oito2ListCollection(const [
      'Apple',
      'Banana',
      'Cherry',
      'Date',
    ], isDisabled: (f) => f == 'Cherry');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.lg,
          children: [
            SizedBox(
              width: 140,
              child: Oito2ListBox(
                collection: fruits,
                controller: Oito2SelectionController(
                  collection: fruits,
                  mode: Oito2SelectionMode.multiple,
                  initialValues: const ['Apple', 'Date'],
                ),
              ),
            ),
            Oito2ColorPicker(
              value: const Color(0xCC3584E4),
              onChanged: (_) {},
              width: 220,
              swatches: const [
                Color(0xFFE01B24),
                Color(0xFFFF7800),
                Color(0xFF2EC27E),
                Color(0xFF3584E4),
              ],
            ),
            Oito2Calendar(
              firstDate: DateTime(2026),
              lastDate: DateTime(2026, 12, 31),
              initialMonth: DateTime(2026, 10),
              currentDate: DateTime(2026, 10, 20),
              showWeekNumbers: true,
              selectedRange: DateTimeRange(
                start: DateTime(2026, 10, 6),
                end: DateTime(2026, 10, 14),
              ),
              onRangeSelected: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

/// Pagination, steps, avatars, a copy field and a timer.
class _DisplayScene extends StatelessWidget {
  const _DisplayScene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.lg,
          children: [
            Oito2Pagination(page: 5, pageCount: 12, onChanged: (_) {}),
            Oito2Steps(
              current: 1,
              onStepTapped: (_) {},
              steps: const [
                Oito2Step(title: 'Account', description: 'Your e-mail'),
                Oito2Step(title: 'Profile'),
                Oito2Step(title: 'Payment', hasError: true),
                Oito2Step(title: 'Done'),
              ],
            ),
            Row(
              spacing: Oito2Spacing.md,
              children: [
                const Oito2Avatar(
                  name: 'Ana Souza',
                  status: Oito2AvatarStatus.online,
                ),
                const Oito2Avatar(
                  name: 'Bruno Lima',
                  shape: Oito2AvatarShape.square,
                  status: Oito2AvatarStatus.busy,
                ),
                const Oito2Avatar(),
                Oito2AvatarGroup(
                  max: 3,
                  avatars: [
                    for (final name in [
                      'Ana Souza',
                      'Bruno Lima',
                      'Caio',
                      'Dani',
                      'Eva',
                    ])
                      Oito2Avatar(name: name, size: 32),
                  ],
                ),
                Oito2TimerText(
                  controller: Oito2TimerController(
                    countdown: const Duration(minutes: 4, seconds: 30),
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(
              width: 320,
              child: Oito2CopyField(
                value: 'https://oito2.github.io/oito2_ui/',
                labelText: 'Link',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A checkable tree, a JSON tree, a splitter and a table of contents.
class _DataScene extends StatelessWidget {
  const _DataScene();

  @override
  Widget build(BuildContext context) {
    final files = Oito2TreeCollection<void>.fromPaths(const [
      'lib/main.dart',
      'lib/src/app.dart',
      'lib/src/home.dart',
      'test/app_test.dart',
      'README.md',
    ]);
    final controller = Oito2TreeController(
      expanded: files.branchValues,
      selected: const ['lib/src/app.dart'],
      checked: const ['lib/main.dart', 'lib/src/app.dart'],
    );
    final scroll = ScrollController();
    final keys = [GlobalKey(), GlobalKey(), GlobalKey()];
    return Scaffold(
      body: Oito2Splitter(
        panes: [
          Oito2SplitterPane(
            initialFraction: 0.34,
            child: Oito2TreeView(
              collection: files,
              controller: controller,
              checkable: true,
            ),
          ),
          Oito2SplitterPane(
            child: Oito2Splitter(
              axis: Axis.vertical,
              panes: [
                const Oito2SplitterPane(
                  child: Oito2JsonTreeView(
                    expandDepth: 2,
                    data: {
                      'name': 'oito2_ui',
                      'version': '0.1.0',
                      'stars': 42,
                      'published': false,
                      'license': null,
                      'tags': ['flutter', 'ui'],
                    },
                  ),
                ),
                Oito2SplitterPane(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Oito2TableOfContents(
                          controller: scroll,
                          entries: [
                            Oito2TocEntry(title: 'Install', target: keys[0]),
                            Oito2TocEntry(
                              title: 'Linux',
                              target: keys[1],
                              depth: 1,
                            ),
                            Oito2TocEntry(title: 'Usage', target: keys[2]),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scroll,
                          children: [
                            for (var i = 0; i < 3; i++)
                              SizedBox(
                                key: keys[i],
                                height: 120,
                                child: Text('Section $i'),
                              ),
                          ],
                        ),
                      ),
                    ],
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

/// A floating panel over a page.
class _FloatingPanelScene extends StatelessWidget {
  const _FloatingPanelScene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(child: Text('Page content')),
          Oito2FloatingPanel(
            title: 'Inspector',
            initialRect: const Rect.fromLTWH(40, 30, 300, 200),
            onClose: () {},
            child: const Padding(
              padding: EdgeInsets.all(Oito2Spacing.md),
              child: Text('Width: 320\nHeight: 240\nOpacity: 100%'),
            ),
          ),
        ],
      ),
    );
  }
}

/// A carousel and the page indicator layouts.
class _CarouselScene extends StatelessWidget {
  const _CarouselScene();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.md,
          children: [
            Oito2Carousel(
              height: 140,
              children: [
                for (final color in [
                  scheme.primaryContainer,
                  scheme.secondaryContainer,
                  scheme.tertiaryContainer,
                ])
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: Oito2Radius.largeAll,
                    ),
                  ),
              ],
            ),
            for (final layout in Oito2PageIndicatorLayout.values)
              SizedBox(
                width: 200,
                child: Oito2PageIndicator(length: 9, page: 2, layout: layout),
              ),
          ],
        ),
      ),
    );
  }
}

/// The three navigation rail styles side by side.
class _RailsScene extends StatelessWidget {
  const _RailsScene();

  @override
  Widget build(BuildContext context) {
    const items = [
      Oito2NavigationItem(icon: Icon(LucideIcons.house), label: 'Home'),
      Oito2NavigationItem(icon: Icon(LucideIcons.search), label: 'Search'),
      Oito2NavigationItem(icon: Icon(LucideIcons.settings), label: 'Settings'),
    ];
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final style in Oito2NavigationRailStyle.values) ...[
            Oito2NavigationRail(
              items: items,
              selectedIndex: 1,
              style: style,
              onDestinationSelected: (_) {},
            ),
            const VerticalDivider(width: 1),
          ],
        ],
      ),
    );
  }
}

typedef _Transfer = (String, String, double, String);

/// A data table of transfers, sorted by size, with a selected row and a
/// progress column, its first [pinned] columns pinned and, when there are
/// any, a fixed-width name column.
class _DataTableScene extends StatelessWidget {
  const _DataTableScene({this.pinned = 0});

  final int pinned;

  static final _transfers = Oito2ListCollection(const [
    ('report.pdf', '2.4 MB', 1.0, 'Done'),
    ('photos.zip', '148 MB', 0.42, 'Uploading'),
    ('notes.txt', '12 kB', 0.0, 'Queued'),
    ('backup.tar', '1.2 GB', 0.08, 'Paused'),
  ], valueOf: (t) => t.$1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.md),
        child: Oito2DataTable<_Transfer>(
          collection: _transfers,
          controller: Oito2SelectionController(
            collection: _transfers,
            initialValues: const ['photos.zip'],
          ),
          sort: const Oito2SortDescriptor(
            'size',
            Oito2SortDirection.descending,
          ),
          onSortChanged: (_) {},
          pinnedColumns: pinned,
          columns: [
            Oito2TableColumn<_Transfer>(
              id: 'name',
              label: 'Name',
              // A pinned name keeps its width while the table scrolls.
              width: pinned > 0
                  ? const Oito2ColumnWidth.fixed(140)
                  : const Oito2ColumnWidth.flex(1),
              sortable: true,
              resizable: true,
            ),
            Oito2TableColumn(
              id: 'size',
              label: 'Size',
              width: const Oito2ColumnWidth.fixed(90),
              alignment: AlignmentDirectional.centerEnd,
              sortable: true,
              cellBuilder: (context, t) => Text(t.$2),
            ),
            Oito2TableColumn(
              id: 'progress',
              label: 'Progress',
              width: const Oito2ColumnWidth.fixed(120),
              cellBuilder: (context, t) =>
                  Oito2LinearProgressIndicator(value: t.$3),
            ),
            Oito2TableColumn(
              id: 'status',
              label: 'Status',
              width: const Oito2ColumnWidth.fixed(100),
              cellBuilder: (context, t) => Text(t.$4),
            ),
          ],
        ),
      ),
    );
  }
}

/// An alert stack with a hidden alert, a compact alert, status pills, a
/// still skeleton and a compact status page.
class _FeedbackScene extends StatelessWidget {
  const _FeedbackScene();

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(Oito2Spacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Oito2Spacing.lg,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Oito2Spacing.md,
                  children: [
                    Oito2AlertStack(
                      maxVisible: 2,
                      alerts: [
                        const Oito2Alert(
                          key: ValueKey('info'),
                          type: Oito2InfoType.information,
                          title: Text('Update available'),
                        ),
                        Oito2Alert(
                          key: const ValueKey('danger'),
                          type: Oito2InfoType.danger,
                          title: const Text('Sync failed'),
                          message: const Text('The server did not answer.'),
                          actions: [
                            TextButton(
                              onPressed: () {},
                              child: const Text('Retry'),
                            ),
                          ],
                          onDismiss: () {},
                        ),
                        const Oito2Alert(
                          key: ValueKey('warning'),
                          type: Oito2InfoType.warning,
                          title: Text('Low disk space'),
                          message: Text('2 GB left on the system disk.'),
                        ),
                      ],
                    ),
                    Oito2Alert(
                      type: Oito2InfoType.success,
                      compact: true,
                      title: const Text('Saved'),
                      message: const Text('All changes are stored.'),
                      onDismiss: () {},
                    ),
                    const Wrap(
                      spacing: Oito2Spacing.sm,
                      runSpacing: Oito2Spacing.sm,
                      children: [
                        Oito2StatusPill(label: 'Draft'),
                        Oito2StatusPill(
                          label: 'Synced',
                          type: Oito2InfoType.success,
                        ),
                        Oito2StatusPill(
                          label: 'Expiring',
                          type: Oito2InfoType.warning,
                        ),
                        Oito2StatusPill(
                          label: 'Offline',
                          type: Oito2InfoType.danger,
                          icon: Icon(LucideIcons.wifi_off),
                        ),
                        Oito2StatusPill(
                          label: 'Beta',
                          type: Oito2InfoType.important,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Oito2Spacing.md,
                  children: [
                    Row(
                      spacing: Oito2Spacing.md,
                      children: [
                        Oito2Skeleton.circle(),
                        Expanded(child: Oito2Skeleton.text(lines: 2)),
                      ],
                    ),
                    Oito2Skeleton.rect(height: 64),
                    SizedBox(
                      height: 200,
                      child: Oito2StatusPage(
                        compact: true,
                        icon: Icon(LucideIcons.search_x),
                        title: Text('No results'),
                        description: Text('Try other words.'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A full status page with an icon, a description and actions.
class _StatusPageScene extends StatelessWidget {
  const _StatusPageScene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Oito2StatusPage(
        icon: const Icon(LucideIcons.cloud_off),
        title: const Text('Couldn\'t load the files'),
        description: const Text(
          'Check the connection and try again. Files saved on this device '
          'are still available.',
        ),
        actions: [
          FilledButton(onPressed: () {}, child: const Text('Retry')),
          OutlinedButton(onPressed: () {}, child: const Text('Open offline')),
        ],
      ),
    );
  }
}

enum _Bandwidth { unlimited, limited, paused }

/// A bandwidth schedule: limited on weekday working hours, paused on
/// weekend nights, with a focused cell and a keyboard selection.
class _ScheduleScene extends StatelessWidget {
  const _ScheduleScene();

  static final _schedule = [
    for (var day = 0; day < 7; day++)
      for (var hour = 0; hour < 24; hour++)
        if (day < 5 && hour >= 9 && hour < 18)
          _Bandwidth.limited
        else if (day >= 5 && hour < 6)
          _Bandwidth.paused
        else
          _Bandwidth.unlimited,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.md),
        child: Oito2WeekScheduleGrid<_Bandwidth>(
          values: const [
            Oito2ScheduleValue(
              value: _Bandwidth.unlimited,
              label: 'Unlimited',
              type: Oito2InfoType.success,
            ),
            Oito2ScheduleValue(
              value: _Bandwidth.limited,
              label: 'Limited',
              type: Oito2InfoType.warning,
            ),
            Oito2ScheduleValue(
              value: _Bandwidth.paused,
              label: 'Paused',
              type: Oito2InfoType.danger,
            ),
          ],
          schedule: _schedule,
          paintValue: _Bandwidth.limited,
          onChanged: (_) {},
        ),
      ),
    );
  }
}

/// Usage bars below, at and above the thresholds, over quota, and a
/// compact bar in a narrow column.
class _UsageScene extends StatelessWidget {
  const _UsageScene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.lg,
          children: [
            const Expanded(
              child: Column(
                spacing: Oito2Spacing.md,
                children: [
                  Oito2UsageBar.bytes(
                    title: Text('Personal'),
                    used: 4200000000,
                    total: 15000000000,
                  ),
                  Oito2UsageBar.bytes(
                    title: Text('Work'),
                    used: 11500000000,
                    total: 15000000000,
                  ),
                  Oito2UsageBar.bytes(
                    title: Text('Shared'),
                    used: 14200000000,
                    total: 15000000000,
                  ),
                  Oito2UsageBar.bytes(
                    title: Text('Archive'),
                    used: 16800000000,
                    total: 15000000000,
                  ),
                  Oito2UsageBar(title: Text('Upload'), value: 0.42),
                ],
              ),
            ),
            SizedBox(
              width: 170,
              child: Column(
                spacing: Oito2Spacing.md,
                children: const [
                  Oito2UsageBar.bytes(
                    title: Text('Drive'),
                    used: 3100000000,
                    total: 15000000000,
                    compact: true,
                  ),
                  Oito2UsageBar(value: 0.93, compact: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The accounts of the account switcher scene.
const _goldenAccounts = [
  Oito2Account(
    id: 'ana',
    name: 'Ana Souza',
    subtitle: 'ana@example.com',
    status: Oito2AvatarStatus.online,
    count: 3,
  ),
  Oito2Account(
    id: 'work',
    name: 'Bruno Lima',
    subtitle: 'bruno@work.example',
    status: Oito2AvatarStatus.busy,
    count: 128,
  ),
  Oito2Account(
    id: 'carla',
    name: 'Carla Dias',
    subtitle: 'carla@example.org',
    status: Oito2AvatarStatus.offline,
  ),
];

/// An extended rail and a compact rail led by account switchers, with the
/// extended one's menu open.
class _AccountSwitcherScene extends StatelessWidget {
  const _AccountSwitcherScene();

  static const _items = [
    Oito2NavigationItem(icon: Icon(LucideIcons.inbox), label: 'Inbox'),
    Oito2NavigationItem(icon: Icon(LucideIcons.send), label: 'Sent'),
  ];

  Widget _rail(Oito2NavigationRailStyle style) => Oito2NavigationRail(
    items: _items,
    selectedIndex: 0,
    onDestinationSelected: (_) {},
    style: style,
    leading: Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.sm),
      child: Oito2AccountSwitcher(
        accounts: _goldenAccounts,
        current: _goldenAccounts.first,
        onSelected: (_) {},
        onAdd: () {},
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rail(Oito2NavigationRailStyle.labelledExtended),
          const VerticalDivider(width: 1),
          const Spacer(),
          const VerticalDivider(width: 1),
          _rail(Oito2NavigationRailStyle.compact),
        ],
      ),
    );
  }
}

/// A path bar with every segment, the same path collapsed in a narrow
/// width, and an editable one.
class _BreadcrumbScene extends StatelessWidget {
  const _BreadcrumbScene();

  static const _items = [
    Oito2BreadcrumbItem<String>(label: 'Home', icon: LucideIcons.house),
    Oito2BreadcrumbItem<String>(label: 'Documents'),
    Oito2BreadcrumbItem<String>(label: 'Projects'),
    Oito2BreadcrumbItem<String>(label: 'oito2'),
    Oito2BreadcrumbItem<String>(label: 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.lg,
          children: [
            Oito2Breadcrumb(items: _items, onSelected: (_) {}),
            SizedBox(
              width: 260,
              child: Oito2Breadcrumb(items: _items, onSelected: (_) {}),
            ),
            Oito2Breadcrumb(
              items: _items,
              onSelected: (_) {},
              onSubmitted: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

/// A grouped property list beside the same list stacked in a narrow
/// column.
class _PropertyListScene extends StatelessWidget {
  const _PropertyListScene();

  static const _groups = [
    Oito2PropertyGroup(
      heading: 'General',
      properties: [
        Oito2Property(label: 'Name', value: 'report.pdf'),
        Oito2Property(label: 'Size', value: '2.4 MB (2,412,544 bytes)'),
        Oito2Property(
          label: 'Location',
          value: '/home/ana/Documents',
          copyable: true,
        ),
      ],
    ),
    Oito2PropertyGroup(
      heading: 'Sync',
      properties: [
        Oito2Property.widget(
          label: 'Status',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Oito2StatusPill(
              label: 'Synced',
              type: Oito2InfoType.success,
            ),
          ),
        ),
        Oito2Property(label: 'Modified', value: 'Nov 17, 2026 10:42'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Oito2Spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Oito2Spacing.lg,
          children: [
            const Expanded(child: Oito2PropertyList.grouped(groups: _groups)),
            SizedBox(
              width: 200,
              child: Oito2PropertyList(properties: _groups.first.properties),
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

  for (final MapEntry(key: name, value: colors) in goldenSchemes.entries) {
    testWidgets('menus and lists in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _MenusListsScene(),
        name: 'menus_lists_$name',
        colors: colors,
        size: const Size(720, 320),
      );
    });
  }

  for (final MapEntry(key: name, value: colors) in goldenSchemes.entries) {
    testWidgets('icons in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _IconsScene(),
        name: 'icons_$name',
        colors: colors,
        size: const Size(520, 280),
      );
    });
  }

  for (final MapEntry(key: name, value: colors) in goldenSchemes.entries) {
    testWidgets('overlays in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _OverlaysScene(),
        name: 'overlays_$name',
        colors: colors,
        size: const Size(560, 360),
        wholeApp: true,
      );
    });
  }

  for (final name in ['light', 'dark']) {
    testWidgets('sheet in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _SheetScene(),
        name: 'sheet_$name',
        colors: goldenSchemes[name]!,
        size: const Size(640, 360),
        wholeApp: true,
      );
    });

    testWidgets('tour in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _TourScene(),
        name: 'tour_$name',
        colors: goldenSchemes[name]!,
        size: const Size(520, 300),
        wholeApp: true,
      );
    });
  }

  for (final MapEntry(key: name, value: colors) in goldenSchemes.entries) {
    testWidgets('entries in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _EntriesScene(),
        name: 'entries_wave9_$name',
        colors: colors,
        size: const Size(520, 340),
      );
    });

    testWidgets('pickers in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _PickersScene(),
        name: 'pickers_$name',
        colors: colors,
        size: const Size(860, 460),
      );
    });
  }

  for (final MapEntry(key: name, value: colors) in goldenSchemes.entries) {
    testWidgets('display in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _DisplayScene(),
        name: 'display_$name',
        colors: colors,
        size: const Size(640, 360),
      );
    });

    testWidgets('data views in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _DataScene(),
        name: 'data_views_$name',
        colors: colors,
        size: const Size(720, 420),
      );
    });
  }

  for (final name in ['light', 'dark']) {
    testWidgets('floating panel in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _FloatingPanelScene(),
        name: 'floating_panel_$name',
        colors: goldenSchemes[name]!,
        size: const Size(480, 300),
      );
    });
  }

  for (final MapEntry(key: name, value: colors) in goldenSchemes.entries) {
    testWidgets('carousel in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _CarouselScene(),
        name: 'carousel_$name',
        colors: colors,
        size: const Size(520, 320),
      );
    });
  }

  for (final name in ['light', 'dark']) {
    testWidgets('open autocomplete in $name', (tester) async {
      await expectGoldenScene(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(Oito2Spacing.lg),
            child: SizedBox(
              width: 280,
              child: Oito2Autocomplete<String>(
                collection: Oito2ListCollection(const [
                  'Belo Horizonte',
                  'Salvador',
                  'São Paulo',
                  'Santos',
                ]),
                hintText: 'City',
              ),
            ),
          ),
        ),
        name: 'open_autocomplete_$name',
        setup: () => tester.enterText(find.byType(TextField), 'sa'),
        colors: goldenSchemes[name]!,
        size: const Size(320, 240),
        wholeApp: true,
      );
    });
  }

  for (final MapEntry(key: name, value: colors) in goldenSchemes.entries) {
    testWidgets('navigation rails in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _RailsScene(),
        name: 'rails_$name',
        colors: colors,
        size: const Size(460, 240),
      );
    });
  }

  for (final name in ['light', 'dark']) {
    testWidgets('open select in $name', (tester) async {
      await expectGoldenScene(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(Oito2Spacing.lg),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Oito2Select(
                collection: _goldenDesktops,
                value: 'kde',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
        name: 'open_select_$name',
        setup: () => tester.tap(find.text('KDE Plasma')),
        colors: goldenSchemes[name]!,
        size: const Size(320, 280),
        wholeApp: true,
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
          child: const Scaffold(),
        ),
        name: 'command_palette_$name',
        setup: () async {
          // The palette's future completes when it closes, so it isn't
          // awaited.
          unawaited(
            showOito2CommandPalette(tester.element(find.byType(Scaffold))),
          );
        },
        colors: goldenSchemes[name]!,
        size: const Size(640, 400),
        wholeApp: true,
      );
    });
  }

  for (final name in ['light', 'dark']) {
    testWidgets('data table in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _DataTableScene(),
        name: 'data_table_$name',
        colors: goldenSchemes[name]!,
        size: const Size(560, 220),
      );
    });
  }

  for (final name in ['light', 'dark']) {
    testWidgets('data table with a pinned column scrolled in $name', (
      tester,
    ) async {
      await expectGoldenScene(
        tester,
        const _DataTableScene(pinned: 1),
        name: 'data_table_pinned_$name',
        colors: goldenSchemes[name]!,
        size: const Size(400, 220),
        setup: () async {
          final scrollable = find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
          );
          tester.state<ScrollableState>(scrollable).position.jumpTo(80);
        },
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

  for (final name in ['light', 'dark']) {
    testWidgets('feedback in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _FeedbackScene(),
        name: 'feedback_$name',
        colors: goldenSchemes[name]!,
        size: const Size(720, 420),
      );
    });

    testWidgets('status page in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _StatusPageScene(),
        name: 'status_page_$name',
        colors: goldenSchemes[name]!,
        size: const Size(520, 360),
      );
    });
  }

  for (final name in ['light', 'dark']) {
    testWidgets('week schedule grid in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _ScheduleScene(),
        name: 'week_schedule_$name',
        colors: goldenSchemes[name]!,
        size: const Size(760, 340),
        setup: () async {
          FocusManager.instance.highlightStrategy =
              FocusHighlightStrategy.alwaysTraditional;
          addTearDown(
            () => FocusManager.instance.highlightStrategy =
                FocusHighlightStrategy.automatic,
          );
          await tester.tap(find.byType(Oito2WeekScheduleGrid<_Bandwidth>));
          await tester.sendKeyEvent(LogicalKeyboardKey.home);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        },
      );
    });

    testWidgets('usage bars in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _UsageScene(),
        name: 'usage_bars_$name',
        colors: goldenSchemes[name]!,
        size: const Size(560, 300),
      );
    });

    testWidgets('property list in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _PropertyListScene(),
        name: 'property_list_$name',
        colors: goldenSchemes[name]!,
        size: const Size(720, 320),
      );
    });

    testWidgets('account switcher in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _AccountSwitcherScene(),
        name: 'account_switcher_$name',
        colors: goldenSchemes[name]!,
        size: const Size(640, 360),
        wholeApp: true,
        setup: () => tester.tap(find.text('Ana Souza')),
      );
    });

    testWidgets('breadcrumb in $name', (tester) async {
      await expectGoldenScene(
        tester,
        const _BreadcrumbScene(),
        name: 'breadcrumb_$name',
        colors: goldenSchemes[name]!,
        size: const Size(560, 200),
      );
    });
  }
}
