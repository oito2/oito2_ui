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

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../collections/list_collection.dart';
import '../collections/text_folding.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'highlighted_text.dart';

/// A text field that suggests items of a [collection] as the user types,
/// as a combobox.
///
/// Suggestions are the enabled items whose label contains the typed text,
/// ignoring case and accents, with the matches highlighted; with
/// [showAllWhenEmpty] every enabled item shows while the field is empty.
/// The Up and Down arrows move the highlight, Enter picks it, and Escape
/// closes the list. A live region announces the number of suggestions to
/// screen readers, or that none matched.
class Oito2Autocomplete<T extends Object> extends StatefulWidget {
  /// Creates an autocomplete field.
  const Oito2Autocomplete({
    super.key,
    required this.collection,
    this.onSelected,
    this.initialValue,
    this.hintText,
    this.showAllWhenEmpty = false,
    this.optionsMaxHeight = 240,
    this.optionsWidth,
    this.controller,
    this.focusNode,
  }) : assert((controller == null) == (focusNode == null));

  /// The items to suggest.
  final Oito2ListCollection<T> collection;

  /// Called with the picked item.
  final ValueChanged<T>? onSelected;

  /// The value of the item shown in the field at start.
  final String? initialValue;

  /// The field hint.
  final String? hintText;

  /// Whether every enabled item is suggested while the field is empty.
  final bool showAllWhenEmpty;

  /// The tallest the suggestion list grows before it scrolls.
  final double optionsMaxHeight;

  /// The width of the suggestion list; defaults to the field width.
  final double? optionsWidth;

  /// The field controller; give it together with [focusNode].
  final TextEditingController? controller;

  /// The field focus node; give it together with [controller].
  final FocusNode? focusNode;

  @override
  State<Oito2Autocomplete<T>> createState() => _Oito2AutocompleteState<T>();
}

class _Oito2AutocompleteState<T extends Object>
    extends State<Oito2Autocomplete<T>> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownController ??= TextEditingController(
        text: switch (widget.collection.find(widget.initialValue)) {
          final item? => widget.collection.labelOf(item),
          null => '',
        },
      ));

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
    _focusNode.addListener(_onText);
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _focusNode.removeListener(_onText);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _onText() => setState(() {});

  List<T> _options(String text) {
    final collection = widget.collection;
    if (text.isEmpty && !widget.showAllWhenEmpty) return const [];
    final needle = foldText(text);
    return [
      for (final item in collection.items)
        if (!collection.isDisabled(item) &&
            foldText(collection.labelOf(item)).contains(needle))
          item,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Oito2Localizations.of(context);
    final text = _controller.text;
    final count = _options(text).length;
    final announcement =
        !_focusNode.hasFocus || (text.isEmpty && !widget.showAllWhenEmpty)
        ? ''
        : count == 0
        ? l10n.noResults
        : l10n.resultCount(count);

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        clipBehavior: Clip.none,
        children: [
          RawAutocomplete<T>(
            textEditingController: _controller,
            focusNode: _focusNode,
            displayStringForOption: widget.collection.labelOf,
            optionsBuilder: (value) => _options(value.text),
            onSelected: widget.onSelected,
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (_) => onSubmitted(),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    suffixIcon: const Icon(
                      LucideIcons.chevrons_up_down,
                      size: Oito2Sizes.iconSize,
                    ),
                  ),
                ),
            optionsViewBuilder: (context, onSelected, options) =>
                _OptionsView<T>(
                  options: options.toList(),
                  collection: widget.collection,
                  query: text,
                  onSelected: onSelected,
                  maxHeight: widget.optionsMaxHeight,
                  width:
                      widget.optionsWidth ??
                      (constraints.hasBoundedWidth
                          ? constraints.maxWidth
                          : 280),
                ),
          ),
          Semantics(
            liveRegion: true,
            label: announcement,
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _OptionsView<T extends Object> extends StatelessWidget {
  const _OptionsView({
    required this.options,
    required this.collection,
    required this.query,
    required this.onSelected,
    required this.maxHeight,
    required this.width,
  });

  final List<T> options;
  final Oito2ListCollection<T> collection;
  final String query;
  final AutocompleteOnSelected<T> onSelected;
  final double maxHeight;
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
