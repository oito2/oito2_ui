# oito2_ui_settings example

Load the settings before `runApp`, keep them current with `Oito2SystemSettingsScope` and build the theme from them:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_settings/oito2_ui_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await Oito2Settings.load();
  runApp(
    Oito2SystemSettingsScope(initialSettings: settings, child: const App()),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the desktop settings change.
    final system = Oito2SystemScope.of(context);
    return MaterialApp(
      theme: Oito2Theme.fromSystem(system, brightness: Brightness.light),
      darkTheme: Oito2Theme.fromSystem(system, brightness: Brightness.dark),
      home: const Scaffold(),
    );
  }
}
```

The [oito2_ui showcase](https://oito2.github.io/oito2_ui/) shows every component of the oito2_ui packages, live, with its documentation. Its source is the [`example`](https://github.com/oito2/oito2_ui/tree/main/example) app of the repository.
