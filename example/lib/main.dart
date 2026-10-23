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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/semantics.dart' show SemanticsBinding;
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_settings/oito2_ui_settings.dart';
import 'package:oito2_ui_window/oito2_ui_window.dart';

import 'src/showcase_options.dart';
import 'src/showcase_router.dart';
import 'src/showcase_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On the web the semantics tree is built only on request; the showcase
  // always builds it, so screen readers and accessibility checkers see the
  // page without the "Enable accessibility" button.
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
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
  /// the launch route, such as `#/check-button` on the web. The address
  /// follows the selected page afterwards, and an address change selects
  /// its page.
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
  final _location = ShowcaseLocation();
  late final _routeInformation = PlatformRouteInformationProvider(
    initialRouteInformation: RouteInformation(
      uri: Uri.parse(
        widget.initialSlug != null
            ? '/${widget.initialSlug}'
            : WidgetsBinding.instance.platformDispatcher.defaultRouteName,
      ),
    ),
  );
  late final _router = ShowcaseRouterDelegate(
    location: _location,
    builder: (context) => ShowcaseShell(
      controller: _controller,
      colors: _options.colorsFor(Theme.of(context).brightness, _system),
      location: _location,
    ),
  );

  // The options and system settings of the latest build, read by the
  // router's page builder.
  late ShowcaseOptions _options;
  late Oito2SystemSettings _system;

  @override
  void dispose() {
    _router.dispose();
    _routeInformation.dispose();
    _location.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final system = _system = Oito2SystemScope.of(context);
    return Oito2WindowScope(
      controller: widget.windowController,
      child: ValueListenableBuilder<ShowcaseOptions>(
        valueListenable: _controller,
        builder: (context, options, _) {
          _options = options;
          final platform = options.platformFor(system.platform);
          ThemeData theme(Brightness brightness) => Oito2Theme.fromColors(
            options.colorsFor(brightness, system),
            platform: platform,
          );
          return MaterialApp.router(
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
            routeInformationProvider: _routeInformation,
            routeInformationParser: const ShowcaseRouteParser(),
            routerDelegate: _router,
            builder: (context, child) => Directionality(
              textDirection: options.rtl
                  ? TextDirection.rtl
                  : Directionality.of(context),
              child: Oito2Toaster(child: child!),
            ),
          );
        },
      ),
    );
  }
}
