# oito2_ui_code_editor

Code editor for oito2_ui: an editable code field built on re_editor, colored with the oito2 syntax palette, with line numbers, highlighted lines and line markers.

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

oito2_ui_code_editor is part of the [oito2_ui](https://github.com/oito2/oito2_ui) design system for Flutter apps on the desktop, mobile and the web.

- `Oito2CodeEditor` edits code with syntax highlighting from `oito2_ui_syntax`.
- Line numbers, highlighted lines and line markers, read-only mode and a minimum and maximum number of lines.
- Re-exports the `re_editor` types it uses, such as `CodeLineEditingController`.

**Platforms:** Linux, Windows, macOS, iOS, Android and Web.

## Installation

Requires Flutter 3.47 or later (Dart 3.13 or later).

The package isn't published on pub.dev yet. Add it as a git dependency:

```yaml
dependencies:
  oito2_ui_code_editor:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui_code_editor

dependency_overrides:
  oito2_ui:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui
  oito2_ui_syntax:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui_syntax
```

The packages `oito2_ui` and `oito2_ui_syntax` aren't on pub.dev yet either, and this package asks for them by version, so `dependency_overrides` takes them from the same repository. Add any other oito2_ui package your app uses to `dependencies` the same way.

Or, from a local clone of the repository next to your app:

```yaml
dependencies:
  oito2_ui_code_editor:
    path: ../oito2_ui/packages/oito2_ui_code_editor

dependency_overrides:
  oito2_ui:
    path: ../oito2_ui/packages/oito2_ui
  oito2_ui_syntax:
    path: ../oito2_ui/packages/oito2_ui_syntax
```

Then run `flutter pub get`.

## Usage

Edit code through a `CodeLineEditingController`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_code_editor/oito2_ui_code_editor.dart';

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final _controller = CodeLineEditingController.fromText('void main() {}\n');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Oito2CodeEditor(controller: _controller, language: 'dart', minLines: 10);
}
```

## Documentation

- [Showcase and documentation site](https://oito2.github.io/oito2_ui/): every component, live, with its API reference and guides.
- [CHANGELOG](CHANGELOG.md)
- [Source repository](https://github.com/oito2/oito2_ui/tree/main/packages/oito2_ui_code_editor)
- [Issue tracker](https://github.com/oito2/oito2_ui/issues)

## License

GPL-3.0 — see [LICENSE](LICENSE).
