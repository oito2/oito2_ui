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

void main() {
  runApp(const ShowcaseApp());
}

/// Root widget of the `oito2_ui` showcase.
class ShowcaseApp extends StatelessWidget {
  /// Creates the showcase root widget.
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'oito2_ui',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter', package: 'oito2_ui'),
      home: const ShowcaseHome(),
    );
  }
}

/// Placeholder home page shown until the showcase pages exist.
class ShowcaseHome extends StatelessWidget {
  /// Creates the placeholder home page.
  const ShowcaseHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('oito2_ui')),
      body: const Center(child: Text('oito2_ui showcase')),
    );
  }
}
