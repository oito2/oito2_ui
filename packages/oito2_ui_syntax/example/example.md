# oito2_ui_syntax example

Show a highlighted code block, or check paths against `.gitignore` rules:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_syntax/oito2_ui_syntax.dart';

const snippet = '''
void main() {
  print('Hello');
}
''';

Widget example() => const Oito2CodeBlock(
  code: snippet,
  language: 'dart',
  showLineNumbers: true,
);

bool ignored() =>
    Oito2GitignoreMatcher.parse('build/\n*.log').isIgnored('app.log');
```

The [oito2_ui showcase](https://oito2.github.io/oito2_ui/) shows every component of the oito2_ui packages, live, with its documentation. Its source is the [`example`](https://github.com/oito2/oito2_ui/tree/main/example) app of the repository.
