# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial package skeleton.
- `Oito2Highlighter`: highlights code into a `TextSpan` colored with a `Oito2SyntaxPalette`, in pure Dart through `re_highlight`, with 27 languages registered by default (`oito2DefaultLanguages`) and support for any other `re_highlight` grammar.
- `Oito2HighlighterTheme` and `Oito2SyntaxRole`: map highlight.js token scopes to the 11 palette roles.
- `Oito2CodeBlock`: selectable code block on the scheme container surface, with optional line numbers and a copy button.
- `Oito2CodeBlock`'s copy button is the core `Oito2CopyButton`: a check mark and a "Copied" tooltip after copying, announced to assistive technologies.
- Bundled JetBrains Mono variable font (regular and italic, SIL Open Font License), used by `Oito2CodeBlock` so code stays monospaced on every platform, including the web.
- The bundled JetBrains Mono font's license shows in the app's license page.

### Fixed

- `Oito2Highlighter` and `Oito2CodeBlock` accept language aliases and any letter case (`js`, `ts`, `sh`, `yml`, `py`, `Dart`); `Oito2Highlighter.supports` tells whether a name or alias is registered.
- `Oito2CodeBlock` highlights again only when its code, language, palette, style or highlighter change, and `Oito2Highlighter` reuses the token styles of recent palettes.
