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

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';

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

/// Documents [Oito2TitleBar], [Oito2WindowTitleBar] and the window
/// controls in every control style and button layout, and the inactive
/// window state.
class TitleBarPage extends StatefulWidget {
  /// Creates the title bar page.
  const TitleBarPage({super.key});

  @override
  State<TitleBarPage> createState() => _TitleBarPageState();
}

class _TitleBarPageState extends State<TitleBarPage> {
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

  /// A miniature window with [titleBar] above an empty page.
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

  @override
  Widget build(BuildContext context) {
    final settings = Oito2SystemScope.of(context);
    final macLayout = Oito2WindowButtonLayout.defaultFor(
      Oito2WindowControlStyle.macos,
    );
    return DocPage(
      title: 'Title Bar',
      description:
          'A desktop header bar with a title, actions and window control '
          'buttons drawn in the style of the user\'s desktop.',
      source: 'lib/src/pages/title_bar_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: _frame(
            // #region preview
            Oito2TitleBar(
              title: const Text('Documents'),
              controller: _preview,
              isDraggable: false,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Most apps use `Oito2WindowTitleBar`, which adapts to the platform: '
          'on native Linux and Windows it draws the control style and button '
          'layout of the system; on native macOS it keeps room for the '
          'native traffic lights; on the web it shows the title and actions '
          'without window buttons; and on touch platforms it is a regular '
          '`AppBar`. Its controller defaults to the closest '
          '`Oito2WindowScope`.',
        ),
        const DocText(
          'The `oito2_ui_window` package connects the bar to the native '
          'window: `Oito2Window.ensureInitialized` hides the native title '
          'bar and returns a controller, or null where the app does not own '
          'a desktop window, which an `Oito2WindowScope` provides to the '
          'app.',
        ),
        const DocCode(
          "import 'package:oito2_ui/oito2_ui.dart';\n"
          "import 'package:oito2_ui_window/oito2_ui_window.dart';",
        ),
        const DocCode(
          'Future<void> main() async {\n'
          '  WidgetsFlutterBinding.ensureInitialized();\n'
          '  final window = await Oito2Window.ensureInitialized(\n'
          "    title: 'My app',\n"
          '    size: const Size(1280, 820),\n'
          '  );\n'
          '  runApp(Oito2WindowScope(controller: window, child: const MyApp()));\n'
          '}\n'
          '\n'
          '// In a page:\n'
          'Scaffold(\n'
          "  appBar: const Oito2WindowTitleBar(title: Text('My app')),\n"
          '  body: content,\n'
          ')',
        ),
        const DocText(
          '`Oito2TitleBar` is the bar itself, with the `controlStyle`, '
          '`buttonLayout` and `controller` given explicitly. Its empty area '
          'moves the window when dragged, maximizes or restores it on a '
          'double click and opens the window menu on a secondary click. '
          'Without a controller, the buttons render disabled unless '
          '`onClose` handles the close button.',
        ),
        const DocText(
          '`Oito2SystemScope` holds the control style and button layout '
          'read from the system, which `Oito2WindowTitleBar` follows.',
        ),
        ExamplePanel(
          region: 'system',
          // #region system
          child: Text(
            'Control style: ${settings.windowControlStyle.name} · '
            'leading: ${settings.windowButtonLayout.leading.map((b) => b.name).join(', ')} · '
            'trailing: ${settings.windowButtonLayout.trailing.map((b) => b.name).join(', ')}',
          ),
          // #endregion
        ),
        const DocHeading('Examples'),
        const DocHeading('Control styles', level: 3),
        const DocText(
          '`controlStyle` draws the buttons in the look of a desktop. '
          '`Oito2WindowButtonLayout.defaultFor` gives each style its usual '
          'layout: leading close, minimize and maximize for macOS, and '
          'trailing minimize, maximize and close otherwise.',
        ),
        ExamplePanel(
          region: 'styles',
          child: Column(
            spacing: Oito2Spacing.md,
            children: [
              // #region styles
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
              // #endregion
            ],
          ),
        ),
        const DocHeading('Button layouts', level: 3),
        const DocText(
          '`Oito2WindowButtonLayout` lists the buttons before and after the '
          'title. It parses the formats of the desktops: '
          '`parseGnome` for the GNOME `button-layout` setting, `parseKde` '
          'for the KWin `ButtonsOnLeft` and `ButtonsOnRight` values, and '
          '`parseXfwm` for the Xfce `button_layout`. Entries other than '
          'minimize, maximize and close are ignored.',
        ),
        ExamplePanel(
          region: 'layouts',
          child: Column(
            spacing: Oito2Spacing.md,
            children: [
              // #region layouts
              for (final (name, layout) in [
                (
                  'GNOME default: appmenu:close',
                  Oito2WindowButtonLayout.parseGnome('appmenu:close'),
                ),
                (
                  'Left side: close,minimize,maximize:',
                  Oito2WindowButtonLayout.parseGnome(
                    'close,minimize,maximize:',
                  ),
                ),
                (
                  'KDE: ButtonsOnLeft=X, ButtonsOnRight=IA',
                  Oito2WindowButtonLayout.parseKde(
                    buttonsOnLeft: 'X',
                    buttonsOnRight: 'IA',
                  ),
                ),
                ('Xfce: O|HMC', Oito2WindowButtonLayout.parseXfwm('O|HMC')),
              ])
                _frame(
                  Oito2TitleBar(
                    title: Text(name),
                    buttonLayout: layout,
                    controller: _preview,
                    isDraggable: false,
                  ),
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Leading and actions', level: 3),
        const DocText(
          '`leading` goes before the title, such as a back button, and '
          '`actions` after it, before the window buttons. '
          '`centerTitle: false` starts the title after the leading widget.',
        ),
        ExamplePanel(
          region: 'actions',
          child: _frame(
            // #region actions
            Oito2TitleBar(
              leading: Oito2IconButton(
                tooltip: 'Back',
                onPressed: () {},
                icon: const Icon(LucideIcons.arrow_left),
              ),
              title: const Text('Settings'),
              centerTitle: false,
              actions: [
                Oito2IconButton(
                  tooltip: 'Search',
                  onPressed: () {},
                  icon: const Icon(LucideIcons.search),
                ),
              ],
              controller: _preview,
              isDraggable: false,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Without window buttons', level: 3),
        const DocText(
          '`style: Oito2TitleBarStyle.undecorated` shows the bar without '
          'window controls, and `hidden` hides it. The theme can set the '
          'style, height, colors and title style of every bar through '
          '`Oito2TitleBarThemeData`.',
        ),
        ExamplePanel(
          region: 'undecorated',
          child: _frame(
            // #region undecorated
            Oito2TitleBar(
              title: const Text('Undecorated'),
              style: Oito2TitleBarStyle.undecorated,
              controller: _preview,
              isDraggable: false,
            ),
            // #endregion
          ),
        ),
        const DocHeading('Inactive window', level: 3),
        const DocText(
          'While the window does not have the input focus, as reported by '
          'the controller\'s `state`, the bar content fades to the theme\'s '
          '`inactiveOpacity`, 0.7 by default, and macOS buttons turn grey.',
        ),
        ExamplePanel(
          region: 'inactive',
          child: SizedBox(
            width: 560,
            child: Column(
              spacing: Oito2Spacing.sm,
              children: [
                // #region inactive
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Window active'),
                  value: _active,
                  onChanged: (value) => setState(() {
                    _active = value;
                    _preview.isActive = value;
                  }),
                ),
                // #endregion
                _frame(
                  Oito2TitleBar(
                    title: const Text('Inactive preview'),
                    controlStyle: Oito2WindowControlStyle.macos,
                    buttonLayout: macLayout,
                    controller: _preview,
                    isDraggable: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The title is marked as a header. Each window button is labeled '
          '"Minimize", "Maximize", "Restore" or "Close" from the '
          'localizations, unless `labels` overrides it.',
        ),
        ...apiReferenceWidgets([
          'Oito2TitleBar',
          'Oito2WindowTitleBar',
          'Oito2TitleBarStyle',
          'Oito2TitleBarThemeData',
          'Oito2TitleBarGestureDetector',
          'Oito2WindowButtonLayout',
          'Oito2WindowButton',
          'Oito2WindowButtonSides',
          'Oito2WindowControl',
          'Oito2WindowControlStyle',
          'Oito2WindowControlType',
          'Oito2WindowControlLabels',
          'Oito2WindowController',
          'Oito2WindowState',
          'Oito2WindowScope',
          'Oito2Window',
        ]),
      ],
    );
  }
}
