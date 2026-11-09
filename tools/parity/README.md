# oito2_ui parity fixtures

`tools/parity` exports the design data of `oito2_ui` as JSON fixtures. The
sibling implementations of the design system (`oito2_uikit`, `oito2_rs`,
`oito2_iced`) test themselves against these files, so a change in a color, a
measure, a string or a tokenization shows up here as a data diff before it
reaches them.

The fixtures live in `fixtures/` and are committed. CI regenerates them and
fails when they are stale.

## Fixtures

| File | Content |
|---|---|
| `tokens.json` | Radii, spacing, sizes, accent colors, neutral and status palettes, typography scale |
| `schemes.json` | Theme family palettes, every resolved color of the base schemes (light, dark, each accent, high contrast) and of the presets |
| `foundation.json` | Contrast ratios and adjustments, desktop environment detection, window button layouts, platform flags, fallback system settings |
| `l10n.json` | Every `Oito2Localizations` string in English and Brazilian Portuguese, plus the Material strings the widgets use |
| `format.json` | `Oito2Format` results for byte sizes, compact numbers and relative times |
| `syntax.json` | How `oito2_ui_syntax` tokenizes a sample of every default language, with the palette role of each run |
| `qr.json` | The QR modules `oito2_ui_extras` encodes for fixed texts at every error level |
| `manifest.json` | The Flutter version, the `oito2_ui` package versions and the third-party versions the other files were generated with |

The files are tab-indented JSON with a final newline. Keys are only added,
never renamed or removed, without agreeing with the consumers first.

## Regenerating

```bash
cd tools/parity
flutter test
```

The exporters are Flutter tests because they read `dart:ui` types; `dart
test` can't run them. `PARITY_OUT=<dir>` writes the files somewhere else.

## Consuming

Copy the files from a commit or tag of this repository, for example from
`https://raw.githubusercontent.com/oito2/oito2_ui/<ref>/tools/parity/fixtures/<name>.json`,
and record the commit SHA next to the copy. `manifest.json` tells which
versions produced the data. A weekly job in each consumer can compare its
copy with `main` to learn that `oito2_ui` moved.
