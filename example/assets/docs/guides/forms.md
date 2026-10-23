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

```dart
Oito2DateEntry(
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onChanged: (date) => setState(() => _date = date),
  onErrorChanged: (error) => setState(() => _dateError = error),
);
```

## Validating a form

Keep the latest value and error of each entry in your state, and check them when the form is submitted. Fields of a `Form` can sit beside them:

```dart
final _form = GlobalKey<FormState>();

void _submit() {
  final valid = _form.currentState!.validate() && _dateError == null;
  if (valid) save(_name, _date);
}

Form(
  key: _form,
  child: Column(
    children: [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Name'),
        validator: (text) => text!.isEmpty ? 'Enter a name' : null,
        onSaved: (text) => _name = text!,
      ),
      Oito2DateEntry(
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        onChanged: (date) => _date = date,
        onErrorChanged: (error) => _dateError = error,
      ),
      FilledButton(onPressed: _submit, child: const Text('Save')),
    ],
  ),
);
```

## Labels and help

Give every field a visible label, through `labelText` or the decoration. Assistive technologies read it, and the error text is announced when it appears.
