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

/// Shows every color of the active scheme: Material roles, semantic
/// colors, chrome and syntax highlighting.
class ColorsPage extends StatelessWidget {
  /// Creates the colors page for [colors].
  const ColorsPage({super.key, required this.colors});

  /// The active scheme.
  final Oito2ColorTheme colors;

  @override
  Widget build(BuildContext context) {
    final s = colors.colorScheme;
    final semantic = colors.semantic;

    return ListView(
      padding: const EdgeInsets.all(Oito2Spacing.page),
      children: [
        ShowcaseSection(
          'Accent and error fills',
          children: [
            Swatch('primary', s.primary, s.onPrimary),
            Swatch(
              'primaryContainer',
              s.primaryContainer,
              s.onPrimaryContainer,
            ),
            Swatch('secondary', s.secondary, s.onSecondary),
            Swatch(
              'secondaryContainer',
              s.secondaryContainer,
              s.onSecondaryContainer,
            ),
            Swatch('tertiary', s.tertiary, s.onTertiary),
            Swatch(
              'tertiaryContainer',
              s.tertiaryContainer,
              s.onTertiaryContainer,
            ),
            Swatch('error', s.error, s.onError),
            Swatch('errorContainer', s.errorContainer, s.onErrorContainer),
          ],
        ),
        ShowcaseSection(
          'Surfaces',
          children: [
            Swatch('background', colors.background, s.onSurface),
            Swatch('lowest', s.surfaceContainerLowest, s.onSurface),
            Swatch('low', s.surfaceContainerLow, s.onSurface),
            Swatch('surface', s.surface, s.onSurface),
            Swatch('container', s.surfaceContainer, s.onSurface),
            Swatch('high', s.surfaceContainerHigh, s.onSurface),
            Swatch('highest', s.surfaceContainerHighest, s.onSurfaceVariant),
            Swatch('inverseSurface', s.inverseSurface, s.onInverseSurface),
            Swatch('outline', s.surface, s.outline, border: s.outline),
          ],
        ),
        ShowcaseSection(
          'Text-safe colors (lowest ratio on any surface)',
          children: [
            for (final (name, color) in [
              ('onSurface', s.onSurface),
              ('onSurfaceVariant', s.onSurfaceVariant),
              ('primaryText', semantic.primaryText),
              ('errorText', semantic.errorText),
              ('success', semantic.success),
              ('warning', semantic.warning),
              ('info', semantic.info),
              ('link', semantic.link),
            ])
              _TextSample(name, color, colors.surfaces),
          ],
        ),
        ShowcaseSection('Chrome', children: [_ChromePreview(colors.chrome)]),
        ShowcaseSection(
          'Syntax highlighting',
          children: [_CodeSample(colors.syntax, s.surfaceContainer)],
        ),
      ],
    );
  }
}

/// A text sample with its lowest contrast ratio against [surfaces].
class _TextSample extends StatelessWidget {
  const _TextSample(this.label, this.color, this.surfaces);

  final String label;
  final Color color;
  final List<Color> surfaces;

  @override
  Widget build(BuildContext context) {
    final ratio = Oito2Contrast.minRatio(color, surfaces);
    return SizedBox(
      width: 180,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: '  ≥ ${ratio.toStringAsFixed(1)}:1',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// A miniature window showing the title bar, sidebar, mainbar and page
/// background.
class _ChromePreview extends StatelessWidget {
  const _ChromePreview(this.chrome);

  final Oito2ChromeColors chrome;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant;
    Widget label(String text) =>
        Center(child: Text(text, style: Theme.of(context).textTheme.bodySmall));
    return Container(
      width: 480,
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: Oito2Radius.windowAll,
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            height: Oito2Sizes.titleBarHeight,
            color: chrome.titleBar,
            child: label('titleBar'),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 64,
                  color: chrome.sidebar,
                  child: label('sidebar'),
                ),
                Container(
                  width: 160,
                  color: chrome.mainbar,
                  child: label('mainbar'),
                ),
                Expanded(
                  child: ColoredBox(
                    color: chrome.background,
                    child: label('background'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A short Dart snippet colored with [syntax] on [background].
class _CodeSample extends StatelessWidget {
  const _CodeSample(this.syntax, this.background);

  final SyntaxHighlightPalette syntax;
  final Color background;

  @override
  Widget build(BuildContext context) {
    TextSpan t(String text, Color color) => TextSpan(
      text: text,
      style: TextStyle(color: color),
    );
    final s = syntax;
    return Container(
      padding: const EdgeInsets.all(Oito2Spacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: Oito2Radius.mediumAll,
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.5,
          ),
          children: [
            t('// Greets everyone on the list.\n', s.comment),
            t('@override\n', s.attribute),
            t('Future', s.type),
            t('<', s.foreground),
            t('void', s.keyword),
            t('> ', s.foreground),
            t('greet', s.function),
            t('(', s.foreground),
            t('List', s.type),
            t('<', s.foreground),
            t('String', s.type),
            t('> names) ', s.foreground),
            t('async', s.keyword),
            t(' {\n  ', s.foreground),
            t('const', s.keyword),
            t(' limit = ', s.foreground),
            t('42', s.number),
            t(';\n  ', s.foreground),
            t('final', s.keyword),
            t(' html = ', s.foreground),
            t("'<", s.string),
            t('p', s.tag),
            t(' class', s.attribute),
            t("=\"hi\">'", s.string),
            t(';\n  ', s.foreground),
            t('if', s.keyword),
            t(' (names.isEmpty == ', s.foreground),
            t('true', s.constant),
            t(') ', s.foreground),
            t('return', s.keyword),
            t(';\n  print(', s.foreground),
            t("'Hello, \${names.take(limit)}'", s.string),
            t(');\n  ', s.foreground),
            t('undefinedCall', s.invalid),
            t('();\n}', s.foreground),
          ],
        ),
      ),
    );
  }
}
