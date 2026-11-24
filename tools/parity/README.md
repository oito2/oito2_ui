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
| `l10n.json` | Every `Oito2Localizations` string in English and Brazilian Portuguese, plus the Material strings, calendar data (first weekday, narrow weekdays), date and time formats and the date and time entry parser results the widgets use |
| `format.json` | `Oito2Format` results for byte sizes, compact numbers and relative times |
| `syntax.json` | How `oito2_ui_syntax` tokenizes a sample of every default language, with the palette role of each run |
| `qr.json` | The QR modules `oito2_ui_extras` encodes for fixed texts at every error level |
| `password_strength.json` | The level and hint names `Oito2PasswordStrength.estimate` gives a sample of passwords, with and without user inputs |
| `gitignore.json` | How `Oito2GitignoreMatcher` of `oito2_ui_syntax` parses rule sets (git's documentation examples, negation, anchoring, directory-only rules, `**`, classes, escapes, trailing spaces, invalid rules, case folding) and the rule, ignored path and result it gives each sample path; trailing space trimming |
| `mime_icons.json` | The freedesktop icon name `Oito2FreedesktopIcons.forMimeType` picks for a table of MIME types |
| `widgets.json` | The pure rules behind widgets: `Oito2InfoType.severity`, the `Oito2AlertStack` order (`arrange`), the `Oito2DataTable.nextSort` cycle, the `Oito2UsageBar` fraction and tone, `Oito2TableColumn.resolveWidths`, the `Oito2Breadcrumb.collapse` results with the bar's measures, and `Oito2WeekScheduleGrid.indexOf` and day order for `en`, `en-GB` and `pt-BR` |
| `manifest.json` | The Flutter version, the `oito2_ui` package versions and the third-party versions the other files were generated with |

The files are tab-indented JSON with a final newline. Widths and fractions
are doubles as Dart prints them, such as `33.333333333333336`; compare them
with a small tolerance. Enum values are written by their Dart names, such as
`avoidCommon`, `warning` or `descending`; indexes count from 0. Keys are
only added, never renamed or removed, without agreeing with the consumers
first.

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
