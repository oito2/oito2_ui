// Copyright (C) 2026  OITO2
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_test_utils/oito2_ui_test_utils.dart';

/// A tree controller that counts the calls to [checkStateOf].
class _CountingTreeController extends Oito2TreeController {
  _CountingTreeController() : super(expanded: ['src', 'src/widgets']);

  int checkStateCalls = 0;

  @override
  bool? checkStateOf(Oito2TreeCollection<Object?> collection, String value) {
    checkStateCalls++;
    return super.checkStateOf(collection, value);
  }
}

/// A global key that counts the reads of [currentContext].
class _CountingKey extends LabeledGlobalKey<State<StatefulWidget>> {
  _CountingKey(super.label);

  /// Holds the read count; keys are immutable, so the count lives in a
  /// final list.
  final List<int> _reads = [0];

  int get contextReads => _reads.first;

  @override
  BuildContext? get currentContext {
    _reads[0]++;
    return super.currentContext;
  }
}

/// A form field that counts its builds and shows whether the form shows
/// every error.
class _CountingField extends StatefulWidget {
  const _CountingField({required this.label, required this.builds});

  final String label;
  final Map<String, int> builds;

  @override
  State<_CountingField> createState() => _CountingFieldState();
}

class _CountingFieldState extends State<_CountingField>
    with Oito2FormFieldMixin {
  String? error;

  @override
  String? get formFieldLabel => widget.label;

  @override
  FocusNode? get formFieldFocusNode => null;

  @override
  String? get formFieldError => error;

  @override
  bool get isFormFieldDirty => false;

  @override
  Widget build(BuildContext context) {
    widget.builds.update(widget.label, (n) => n + 1, ifAbsent: () => 1);
    return Text('${widget.label}: ${formShowsErrors ? 'errors' : 'quiet'}');
  }
}

final _tree = Oito2TreeCollection<void>([
  const Oito2TreeNode(
    value: 'src',
    children: [
      Oito2TreeNode(value: 'src/main.dart', label: 'main.dart'),
      Oito2TreeNode(
        value: 'src/widgets',
        label: 'widgets',
        children: [
          Oito2TreeNode(value: 'src/widgets/a.dart', label: 'a.dart'),
          Oito2TreeNode(value: 'src/widgets/b.dart', label: 'b.dart'),
        ],
      ),
    ],
  ),
  const Oito2TreeNode(value: 'README.md'),
]);

const _crumbs = [
  Oito2BreadcrumbItem(label: 'Root', value: '/'),
  Oito2BreadcrumbItem(label: 'home', value: '/home'),
  Oito2BreadcrumbItem(label: 'ana', value: '/home/ana'),
  Oito2BreadcrumbItem(label: 'Documents', value: '/home/ana/Documents'),
  Oito2BreadcrumbItem(label: 'Projects', value: '/home/ana/Documents/P'),
  Oito2BreadcrumbItem(label: 'Reports', value: '/home/ana/Documents/P/R'),
];

/// Returns the focus node of the breadcrumb segment button [index].
FocusNode _crumbNode(WidgetTester tester, int index) => tester
    .widget<Focus>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Focus &&
            widget.focusNode?.debugLabel == 'Oito2Breadcrumb $index',
      ),
    )
    .focusNode!;

void main() {
  testWidgets('a checkable tree computes its check states only when they '
      'can change', (tester) async {
    final controller = _CountingTreeController();
    addTearDown(controller.dispose);
    await pumpOito2(
      tester,
      Oito2TreeView(collection: _tree, controller: controller, checkable: true),
    );
    final afterFirstBuild = controller.checkStateCalls;
    expect(afterFirstBuild, greaterThan(0));

    controller.setSelected(['README.md']);
    await tester.pump();
    expect(controller.checkStateCalls, afterFirstBuild);

    controller.toggleChecked(_tree, 'src/widgets');
    await tester.pump();
    expect(controller.checkStateCalls, greaterThan(afterFirstBuild));
    expect(controller.checkStateOf(_tree, 'src'), isNull);
  });

  testWidgets('a breadcrumb releases the focus nodes of removed segments', (
    tester,
  ) async {
    Future<void> pump(List<Oito2BreadcrumbItem<String>> items) => pumpOito2(
      tester,
      Oito2Breadcrumb<String>(items: items, onSelected: (_) {}),
    );
    await pump(_crumbs);
    final kept = _crumbNode(tester, 0);
    final removed = _crumbNode(tester, 4);

    await pump(_crumbs.sublist(0, 3));
    await tester.pump();
    expect(
      () => ChangeNotifier.debugAssertNotDisposed(removed),
      throwsFlutterError,
    );
    expect(ChangeNotifier.debugAssertNotDisposed(kept), isTrue);
    expect(identical(_crumbNode(tester, 0), kept), isTrue);
  });

  testWidgets('a change in one form field rebuilds only that field until '
      'the form shows every error', (tester) async {
    final form = Oito2FormController();
    addTearDown(form.dispose);
    final builds = <String, int>{};
    await pumpOito2(
      tester,
      Oito2Form(
        controller: form,
        child: Column(
          children: [
            _CountingField(label: 'A', builds: builds),
            _CountingField(label: 'B', builds: builds),
          ],
        ),
      ),
    );
    await tester.pump();
    final bBuilds = builds['B'];

    final a = tester.state<_CountingFieldState>(
      find.byWidgetPredicate((w) => w is _CountingField && w.label == 'A'),
    );
    a.error = 'Required';
    a.notifyFormFieldChanged();
    await tester.pump();
    expect(builds['B'], bBuilds);
    expect(find.text('B: quiet'), findsOneWidget);

    form.validate(focusFirstError: false, announce: false);
    await tester.pump();
    expect(find.text('A: errors'), findsOneWidget);
    expect(find.text('B: errors'), findsOneWidget);
  });

  testWidgets('a table of contents rebuilt with equal entries measures its '
      'headings only once', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final keys = [for (var i = 0; i < 3; i++) _CountingKey('Section $i')];
    late StateSetter rebuild;
    await pumpOito2(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return Row(
            children: [
              SizedBox(
                width: 200,
                child: Oito2TableOfContents(
                  controller: controller,
                  entries: [
                    for (var i = 0; i < 3; i++)
                      Oito2TocEntry(title: 'Section $i', target: keys[i]),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    for (var i = 0; i < 3; i++)
                      SizedBox(
                        height: 600,
                        child: Text('Heading $i', key: keys[i]),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    await tester.pump();
    final reads = keys.first.contextReads;
    expect(reads, greaterThan(0));

    rebuild(() {});
    await tester.pump();
    await tester.pump();
    expect(keys.first.contextReads, reads);
  });
}
