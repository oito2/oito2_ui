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
import 'package:oito2_ui_settings/oito2_ui_settings.dart';
import 'package:oito2_ui_window/oito2_ui_window.dart';

import 'src/showcase_options.dart';
import 'src/showcase_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final windowController = await Oito2Window.ensureInitialized(
    title: 'oito2_ui',
    size: const Size(1280, 820),
    minimumSize: const Size(720, 480),
  );
  final settings = await Oito2Settings.load();
  runApp(
    Oito2SystemSettingsScope(
      initialSettings: settings,
      child: ShowcaseApp(windowController: windowController),
    ),
  );
}

/// Root widget of the `oito2_ui` showcase.
class ShowcaseApp extends StatefulWidget {
  /// Creates the showcase root widget. It renders with the system settings
  /// of the closest [Oito2SystemScope].
  ///
  /// [initialSlug] selects the first page; it defaults to the page named in
  /// the launch route, such as `#/check-button` on the web.
  const ShowcaseApp({
    super.key,
    this.windowController,
    this.initialSlug,
    this.initialOptions = const ShowcaseOptions(),
  });

  /// The native window controller, or null where the app doesn't own a
  /// desktop window.
  final Oito2WindowController? windowController;

  /// The slug of the page to show first.
  final String? initialSlug;

  /// The appearance and layout at start.
  final ShowcaseOptions initialOptions;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  late final _controller = ShowcaseController(widget.initialOptions);
  late final String _initialSlug;

  @override
  void initState() {
    super.initState();
    // Reads the launch route before the navigator reports its own '/' to
    // the browser, which replaces the address the slug comes from.
    _initialSlug =
        widget.initialSlug ??
        WidgetsBinding.instance.platformDispatcher.defaultRouteName
            .replaceFirst(RegExp('^/'), '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final system = Oito2SystemScope.of(context);
    return Oito2WindowScope(
      controller: widget.windowController,
      child: ValueListenableBuilder<ShowcaseOptions>(
        valueListenable: _controller,
        builder: (context, options, _) {
          final platform = options.platformFor(system.platform);
          ThemeData theme(Brightness brightness) => Oito2Theme.fromColors(
            options.colorsFor(brightness, system),
            platform: platform,
          );
          return MaterialApp(
            title: 'oito2_ui',
            debugShowCheckedModeBanner: false,
            theme: theme(Brightness.light),
            darkTheme: theme(Brightness.dark),
            themeMode: options.effectiveThemeMode,
            locale: options.locale,
            localizationsDelegates: const [
              Oito2Localizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: Oito2Localizations.supportedLocales,
            initialRoute: '/',
            builder: (context, child) => Directionality(
              textDirection: options.rtl
                  ? TextDirection.rtl
                  : Directionality.of(context),
              child: Oito2Toaster(child: child!),
            ),
            home: Builder(
              builder: (context) => ShowcaseShell(
                controller: _controller,
                colors: options.colorsFor(Theme.of(context).brightness, system),
                initialSlug: _initialSlug,
              ),
            ),
          );
        },
      ),
    );
  }
}
