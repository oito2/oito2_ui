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

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';
import 'package:oito2_ui_themes/oito2_ui_themes.dart';
import 'package:url_launcher/url_launcher.dart';

import 'showcase_catalog.dart';
import 'showcase_options.dart';
import 'showcase_router.dart';

/// The width at which the page list and the page sit side by side.
const _breakpoint = 620.0;

/// The GitHub URL of the repository folder that holds the page sources.
const _sourceUrl =
    'https://github.com/oito2/oito2_ui/blob/main/example/lib/src/pages/';

/// The showcase shell: the page list beside the selected page, or a
/// navigation rail in compact mode, with the appearance actions in the
/// title bar.
///
/// The selected page is kept in [location], which the app's router mirrors
/// in the web address as `#/<slug>`, so a page can be linked to and the
/// browser's back and forward buttons move between pages.
class ShowcaseShell extends StatefulWidget {
  /// Creates the shell.
  const ShowcaseShell({
    super.key,
    required this.controller,
    required this.colors,
    required this.location,
  });

  /// The showcase options.
  final ShowcaseController controller;

  /// The active scheme colors.
  final Oito2ColorTheme colors;

  /// The slug of the page shown, shared with the router.
  final ShowcaseLocation location;

  @override
  State<ShowcaseShell> createState() => _ShowcaseShellState();
}

class _ShowcaseShellState extends State<ShowcaseShell> {
  late final int _initialIndex = showcasePages.indexWhere(
    (page) => page.slug == widget.location.value,
  );
  late ShowcasePage _selected =
      showcasePages[_initialIndex < 0 ? 0 : _initialIndex];

  /// The page list selection. Without a page in the launch route nothing
  /// is selected, so the narrow layout opens on the list; the wide layout
  /// shows the first page.
  late final _listController = Oito2PageController(
    length: showcasePages.length,
    initialIndex: _initialIndex,
  );

  /// The navigation rail selection of the compact layout.
  late final _railController = Oito2PageController(
    length: showcasePages.length,
    initialIndex: _initialIndex < 0 ? 0 : _initialIndex,
  );
  String _query = '';
  final _searchFocus = FocusNode(debugLabel: 'Page search');
  final _searchController = TextEditingController();

  List<ShowcasePage> get _filtered => _query.isEmpty
      ? showcasePages
      : [
          for (final page in showcasePages)
            if (page.title.toLowerCase().contains(_query.toLowerCase()) ||
                page.slug.contains(_query.toLowerCase()))
              page,
        ];

  @override
  void initState() {
    super.initState();
    widget.location.addListener(_onLocation);
    widget.controller.addListener(_onOptionsChanged);
    _listController.addListener(_onListSelection);
  }

