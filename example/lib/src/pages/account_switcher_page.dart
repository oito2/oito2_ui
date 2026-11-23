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
import '../widgets/showcase_widgets.dart';

// #region accounts
const _accounts = [
  Oito2Account(
    id: 'ana',
    name: 'Ana Souza',
    subtitle: 'ana@example.com',
    status: Oito2AvatarStatus.online,
    count: 3,
  ),
  Oito2Account(
    id: 'work',
    name: 'Ana Souza',
    subtitle: 'ana@company.example',
    status: Oito2AvatarStatus.busy,
    count: 128,
  ),
  Oito2Account(
    id: 'bruno',
    name: 'Bruno Lima',
    subtitle: 'bruno@example.org',
    status: Oito2AvatarStatus.away,
  ),
  Oito2Account(
    id: 'carla',
    name: 'Carla Dias',
    subtitle: 'carla@nextcloud.example',
    status: Oito2AvatarStatus.offline,
    count: 1,
  ),
  Oito2Account(id: 'diego', name: 'Diego Rocha', subtitle: 'diego@example.net'),
];
// #endregion

const _items = [
  Oito2NavigationItem(icon: Icon(LucideIcons.folder), label: 'Files'),
  Oito2NavigationItem(icon: Icon(LucideIcons.refresh_cw), label: 'Sync'),
  Oito2NavigationItem(icon: Icon(LucideIcons.settings), label: 'Settings'),
];

/// Documents [Oito2AccountSwitcher]: the switcher at the top of a
/// navigation page, in the extended and compact rails.
class AccountSwitcherPage extends StatefulWidget {
  /// Creates the account switcher page.
  const AccountSwitcherPage({super.key});

  @override
  State<AccountSwitcherPage> createState() => _AccountSwitcherPageState();
}

class _AccountSwitcherPageState extends State<AccountSwitcherPage> {
  Oito2Account _current = _accounts.first;
  String _event = 'No action yet';

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;
    return DocPage(
      title: 'Account Switcher',
      description:
          'The current account at the top of a navigation rail, with a menu '
          'to switch to another account or add one.',
      source: 'lib/src/pages/account_switcher_page.dart',
      children: [
        ExamplePanel(
          regions: const ['accounts', 'preview'],
          child: ShowcaseFrame(
            initialWidth: 820,
            // #region preview
            child: Oito2NavigationPage(
              items: _items,
              compactBreakpoint: 560,
              extendedBreakpoint: 720,
              leading: Padding(
                padding: const EdgeInsets.only(bottom: Oito2Spacing.sm),
                child: Oito2AccountSwitcher(
                  accounts: _accounts,
                  current: _current,
                  onSelected: (account) => setState(() {
                    _current = account;
                    _event = 'Switched to ${account.subtitle}';
                  }),
                  onAdd: () => setState(() => _event = 'Add account'),
                  actions: [
                    MenuItemButton(
                      leadingIcon: const Icon(LucideIcons.user_cog, size: 20),
                      onPressed: () =>
                          setState(() => _event = 'Manage accounts'),
                      child: const Text('Manage accounts'),
                    ),
                  ],
                ),
              ),
              pageBuilder: (context, index) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Oito2Spacing.sm,
                  children: [
                    Text(
                      '${_items[index].label} of ${_current.subtitle}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(_event, style: small),
                  ],
                ),
              ),
            ),
            // #endregion
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Describe each account with an `Oito2Account`: an `id`, the '
          '`name` the avatar initials come from, a `subtitle` such as the '
          'email address, an optional `image`, a presence `status` and a '
          '`count` of pending items. Pass the list in `accounts` and the '
          'account in use in `current`; the switcher reports the choice to '
          '`onSelected` and leaves `current` to the app.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocText(
          'Place it in the `leading` slot of an `Oito2NavigationPage` or '
          '`Oito2NavigationRail`. In the extended rail it shows the avatar, '
          'the name, the subtitle and the count; narrower than 160 pixels, '
          'as in the compact and labelled rails, it shows only the avatar, '
          'with the count as a badge and the name as a tooltip. Resize the '
          'frame above to see it change.',
        ),
        const DocNote(
          'The menu lists the accounts with a check on the current one, '
          'then "Add account" when `onAdd` is given, and the `actions`, '
          'usually `MenuItemButton`s. Counts above `maxCount` (99) show as '
          '"99+".',
        ),
        const DocHeading('Examples'),
        const DocHeading('Forced compact', level: 3),
        const DocText(
          '`compact: true` keeps the avatar alone whatever the width, and '
          'without `onAdd` the menu has only the accounts.',
        ),
        ExamplePanel(
          region: 'compact',
          // #region compact
          child: Oito2AccountSwitcher(
            accounts: _accounts,
            current: _current,
            compact: true,
            onSelected: (account) => setState(() => _current = account),
          ),
          // #endregion
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The switcher is a button read as "Switch account, current:" '
          'followed by the name, the status, the subtitle and the pending '
          'count, and reports whether its menu is open. Each account in the '
          'menu reads the same details and whether it is the current one.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            ['`Tab`', 'Moves the focus to the switcher.'],
            ['`Enter` / `Space` / `↓`', 'Opens the menu.'],
            ['`↑` / `↓`', 'Moves between the menu entries.'],
            ['`Escape`', 'Closes the menu.'],
          ],
        ),
        ...apiReferenceWidgets(['Oito2AccountSwitcher', 'Oito2Account']),
      ],
    );
  }
}
