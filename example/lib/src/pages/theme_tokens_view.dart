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

import '../widgets/showcase_widgets.dart';

/// The Tokens section of the Material theme page: the color, radius,
/// spacing, elevation and size tokens.
class ThemeTokensView extends StatelessWidget {
  /// Creates the tokens section.
  const ThemeTokensView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final neutrals = Oito2NeutralPalette.of(brightness);
    final status = Oito2StatusPalette.of(brightness);
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'Neutrals (${brightness.name})',
          children: [
            Swatch('surface', neutrals.surface, neutrals.onSurface),
            Swatch(
              'lowest',
              neutrals.surfaceContainerLowest,
              neutrals.onSurface,
            ),
            Swatch('low', neutrals.surfaceContainerLow, neutrals.onSurface),
            Swatch('container', neutrals.surfaceContainer, neutrals.onSurface),
            Swatch('high', neutrals.surfaceContainerHigh, neutrals.onSurface),
            Swatch(
              'highest',
              neutrals.surfaceContainerHighest,
              neutrals.onSurface,
            ),
            Swatch('titleBar', neutrals.titleBar, neutrals.onSurface),
            Swatch('onSurface', neutrals.onSurface, neutrals.surface),
            Swatch(
              'onSurfaceVariant',
              neutrals.onSurfaceVariant,
              neutrals.surface,
            ),
            Swatch('outline', neutrals.outline, neutrals.surface),
            Swatch(
              'outlineVariant',
              neutrals.outlineVariant,
              neutrals.onSurface,
            ),
          ],
        ),
        ShowcaseSection(
          'Accents',
          children: [
            for (final accent in Oito2AccentColor.values)
              Swatch(
                accent.name,
                accent.color,
                Oito2Contrast.foregroundFor(accent.color),
              ),
          ],
        ),
        ShowcaseSection(
          'Status (${brightness.name})',
          children: [
            for (final (name, color) in [
              ('success', status.success),
              ('warning', status.warning),
              ('error', status.error),
              ('info', status.info),
              ('link', status.link),
            ])
              Swatch(name, neutrals.surface, color, border: neutrals.outline),
          ],
        ),
        ShowcaseSection(
          'Radii',
          children: [
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
          ],
        ),
        ShowcaseSection(
          'Spacing',
          children: [
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
          ],
        ),
        ShowcaseSection(
          'Elevation',
          children: [
            for (final level in const [0.0, 1.0, 3.0, 6.0, 8.0, 12.0])
              Material(
                elevation: level,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                shadowColor: Theme.of(context).colorScheme.shadow,
                borderRadius: Oito2Radius.mediumAll,
                child: SizedBox(
                  width: 88,
                  height: 64,
                  child: Center(child: Text('${level.toStringAsFixed(0)} dp')),
                ),
              ),
          ],
        ),
        ShowcaseSection(
          'Sizes',
          children: [
            for (final (name, value) in [
              ('buttonHeight', Oito2Sizes.buttonHeight),
              ('titleBarHeight', Oito2Sizes.titleBarHeight),
              ('titleBarItemHeight', Oito2Sizes.titleBarItemHeight),
              ('iconSize', Oito2Sizes.iconSize),
              ('focusBorderWidth', Oito2Sizes.focusBorderWidth),
              ('windowControlSize', Oito2Sizes.windowControlSize),
              (
                'windowsWindowControlWidth',
                Oito2Sizes.windowsWindowControlWidth,
              ),
              ('minPointerTarget', Oito2Sizes.minPointerTarget),
              ('minTouchTarget', Oito2Sizes.minTouchTarget),
            ])
              Chip(label: Text('$name: ${value.toStringAsFixed(0)}')),
          ],
        ),
      ],
    );
  }
}