  @override
  void didUpdateWidget(ShowcaseShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      oldWidget.location.removeListener(_onLocation);
      widget.location.addListener(_onLocation);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onOptionsChanged);
      widget.controller.addListener(_onOptionsChanged);
    }
  }

  @override
  void dispose() {
    widget.location.removeListener(_onLocation);
    widget.controller.removeListener(_onOptionsChanged);
    _searchFocus.dispose();
    _searchController.dispose();
    _listController.dispose();
    _railController.dispose();
    super.dispose();
  }

  /// Rebuilds the shell whenever the options change, so the options it
  /// reads, such as the compact mode, take effect.
  void _onOptionsChanged() => setState(() {});

  /// Shows [page] and writes its slug to the location, which the router
  /// turns into a new history entry.
  void _select(ShowcasePage page) {
    setState(() => _selected = page);
    _railController.index = showcasePages.indexOf(page);
    widget.location.value = page.slug;
  }

  /// Follows an address change: shows the page it names, or goes back to
  /// the page list when it names none.
  void _onLocation() {
    final slug = widget.location.value;
    if (slug.isEmpty) {
      if (_listController.hasSelection) _listController.index = -1;
      return;
    }
    if (slug == _selected.slug && _listController.hasSelection) return;
    final page = showcasePages.where((p) => p.slug == slug).firstOrNull;
    if (page != null) _goTo(page);
  }

  /// Whether the last master-detail layout showed both panes.
  bool _wide = true;

  /// Clears the address when the narrow layout goes back from a page to
  /// the list, after the current frame since the list can change while
  /// the navigator rebuilds.
  void _onListSelection() {
    if (_wide || _listController.hasSelection) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_wide && !_listController.hasSelection) {
        widget.location.value = '';
      }
    });
  }

  /// Filters the page list by [query], keeping the selected page selected
  /// while it matches and clearing the selection otherwise.
  void _search(String query) {
    setState(() => _query = query);
    final filtered = _filtered;
    _listController
      ..length = filtered.length
      ..index = filtered.indexOf(_selected);
  }

  /// Opens the command palette with the commands available where the
  /// keyboard focus is, so page-level commands are listed too.
  void _openPalette() => showOito2CommandPalette(
    FocusManager.instance.primaryFocus?.context ?? context,
  );

  /// Cycles the theme mode: system, light, dark.
  void _cycleThemeMode() => widget.controller.update(
    (o) => o.copyWith(
      themeMode: switch (o.themeMode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      },
    ),
  );

  /// The app-wide commands: palette, search, settings, appearance and one
  /// "Go to" command per page.
  List<Oito2Command> _commands() {
    final options = widget.controller.value;
    return [
      Oito2Command(
        id: 'app.palette',
        label: 'Show all commands',
        icon: LucideIcons.command,
        shortcut: Oito2Shortcut.parse('Mod+K'),
        onInvoke: _openPalette,
      ),
      Oito2Command(
        id: 'app.search',
        label: 'Search pages',
        icon: LucideIcons.search,
        shortcut: Oito2Shortcut.parse('Mod+F'),
        enabled: !options.compactMode,
        onInvoke: _searchFocus.requestFocus,
      ),
      Oito2Command(
        id: 'app.settings',
        label: 'Open settings',
        icon: LucideIcons.settings,
        keywords: const ['preferences'],
        shortcut: Oito2Shortcut.parse('Mod+,'),
        onInvoke: _openSettings,
      ),
      Oito2Command(
        id: 'app.theme',
        label: 'Switch light, dark or system style',
        group: 'Appearance',
        icon: LucideIcons.sun_moon,
        shortcut: Oito2Shortcut.parse('Mod+Shift+L'),
        enabled: options.preset == null,
        onInvoke: _cycleThemeMode,
      ),
      Oito2Command(
        id: 'app.contrast',
        label: 'Toggle high contrast',
        group: 'Appearance',
        icon: LucideIcons.contrast,
        onInvoke: () => widget.controller.update(
          (o) => o.copyWith(highContrast: !o.highContrast),
        ),
      ),
      Oito2Command(
        id: 'app.compact',
        label: 'Toggle compact mode',
        group: 'Appearance',
        icon: LucideIcons.panel_left,
        onInvoke: () => widget.controller.update(
          (o) => o.copyWith(compactMode: !o.compactMode),
        ),
      ),
      Oito2Command(
        id: 'app.source',
        label: 'View the source of this page',
        icon: LucideIcons.file_code,
        onInvoke: () => _showSource(_selected),
      ),
      Oito2Command(
        id: 'app.home',
        label: 'Go to the first page',
        group: 'Pages',
        icon: LucideIcons.house,
        shortcut: Oito2Shortcut.parse('G H'),
        onInvoke: () => _goTo(showcasePages.first),
      ),
      ..._pageCommands,
    ];
  }

  /// One "Go to" command per page, built once: they don't depend on the
  /// options or the search.
  late final List<Oito2Command> _pageCommands = [
    for (final page in showcasePages)
      Oito2Command(
        id: 'page.${page.slug}',
        label: 'Go to ${page.title}',
        group: 'Pages',
        icon: page.icon,
        keywords: [page.slug],
        onInvoke: () => _goTo(page),
      ),
  ];

  /// Shows [page], clearing the search so it is in the list.
  void _goTo(ShowcasePage page) {
    if (_query.isNotEmpty) {
      _searchController.clear();
      _search('');
    }
    _select(page);
    _listController.index = showcasePages.indexOf(page);
  }

  /// The title bar actions; [source] adds the button that shows the source
  /// of the selected page.
  List<Widget> _actions({bool source = false}) => [
    IconButton(
      tooltip: 'Commands',
      icon: const Icon(LucideIcons.command),
      onPressed: _openPalette,
    ),
    if (source) _sourceButton(_selected),
    _ThemeModeButton(controller: widget.controller),
    _SchemeMenu(controller: widget.controller),
    _HighContrastButton(controller: widget.controller),
  ];

  /// Shows the source of [page] in a dialog.
  void _showSource(ShowcasePage page) => showDialog<void>(
    context: context,
    builder: (context) => _SourceDialog(page: page),
  );

  /// The title bar button that shows the source of [page].
  Widget _sourceButton(ShowcasePage page) => IconButton(
    tooltip: 'View source',
    icon: const Icon(LucideIcons.file_code),
    onPressed: () => _showSource(page),
  );

  void _openSettings() => showDialog<void>(
    context: context,
    builder: (context) => _SettingsDialog(controller: widget.controller),
  );

  Widget _body(BuildContext context, ShowcasePage page) =>
      page.builder(context, widget.colors);

  @override
  Widget build(BuildContext context) {
    final platform = Oito2SystemScope.of(context).platform;
    return Oito2Commands(
      commands: _commands(),
      // Gives the shell the initial focus, so the shortcuts work before
      // the user clicks anything.
      child: Focus(
        autofocus: true,
        child: widget.controller.value.compactMode
            ? _compact(platform)
            : LayoutBuilder(
                builder: (context, constraints) => _masterDetail(
                  platform,
                  wide: constraints.maxWidth >= _breakpoint,
                ),
              ),
      ),
    );
  }

  /// The page list beside the selected page, with a search field above the
  /// list; [wide] tells whether both panes are visible.
  Widget _masterDetail(Oito2Platform platform, {required bool wide}) {
    _wide = wide;
    final filtered = _filtered;
    final chrome = Oito2ChromeColors.maybeOf(context);
    final bar = Oito2WindowTitleBar(
      platform: platform,
      title: const Text('oito2_ui'),
      actions: _actions(),
      backgroundColor: chrome?.mainbar,
      buttonSides: wide
          ? Oito2WindowButtonSides.leading
          : Oito2WindowButtonSides.both,
    );
    const searchHeight = 56.0;
    return Scaffold(
      body: Oito2MasterDetailPage(
        controller: _listController,
        breakpoint: _breakpoint,
        minPaneSize: 200,
        onSelected: (index) => _select(_filtered[index]),
        masterBar: PreferredSize(
          preferredSize: Size.fromHeight(
            bar.preferredSize.height + searchHeight,
          ),
          child: Column(
            children: [
              bar,
              SizedBox(
                height: searchHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Oito2Spacing.sm,
                    Oito2Spacing.sm,
                    Oito2Spacing.sm,
                    0,
                  ),
                  child: Oito2SearchField(
                    focusNode: _searchFocus,
                    controller: _searchController,
                    onChanged: _search,
                  ),
                ),
              ),
            ],
          ),
        ),
        masterFooter: Padding(
          padding: const EdgeInsets.all(Oito2Spacing.sm),
          child: Oito2MasterTile(
            leading: const Icon(LucideIcons.settings),
            title: const Text('Settings'),
            selected: false,
            onTap: _openSettings,
          ),
        ),
        emptyBuilder: (context) => const Center(child: Text('No pages')),
        tileBuilder: (context, index, selected, width) {
          final page = filtered[index];
          final tile = Oito2MasterTile(
            leading: Icon(page.icon),
            title: Oito2HighlightedText(
              page.title,
              query: _query,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
          if (index > 0 && filtered[index - 1].group == page.group) {
            return tile;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Oito2Spacing.md,
                  Oito2Spacing.md,
                  Oito2Spacing.md,
                  Oito2Spacing.xs,
                ),
                child: Text(
                  page.group.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              tile,
            ],
          );
        },
        pageBuilder: (context, index) {
          final page = filtered[index];
          return Builder(
            builder: (context) {
              final canPop = ModalRoute.of(context)?.canPop ?? false;
              return Oito2DetailPage(
                appBar: Oito2WindowTitleBar(
                  platform: platform,
                  leading: canPop ? const Oito2BackButton() : null,
                  title: Text(page.title),
                  actions: [_sourceButton(page)],
                  buttonSides: wide
                      ? Oito2WindowButtonSides.trailing
                      : Oito2WindowButtonSides.both,
                ),
                body: _body(context, page),
              );
            },
          );
        },
      ),
    );
  }

  /// The compact layout: the selected page beside a navigation rail.
  Widget _compact(Oito2Platform platform) {
    return Scaffold(
      appBar: Oito2WindowTitleBar(
        platform: platform,
        title: Text(_selected.title),
        actions: _actions(source: true),
      ),
      body: Oito2NavigationPage(
        controller: _railController,
        compactBreakpoint: 0,
        extendedBreakpoint: 1000,
        onSelected: (index) => _select(showcasePages[index]),
        trailing: IconButton(
          tooltip: 'Settings',
          icon: const Icon(LucideIcons.settings),
          onPressed: _openSettings,
        ),
        items: [
          for (final page in showcasePages)
            Oito2NavigationItem(
              icon: Icon(page.icon),
              label: page.title.replaceFirst('Oito2', ''),
              tooltip: page.title,
            ),
        ],
        pageBuilder: (context, index) => _body(context, showcasePages[index]),
      ),
    );
  }
}

