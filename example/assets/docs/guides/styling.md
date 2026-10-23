# Styling

oito2_ui is styled through the Flutter theme. One `ThemeData` built by `Oito2Theme` styles every oito2 component and the Material widgets alike, so an app changes its look in one place.

## Build the theme

`Oito2Theme` builds a Material 3 `ThemeData` from a color scheme and the platform. The platform sets the density, control sizes, tap targets and page transitions.

| Builder | Use it for |
|---|---|
| `Oito2Theme.light()` / `Oito2Theme.dark()` | The oito2 base scheme, with an optional `accent` and `highContrast` |
| `Oito2Theme.fromSystem(settings, brightness: ...)` | The system accent, contrast and platform, read by `oito2_ui_settings` |
| `Oito2Theme.fromColors(colors)` | Any `Oito2ColorTheme`, such as a preset or your own roles |

```dart
MaterialApp(
  theme: Oito2Theme.light(accent: const Color(0xFF26A269)),
  darkTheme: Oito2Theme.dark(accent: const Color(0xFF26A269)),
);
```

## Color schemes

An `Oito2ColorTheme` holds the Material `ColorScheme` and the oito2 color extensions, with every text role checked for WCAG AA contrast. `Oito2ColorTheme.fromRoles` builds one from the dozen colors a theme family defines; the `oito2_ui_themes` package ships named presets built that way.

```dart
import 'package:oito2_ui_themes/oito2_ui_themes.dart';

MaterialApp(theme: Oito2Theme.fromColors(Oito2ThemePreset.dracula.colors));
```

## Theme extensions

Colors that `ColorScheme` has no role for live in theme extensions. Read them from the theme in `build`:

| Extension | Colors |
|---|---|
| `Oito2SemanticColors` | `primaryText`, `errorText`, `success`, `warning`, `info`, `link`: text-safe status and accent tones |
| `Oito2ChromeColors` | `background`, `sidebar`, `mainbar`, `titleBar`, `dialog`: the window surfaces |

```dart
final colors = Theme.of(context).extension<Oito2SemanticColors>()!;
Text('Saved', style: TextStyle(color: colors.success));
```

## Design tokens

Spacing, radii and sizes are constants, so custom widgets line up with the components.

| Token class | Examples |
|---|---|
| `Oito2Spacing` | `xxs` (2), `xs` (4), `sm` (8), `md` (12), `lg` (16), `xl` (24), `xxl` (32) |
| `Oito2Radius` | `small` (6), `medium` (8), `large` (12), with `smallAll`, `mediumAll` and `largeAll` |
| `Oito2Sizes` | `buttonHeight` (34), `touchButtonHeight` (40), `iconSize` (20) |

```dart
Padding(
  padding: const EdgeInsets.all(Oito2Spacing.md),
  child: DecoratedBox(
    decoration: BoxDecoration(borderRadius: Oito2Radius.mediumAll),
  ),
);
```

## Component variants

Components offer their variations as parameters instead of separate widgets: a `style` enum, a named constructor or a color.

```dart
Oito2TabBar(style: Oito2TabBarStyle.subtle, tabs: tabs);
Oito2BorderContainer.tinted(tint: Colors.green, child: content);
Oito2TagsField(style: Oito2TagsFieldStyle.subtle, tags: tags, onChanged: update);
```

## Override one component

To restyle a Material widget in one subtree, wrap it in its theme widget, such as `FilledButtonTheme` or `InputDecorationTheme`, built from the ambient theme. The oito2 components read the same Material themes, so overrides apply to them too.

```dart
FilledButtonTheme(
  data: FilledButtonThemeData(
    style: FilledButton.styleFrom(shape: const StadiumBorder()),
  ),
  child: content,
);
```
