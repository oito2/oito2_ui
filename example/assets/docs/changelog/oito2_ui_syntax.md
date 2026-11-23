# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial package skeleton.
- `Oito2Highlighter`: highlights code into a `TextSpan` colored with a `Oito2SyntaxPalette`, in pure Dart through `re_highlight`, with 28 languages registered by default (`oito2DefaultLanguages`) and support for any other `re_highlight` grammar.
- `Oito2HighlighterTheme` and `Oito2SyntaxRole`: map highlight.js token scopes to the 11 palette roles.
- `Oito2CodeBlock`: selectable code block on the scheme container surface, with optional line numbers and a copy button.
- `Oito2CodeBlock`'s copy button is the core `Oito2CopyButton`: a check mark and a "Copied" tooltip after copying, announced to assistive technologies.
- Bundled JetBrains Mono variable font (regular and italic, SIL Open Font License), used by `Oito2CodeBlock` so code stays monospaced on every platform, including the web.
- The bundled JetBrains Mono font's license shows in the app's license page.
- `gitignore` language (`langGitignore`, also `ignore` and `dockerignore`), registered by default: comments, negation, root anchors and directory slashes, wildcards, character classes, escapes and trailing spaces.
- `Oito2CodeBlock.highlightedLines`: tints the given lines with a bar along their leading edge, with or without line numbers.
- `Oito2CodeEditor`: editable code field built on `re_editor`, with the theme's syntax palette, line numbers, `highlightedLines`, `lineMarkers` (`Oito2LineMarker` errors, warnings and information with a tooltip and an accessibility label), read-only mode, `minLines` and `maxLines`, the input focus border and themed scroll bars. It leaves the find, replace and save shortcuts to the app. `CodeLineEditingController` and its value types are exported from this package. Known limits from `re_editor`: web builds with `--wasm` are not supported (a dependency imports `dart:html`); each editor runs highlighting, folding and search in three background isolates on native platforms (on the web, on the main thread); and it colors a token by the first segment of its scope, so class names take the function color, unlike `Oito2CodeBlock`.
- `Oito2Highlighter.modeOf`: the grammar registered for a language name or alias.
- `Oito2GitignoreMatcher`: parses gitignore rules (`Oito2GitignoreMatcher.parse`) and tells whether a relative path is ignored with git's semantics: comments, negation, escapes, trailing spaces, anchoring, directory-only rules, `*`, `?`, bracket classes with ranges, negation and POSIX classes, `**` forms, the last matching rule winning and no re-including inside an ignored directory. `match` returns the deciding `Oito2GitignoreRule` (1-based line, pattern, negation) with the path it matched, and `isIgnored` the verdict.

### Fixed

- `Oito2Highlighter` and `Oito2CodeBlock` accept language aliases and any letter case (`js`, `ts`, `sh`, `yml`, `py`, `Dart`); `Oito2Highlighter.supports` tells whether a name or alias is registered.
- `Oito2CodeBlock` highlights again only when its code, language, palette, style or highlighter change, and `Oito2Highlighter` reuses the token styles of recent palettes.