/// Cycles the theme mode: system, light, dark. Hidden while a preset is
/// selected, since presets have a fixed brightness.
class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({required this.controller});

  final ShowcaseController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ShowcaseOptions>(
    valueListenable: controller,
    builder: (context, options, _) => _build(context, options),
  );

  Widget _build(BuildContext context, ShowcaseOptions options) {
    if (options.preset != null) return const SizedBox.shrink();
    final (icon, label, next) = switch (options.themeMode) {
      ThemeMode.system => (
        LucideIcons.sun_moon,
        'System style',
        ThemeMode.light,
      ),
      ThemeMode.light => (LucideIcons.sun, 'Light style', ThemeMode.dark),
      ThemeMode.dark => (LucideIcons.moon, 'Dark style', ThemeMode.system),
    };
    return IconButton(
      tooltip: label,
      icon: Icon(icon),
      onPressed: () => controller.update((o) => o.copyWith(themeMode: next)),
    );
  }
}

/// Toggles high contrast on the scheme in use, the base one or a preset.
class _HighContrastButton extends StatelessWidget {
  const _HighContrastButton({required this.controller});

  final ShowcaseController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ShowcaseOptions>(
    valueListenable: controller,
    builder: (context, options, _) => _build(context, options),
  );

  Widget _build(BuildContext context, ShowcaseOptions options) {
    return Oito2IconButton(
      tooltip: 'High contrast',
      isSelected: options.highContrast,
      icon: const Icon(LucideIcons.contrast),
      onPressed: () =>
          controller.update((o) => o.copyWith(highContrast: !o.highContrast)),
    );
  }
}

