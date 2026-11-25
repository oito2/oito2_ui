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

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';

/// Documents [Oito2Form]: an account settings form with an error summary,
/// a dirty indicator and a guard against leaving unsaved changes.
class FormPage extends StatelessWidget {
  /// Creates the form page.
  const FormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Form',
      description:
          'Validates a group of fields, leads to the first error and asks '
          'before unsaved changes are lost.',
      source: 'lib/src/pages/form_page.dart',
      children: [
        const ExamplePanel(
          region: 'preview',
          regions: ['save'],
          child: SizedBox(width: 480, child: _AccountForm()),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Create an `Oito2FormController` in your state and put the fields '
          'below an `Oito2Form` that uses it. The oito2 entries register '
          'with it on their own; wrap a Flutter `FormField`, such as a '
          '`TextFormField`, in an `Oito2FormFieldAdapter`. Fields outside a '
          'form keep working on their own.',
        ),
        const DocText(
          'A field with `participatesInForm: false` stays out of the form '
          'and keeps showing its own errors. `Oito2SearchField` stays out '
          'by default, since a search usually filters the screen; pass '
          '`participatesInForm: true` to make it part of the form.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          '`validate` checks every field, shows every error at once, '
          'focuses and scrolls to the first invalid field and announces '
          'the number of errors. `submit` validates and runs the save only '
          'when the form is valid. `isDirty` tells whether any value '
          'changed since the start or the last `markClean`, and `reset` '
          'puts the clean values back.',
        ),
        const DocHeading('Validators', level: 3),
        const DocText(
          'The entries take a `validator`, which runs after the text '
          'parses, and `required`, which shows "This field is required" '
          'for an empty field. Errors show once a field loses focus; after '
          'a failed validation, they show at once and follow the value '
          'while it is fixed. The `validator` of `Oito2TagsField` checks '
          'the whole list, while its `tagValidator` accepts or refuses each '
          'tag as it is added.',
        ),
        const DocHeading('Error summary', level: 3),
        const DocText(
          '`Oito2FormErrorSummary` shows the errors in a danger alert after '
          'a failed validation, such as "Fix 2 errors to continue", with a '
          'link per error that scrolls to its field and focuses it. It '
          'goes away once every error is fixed.',
        ),
        const DocHeading('Unsaved changes', level: 3),
        const DocText(
          '`Oito2UnsavedChangesGuard` asks before the page is left with '
          'unsaved changes: going back, switching pages in an '
          '`Oito2MasterDetailPage` or `Oito2NavigationPage` under an '
          '`Oito2UnsavedChangesScope`, and closing the window when the '
          'window controller of `oito2_ui_window` is in an '
          '`Oito2WindowScope`. With `onSave`, the dialog also offers to '
          'save. Change a field above and pick another page in the list, '
          'or close the window of the desktop showcase, to see it.',
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The summary is a live region, and `validate` politely announces '
          'the number of errors, such as "2 errors in the form". Each '
          'summary link reads as the field name and its error, with the '
          'hint "Go to the field". The unsaved changes dialog focuses '
          '"Keep editing", so Enter never drops the changes.',
        ),
        ...apiReferenceWidgets([
          'Oito2Form',
          'Oito2FormController',
          'Oito2FormError',
          'Oito2FormErrorSummary',
          'Oito2FormFieldAdapter',
          'Oito2FormFieldMixin',
          'Oito2UnsavedChangesGuard',
          'Oito2UnsavedChangesScope',
          'Oito2UnsavedChangesController',
          'Oito2UnsavedChangesAction',
        ]),
      ],
    );
  }
}

/// The account settings form of the preview.
class _AccountForm extends StatefulWidget {
  const _AccountForm();

  @override
  State<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<_AccountForm> {
  // #region preview
  final _form = Oito2FormController();
  final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  List<String> _interests = ['Design'];

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Oito2UnsavedChangesGuard(
      form: _form,
      onSave: _save,
      child: Oito2Form(
        controller: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Oito2Spacing.md,
          children: [
            const Oito2FormErrorSummary(),
            Oito2FormFieldAdapter(
              label: 'Name',
              child: TextFormField(
                initialValue: 'Ana Souza',
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (text) =>
                    (text ?? '').trim().isEmpty ? 'Enter your name' : null,
              ),
            ),
            Oito2FormFieldAdapter(
              label: 'Email',
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (text) => _email.hasMatch(text ?? '')
                    ? null
                    : 'Enter an email such as ana@example.com',
              ),
            ),
            Oito2DateEntry(
              labelText: 'Birthday',
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              validator: (date) => date != null && date.isAfter(DateTime.now())
                  ? 'The birthday is in the future'
                  : null,
            ),
            Oito2PasswordField(
              labelText: 'New password',
              autofillHints: const [AutofillHints.newPassword],
              showStrength: true,
              validator: (text) => text.isNotEmpty && text.length < 8
                  ? 'Use at least 8 characters'
                  : null,
            ),
            Oito2TagsField(
              labelText: 'Interests',
              tags: _interests,
              required: true,
              validator: (tags) =>
                  tags.length > 5 ? 'Pick up to 5 interests' : null,
              onChanged: (tags) => setState(() => _interests = tags),
            ),
            _Actions(form: _form, onSave: _save),
          ],
        ),
      ),
    );
  }
  // #endregion

  // #region save
  /// Validates the form and, when it is valid, keeps the values as the
  /// clean ones and confirms with a toast. Returns whether it saved.
  Future<bool> _save() => _form.submit(() {
    _form.markClean();
    Oito2Toaster.maybeOf(context)?.show(
      const Oito2Toast(title: 'Account saved', type: Oito2InfoType.success),
    );
  });
  // #endregion
}

/// The dirty indicator and the Reset and Save buttons.
class _Actions extends StatelessWidget {
  const _Actions({required this.form, required this.onSave});

  final Oito2FormController form;
  final Future<bool> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) => Row(
        spacing: Oito2Spacing.sm,
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: form.isDirty
                  ? const Oito2StatusPill(
                      label: 'Not saved',
                      type: Oito2InfoType.warning,
                    )
                  : const Oito2StatusPill(
                      label: 'All saved',
                      type: Oito2InfoType.success,
                    ),
            ),
          ),
          OutlinedButton(
            onPressed: form.isDirty ? form.reset : null,
            child: const Text('Reset'),
          ),
          FilledButton(onPressed: onSave, child: const Text('Save')),
        ],
      ),
    );
  }
}
