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
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'options_view.dart';
import 'widget_helpers.dart';

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
    extends State<Oito2Autocomplete<T>>
    with
        OwnedFocusNodeMixin,
        OwnedControllerMixin<Oito2Autocomplete<T>, TextEditingController> {
  @override
  TextEditingController? get widgetController => widget.controller;

  @override
  TextEditingController createOwnedController() => TextEditingController(
    text: switch (widget.collection.find(widget.initialValue)) {
      final item? => widget.collection.labelOf(item),
      null => '',
    },
  );

  @override
  void onControllerChange() => _onText();

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  @override
  void onEffectiveFocusChange() => _onText();

  TextEditingController get _controller => effectiveController;

  FocusNode get _focusNode => effectiveFocusNode;

  @override
  void didUpdateWidget(Oito2Autocomplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showAllWhenEmpty != widget.showAllWhenEmpty) {
      _lastQuery = null;
    }
  }

  void _onText() => setState(() {});

  Oito2ListCollection<T>? _optionsSource;
  String? _lastQuery;
  List<T> _lastOptions = const [];

  /// The items matching [text], reused while the text and the collection
  /// stay the same.
  List<T> _options(String text) {
    final collection = widget.collection;
    if (identical(_optionsSource, collection) && text == _lastQuery) {
      return _lastOptions;
    }
    _optionsSource = collection;
    _lastQuery = text;
    if (text.isEmpty && !widget.showAllWhenEmpty) {
      return _lastOptions = const [];
    }
    return _lastOptions = collection.suggestions(text);
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
                AutocompleteOptionsView<T>(
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
