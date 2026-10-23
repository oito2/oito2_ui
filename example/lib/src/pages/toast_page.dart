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

/// Documents [Oito2Toast] and [Oito2Toaster]: each type, an action, a
/// persistent toast and a promise.
class ToastPage extends StatelessWidget {
  /// Creates the toast page.
  const ToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    final toaster = Oito2Toaster.of(context);
    return DocPage(
      title: 'Toast',
      description:
          'A short notification that appears over the app for a few '
          'seconds, optionally with an action.',
      source: 'lib/src/pages/toast_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          // #region preview
          child: OutlinedButton(
            onPressed: () => Oito2Toaster.of(context).show(
              const Oito2Toast(
                title: 'Settings saved',
                description: 'They apply to every window.',
              ),
            ),
            child: const Text('Show a toast'),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Wrap the navigator in an `Oito2Toaster`, usually in '
          '`MaterialApp.builder`, then call `Oito2Toaster.of(context).show` '
          'with an `Oito2Toast`. `Oito2Toaster.maybeOf` returns null instead '
          'of failing when there is no toaster.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocCode(
          'MaterialApp(\n'
          '  builder: (context, child) => Oito2Toaster(child: child!),\n'
          '  home: const HomePage(),\n'
          ')',
        ),
        const DocText(
          'A toast stays for `duration`, 4 seconds by default, and its time '
          'stops while the pointer or the focus is on the stack. At most '
          '`maxVisible` toasts show at a time, 3 by default, the oldest '
          'nearest the `placement` edge, which is the bottom center by '
          'default; newer ones wait for room. `show` returns an '
          '`Oito2ToastHandle` that updates or dismisses the toast.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Types', level: 3),
        const DocText(
          '`type` shows a colored icon for the kind of message; a toast '
          'without a type has no icon. `description` adds a line of detail '
          'under the bold `title`.',
        ),
        ExamplePanel(
          region: 'types',
          child: Wrap(
            spacing: Oito2Spacing.sm,
            runSpacing: Oito2Spacing.sm,
            alignment: WrapAlignment.center,
            children: [
              // #region types
              OutlinedButton(
                onPressed: () => toaster.show(const Oito2Toast(title: 'Plain')),
                child: const Text('Plain'),
              ),
              for (final type in Oito2InfoType.values)
                OutlinedButton(
                  onPressed: () => toaster.show(
                    Oito2Toast(
                      title: type.name,
                      description: 'A ${type.name} message.',
                      type: type,
                    ),
                  ),
                  child: Text(type.name),
                ),
              // #endregion
            ],
          ),
        ),
        const DocHeading('Action', level: 3),
        const DocText(
          'An action button shows when both `actionLabel` and `onAction` '
          'are set; pressing it runs `onAction` and dismisses the toast.',
        ),
        ExamplePanel(
          region: 'action',
          // #region action
          child: OutlinedButton(
            onPressed: () => toaster.show(
              Oito2Toast(
                title: 'Message deleted',
                actionLabel: 'Undo',
                onAction: () =>
                    toaster.show(const Oito2Toast(title: 'Restored')),
              ),
            ),
            child: const Text('With an action'),
          ),
          // #endregion
        ),
        const DocHeading('Persistent', level: 3),
        const DocText(
          'With a null `duration` the toast stays until it is dismissed. '
          '`dismissible: false` removes its dismiss button and the Escape '
          'key, so only code can close it.',
        ),
        ExamplePanel(
          region: 'persistent',
          // #region persistent
          child: OutlinedButton(
            onPressed: () => toaster.show(
              const Oito2Toast(title: 'Stays until dismissed', duration: null),
            ),
            child: const Text('Persistent'),
          ),
          // #endregion
        ),
        const DocHeading('Promise', level: 3),
        const DocText(
          '`promise` shows the `loading` toast until the future completes, '
          'then replaces it with the toast `success` builds from the value '
          'or `error` builds from the error. A toast with `loading: true` '
          'shows a spinner and stays until it is updated or dismissed.',
        ),
        ExamplePanel(
          region: 'promise',
          // #region promise
          child: OutlinedButton(
            onPressed: () => toaster.promise<int>(
              Future.delayed(const Duration(seconds: 2), () => 3),
              loading: const Oito2Toast(title: 'Uploading…', loading: true),
              success: (n) => Oito2Toast(
                title: '$n files uploaded',
                type: Oito2InfoType.success,
              ),
              error: (_) => const Oito2Toast(
                title: 'Upload failed',
                type: Oito2InfoType.danger,
              ),
            ),
            child: const Text('Promise'),
          ),
          // #endregion
        ),
        const DocHeading('Dismiss all', level: 3),
        const DocText('`dismissAll` closes every toast, shown or waiting.'),
        ExamplePanel(
          region: 'dismiss-all',
          // #region dismiss-all
          child: TextButton(
            onPressed: toaster.dismissAll,
            child: const Text('Dismiss all'),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'Each toast is a live region, so assistive technologies announce '
          'it when it appears. The stack is a container labeled '
          '"Notifications", and the dismiss button is labeled "Dismiss". '
          'Since the time stops while the focus is on the stack, keyboard '
          'users can reach the action before the toast goes away.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Escape`',
              'Dismisses the focused toast, when it is dismissible.',
            ],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2Toast',
          'Oito2Toaster',
          'Oito2ToasterState',
          'Oito2ToastHandle',
          'Oito2ToasterPlacement',
        ]),
      ],
    );
  }
}
