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

/// Documents [Oito2DialogTitleBar] on a dialog, with a plain title, an
/// icon, an animated icon and a custom close label.
class DialogTitleBarPage extends StatelessWidget {
  /// Creates the dialog title bar page.
  const DialogTitleBarPage({super.key});

  // #region dialog
  /// Opens a dialog whose title bar shows [leading] and [title], or
  /// "Preferences" when [title] is null, with the close button [labels].
  void _openDialog(
    BuildContext context, {
    Widget? leading,
    String? title,
    Oito2WindowControlLabels? labels,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Oito2DialogTitleBar(
                leading: leading,
                title: Text(title ?? 'Preferences'),
                labels: labels,
              ),
              Padding(
                padding: const EdgeInsets.all(Oito2Spacing.xl),
                child: Text(
                  'The close button follows the system button style and '
                  'side, and pops the dialog.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // #endregion

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Dialog Title Bar',
      description:
          'The title bar of a dialog: a title and a close button that pops '
          'the dialog route.',
      source: 'lib/src/pages/dialog_title_bar_page.dart',
      children: [
        ExamplePanel(
          region: 'preview',
          regions: const ['dialog'],
          // #region preview
          child: OutlinedButton(
            onPressed: () => _openDialog(context),
            child: const Text('Open dialog'),
          ),
          // #endregion
        ),
        const DocHeading('Usage'),
        const DocText(
          'Put `Oito2DialogTitleBar` at the top of the dialog content. The '
          'close button pops the current route, or runs `onClose` when it is '
          'set. The bar is transparent, has no bottom border and does not '
          'move the window when dragged.',
        ),
        const DocText(
          'The close button follows the system window control style, '
          'falling back to the GNOME style where the platform has none (the '
          'web, touch platforms and macOS), and sits on the side of the '
          'close button in the system button layout.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For the title bar of the app window, use `Oito2WindowTitleBar`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('With an icon', level: 3),
        const DocText(
          '`leading` shows a widget before the title, such as an icon that '
          'tells what the dialog is about.',
        ),
        ExamplePanel(
          region: 'icon',
          // #region icon
          child: OutlinedButton(
            onPressed: () => _openDialog(
              context,
              leading: const Icon(LucideIcons.settings),
              title: 'Settings',
            ),
            child: const Text('With an icon'),
          ),
          // #endregion
        ),
        const DocHeading('With an animated icon', level: 3),
        const DocText('The leading widget can also be an `Oito2AnimatedIcon`.'),
        ExamplePanel(
          region: 'animated',
          // #region animated
          child: OutlinedButton(
            onPressed: () => _openDialog(
              context,
              leading: const Oito2AnimatedIcon(Oito2AnimatedIcons.ok),
              title: 'Saved',
            ),
            child: const Text('With an animated icon'),
          ),
          // #endregion
        ),
        const DocHeading('Close label', level: 3),
        const DocText(
          '`labels` overrides the accessibility label of the close button, '
          '"Close" by default.',
        ),
        ExamplePanel(
          region: 'labels',
          // #region labels
          child: OutlinedButton(
            onPressed: () => _openDialog(
              context,
              title: 'Export',
              labels: const Oito2WindowControlLabels(close: 'Cancel export'),
            ),
            child: const Text('Custom close label'),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The title is marked as a header, and the close button is labeled '
          'from the localizations unless `labels` overrides it.',
        ),
        ...apiReferenceWidgets([
          'Oito2DialogTitleBar',
          'Oito2WindowControlLabels',
        ]),
      ],
    );
  }
}
