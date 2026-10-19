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

/// Shows the color, radius, spacing and size tokens.
class TokensPage extends StatelessWidget {
  /// Creates the tokens page.
  const TokensPage({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final neutrals = Oito2NeutralPalette.of(brightness);
    final status = Oito2StatusPalette.of(brightness);
    final textTheme = Theme.of(context).textTheme;

    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: Oito2Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: Oito2Spacing.md),
          Wrap(
            spacing: Oito2Spacing.md,
            runSpacing: Oito2Spacing.md,
            children: children,
          ),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        section('Neutrals (${brightness.name})', [
          _Swatch('surface', neutrals.surface, neutrals.onSurface),
          _Swatch(
            'lowest',
            neutrals.surfaceContainerLowest,
            neutrals.onSurface,
          ),
          _Swatch('low', neutrals.surfaceContainerLow, neutrals.onSurface),
          _Swatch('container', neutrals.surfaceContainer, neutrals.onSurface),
          _Swatch('high', neutrals.surfaceContainerHigh, neutrals.onSurface),
          _Swatch(
            'highest',
            neutrals.surfaceContainerHighest,
            neutrals.onSurface,
          ),
          _Swatch('titleBar', neutrals.titleBar, neutrals.onSurface),
          _Swatch('onSurface', neutrals.onSurface, neutrals.surface),
          _Swatch(
            'onSurfaceVariant',
            neutrals.onSurfaceVariant,
            neutrals.surface,
          ),
          _Swatch('outline', neutrals.outline, neutrals.surface),
          _Swatch(
            'outlineVariant',
            neutrals.outlineVariant,
            neutrals.onSurface,
          ),
        ]),
        section('Accents', [
          for (final accent in Oito2AccentColor.values)
            _Swatch(
              accent.name,
              accent.color,
              Oito2Contrast.foregroundFor(accent.color),
            ),
        ]),
        section('Status (${brightness.name})', [
          for (final (name, color) in [
            ('success', status.success),
            ('warning', status.warning),
            ('error', status.error),
            ('info', status.info),
            ('link', status.link),
          ])
            _Swatch(name, neutrals.surface, color, border: neutrals.outline),
        ]),
        section('Radii', [
          for (final (name, radius) in [
            ('check', Oito2Radius.check),
            ('small', Oito2Radius.small),
            ('medium', Oito2Radius.medium),
            ('large', Oito2Radius.large),
            ('window', Oito2Radius.window),
          ])
            Container(
              width: 96,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: neutrals.surfaceContainerHigh,
                border: Border.all(color: neutrals.outline),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Text(
                '$name\n${radius.toStringAsFixed(0)}',
                textAlign: TextAlign.center,
              ),
            ),
        ]),
        section('Spacing', [
          for (final (name, value) in [
            ('xxs', Oito2Spacing.xxs),
            ('xs', Oito2Spacing.xs),
            ('sm', Oito2Spacing.sm),
            ('md', Oito2Spacing.md),
            ('lg', Oito2Spacing.lg),
            ('page', Oito2Spacing.page),
            ('xl', Oito2Spacing.xl),
            ('xxl', Oito2Spacing.xxl),
            ('xxxl', Oito2Spacing.xxxl),
          ])
            Column(
              children: [
                Container(
                  width: value,
                  height: value,
                  color: Oito2AccentColor.fallback.color,
                ),
                const SizedBox(height: Oito2Spacing.xs),
                Text(
                  '$name ${value.toStringAsFixed(0)}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
        ]),
        section('Sizes', [
          for (final (name, value) in [
            ('buttonHeight', Oito2Sizes.buttonHeight),
            ('titleBarHeight', Oito2Sizes.titleBarHeight),
            ('titleBarItemHeight', Oito2Sizes.titleBarItemHeight),
            ('iconSize', Oito2Sizes.iconSize),
            ('focusBorderWidth', Oito2Sizes.focusBorderWidth),
            ('windowControlSize', Oito2Sizes.windowControlSize),
            ('windowsWindowControlWidth', Oito2Sizes.windowsWindowControlWidth),
            ('minPointerTarget', Oito2Sizes.minPointerTarget),
            ('minTouchTarget', Oito2Sizes.minTouchTarget),
          ])
            Chip(label: Text('$name: ${value.toStringAsFixed(0)}')),
        ]),
      ],
    );
  }
}

/// A labeled color sample.
class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.background, this.foreground, {this.border});

  final String label;
  final Color background;
  final Color foreground;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final ratio = Oito2Contrast.ratio(background, foreground);
    return Container(
      width: 132,
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(Oito2Spacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: Oito2Radius.mediumAll,
        border: Border.all(
          color:
              border ??
              Oito2NeutralPalette.of(Theme.of(context).brightness)
                  .outlineVariant,
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: Oito2Spacing.sm),
            Text(
              '#${background.toARGB32().toRadixString(16).substring(2).toUpperCase()}'
              ' · ${ratio.toStringAsFixed(1)}:1',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
