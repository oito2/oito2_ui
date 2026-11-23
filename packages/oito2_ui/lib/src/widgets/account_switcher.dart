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

import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'avatar.dart';
import 'utilities.dart';

/// An account of an [Oito2AccountSwitcher].
@immutable
class Oito2Account {
  /// Creates an account identified by [id].
  const Oito2Account({
    required this.id,
    required this.name,
    this.subtitle,
    this.image,
    this.status,
    this.count = 0,
  }) : assert(count >= 0);

  /// The identifier that tells this account from the others.
  final String id;

  /// The account name, shown in full and as the avatar initials.
  final String name;

  /// A secondary line, such as the email address or the server.
  final String? subtitle;

  /// The avatar picture; the initials of [name] show without it.
  final ImageProvider? image;

  /// The presence status shown on the avatar, or null for none.
  final Oito2AvatarStatus? status;

  /// The number of pending items, such as unread messages; zero shows no
  /// badge.
  final int count;
}

/// The current account of an app with a menu to switch to another one,
/// made for the `leading` slot of an `Oito2NavigationRail` or an
/// `Oito2NavigationPage`.
///
/// The button shows the avatar of [current] with its status, its name,
/// its subtitle and its pending count. When [compact], or when it is
/// narrower than 160 pixels, such as in a compact or labelled rail, it
/// shows only the avatar, with the count as a badge and the name as a
/// tooltip.
///
/// Activating the button opens a menu that lists [accounts], with a check
/// mark on the current one, then an "Add account" entry when [onAdd] is
/// given, and [actions]. Choosing an account calls [onSelected]; the
/// switcher doesn't change [current] itself.
class Oito2AccountSwitcher extends StatelessWidget {
  /// Creates an account switcher.
  const Oito2AccountSwitcher({
    super.key,
    required this.accounts,
    required this.current,
    required this.onSelected,
    this.onAdd,
    this.actions = const [],
    this.compact,
    this.maxCount = 99,
    this.menuWidth = 280,
  }) : assert(maxCount > 0);

  /// The accounts listed in the menu, in order.
  final List<Oito2Account> accounts;

  /// The account in use, matched with [accounts] by [Oito2Account.id].
  final Oito2Account current;

  /// Called with the account chosen in the menu.
  final ValueChanged<Oito2Account> onSelected;

  /// Called by the "Add account" menu entry; null hides it.
  final VoidCallback? onAdd;

  /// Further menu entries after "Add account", usually `MenuItemButton`s.
  final List<Widget> actions;

  /// Whether the button shows only the avatar; null decides by the width
  /// available.
  final bool? compact;

  /// The largest count shown in full; larger counts show as "99+".
  final int maxCount;

  /// The smallest width of the menu.
  final double menuWidth;

  /// The width below which the switcher is compact when [compact] is null.
  static const double compactWidth = 160;

  /// Returns [count] as shown on a badge, capped at [maxCount].
  String _countText(int count) => count > maxCount ? '$maxCount+' : '$count';

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final hasExtras = onAdd != null || actions.isNotEmpty;
    return MenuAnchor(
      style: MenuStyle(minimumSize: WidgetStatePropertyAll(Size(menuWidth, 0))),
      menuChildren: [
        Semantics(
          container: true,
          explicitChildNodes: true,
          label: strings.accounts,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final account in accounts)
                _AccountMenuItem(
                  account: account,
                  checked: account.id == current.id,
                  countText: _countText(account.count),
                  onPressed: () => onSelected(account),
                ),
            ],
          ),
        ),
        if (hasExtras) const Divider(height: Oito2Spacing.sm),
        if (onAdd case final onAdd?)
          MenuItemButton(
            leadingIcon: const Icon(
              LucideIcons.user_plus,
              size: Oito2Sizes.iconSize,
            ),
            onPressed: onAdd,
            child: Text(strings.addAccount),
          ),
        ...actions,
      ],
      builder: (context, controller, _) => LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = compact ?? constraints.maxWidth < compactWidth;
          return _AccountButton(
            account: current,
            compact: isCompact,
            open: controller.isOpen,
            countText: _countText(current.count),
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
            onOpen: controller.open,
          );
        },
      ),
    );
  }
}