/// Selects the base scheme with an accent color, or a preset.
class _SchemeMenu extends StatelessWidget {
  const _SchemeMenu({required this.controller});

  final ShowcaseController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ShowcaseOptions>(
    valueListenable: controller,
    builder: (context, options, _) => _build(context, options),
  );

  Widget _build(BuildContext context, ShowcaseOptions options) {
    final system = Oito2SystemScope.of(context).accentColor;
    Widget check(bool selected) => selected
        ? const Icon(LucideIcons.check)
        : const SizedBox.square(dimension: Oito2Sizes.iconSize);
    return MenuAnchor(
      menuChildren: [
        SubmenuButton(
          leadingIcon: Icon(
            LucideIcons.circle,
            color: options.accentFor(Oito2SystemScope.of(context)),
          ),
          menuChildren: [
            MenuItemButton(
              leadingIcon: check(
                options.preset == null && options.accent == null,
              ),
              trailingIcon: Icon(
                LucideIcons.circle,
                color: system ?? Oito2AccentColor.fallback.color,
              ),
              onPressed: () => controller.update(
                (o) => o.copyWith(clearPreset: true, clearAccent: true),
              ),
              child: Text(system == null ? 'System (unavailable)' : 'System'),
            ),
            for (final accent in Oito2AccentColor.values)
              MenuItemButton(
                leadingIcon: check(
                  options.preset == null && options.accent == accent,
                ),
                trailingIcon: Icon(LucideIcons.circle, color: accent.color),
                onPressed: () => controller.update(
                  (o) => o.copyWith(clearPreset: true, accent: accent),
                ),
                child: Text(accent.name),
              ),
          ],
          child: const Text('oito2'),
        ),
        const Divider(height: 1),
        for (final preset in Oito2ThemePreset.values)
          MenuItemButton(
            leadingIcon: check(options.preset == preset),
            onPressed: () =>
                controller.update((o) => o.copyWith(preset: preset)),
            child: Text(preset.label),
          ),
      ],
      builder: (context, menu, _) => IconButton(
        tooltip: 'Color scheme',
        icon: const Icon(LucideIcons.palette),
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      ),
    );
  }
}

/// Shows the source of a page, with a link to it on GitHub.
class _SourceDialog extends StatefulWidget {
  const _SourceDialog({required this.page});

