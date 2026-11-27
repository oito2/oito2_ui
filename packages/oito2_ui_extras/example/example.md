# oito2_ui_extras example

Show a QR code and a signature pad that exports SVG:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui_extras/oito2_ui_extras.dart';

class Sign extends StatefulWidget {
  const Sign({super.key});

  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {
  final _signature = Oito2SignatureController();

  @override
  void dispose() {
    _signature.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Oito2QrCode(data: 'https://oito2.github.io/oito2_ui/'),
      Oito2SignaturePad(controller: _signature),
      TextButton(
        onPressed: () => debugPrint(_signature.toSvg()),
        child: const Text('Export SVG'),
      ),
    ],
  );
}
```

The [oito2_ui showcase](https://oito2.github.io/oito2_ui/) shows every component of the oito2_ui packages, live, with its documentation. Its source is the [`example`](https://github.com/oito2/oito2_ui/tree/main/example) app of the repository.
