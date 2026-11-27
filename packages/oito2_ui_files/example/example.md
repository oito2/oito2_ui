# oito2_ui_files example

Collect up to five images of at most 10 MB:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_files/oito2_ui_files.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _files = Oito2FileUploadController(
    accept: const [
      XTypeGroup(
        label: 'Images',
        extensions: ['png', 'jpg'],
        mimeTypes: ['image/*'],
      ),
    ],
    maxFiles: 5,
    maxFileSize: 10 * 1024 * 1024,
  );

  @override
  void dispose() {
    _files.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _files,
    builder: (context, _) => Column(
      children: [
        Oito2FileUpload(controller: _files),
        Text('${_files.files.length} files ready'),
      ],
    ),
  );
}
```

The [oito2_ui showcase](https://oito2.github.io/oito2_ui/) shows every component of the oito2_ui packages, live, with its documentation. Its source is the [`example`](https://github.com/oito2/oito2_ui/tree/main/example) app of the repository.
