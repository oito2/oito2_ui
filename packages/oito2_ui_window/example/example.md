# oito2_ui_window example

Initialize the window before `runApp` and hand its controller to the `oito2_ui` widgets through `Oito2WindowScope`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_window/oito2_ui_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Null on the web, Android and iOS, where the app owns no window.
  final window = await Oito2Window.ensureInitialized(
    title: 'Notes',
    size: const Size(1024, 720),
    minimumSize: const Size(480, 360),
  );
  runApp(
    Oito2WindowScope(
      controller: window,
      child: MaterialApp(
        theme: Oito2Theme.light(),
        home: const Scaffold(
          // The title bar draws the window buttons and drags the window.
          appBar: Oito2WindowTitleBar(title: Text('Notes')),
        ),
      ),
    ),
  );
}
```

The [oito2_ui showcase](https://oito2.github.io/oito2_ui/) shows every component of the oito2_ui packages, live, with its documentation. Its source is the [`example`](https://github.com/oito2/oito2_ui/tree/main/example) app of the repository.
