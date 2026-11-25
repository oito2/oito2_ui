# Forms

oito2_ui fields report a value and, when the text doesn't parse, an error. Combine them with the Material `Form` and `TextFormField`, which the theme styles the same way.

## Text fields

Use `TextField` or `TextFormField` for free text; the theme gives them the oito2 height, border and focus ring. For specific values, the oito2 entries parse and validate the text for you:

| Field | Value |
|---|---|
| `Oito2NumberEntry` | A number within a range, with steps, arrow keys and the mouse wheel |
| `Oito2DateEntry`, `Oito2TimeEntry`, `Oito2DateTimeEntry` | Dates and times in the locale format, with a calendar picker |
| `Oito2PasswordField` | A password with a show button and a Caps Lock warning |
| `Oito2PinEntry` | A code of single characters, such as a verification code |
| `Oito2SegmentedEntry` | Joined segments, such as an IP address |
| `Oito2TagsField` | A list of tags, with suggestions and validation |

## Values and errors

Entries call `onChanged` only with valid values, and `onErrorChanged` with the error message when the text stops parsing, or null when it parses again. Errors show under the field once it loses focus or is submitted.

Fields work on their own, as above, or together in an `Oito2Form`.

```dart
Oito2DateEntry(
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onChanged: (date) => setState(() => _date = date),
  onErrorChanged: (error) => setState(() => _dateError = error),
);
```

## Validating a form

Put the fields below an `Oito2Form` with an `Oito2FormController`. The oito2 entries register with it on their own; wrap a `TextFormField` or another `FormField` in an `Oito2FormFieldAdapter`. Entries take a `validator`, which runs after the text parses, and `required`, which shows "This field is required" for an empty field.

```dart
final _form = Oito2FormController();

Future<bool> _save() => _form.submit(() {
  save();
  _form.markClean();
});

Oito2Form(
  controller: _form,
  child: Column(
    children: [
      const Oito2FormErrorSummary(),
      Oito2FormFieldAdapter(
        label: 'Name',
        child: TextFormField(
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (text) => text!.isEmpty ? 'Enter a name' : null,
        ),
      ),
      Oito2DateEntry(
        labelText: 'Start',
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        required: true,
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  ),
);
```

`validate` and `submit` show every error at once, focus and scroll to the first invalid field and announce the number of errors; after that, errors follow the values while they are fixed. `Oito2FormErrorSummary` lists the errors with links to their fields. `isDirty` tells whether a value changed since the start or the last `markClean`, and `reset` puts the clean values back.

Set `participatesInForm: false` on a field that isn't form data; it keeps showing its own errors. `Oito2SearchField` defaults to false, since a search usually filters the screen; pass `participatesInForm: true` to make it part of the form.

## Unsaved changes

Wrap the page in an `Oito2UnsavedChangesGuard` with the form, and optionally `onSave`. While the form has changes, going back asks whether to keep editing, discard or save. An `Oito2MasterDetailPage` or `Oito2NavigationPage` under an `Oito2UnsavedChangesScope` asks before switching pages, and with the `oito2_ui_window` controller in an `Oito2WindowScope`, closing the window asks too.

```dart
Oito2UnsavedChangesGuard(
  form: _form,
  onSave: _save,
  child: Oito2Form(controller: _form, child: fields),
);
```

## Labels and help

Give every field a visible label, through `labelText` or the decoration. Assistive technologies read it, and the error text is announced when it appears.
