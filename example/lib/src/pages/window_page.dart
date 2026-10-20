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

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../widgets/showcase_widgets.dart';

/// A window controller for the title bar previews: it toggles the
/// maximized state and ignores the other actions, so the previews never
/// affect the real window.
class _PreviewWindowController implements Oito2WindowController {
  final ValueNotifier<Oito2WindowState> _state = ValueNotifier(
    const Oito2WindowState(),
  );

  @override
  ValueListenable<Oito2WindowState> get state => _state;

  /// Sets whether the previewed window is active.
  set isActive(bool value) =>
      _state.value = _state.value.copyWith(isActive: value);

  @override
  Future<void> toggleMaximize() async => _state.value = _state.value.copyWith(
    isMaximized: !_state.value.isMaximized,
  );

  @override
  Future<void> minimize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> startDrag() async {}

  @override
  Future<void> showMenu() async {}

  void dispose() => _state.dispose();
}

/// Previews the title bar in every window control style and layout, the
/// inactive state and the dialog title bar.
class WindowPage extends StatefulWidget {
  /// Creates the window page.
  const WindowPage({super.key});

  @override
  State<WindowPage> createState() => _WindowPageState();
}

class _WindowPageState extends State<WindowPage> {
  final _preview = _PreviewWindowController();
  bool _active = true;

  static const _styles = [
    ('GNOME, Budgie, Cinnamon, Pantheon', Oito2WindowControlStyle.gnome),
    ('KDE Plasma', Oito2WindowControlStyle.breeze),
    ('Xfce', Oito2WindowControlStyle.xfwm),
    ('COSMIC', Oito2WindowControlStyle.cosmic),
    ('Windows', Oito2WindowControlStyle.windows),
    ('macOS (drawn for preview)', Oito2WindowControlStyle.macos),
  ];

  @override
  void dispose() {
    _preview.dispose();
    super.dispose();
  }

  Widget _frame(Widget titleBar) {
    return Container(
      width: 560,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(borderRadius: Oito2Radius.windowAll),
      foregroundDecoration: BoxDecoration(
        borderRadius: Oito2Radius.windowAll,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          titleBar,
          Container(
            height: 48,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ],
      ),
    );
  }

  void _openDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Oito2DialogTitleBar(title: Text('Preferences')),
              Padding(
                padding: const EdgeInsets.all(Oito2Spacing.xl),
                child: Text(
                  'The close button follows the system button style and '
                  'side, and pops the dialog.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Oito2SystemScope.of(context);
    final macLayout = Oito2WindowButtonLayout.defaultFor(
      Oito2WindowControlStyle.macos,
    );
    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'This window',
          children: [
            Text(
              'Control style: ${settings.windowControlStyle.name} · '
              'leading: ${settings.windowButtonLayout.leading.map((b) => b.name).join(', ')} · '
              'trailing: ${settings.windowButtonLayout.trailing.map((b) => b.name).join(', ')}',
            ),
          ],
        ),
        ShowcaseSection(
          'Control styles',
          children: [
            for (final (name, style) in _styles)
              _frame(
                Oito2TitleBar(
                  title: Text(name),
                  controlStyle: style,
                  buttonLayout: style == Oito2WindowControlStyle.macos
                      ? macLayout
                      : Oito2WindowButtonLayout.defaultFor(style),
                  centerTitle: style != Oito2WindowControlStyle.windows,
                  controller: _preview,
                  isDraggable: false,
                ),
              ),
          ],
        ),
        ShowcaseSection(
          'Button layouts',
          children: [
            for (final (name, layout) in [
              (
                'GNOME default: appmenu:close',
                Oito2WindowButtonLayout.parseGnome('appmenu:close'),
              ),
              (
                'Left side: close,minimize,maximize:',
                Oito2WindowButtonLayout.parseGnome('close,minimize,maximize:'),
              ),
              (
                'KDE: ButtonsOnLeft=X, ButtonsOnRight=IA',
                Oito2WindowButtonLayout.parseKde(
                  buttonsOnLeft: 'X',
                  buttonsOnRight: 'IA',
                ),
              ),
            ])
              _frame(
                Oito2TitleBar(
                  title: Text(name),
                  buttonLayout: layout,
                  controller: _preview,
                  isDraggable: false,
                ),
              ),
          ],
        ),
        ShowcaseSection(
          'Inactive window',
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Window active'),
              value: _active,
              onChanged: (value) => setState(() {
                _active = value;
                _preview.isActive = value;
              }),
            ),
          ],
        ),
        ShowcaseSection(
          'Dialog title bar',
          children: [
            OutlinedButton(
              onPressed: _openDialog,
              child: const Text('Open dialog'),
            ),
          ],
        ),
      ],
    );
  }
}
