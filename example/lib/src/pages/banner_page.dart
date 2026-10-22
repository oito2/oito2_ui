// Copyright (C) 2026  oito2
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

import '../widgets/showcase_widgets.dart';

/// Shows [Oito2Banner]: selectable app cards, and tiles that change on
/// hover, carry a tint and open a dialog.
class BannerPage extends StatefulWidget {
  /// Creates the banner page.
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ShowcasePageBody(
      children: [
        ShowcaseSection(
          'Selectable',
          children: [
            for (final (index, (title, subtitle)) in const [
              ('Text Editor', 'Edit plain text files'),
              ('Files', 'Access and organize files'),
              ('Calculator', 'Perform calculations'),
            ].indexed)
              SizedBox(
                width: 240,
                child: Oito2Banner(
                  selected: _selected == index,
                  onTap: () => setState(() => _selected = index),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleMedium),
                      const SizedBox(height: Oito2Spacing.xs),
                      Text(subtitle, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
        ),
        ShowcaseSection(
          'With a watermark',
          children: [
            for (final (title, description, icon) in _apps.take(2))
              SizedBox(
                width: 320,
                height: 140,
                child: Oito2Banner(
                  padding: EdgeInsets.zero,
                  onTap: () {},
                  child: Oito2Watermark(
                    watermark: Icon(icon, size: 96),
                    child: Padding(
                      padding: const EdgeInsets.all(Oito2Spacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: textTheme.titleMedium),
                          const SizedBox(height: Oito2Spacing.xs),
                          Text(description, style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        ShowcaseSection(
          'Tiles: hover for details, click for a dialog',
          children: [
            for (var i = 0; i < 6; i++)
              SizedBox(
                width: 320,
                height: 170,
                child: _HoverTile(
                  index: i,
                  tint: switch (i % 3) {
                    1 => scheme.primary,
                    2 => scheme.tertiary,
                    _ => null,
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}

const _apps = [
  ('Weather', 'Forecasts for your places', LucideIcons.sun),
  ('Music', 'Play your library', LucideIcons.headphones),
  ('Photos', 'Browse and edit pictures', LucideIcons.image),
  ('Maps', 'Find places and routes', LucideIcons.map),
  ('Mail', 'Read and send messages', LucideIcons.mail),
  ('Notes', 'Write things down', LucideIcons.notebook_pen),
];

const _details =
    'Shows more on hover: the icon steps aside and the description grows '
    'to several lines. A click opens a dialog with the full text.';

/// A banner tile whose content changes while the pointer is over it.
class _HoverTile extends StatefulWidget {
  const _HoverTile({required this.index, this.tint});

  final int index;
  final Color? tint;

  @override
  State<_HoverTile> createState() => _HoverTileState();
}

class _HoverTileState extends State<_HoverTile> {
  bool _hovered = false;

  void _open(String title, IconData icon) => showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Oito2DialogTitleBar(leading: Icon(icon), title: Text(title)),
            const Padding(
              padding: EdgeInsets.all(Oito2Spacing.lg),
              child: Text(_details),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final (title, description, icon) = _apps[widget.index % _apps.length];
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.expand(
      child: Oito2Banner.tile(
        tint: widget.tint,
        onHover: (value) => setState(() => _hovered = value),
        onTap: () => _open(title, icon),
        icon: _hovered
            ? null
            : Icon(icon, size: 48, color: widget.tint ?? scheme.primary),
        title: Text(title),
        subtitle: Text(
          _hovered ? _details : description,
          maxLines: _hovered ? 4 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
