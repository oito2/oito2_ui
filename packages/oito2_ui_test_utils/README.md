# oito2_ui_test_utils

Test helpers shared by the oito2_ui packages: a themed pump, the real fonts and a tolerant comparator for golden tests.

This package is internal to the [oito2_ui](https://github.com/oito2/oito2_ui) repository. It isn't published (`publish_to: none`) and is meant only for the tests of the workspace packages, which list it under `dev_dependencies`.

## Table of Contents

- [Overview](#overview)
- [Usage](#usage)
- [Golden comparison](#golden-comparison)
- [Updating goldens](#updating-goldens)
- [License](#license)

## Overview

- `pumpOito2` pumps a widget in a `MaterialApp` with an oito2 theme, at a given window size and text direction, inside a `Scaffold` by default.
- `loadGoldenFonts` loads Inter, the Lucide icons and, when the package under test bundles them, JetBrains Mono and the Material icons, so goldens show real glyphs instead of the test font's boxes.
- `installGoldenComparator` replaces the golden comparator with `TolerantGoldenComparator`.
- `runGoldenTests` does both before running the tests: the body of a golden directory's `flutter_test_config.dart`.

## Usage

A package's golden directory, such as `test/goldens/`, holds a `flutter_test_config.dart`:

```dart
import 'dart:async';

import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) =>
    runGoldenTests(testMain);
```

Widget tests pump their widget with the oito2 theme:

```dart
testWidgets('shows the hint', (tester) async {
  await pumpOito2(tester, const Oito2SearchField(hintText: 'Find'));
  expect(find.text('Find'), findsOneWidget);
});
```

## Golden comparison

`TolerantGoldenComparator` accepts anti-aliasing noise and fails on real visual changes. It measures, for every pixel, the largest change of one RGBA channel, and passes when both limits hold:

| Limit | Constant | Value |
|---|---|---|
| Share of pixels that differ at all | `goldenTolerance` | 0.5% |
| Change of one channel above which a pixel differs strongly | `goldenStrongDelta` | 64 of 255 |
| Share of pixels that differ strongly | `goldenStrongTolerance` | 0.02% |

Text drawn a fraction of a pixel away changes the edge pixels of its glyphs and stays within the limits, while a moved dot, a resized swatch or a different icon fails, even when it changes only a few hundred pixels. A failure writes the master, test and diff images to the `failures/` folder next to the goldens, and its message gives the measured shares and the largest channel change.

A comparison against a missing golden fails the test with a `TestFailure`.

## Updating goldens

`flutter test --update-goldens` rewrites every golden, including the ones that only differ by noise. To rewrite only the goldens that are missing or differ beyond the limits, run the tests from the package directory with `OITO2_UPDATE_FAILED_GOLDENS` set to `1`:

```sh
OITO2_UPDATE_FAILED_GOLDENS=1 flutter test
```

Each rewritten golden is printed as `Updated golden <file> (<reason>)`. Review the new images before committing them.

## License

GPL-3.0 — see [LICENSE](LICENSE).
