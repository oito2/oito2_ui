# oito2_ui_code_editor example

Edit code through a `CodeLineEditingController`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_code_editor/oito2_ui_code_editor.dart';

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final _controller = CodeLineEditingController.fromText('void main() {}\n');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Oito2CodeEditor(controller: _controller, language: 'dart', minLines: 10);
}
```

The [oito2_ui showcase](https://oito2.github.io/oito2_ui/) shows every component of the oito2_ui packages, live, with its documentation. Its source is the [`example`](https://github.com/oito2/oito2_ui/tree/main/example) app of the repository.
