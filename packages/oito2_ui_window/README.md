# oito2_ui_window

Window chrome integration for oito2_ui: client-side decorations and window controls on Linux, Windows and macOS.

[![CI](https://github.com/oito2/oito2_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/oito2/oito2_ui/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.50-02569B?logo=flutter)](https://flutter.dev)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [License](#license)

## Overview

oito2_ui_window is part of the [oito2_ui](https://github.com/oito2/oito2_ui) design system for Flutter apps on the desktop, mobile and the web.

- `Oito2Window.ensureInitialized` hides the native title bar (keeping the macOS traffic lights) and returns an `Oito2WindowController` backed by `window_manager`.
- The controller drives the `oito2_ui` title bars: minimize, maximize, close, drag and the window menu, and follows the window state.
- `Oito2NativeWindowController` asks the close handlers, such as an `Oito2UnsavedChangesGuard` with unsaved changes, before the window closes.
- Built on the native `Window` API of `window_manager` 0.7; the controller is created only by `Oito2Window.ensureInitialized`.

**Platforms:** Linux, Windows and macOS. On the web, Android and iOS `Oito2Window.ensureInitialized` returns null and the title bars show no window buttons.

## Installation

Requires Flutter 3.50 or later (Dart 3.14 or later) and, on macOS, macOS 10.15 or later.

Building for Linux needs the GTK 3, X11 and Xi development files, for the native window library `window_manager` builds. On Debian and Ubuntu:

```sh
sudo apt-get install libgtk-3-dev libx11-dev libxi-dev pkg-config
```

The package isn't published on pub.dev yet. Add it as a git dependency:

```yaml
dependencies:
  oito2_ui_window:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui_window

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
  oito2_ui_window:
    path: ../oito2_ui/packages/oito2_ui_window

dependency_overrides:
  oito2_ui:
    path: ../oito2_ui/packages/oito2_ui
```

Then run `flutter pub get`.

## Usage

Initialize the window before `runApp` and hand its controller to the `oito2_ui` widgets through `Oito2WindowScope`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_window/oito2_ui_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Null on the web, Android and iOS, where the app owns no window.
  final window = await Oito2Window.ensureInitialized(
    title: 'Notes',
    size: const Size(1024, 720),
    minimumSize: const Size(480, 360),
  );
  runApp(
    Oito2WindowScope(
      controller: window,
      child: MaterialApp(
        theme: Oito2Theme.light(),
        home: const Scaffold(
          // The title bar draws the window buttons and drags the window.
          appBar: Oito2WindowTitleBar(title: Text('Notes')),
        ),
      ),
    ),
  );
}
```

## Documentation

- [Showcase and documentation site](https://oito2.github.io/oito2_ui/): every component, live, with its API reference and guides.
- [CHANGELOG](CHANGELOG.md)
- [Source repository](https://github.com/oito2/oito2_ui/tree/main/packages/oito2_ui_window)
- [Issue tracker](https://github.com/oito2/oito2_ui/issues)

## License

GPL-3.0 — see [LICENSE](LICENSE).
