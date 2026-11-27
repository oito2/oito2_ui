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

/// Returns the text field whose decoration has [label].
Finder _field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

/// Returns the focus node of the text field labelled [label].
FocusNode _focusOf(WidgetTester tester, String label) => tester
    .widget<EditableText>(
      find.descendant(of: _field(label), matching: find.byType(EditableText)),
    )
    .focusNode;

/// The remove button of the tag "a".
final _removeTag = find.byWidgetPredicate(
  (widget) => widget is Tooltip && widget.message == 'Remove a',
);

/// A form controller disposed after the test.
Oito2FormController _controller() {
  final form = Oito2FormController();
  addTearDown(form.dispose);
  return form;
}

/// Pumps [children] in a column inside an [Oito2Form] of [form], above a
/// button that takes the focus away from the fields.
Future<void> _pumpForm(
  WidgetTester tester,
  Oito2FormController form,
  List<Widget> children,
) => pumpOito2(
  tester,
  Oito2Form(
    controller: form,
    child: SingleChildScrollView(
      child: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Oito2FormErrorSummary(),
            ...children,
            TextButton(onPressed: () {}, child: const Text('Elsewhere')),
          ],
        ),
      ),
    ),
  ),
);

/// Moves the focus to the "Elsewhere" button.
Future<void> _blur(WidgetTester tester) async {
  Focus.of(tester.element(find.text('Elsewhere'))).requestFocus();
  await tester.pump();
}

/// A tags field that keeps its tags in its own state.
class _Tags extends StatefulWidget {
  const _Tags({this.required = false});

  final bool required;

  @override
  State<_Tags> createState() => _TagsState();
}

class _TagsState extends State<_Tags> {
  List<String> _tags = const ['a'];

  @override
  Widget build(BuildContext context) => Oito2TagsField(
    labelText: 'Tags',
    tags: _tags,
    required: widget.required,
    onChanged: (tags) => setState(() => _tags = tags),
  );
}

/// A number entry that keeps its value in its own state.
class _Number extends StatefulWidget {
  const _Number();

  @override
  State<_Number> createState() => _NumberState();
}

class _NumberState extends State<_Number> {
  double _value = 5;

  @override
  Widget build(BuildContext context) => Oito2NumberEntry(
    labelText: 'Count',
    value: _value,
    validator: (value) => value > 8 ? 'Too many' : null,
    onChanged: (value) => setState(() => _value = value),
  );
}

