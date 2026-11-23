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

/// Documents [Oito2Alert] and [Oito2AlertStack]: types, actions, the
/// dismiss button, the compact layout and a stack ordered by urgency.
class AlertPage extends StatefulWidget {
  /// Creates the alert page.
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  bool _showUpdate = true;

  // #region stack-state
  final List<(int, Oito2InfoType)> _alerts = [
    (1, Oito2InfoType.information),
    (2, Oito2InfoType.warning),
  ];
  int _next = 3;

  /// Adds an alert of [type] to the stack.
  void _add(Oito2InfoType type) => setState(() => _alerts.add((_next++, type)));

  /// Removes the alert [id] from the stack.
  void _remove(int id) =>
      setState(() => _alerts.removeWhere((alert) => alert.$1 == id));
  // #endregion

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Alert',
      description:
          'Inline messages about the state of a page or a task, with '
          'actions and a dismiss button, alone or in a stack ordered by '
          'urgency.',
      source: 'lib/src/pages/alert_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          child: SizedBox(
            width: 420,
            // #region preview
            child: Oito2Alert(
              type: Oito2InfoType.danger,
              title: const Text('Sync failed'),
              message: const Text("The server didn't answer in time."),
              actions: [
                TextButton(onPressed: () {}, child: const Text('Retry')),
                TextButton(onPressed: () {}, child: const Text('Details')),
              ],
              onDismiss: () {},
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          '`Oito2Alert` takes a `type` (an `Oito2InfoType`), a `title`, a '
          '`message` and a list of `actions`, usually `TextButton`s, which '
          'take the type color. With `onDismiss`, a dismiss button shows '
          'at the end; the app removes the alert when it is called.',
        ),
        const DocText(
          'Use an alert for a state that stays until it is solved or '
          'dismissed, such as an offline mode or a failed sync, next to '
          'the content it is about. For a short notice of something that '
          'just happened, use a toast; for a promotion, `Oito2Banner`.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocHeading('Examples'),
        const DocHeading('Types', level: 3),
        const DocText(
          'The type picks the icon and the tint, as in `Oito2InfoBox`.',
        ),
        ExamplePanel(
          region: 'types',
          child: SizedBox(
            width: 420,
            child: Column(
              spacing: Oito2Spacing.sm,
              children: [
                // #region types
                for (final type in Oito2InfoType.values)
                  Oito2Alert(
                    type: type,
                    title: Text(
                      '${type.name[0].toUpperCase()}${type.name.substring(1)}',
                    ),
                    message: const Text('A short message about the state.'),
                  ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Dismiss', level: 3),
        const DocText(
          'The dismiss button has the localized "Dismiss" tooltip. Remove '
          'the alert in `onDismiss`.',
        ),
        ExamplePanel(
          region: 'dismiss',
          child: SizedBox(
            width: 420,
            child: _showUpdate
                // #region dismiss
                ? Oito2Alert(
                    type: Oito2InfoType.information,
                    icon: const Icon(LucideIcons.refresh_cw),
                    title: const Text('Update available'),
                    message: const Text('Version 2.0 is ready to install.'),
                    actions: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Restart now'),
                      ),
                    ],
                    onDismiss: () => setState(() => _showUpdate = false),
                  )
                // #endregion
                : OutlinedButton(
                    onPressed: () => setState(() => _showUpdate = true),
                    child: const Text('Show the alert again'),
                  ),
          ),
        ),
        const DocHeading('Compact', level: 3),
        const DocText(
          '`compact` puts the icon, the title, the message, the actions and '
          'the dismiss button on one row, for toolbars and narrow panes. '
          'The text wraps when it does not fit.',
        ),
        ExamplePanel(
          region: 'compact',
          child: SizedBox(
            width: 520,
            // #region compact
            child: Oito2Alert(
              type: Oito2InfoType.warning,
              compact: true,
              title: const Text('Offline'),
              message: const Text('Changes sync when you reconnect.'),
              actions: [
                TextButton(onPressed: () {}, child: const Text('Retry')),
              ],
              onDismiss: () {},
            ),
            // #endregion
          ),
        ),
        const DocHeading('Stack', level: 3),
        const DocText(
          '`Oito2AlertStack` shows a list of alerts, each with a distinct '
          'key, ordered by `Oito2InfoType.severity` (danger, warning, '
          'important, information, then success) and, within a type, in '
          'the order they were added. At most `maxVisible` show, 3 by '
          'default; a button shows the others and hides them again. Alerts '
          'grow in and shrink out, at once when animations are disabled.',
        ),
        ExamplePanel(
          region: 'stack',
          regions: const ['stack-state'],
          child: SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Oito2Spacing.md,
              children: [
                Wrap(
                  spacing: Oito2Spacing.sm,
                  runSpacing: Oito2Spacing.sm,
                  children: [
                    for (final type in [
                      Oito2InfoType.danger,
                      Oito2InfoType.warning,
                      Oito2InfoType.information,
                      Oito2InfoType.success,
                    ])
                      OutlinedButton(
                        onPressed: () => _add(type),
                        child: Text('Add ${type.name}'),
                      ),
                  ],
                ),
                // #region stack
                Oito2AlertStack(
                  alerts: [
                    for (final (id, type) in _alerts)
                      Oito2Alert(
                        key: ValueKey(id),
                        type: type,
                        title: Text('Alert $id'),
                        message: Text('A ${type.name} message.'),
                        onDismiss: () => _remove(id),
                      ),
                  ],
                ),
                // #endregion
              ],
            ),
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The icon carries the localized name of the type, such as '
          '"Warning", so the kind is not told by color alone; a custom '
          '`icon` carries no such label. Alerts of the `warning` and '
          '`danger` types are live regions, announced by screen readers '
          'when they appear or change.',
        ),
        const DocText(
          'The dismiss button and the "Show more" button of the stack are '
          'labeled from the localizations, and the stack keeps its alerts '
          'in reading order, the most urgent first.',
        ),
        ...apiReferenceWidgets(['Oito2Alert', 'Oito2AlertStack']),
      ],
    );
  }
}