  final ShowcasePage page;

  @override
  State<_SourceDialog> createState() => _SourceDialogState();
}

class _SourceDialogState extends State<_SourceDialog> {
  late final Future<String> _source = DefaultAssetBundle.of(context)
      .loadString(widget.page.sourceAsset)
      .then(_withoutLicenseHeader);

  /// Drops the license comment at the top of a source file, which every
  /// page repeats.
  static String _withoutLicenseHeader(String source) {
    final lines = source.split('\n');
    final start = lines.indexWhere((line) => !line.startsWith('//'));
    return lines.skip(start < 0 ? 0 : start).join('\n').trimLeft();
  }

  /// A generic message for a source that didn't load; the details go to
  /// the debug log.
  Widget _sourceError(Object error) {
    debugPrint('Could not load ${widget.page.source}: $error');
    return const Center(child: Text('Could not load the source.'));
  }

  /// Opens the source on GitHub, telling the user when no browser opens.
  Future<void> _openOnGitHub() async {
    final opened = await launchUrl(
      Uri.parse('$_sourceUrl${widget.page.source}'),
    ).catchError((Object _) => false);
    if (!opened && mounted) {
      Oito2Toaster.maybeOf(context)?.show(
        const Oito2Toast(
          title: 'Could not open the browser',
          type: Oito2InfoType.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: size.width.clamp(0, 860),
        height: size.height * 0.8,
        child: Column(
          children: [
            Oito2DialogTitleBar(title: Text(widget.page.source)),
            Expanded(
              child: FutureBuilder<String>(
                future: _source,
                builder: (context, snapshot) => switch (snapshot) {
                  AsyncSnapshot(:final data?) => SingleChildScrollView(
                    padding: const EdgeInsets.all(Oito2Spacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      child: Oito2CodeBlock(
                        code: data.trimRight(),
                        language: 'dart',
                        showLineNumbers: true,
                      ),
                    ),
                  ),
                  AsyncSnapshot(:final error?) => _sourceError(error),
                  _ => const Center(
                    child: Oito2CircularProgressIndicator(
                      semanticsLabel: 'Loading the source',
                    ),
                  ),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Oito2Spacing.md),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  icon: const Icon(LucideIcons.external_link),
                  label: const Text('Open on GitHub'),
                  onPressed: _openOnGitHub,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The showcase settings: layout, direction, language and density.
class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog({required this.controller});

  final ShowcaseController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 460,
        child: ValueListenableBuilder<ShowcaseOptions>(
          valueListenable: controller,
          builder: (context, options, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Oito2DialogTitleBar(title: Text('Settings')),
              Padding(
                padding: const EdgeInsets.all(Oito2Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Oito2Spacing.sm,
                  children: [
                    Oito2SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Compact mode'),
                      subtitle: const Text('Pages in a navigation rail'),
                      value: options.compactMode,
                      onChanged: (v) =>
                          controller.update((o) => o.copyWith(compactMode: v)),
                    ),
                    Oito2SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Right to left'),
                      value: options.rtl,
                      onChanged: (v) =>
                          controller.update((o) => o.copyWith(rtl: v)),
                    ),
                    Text('Language', style: textTheme.titleSmall),
                    SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: '', label: Text('System')),
                        ButtonSegment(value: 'en', label: Text('English')),
                        ButtonSegment(value: 'pt', label: Text('Português')),
                      ],
                      selected: {options.locale?.languageCode ?? ''},
                      onSelectionChanged: (values) => controller.update(
                        (o) => switch (values.single) {
                          'en' => o.copyWith(locale: const Locale('en')),
                          'pt' => o.copyWith(locale: const Locale('pt', 'BR')),
                          _ => o.copyWith(clearLocale: true),
                        },
                      ),
                    ),
                    const SizedBox(height: Oito2Spacing.sm),
                    Text('Control size', style: textTheme.titleSmall),
                    SegmentedButton<ShowcaseDensity>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: ShowcaseDensity.auto,
                          label: Text('Automatic'),
                        ),
                        ButtonSegment(
                          value: ShowcaseDensity.desktop,
                          label: Text('Desktop'),
                        ),
                        ButtonSegment(
                          value: ShowcaseDensity.touch,
                          label: Text('Touch'),
                        ),
                      ],
                      selected: {options.density},
                      onSelectionChanged: (values) => controller.update(
                        (o) => o.copyWith(density: values.single),
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