/// Returns the localized name of [status].
String _statusLabel(Oito2Localizations strings, Oito2AvatarStatus status) =>
    switch (status) {
      Oito2AvatarStatus.online => strings.statusOnline,
      Oito2AvatarStatus.away => strings.statusAway,
      Oito2AvatarStatus.busy => strings.statusBusy,
      Oito2AvatarStatus.offline => strings.statusOffline,
    };

/// Returns the accessibility description of [account]: its name, status,
/// subtitle and pending count.
String _describe(Oito2Localizations strings, Oito2Account account) => [
  account.name,
  if (account.status case final status?) _statusLabel(strings, status),
  ?account.subtitle,
  if (account.count > 0) strings.pendingCount(account.count),
].join(', ');

/// The button of an [Oito2AccountSwitcher]: the avatar alone when
/// [compact], otherwise the avatar, the name, the subtitle, the count and
/// a chevron.
class _AccountButton extends StatelessWidget {
  const _AccountButton({
    required this.account,
    required this.compact,
    required this.open,
    required this.countText,
    required this.onPressed,
    required this.onOpen,
  });

  final Oito2Account account;
  final bool compact;
  final bool open;
  final String countText;
  final VoidCallback onPressed;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final hasCount = account.count > 0;
    Widget avatar = ExcludeSemantics(
      child: Oito2Avatar(
        name: account.name,
        image: account.image,
        status: account.status,
        size: compact ? 36 : 32,
      ),
    );
    final Widget content;
    if (compact) {
      if (hasCount) {
        avatar = Badge(
          label: Text(countText),
          offset: const Offset(-4, -4),
          child: avatar,
        );
      }
      content = Padding(
        padding: const EdgeInsets.all(Oito2Spacing.xxs),
        child: avatar,
      );
    } else {
      final subtitle = account.subtitle;
      content = Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Oito2Spacing.sm,
          vertical: Oito2Spacing.xs,
        ),
        child: Row(
          spacing: Oito2Spacing.sm,
          children: [
            avatar,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    account.name,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (hasCount) Badge(label: Text(countText)),
            Icon(
              LucideIcons.chevrons_up_down,
              size: Oito2Sizes.iconSize,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      );
    }
    const radius = Oito2Radius.mediumAll;
    Widget button = Oito2FocusBorder(
      borderRadius: radius,
      child: Material(
        type: MaterialType.transparency,
        shape: const RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          mouseCursor: WidgetStateMouseCursor.clickable,
          onTap: onPressed,
          focusColor: Colors.transparent,
          child: ExcludeSemantics(child: content),
        ),
      ),
    );
    if (compact) {
      button = Tooltip(message: account.name, child: button);
    }
    return CallbackShortcuts(
      // While the menu is open, the arrow keys move through its entries.
      bindings: open
          ? const {}
          : {const SingleActivator(LogicalKeyboardKey.arrowDown): onOpen},
      child: Semantics(
        button: true,
        expanded: open,
        label: strings.switchAccount(_describe(strings, account)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Oito2Spacing.sm,
            vertical: Oito2Spacing.xxs,
          ),
          child: button,
        ),
      ),
    );
  }
}

/// An account entry of the [Oito2AccountSwitcher] menu: the avatar, the
/// name and subtitle, the count and a check mark on the current account.
class _AccountMenuItem extends StatelessWidget {
  const _AccountMenuItem({
    required this.account,
    required this.checked,
    required this.countText,
    required this.onPressed,
  });

  final Oito2Account account;
  final bool checked;
  final String countText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = Oito2Localizations.of(context);
    final subtitle = account.subtitle;
    return MergeSemantics(
      child: Semantics(
        checked: checked,
        inMutuallyExclusiveGroup: true,
        label: _describe(strings, account),
        child: MenuItemButton(
          onPressed: onPressed,
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(
                horizontal: Oito2Spacing.md,
                vertical: Oito2Spacing.xs,
              ),
            ),
          ),
          leadingIcon: ExcludeSemantics(
            child: Oito2Avatar(
              name: account.name,
              image: account.image,
              status: account.status,
              size: 28,
            ),
          ),
          trailingIcon: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.sm,
              children: [
                if (account.count > 0) Badge(label: Text(countText)),
                if (checked)
                  Icon(
                    LucideIcons.check,
                    size: Oito2Sizes.iconSize,
                    color: scheme.onSurface,
                  )
                else
                  const SizedBox.square(dimension: Oito2Sizes.iconSize),
              ],
            ),
          ),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
