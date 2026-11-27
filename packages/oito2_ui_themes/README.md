# oito2_ui_themes

The 13 named color presets for oito2_ui: Everforest, Rosé Pine, Nord, Dracula/Alucard and Catppuccin, mapped to complete, WCAG-checked oito2 schemes.

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

oito2_ui_themes is part of the [oito2_ui](https://github.com/oito2/oito2_ui) design system for Flutter apps on the desktop, mobile and the web.

- `Oito2ThemePreset` lists the presets, each with its `label`, its brightness, its role colors and a ready `ThemeData` from `theme()`.
- High-contrast variants of every preset through `theme(highContrast: true)`.
- The official palettes of Everforest, Rosé Pine, Nord and Dracula, and Catppuccin through `catppuccin_flutter`.

**Platforms:** Linux, Windows, macOS, iOS, Android and Web.

## Installation

Requires Flutter 3.47 or later (Dart 3.13 or later).

The package isn't published on pub.dev yet. Add it as a git dependency:

```yaml
dependencies:
  oito2_ui_themes:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui_themes

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
  oito2_ui_themes:
    path: ../oito2_ui/packages/oito2_ui_themes

dependency_overrides:
  oito2_ui:
    path: ../oito2_ui/packages/oito2_ui
```

Then run `flutter pub get`.

## Usage

Pick a preset for the light and the dark theme:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_themes/oito2_ui_themes.dart';

Widget app() => MaterialApp(
  theme: Oito2ThemePreset.catppuccinLatte.theme(),
  darkTheme: Oito2ThemePreset.catppuccinMocha.theme(),
  home: const Scaffold(),
);

List<String> names() => [
  for (final preset in Oito2ThemePreset.values) preset.label,
];
```

## Documentation

- [Showcase and documentation site](https://oito2.github.io/oito2_ui/): every component, live, with its API reference and guides.
- [CHANGELOG](CHANGELOG.md)
- [Source repository](https://github.com/oito2/oito2_ui/tree/main/packages/oito2_ui_themes)
- [Issue tracker](https://github.com/oito2/oito2_ui/issues)

## License

GPL-3.0 — see [LICENSE](LICENSE).
