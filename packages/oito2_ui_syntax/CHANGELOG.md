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
- Bundled JetBrains Mono variable font (regular and italic, SIL Open Font License), used by `Oito2CodeBlock` so code stays monospaced on every platform, including the web.

