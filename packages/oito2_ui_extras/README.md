# oito2_ui_extras

Optional oito2_ui components with heavier or niche needs: QR codes, a signature pad, an image cropper and a website-style navigation menu.

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

oito2_ui_extras is part of the [oito2_ui](https://github.com/oito2/oito2_ui) design system for Flutter apps on the desktop, mobile and the web.

- `Oito2QrCode` draws a QR code for any text.
- `Oito2SignaturePad` with `Oito2SignatureController` captures a signature and exports it as SVG or as an image.
- `Oito2ImageCropper` crops an image to a rectangle or a circle.
- `Oito2NavigationMenu` is a website-style menu bar with panels that open on hover or click.

**Platforms:** Linux, Windows, macOS, iOS, Android and Web.

## Installation

Requires Flutter 3.47 or later (Dart 3.13 or later).

The package isn't published on pub.dev yet. Add it as a git dependency:

```yaml
dependencies:
  oito2_ui_extras:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui_extras

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
  oito2_ui_extras:
    path: ../oito2_ui/packages/oito2_ui_extras

dependency_overrides:
  oito2_ui:
    path: ../oito2_ui/packages/oito2_ui
```

Then run `flutter pub get`.

## Usage

Show a QR code and a signature pad that exports SVG:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

class Sign extends StatefulWidget {
  const Sign({super.key});

  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {
  final _signature = Oito2SignatureController();

  @override
  void dispose() {
    _signature.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Oito2QrCode(data: 'https://oito2.github.io/oito2_ui/'),
      Oito2SignaturePad(controller: _signature),
      TextButton(
        onPressed: () => debugPrint(_signature.toSvg()),
        child: const Text('Export SVG'),
      ),
    ],
  );
}
```

## Documentation

- [Showcase and documentation site](https://oito2.github.io/oito2_ui/): every component, live, with its API reference and guides.
- [CHANGELOG](CHANGELOG.md)
- [Source repository](https://github.com/oito2/oito2_ui/tree/main/packages/oito2_ui_extras)
- [Issue tracker](https://github.com/oito2/oito2_ui/issues)

## License

GPL-3.0 — see [LICENSE](LICENSE).