void main() {
  group('Oito2FormController', () {
    testWidgets('validate shows every error, focuses the first invalid '
        'field and announces the count', (tester) async {
      final form = _controller();
      await _pumpForm(tester, form, [
        const Oito2PasswordField(labelText: 'Name', required: true),
        Oito2DateEntry(
          labelText: 'Birthday',
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          required: true,
        ),
        const Oito2PasswordField(labelText: 'Password', required: true),
      ]);
      expect(find.text('This field is required'), findsNothing);

      expect(form.validate(), isFalse);
      await tester.pump();

      expect(find.text('This field is required'), findsNWidgets(3));
      expect(
        [for (final e in form.errors) e.label],
        ['Name', 'Birthday', 'Password'],
      );
      expect(_focusOf(tester, 'Name').hasFocus, isTrue);
      expect(
        [for (final a in tester.takeAnnouncements()) a.message],
        ['3 errors in the form'],
      );
    });

    testWidgets('fields follow the tree order, not the registration '
        'order', (tester) async {
      final form = _controller();
      Widget build({required bool showFirst}) => Column(
        children: [
          if (showFirst)
            const Oito2PasswordField(labelText: 'First', required: true),
          const Oito2PasswordField(labelText: 'Second', required: true),
        ],
      );
      await _pumpForm(tester, form, [build(showFirst: false)]);
      await _pumpForm(tester, form, [build(showFirst: true)]);
      form.validate();
      await tester.pump();
      expect([for (final e in form.errors) e.label], ['First', 'Second']);
      expect(_focusOf(tester, 'First').hasFocus, isTrue);
    });

    testWidgets('errors show after blur, and at once after a failed '
        'submit', (tester) async {
      final form = _controller();
      await _pumpForm(tester, form, [
        Oito2PasswordField(
          labelText: 'Code',
          validator: (text) => text.length < 3 ? 'Too short' : null,
        ),
      ]);
      await tester.enterText(_field('Code'), 'a');
      await tester.pump();
      expect(find.text('Too short'), findsNothing);
      await _blur(tester);
      expect(find.text('Too short'), findsOneWidget);

      // A valid value hides the error; typing an invalid one again
      // doesn't show it until the next blur.
      await tester.enterText(_field('Code'), 'abc');
      await tester.pump();
      expect(find.text('Too short'), findsNothing);
      await tester.enterText(_field('Code'), 'ab');
      await tester.pump();
      expect(find.text('Too short'), findsOneWidget);

      var saved = 0;
      expect(await form.submit(() => saved++), isFalse);
      expect(saved, 0);
      await tester.pump();
      await tester.enterText(_field('Code'), 'x');
      await tester.pump();
      expect(find.text('Too short'), findsOneWidget);
      await tester.enterText(_field('Code'), 'xyz');
      await tester.pump();
      expect(find.text('Too short'), findsNothing);
      expect(await form.submit(() => saved++), isTrue);
      expect(saved, 1);
    });

    testWidgets('fields outside a form behave as on their own', (tester) async {
      await pumpOito2(
        tester,
        Column(
          children: [
            Oito2DateEntry(
              labelText: 'Date',
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
              required: true,
              validator: (date) =>
                  date != null && date.year < 2020 ? 'Too early' : null,
            ),
            TextButton(onPressed: () {}, child: const Text('Elsewhere')),
          ],
        ),
      );
      await tester.tap(_field('Date'));
      await _blur(tester);
      expect(find.text('This field is required'), findsOneWidget);
      await tester.enterText(_field('Date'), '01/02/2010');
      await tester.pump();
      expect(find.text('Too early'), findsNothing);
      await _blur(tester);
      expect(find.text('Too early'), findsOneWidget);
    });

    testWidgets('the validator runs only after the text parses', (
      tester,
    ) async {
      final errors = <String?>[];
      final values = <DateTime?>[];
      final form = _controller();
      await _pumpForm(tester, form, [
        Oito2DateEntry(
          labelText: 'Date',
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
          onChanged: values.add,
          onErrorChanged: errors.add,
          validator: (date) => 'Never valid',
        ),
      ]);
      await tester.enterText(_field('Date'), '13/45/2010');
      await _blur(tester);
      expect(find.text('Invalid format.'), findsOneWidget);
      expect(find.text('Never valid'), findsNothing);
      await tester.enterText(_field('Date'), '01/02/2010');
      await _blur(tester);
      expect(find.text('Never valid'), findsOneWidget);
      // The parse errors are reported; the validator doesn't stop the
      // value.
      expect(errors, ['Invalid format.', null]);
      expect(values, [DateTime(2010, 1, 2)]);
    });

    testWidgets('dirty, markClean and reset follow each kind of field', (
      tester,
    ) async {
      final form = _controller();
      final nameKey = GlobalKey<FormFieldState<String>>();
      await _pumpForm(tester, form, [
        Oito2FormFieldAdapter(
          label: 'Nickname',
          child: TextFormField(
            key: nameKey,
            initialValue: 'Ana',
            decoration: const InputDecoration(labelText: 'Nickname'),
          ),
        ),
        Oito2DateEntry(
          labelText: 'Date',
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
          initialDate: DateTime(2020, 5, 6),
        ),
        const Oito2TimeEntry(labelText: 'Time'),
        const Oito2PasswordField(labelText: 'Password'),
        Oito2Autocomplete<String>(
          labelText: 'Fruit',
          collection: Oito2ListCollection(['Apple', 'Pear']),
        ),
        const Oito2SearchField(hintText: 'Find', participatesInForm: true),
        const _Number(),
        const _Tags(),
        const Oito2PinEntry(length: 4),
        const Oito2SegmentedEntry(
          labelText: 'Address',
          segments: [
            Oito2EntrySegment(length: 3),
            Oito2EntrySegment(length: 3),
          ],
          initialValues: ['10', '0'],
        ),
      ]);
      await tester.pump();
      expect(form.fields, hasLength(10));
      expect(form.isDirty, isFalse);

      Future<void> expectDirtyAfter(Future<void> Function() change) async {
        await change();
        await tester.pump();
        expect(form.isDirty, isTrue);
        form.reset();
        await tester.pump();
        expect(form.isDirty, isFalse);
      }

      await expectDirtyAfter(() => tester.enterText(_field('Nickname'), 'Bo'));
      expect(nameKey.currentState!.value, 'Ana');
      expect(find.text('Ana'), findsOneWidget);

      await expectDirtyAfter(
        () => tester.enterText(_field('Date'), '01/02/2021'),
      );
      expect(find.text('05/06/2020'), findsOneWidget);
      await expectDirtyAfter(() => tester.enterText(_field('Time'), '9:30'));
      await expectDirtyAfter(
        () => tester.enterText(_field('Password'), 'secret'),
      );
      await expectDirtyAfter(() => tester.enterText(_field('Fruit'), 'Ap'));
      await expectDirtyAfter(
        () => tester.enterText(find.byType(TextField).at(5), 'query'),
      );
      await expectDirtyAfter(() async {
        await tester.enterText(_field('Count'), '7');
        await tester.testTextInput.receiveAction(TextInputAction.done);
      });
      expect(find.text('5'), findsOneWidget);
      await expectDirtyAfter(() async {
        await tester.tap(_removeTag);
      });
      expect(find.text('a'), findsOneWidget);
      await expectDirtyAfter(
        () => tester.enterText(
          find.descendant(
            of: find.byType(Oito2PinEntry),
            matching: find.byType(TextField),
          ),
          '12',
        ),
      );
      await expectDirtyAfter(
        () => tester.enterText(
          find
              .descendant(
                of: find.byType(Oito2SegmentedEntry),
                matching: find.byType(TextField),
              )
              .first,
          '192',
        ),
      );
      expect(find.text('10'), findsOneWidget);

      // After markClean, the new values are the clean ones.
      await tester.enterText(_field('Password'), 'saved');
      await tester.pump();
      expect(form.isDirty, isTrue);
      form.markClean();
      expect(form.isDirty, isFalse);
      await tester.enterText(_field('Password'), 'changed');
      await tester.pump();
      form.reset();
      await tester.pump();
      expect(find.text('saved'), findsOneWidget);
    });

    testWidgets('a search field takes part in a form only when it opts in', (
      tester,
    ) async {
      final form = _controller();
      await _pumpForm(tester, form, [
        Oito2SearchField(
          hintText: 'Filter',
          validator: (text) => text.isEmpty ? 'Type a filter' : null,
        ),
        Oito2PasswordField(
          labelText: 'Left out',
          participatesInForm: false,
          validator: (text) => 'Never valid',
        ),
      ]);
      await tester.enterText(find.byType(TextField).first, 'abc');
      await tester.enterText(_field('Left out'), 'x');
      await tester.pump();
      expect(form.fields, isEmpty);
      expect(form.isDirty, isFalse);
      expect(form.validate(), isTrue);
      await tester.pump();
      expect(find.byType(Oito2Alert), findsNothing);
      // A field left out still shows its own error after blur.
      await _blur(tester);
      expect(find.text('Never valid'), findsOneWidget);

      await _pumpForm(tester, form, [
        Oito2SearchField(
          hintText: 'Filter',
          participatesInForm: true,
          validator: (text) => text.isEmpty ? 'Type a filter' : null,
        ),
      ]);
      await tester.pump();
      expect(form.fields, hasLength(1));
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump();
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('Filter: Type a filter'), findsOneWidget);
    });

    testWidgets('a field that stops taking part leaves the form', (
      tester,
    ) async {
      final form = _controller();
      await _pumpForm(tester, form, [
        const Oito2PasswordField(labelText: 'Name', required: true),
      ]);
      expect(form.fields, hasLength(1));
      await _pumpForm(tester, form, [
        const Oito2PasswordField(
          labelText: 'Name',
          required: true,
          participatesInForm: false,
        ),
      ]);
      await tester.pump();
      expect(form.fields, isEmpty);
      expect(form.validate(), isTrue);
    });

    testWidgets('listeners hear when the form turns dirty', (tester) async {
      final form = _controller();
      final dirty = <bool>[];
      form.addListener(() => dirty.add(form.isDirty));
      await _pumpForm(tester, form, [const _Number()]);
      dirty.clear();
      await tester.enterText(_field('Count'), '7');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(dirty, contains(true));
    });

    testWidgets('required and validators on each entry', (tester) async {
      final form = _controller();
      await _pumpForm(tester, form, [
        Oito2TimeEntry(
          labelText: 'Time',
          required: true,
          validator: (time) => 'unused',
        ),
        Oito2DateTimeEntry(
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
          dateLabelText: 'Starts',
          timeLabelText: 'At',
          initialDateTime: DateTime(2020, 1, 1, 8),
          validator: (value) =>
              value != null && value.hour < 9 ? 'Too early' : null,
        ),
        Oito2SegmentedEntry(
          labelText: 'Address',
          segments: const [
            Oito2EntrySegment(length: 3),
            Oito2EntrySegment(length: 3),
          ],
          validator: (values) => values.contains('') ? 'Incomplete' : null,
        ),
        const _Number(),
        const Oito2PinEntry(length: 4, required: true),
        const _Tags(),
        Oito2Autocomplete<String>(
          labelText: 'Fruit',
          collection: Oito2ListCollection(['Apple']),
          validator: (text) => text == 'Apple' ? null : 'Pick a fruit',
        ),
        Oito2SearchField(
          hintText: 'Find',
          participatesInForm: true,
          validator: (text) => text.length < 2 ? 'Type more' : null,
        ),
      ]);
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(
        [for (final e in form.errors) (e.label, e.message)],
        [
          ('Time', 'This field is required'),
          ('Starts', 'Too early'),
          ('Address', 'Incomplete'),
          ('Code of 4 characters', 'This field is required'),
          ('Fruit', 'Pick a fruit'),
          ('Find', 'Type more'),
        ],
      );
      expect(find.text('Too early'), findsWidgets);
      expect(find.text('Incomplete'), findsWidgets);

      // The date and time validator checks the combination again when
      // the time changes.
      await tester.enterText(_field('At'), '10:00');
      await tester.pump();
      expect(form.errors.map((e) => e.label), isNot(contains('Starts')));

      await tester.enterText(_field('Count'), '9');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('Too many'), findsOneWidget);
    });

    testWidgets('a required tags field without tags shows the error', (
      tester,
    ) async {
      final form = _controller();
      await _pumpForm(tester, form, [const _Tags(required: true)]);
      await tester.tap(_removeTag);
      await tester.pump();
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('This field is required'), findsWidgets);
    });

    testWidgets('a tags field refuses tags with tagValidator and checks '
        'the list with validator', (tester) async {
      var tags = <String>['a'];
      final form = _controller();
      await _pumpForm(tester, form, [
        StatefulBuilder(
          builder: (context, setState) => Oito2TagsField(
            labelText: 'Tags',
            tags: tags,
            tagValidator: (tag) => tag != 'bad',
            validator: (tags) => tags.length < 2 ? 'Add two tags' : null,
            onChanged: (value) => setState(() => tags = value),
          ),
        ),
      ]);
      final input = find.descendant(
        of: find.byType(Oito2TagsField),
        matching: find.byType(TextField),
      );
      await tester.enterText(input, 'bad,');
      await tester.pump();
      expect(tags, ['a']);
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('Add two tags'), findsOneWidget);
      await tester.enterText(input, 'good,');
      await tester.pump();
      expect(tags, ['a', 'good']);
      expect(find.text('Add two tags'), findsNothing);
    });

    testWidgets('a FormField in an adapter validates with the form', (
      tester,
    ) async {
      final form = _controller();
      await _pumpForm(tester, form, [
        Oito2FormFieldAdapter(
          label: 'Email',
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (text) =>
                text != null && text.contains('@') ? null : 'Enter an email',
          ),
        ),
      ]);
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter an email'), findsOneWidget);
      expect(find.text('Email: Enter an email'), findsOneWidget);
      expect(_focusOf(tester, 'Email').hasFocus, isTrue);
      await tester.enterText(_field('Email'), 'a@b');
      await tester.pump();
      expect(find.text('Enter an email'), findsNothing);
      expect(form.errors, isEmpty);
    });

    // Each builder returns a text-based field on the given controller.
    final textFields = <String, Widget Function(TextEditingController)>{
      'password': (controller) =>
          Oito2PasswordField(labelText: 'Password', controller: controller),
      'PIN': (controller) => Oito2PinEntry(length: 4, controller: controller),
      'search': (controller) =>
          Oito2SearchField(participatesInForm: true, controller: controller),
    };
    for (final MapEntry(key: name, value: build) in textFields.entries) {
      testWidgets('a $name field takes the text of a new controller as '
          'clean', (tester) async {
        final form = _controller();
        final first = TextEditingController(text: '12');
        final second = TextEditingController(text: '34');
        addTearDown(first.dispose);
        addTearDown(second.dispose);
        await _pumpForm(tester, form, [build(first)]);
        expect(form.isDirty, isFalse);

        await _pumpForm(tester, form, [build(second)]);
        await tester.pump();
        expect(form.isDirty, isFalse);

        second.text = '56';
        await tester.pump();
        expect(form.isDirty, isTrue);
        form.reset();
        await tester.pump();
        expect(second.text, '34');
        expect(form.isDirty, isFalse);
      });
    }

    testWidgets('required trims the search text but not the password or '
        'the PIN', (tester) async {
      final form = _controller();
      final password = TextEditingController(text: '   ');
      final pin = TextEditingController(text: '  ');
      final search = TextEditingController(text: '   ');
      addTearDown(password.dispose);
      addTearDown(pin.dispose);
      addTearDown(search.dispose);
      await _pumpForm(tester, form, [
        Oito2PasswordField(
          labelText: 'Password',
          required: true,
          controller: password,
        ),
        Oito2PinEntry(length: 4, required: true, controller: pin),
        Oito2SearchField(
          hintText: 'Find',
          participatesInForm: true,
          required: true,
          controller: search,
        ),
      ]);
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(
        [for (final e in form.errors) (e.label, e.message)],
        [('Find', 'This field is required')],
      );
    });
  });

  group('Oito2FormErrorSummary', () {
    testWidgets('lists the errors after a failed validation and goes away '
        'once they are fixed', (tester) async {
      final form = _controller();
      await _pumpForm(tester, form, [
        const Oito2PasswordField(labelText: 'Name', required: true),
        const Oito2PasswordField(labelText: 'City', required: true),
      ]);
      expect(find.byType(Oito2Alert), findsNothing);
      form.validate();
      await tester.pump();
      expect(find.text('Fix 2 errors to continue'), findsOneWidget);
      expect(find.text('Name: This field is required'), findsOneWidget);
      expect(find.text('City: This field is required'), findsOneWidget);

      await tester.enterText(_field('Name'), 'Ana');
      await tester.pump();
      expect(find.text('Fix 1 error to continue'), findsOneWidget);
      await tester.enterText(_field('City'), 'Rio');
      await tester.pump();
      expect(find.byType(Oito2Alert), findsNothing);
    });

    testWidgets('a link scrolls to its field and focuses it', (tester) async {
      final form = _controller();
      await pumpOito2(
        tester,
        Oito2Form(
          controller: form,
          child: Column(
            children: [
              const Oito2FormErrorSummary(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Oito2PasswordField(labelText: 'Top'),
                      const SizedBox(height: 2000),
                      Oito2PasswordField(
                        labelText: 'Bottom',
                        validator: (text) => 'Wrong',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        size: const Size(600, 500),
      );
      form.validate(focusFirstError: false);
      await tester.pumpAndSettle();
      expect(_field('Bottom').hitTestable(), findsNothing);
      await tester.tap(find.text('Bottom: Wrong'));
      await tester.pumpAndSettle();
      expect(_focusOf(tester, 'Bottom').hasFocus, isTrue);
      expect(_field('Bottom').hitTestable(), findsOneWidget);
    });

    for (final (name, colors) in [
      ('light', Oito2ColorTheme.light()),
      ('dark', Oito2ColorTheme.dark()),
    ]) {
      testWidgets('meets the contrast and label guidelines, $name', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final form = _controller();
        await pumpOito2(
          tester,
          Oito2Form(
            controller: form,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Oito2FormErrorSummary(),
                  Oito2PasswordField(labelText: 'Name', required: true),
                ],
              ),
            ),
          ),
          colors: colors,
        );
        form.validate(focusFirstError: false);
        await tester.pumpAndSettle();
        expect(find.byType(Oito2Alert), findsOneWidget);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        final link = tester.getSemantics(
          find.text('Name: This field is required'),
        );
        expect(link.getSemanticsData().hint, 'Go to the field');
        semantics.dispose();
      });
    }
  });
}
