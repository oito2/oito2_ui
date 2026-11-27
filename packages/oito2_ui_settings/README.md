# oito2_ui_settings

System integration for oito2_ui: desktop environment detection, window button layout, accent color and high contrast.

[![CI](https://github.com/oito2/oito2_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/oito2/oito2_ui/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.47-02569B?logo=flutter)](https://flutter.dev)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [License](#license)

## Overview

oito2_ui_settings is part of the [oito2_ui](https://github.com/oito2/oito2_ui) design system for Flutter apps on the desktop, mobile and the web.

- `Oito2Settings.load` reads the platform, the desktop environment, the window button layout, the accent color, high contrast, the color scheme, reduced motion and the text scale.
- On Linux it reads GSettings, the desktop configuration files (such as those of KDE and COSMIC) and the XDG desktop portal; elsewhere it reads the platform accent color and brightness.
- `Oito2SystemSettingsScope` provides the settings to `Oito2SystemScope.of` and updates them when the desktop settings change.

**Platforms:** Linux, Windows, macOS, iOS, Android and Web; the GSettings, configuration file and portal readers run only on Linux.

## Installation

Requires Flutter 3.47 or later (Dart 3.13 or later).

The package isn't published on pub.dev yet. Add it as a git dependency:

```yaml
dependencies:
  oito2_ui_settings:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui_settings

dependency_overrides:
  oito2_ui:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui
```

The package `oito2_ui` isn't on pub.dev yet either, and this package asks for it by version, so `dependency_overrides` takes it from the same repository. Add any other oito2_ui package your app uses to `dependencies` the same way.

Or, from a local clone of the repository next to your app:

```yaml
dependencies:
  oito2_ui_settings:
    path: ../oito2_ui/packages/oito2_ui_settings

dependency_overrides:
  oito2_ui:
    path: ../oito2_ui/packages/oito2_ui
```

Then run `flutter pub get`.

## Usage

Load the settings before `runApp`, keep them current with `Oito2SystemSettingsScope` and build the theme from them:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_settings/oito2_ui_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await Oito2Settings.load();
  runApp(
    Oito2SystemSettingsScope(initialSettings: settings, child: const App()),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the desktop settings change.
    final system = Oito2SystemScope.of(context);
    return MaterialApp(
      theme: Oito2Theme.fromSystem(system, brightness: Brightness.light),
      darkTheme: Oito2Theme.fromSystem(system, brightness: Brightness.dark),
      home: const Scaffold(),
    );
  }
}
```

## Documentation

- [Showcase and documentation site](https://oito2.github.io/oito2_ui/): every component, live, with its API reference and guides.
- [CHANGELOG](CHANGELOG.md)
- [Source repository](https://github.com/oito2/oito2_ui/tree/main/packages/oito2_ui_settings)
- [Issue tracker](https://github.com/oito2/oito2_ui/issues)

## License

GPL-3.0 — see [LICENSE](LICENSE).
