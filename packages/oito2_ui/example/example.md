# oito2_ui example

Use the oito2 theme and localizations in a `MaterialApp`, then build with the `Oito2` widgets:

```dart
import 'package:material_ui/material_ui.dart';
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
      home: Scaffold(
        appBar: const Oito2WindowTitleBar(title: Text('Notes')),
        body: Center(
          child: SizedBox(
            width: 320,
            child: Oito2SearchField(
              hintText: 'Search notes',
              onChanged: (text) => debugPrint(text),
            ),
          ),
        ),
      ),
    );
  }
}
```

The [oito2_ui showcase](https://oito2.github.io/oito2_ui/) shows every component of the oito2_ui packages, live, with its documentation. Its source is the [`example`](https://github.com/oito2/oito2_ui/tree/main/example) app of the repository.
