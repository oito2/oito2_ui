# oito2_ui

Material 3 design system for oito2 apps on Linux, Windows, macOS, iOS, Android and Web, with desktop-grade density and GTK-style surfaces.

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

The core package of the [oito2_ui](https://github.com/oito2/oito2_ui) design system for Flutter apps on the desktop, mobile and the web; the other oito2_ui packages build on it.

- **Themes**: `Oito2Theme.light`, `Oito2Theme.dark` and `Oito2Theme.fromColors`, with high-contrast variants, platform density and the bundled Inter font.
- **Window chrome**: `Oito2WindowTitleBar` and `Oito2HeaderBar` with the window buttons of GNOME, KDE, XFCE, COSMIC, Windows and macOS.
- **Collections**: `Oito2ListBox`, `Oito2VirtualList`, `Oito2TreeView` and `Oito2DataTable`, with keyboard navigation, type-ahead, selection and reordering.
- **Forms**: `Oito2Form` with an error summary, plus fields such as `Oito2PasswordField`, `Oito2PinEntry` and `Oito2SearchField`.
- **Layout and navigation**: `Oito2NavigationPage`, `Oito2MasterDetailPage`, `Oito2PanedView` and `Oito2Carousel`.
- **Overlays and feedback**: `Oito2Popover`, `Oito2Sheet`, `Oito2Toaster`, `Oito2Alert` and `Oito2Tour`.
- **Keyboard**: `Oito2Commands` shortcuts, `showOito2CommandPalette` and a shortcuts help.
- **Localization**: `Oito2Localizations` in English and Brazilian Portuguese; Lucide icons as `LucideIcons` and freedesktop icon names in `Oito2FreedesktopIcons`.

**Platforms:** Linux, Windows, macOS, iOS, Android and Web; no native plugins.

## Installation

Requires Flutter 3.47 or later (Dart 3.13 or later).

The package isn't published on pub.dev yet. Add it as a git dependency:

```yaml
dependencies:
  oito2_ui:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui
```

Or, from a local clone of the repository next to your app:

```yaml
dependencies:
  oito2_ui:
    path: ../oito2_ui/packages/oito2_ui
```

Then run `flutter pub get`.

## Usage

Use the oito2 theme and localizations in a `MaterialApp`, then build with the `Oito2` widgets:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Oito2Theme.light(),
      darkTheme: Oito2Theme.dark(),
      localizationsDelegates: const [
        Oito2Localizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: Oito2Localizations.supportedLocales,
      home: Scaffold(
        appBar: const Oito2WindowTitleBar(title: Text('Notes')),
        body: Center(
          child: SizedBox(
            width: 320,
            child: Oito2SearchField(
              hintText: 'Search notes',
              onChanged: (text) => debugPrint(text),
            ),
          ),
        ),
      ),
    );
  }
}
```

The library builds on `material_ui`; import it instead of `package:flutter/material.dart`.

## Documentation

- [Showcase and documentation site](https://oito2.github.io/oito2_ui/): every component, live, with its API reference and guides.
- [CHANGELOG](CHANGELOG.md)
- [Source repository](https://github.com/oito2/oito2_ui/tree/main/packages/oito2_ui)
- [Issue tracker](https://github.com/oito2/oito2_ui/issues)

## License

GPL-3.0 — see [LICENSE](LICENSE).
