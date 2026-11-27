# oito2_ui_files

oito2_ui file components on the official file_selector plugin: a file upload with a drop zone, previews and validation, and a download trigger.

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

oito2_ui_files is part of the [oito2_ui](https://github.com/oito2/oito2_ui) design system for Flutter apps on the desktop, mobile and the web.

- `Oito2FileUpload` picks files with the system dialog or takes them dropped on its zone, with previews, size and type validation and the reason for each refused file.
- `Oito2FileUploadController` holds the chosen and the refused files, with the accepted types, the file count and the size limit.
- `Oito2FileDropZone` receives files dragged from the desktop on Linux, Windows and macOS, and from the browser on the web.
- `Oito2Downloads` saves bytes as a file: a download on the web, the "Save as" dialog on Linux, Windows and macOS; `Oito2DownloadTrigger` is a button that builds the file on demand and saves it.

**Platforms:** Linux, Windows, macOS, Android and Web. Drops from the desktop work on Linux, Windows and macOS (`desktop_drop`) and on the web.

## Installation

Requires Flutter 3.47 or later (Dart 3.13 or later).

The package isn't published on pub.dev yet. Add it as a git dependency:

```yaml
dependencies:
  oito2_ui_files:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui_files

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
  oito2_ui_files:
    path: ../oito2_ui/packages/oito2_ui_files

dependency_overrides:
  oito2_ui:
    path: ../oito2_ui/packages/oito2_ui
```

Then run `flutter pub get`.

## Usage

Collect up to five images of at most 10 MB:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_files/oito2_ui_files.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _files = Oito2FileUploadController(
    accept: const [
      XTypeGroup(
        label: 'Images',
        extensions: ['png', 'jpg'],
        mimeTypes: ['image/*'],
      ),
    ],
    maxFiles: 5,
    maxFileSize: 10 * 1024 * 1024,
  );

  @override
  void dispose() {
    _files.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _files,
    builder: (context, _) => Column(
      children: [
        Oito2FileUpload(controller: _files),
        Text('${_files.files.length} files ready'),
      ],
    ),
  );
}
```

## Documentation

- [Showcase and documentation site](https://oito2.github.io/oito2_ui/): every component, live, with its API reference and guides.
- [CHANGELOG](CHANGELOG.md)
- [Source repository](https://github.com/oito2/oito2_ui/tree/main/packages/oito2_ui_files)
- [Issue tracker](https://github.com/oito2/oito2_ui/issues)

## License

GPL-3.0 — see [LICENSE](LICENSE).
