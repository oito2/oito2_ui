# Getting Started

oito2_ui is a Material 3 design system for Flutter apps on Linux, Windows, macOS, iOS, Android and the web, with desktop-grade density and GTK-style surfaces. This page sets up an app with the theme, the localizations and a first component.

## Requirements

| Tool | Version |
|---|---|
| Flutter | 3.47 or newer |
| Dart | 3.13 or newer |

## Install

The packages aren't on pub.dev yet; add them from the Git repository. Each optional package also needs `oito2_ui` overridden to the same source, since it asks for the hosted version.

```yaml
dependencies:
  oito2_ui:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui
  # Optional packages, as you need them:
  oito2_ui_themes:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui_themes

dependency_overrides:
  oito2_ui:
    git:
      url: https://github.com/oito2/oito2_ui.git
      path: packages/oito2_ui
```

Then run `flutter pub get`.

| Package | What it adds |
|---|---|
| `oito2_ui` | The theme, the tokens and every core component |
| `oito2_ui_window` | The native desktop window: title bar, controls and window scope |
| `oito2_ui_settings` | Reads the system accent, color scheme, contrast and button layout |
| `oito2_ui_syntax` | `Oito2CodeBlock` and the syntax highlighter |
| `oito2_ui_themes` | The named color presets, such as Dracula and Catppuccin |
| `oito2_ui_extras` | QR codes, signature pad, image cropper and navigation menu |
| `oito2_ui_files` | File upload with a drop zone, and the download trigger |

## Set up the app

Give `MaterialApp` the oito2 themes and the oito2 localizations. `Oito2Theme.light` and `Oito2Theme.dark` take an optional accent color; the platform, which sets the density and control sizes, is detected.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oito2_ui/oito2_ui.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Oito2Theme.light(),
      darkTheme: Oito2Theme.dark(),
      localizationsDelegates: const [
        Oito2Localizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: Oito2Localizations.supportedLocales,
      home: const Home(),
    );
  }
}
```

> `Oito2Localizations` holds the texts of the components, such as tooltips and accessibility labels, in English and Brazilian Portuguese.

## Use a component

Components are ordinary widgets. A switch with a clickable label, for example:

```dart
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _wifi = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Oito2SwitchButton(
          value: _wifi,
          onChanged: (value) => setState(() => _wifi = value),
          title: const Text('Wi-Fi'),
        ),
      ),
    );
  }
}
```

## Next steps

- Read the guides on **Styling**, **Composition** and **Component State** to learn the patterns every component shares.
- Browse the components in the navigation: each page has working examples, their code, and the API reference.
