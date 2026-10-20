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

import '../collections/list_collection.dart';
import '../tokens/geometry.dart';
import 'highlighted_text.dart';

/// The suggestion list of an autocomplete field: [options] in a panel
/// below the field, with [query] highlighted in each label and the
/// keyboard-highlighted option scrolled into view.
class AutocompleteOptionsView<T extends Object> extends StatelessWidget {
  /// Creates the suggestion list.
  const AutocompleteOptionsView({
    super.key,
    required this.options,
    required this.collection,
    required this.query,
    required this.onSelected,
    required this.maxHeight,
    required this.width,
  });

  /// The options shown.
  final List<T> options;

  /// Gives each option its label.
  final Oito2ListCollection<T> collection;

  /// The text to highlight.
  final String query;

  /// Called with the chosen option.
  final AutocompleteOnSelected<T> onSelected;

  /// The largest list height.
  final double maxHeight;

  /// The list width.
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highlighted = AutocompleteHighlightedOption.of(context);
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: const EdgeInsets.only(top: Oito2Spacing.xs),
        child: Material(
          color: scheme.surfaceContainer,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: Oito2Radius.mediumAll,
            side: BorderSide(color: scheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: width),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: Oito2Spacing.xs),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final selected = index == highlighted;
                if (selected) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      Scrollable.ensureVisible(context, alignment: 0.5);
                    }
                  });
                }
                return Semantics(
                  selected: selected,
                  button: true,
                  child: InkWell(
                    onTap: () => onSelected(option),
                    child: Container(
                      color: selected ? scheme.secondaryContainer : null,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Oito2Spacing.md,
                        vertical: Oito2Spacing.sm,
                      ),
                      child: Oito2HighlightedText(
                        collection.labelOf(option),
                        query: query,
                        style: TextStyle(
                          color: selected
                              ? scheme.onSecondaryContainer
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
