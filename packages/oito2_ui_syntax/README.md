# oito2_ui_syntax

Syntax highlighting for oito2_ui: code colored with the oito2 color schemes, in pure Dart, plus a ready-made code block widget.

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

oito2_ui_syntax is part of the [oito2_ui](https://github.com/oito2/oito2_ui) design system for Flutter apps on the desktop, mobile and the web.

- `Oito2Highlighter` colors code with `re_highlight` and the `Oito2SyntaxPalette` of the current theme.
- `Oito2CodeBlock` shows highlighted code with line numbers, highlighted lines and a copy button, in the bundled JetBrains Mono font.
- `Oito2GitignoreMatcher` parses `.gitignore` rules and tells which paths they ignore; a `gitignore` language is registered for highlighting.

**Platforms:** Linux, Windows, macOS, iOS, Android and Web.

## Installation

Requires Flutter 3.47 or later (Dart 3.13 or later).

The package isn't published on pub.dev yet. Add it as a git dependency:

```yaml
dependencies:
  oito2_ui_syntax:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui_syntax

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
  oito2_ui_syntax:
    path: ../oito2_ui/packages/oito2_ui_syntax

dependency_overrides:
  oito2_ui:
    path: ../oito2_ui/packages/oito2_ui
```

Then run `flutter pub get`.

## Usage

Show a highlighted code block, or check paths against `.gitignore` rules:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';

const snippet = '''
void main() {
  print('Hello');
}
''';

Widget example() => const Oito2CodeBlock(
  code: snippet,
  language: 'dart',
  showLineNumbers: true,
);

bool ignored() =>
    Oito2GitignoreMatcher.parse('build/\n*.log').isIgnored('app.log');
```

## Documentation

- [Showcase and documentation site](https://oito2.github.io/oito2_ui/): every component, live, with its API reference and guides.
- [CHANGELOG](CHANGELOG.md)
- [Source repository](https://github.com/oito2/oito2_ui/tree/main/packages/oito2_ui_syntax)
- [Issue tracker](https://github.com/oito2/oito2_ui/issues)

## License

GPL-3.0 — see [LICENSE](LICENSE).
