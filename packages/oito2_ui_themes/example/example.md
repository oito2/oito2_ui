# oito2_ui_themes example

Pick a preset for the light and the dark theme:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_themes/oito2_ui_themes.dart';

Widget app() => MaterialApp(
  theme: Oito2ThemePreset.catppuccinLatte.theme(),
  darkTheme: Oito2ThemePreset.catppuccinMocha.theme(),
  home: const Scaffold(),
);

List<String> names() => [
  for (final preset in Oito2ThemePreset.values) preset.label,
];
```

The [oito2_ui showcase](https://oito2.github.io/oito2_ui/) shows every component of the oito2_ui packages, live, with its documentation. Its source is the [`example`](https://github.com/oito2/oito2_ui/tree/main/example) app of the repository.
