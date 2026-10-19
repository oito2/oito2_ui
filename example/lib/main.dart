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
import 'package:oito2_ui_window/oito2_ui_window.dart';

import 'src/showcase_home.dart';
import 'src/showcase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final windowController = await Oito2Window.ensureInitialized(
    title: 'oito2_ui',
    size: const Size(1280, 820),
    minimumSize: const Size(720, 480),
  );
  runApp(
    ShowcaseApp(
      settings: Oito2SystemSettings.fallback(Oito2Platform.current()),
      windowController: windowController,
    ),
  );
}

/// Root widget of the `oito2_ui` showcase.
class ShowcaseApp extends StatefulWidget {
  /// Creates the showcase root widget for the given system [settings].
  const ShowcaseApp({super.key, required this.settings, this.windowController});

  /// The system settings the showcase renders with.
  final Oito2SystemSettings settings;

  /// The native window controller, or null where the app doesn't own a
  /// desktop window.
  final Oito2WindowController? windowController;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  ShowcaseOptions _options = const ShowcaseOptions();

  ThemeData _theme(Brightness brightness) => Oito2Theme.fromColors(
    _options.colorsFor(brightness),
    platform: widget.settings.platform,
  );

  @override
  Widget build(BuildContext context) {
    return Oito2SystemScope(
      settings: widget.settings,
      child: Oito2WindowScope(
        controller: widget.windowController,
        child: MaterialApp(
          title: 'oito2_ui',
          debugShowCheckedModeBanner: false,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: _options.effectiveThemeMode,
          home: ShowcaseHome(
            options: _options,
            onOptionsChanged: (options) => setState(() => _options = options),
          ),
        ),
      ),
    );
  }
}
