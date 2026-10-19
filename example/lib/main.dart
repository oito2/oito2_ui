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

import 'src/showcase_home.dart';

void main() {
  runApp(
    ShowcaseApp(
      settings: Oito2SystemSettings.fallback(Oito2Platform.current()),
    ),
  );
}

/// Root widget of the `oito2_ui` showcase.
class ShowcaseApp extends StatefulWidget {
  /// Creates the showcase root widget for the given system [settings].
  const ShowcaseApp({super.key, required this.settings});

  /// The system settings the showcase renders with.
  final Oito2SystemSettings settings;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeData _theme(Brightness brightness) {
    final neutrals = Oito2NeutralPalette.of(brightness);
    return ThemeData(
      brightness: brightness,
      colorSchemeSeed: Oito2AccentColor.fallback.color,
      scaffoldBackgroundColor: neutrals.surface,
      textTheme: Oito2Typography.textTheme(brightness),
      visualDensity: widget.settings.platform.visualDensity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Oito2SystemScope(
      settings: widget.settings,
      child: MaterialApp(
        title: 'oito2_ui',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: _themeMode,
        home: ShowcaseHome(
          themeMode: _themeMode,
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
        ),
      ),
    );
  }
}
