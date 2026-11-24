# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial package skeleton.
- `Oito2CodeEditor`: editable code field built on `re_editor`, with the theme's syntax palette, line numbers, `highlightedLines`, `lineMarkers` (`Oito2LineMarker` errors, warnings and information with a tooltip and an accessibility label), read-only mode, `minLines` and `maxLines`, the input focus border and themed scroll bars. It leaves the find, replace and save shortcuts to the app. `CodeLineEditingController` and its value types, and `Oito2Highlighter` of `oito2_ui_syntax`, are exported from this package. Known limits from `re_editor`: web builds with `--wasm` are not supported (a dependency imports `dart:html`); each editor runs highlighting, folding and search in three background isolates on native platforms (on the web, on the main thread); and it colors a token by the first segment of its scope, so class names take the function color, unlike `Oito2CodeBlock`.
- Known limit from `re_editor`: it imports the SDK's `flutter/material.dart`, so apps using the editor pull in Material even though this package's own code uses `material_ui`.
