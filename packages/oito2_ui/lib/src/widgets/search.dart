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

import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/geometry.dart';

/// A search text field with a search icon and a clear button that appears
/// while it has text.
///
/// Pressing Escape clears the text; pressing it again on an empty field
/// calls [onEscape]. The hint and the clear button tooltip come from
/// `MaterialLocalizations`, so they follow the app language.
class Oito2SearchField extends StatefulWidget {
  /// Creates a search field.
  const Oito2SearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onEscape,
    this.autofocus = false,
  });

  /// Controls the text; one is created when null.
  final TextEditingController? controller;

  /// The focus node; one is created when null.
  final FocusNode? focusNode;

  /// The hint; defaults to the localized "Search".
  final String? hintText;

  /// Called whenever the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text.
  final ValueChanged<String>? onSubmitted;

  /// Called after the clear button or Escape empties the field.
  final VoidCallback? onClear;

  /// Called when Escape is pressed on an empty field.
  final VoidCallback? onEscape;

  /// Whether the field takes focus when shown.
  final bool autofocus;

  @override
  State<Oito2SearchField> createState() => _Oito2SearchFieldState();
}

class _Oito2SearchFieldState extends State<Oito2SearchField> {
  TextEditingController? _ownController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(Oito2SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.controller ?? _ownController;
    if (old != _controller) {
      old?.removeListener(_onText);
      _controller.addListener(_onText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _ownController?.dispose();
    super.dispose();
  }

  void _onText() => setState(() {});

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      if (_controller.text.isNotEmpty) {
        _clear();
      } else {
        widget.onEscape?.call();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final hasText = _controller.text.isNotEmpty;
    return Focus(
      onKeyEvent: _onKey,
      canRequestFocus: false,
      skipTraversal: true,
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText ?? localizations.searchFieldLabel,
          prefixIcon: const Icon(LucideIcons.search, size: Oito2Sizes.iconSize),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: localizations.clearButtonTooltip,
                  onPressed: _clear,
                  icon: const Icon(LucideIcons.x, size: Oito2Sizes.iconSize),
                )
              : null,
        ),
      ),
    );
  }
}

/// A title bar element that switches between a [title] and a search
/// field, with a toggle button, as in GNOME apps.
///
/// Escape on an empty field closes the search. The toggle button reports
/// its pressed state to assistive technologies.
class Oito2SearchTitleField extends StatelessWidget {
  /// Creates a search title field.
  const Oito2SearchTitleField({
    super.key,
    required this.title,
    required this.searchActive,
    required this.onSearchActiveChanged,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.hintText,
    this.fieldWidth = 260,
    this.toggleLabel,
  });

  /// Shown while the search is closed.
  final Widget title;

  /// Whether the search field is shown.
  final bool searchActive;

  /// Called to open or close the search.
  final ValueChanged<bool> onSearchActiveChanged;

  /// Called whenever the search text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the search text.
  final ValueChanged<String>? onSubmitted;

  /// Controls the search text.
  final TextEditingController? controller;

  /// The search hint; defaults to the localized "Search".
  final String? hintText;

  /// The width of the search field.
  final double fieldWidth;

  /// The tooltip of the toggle button; defaults to the localized
  /// "Search".
  final String? toggleLabel;

  @override
  Widget build(BuildContext context) {
    final label =
        toggleLabel ?? MaterialLocalizations.of(context).searchFieldLabel;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Oito2Spacing.sm,
      children: [
        Flexible(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: searchActive
                ? SizedBox(
                    key: const ValueKey('search'),
                    width: fieldWidth,
                    child: Oito2SearchField(
                      controller: controller,
                      hintText: hintText,
                      autofocus: true,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      onEscape: () => onSearchActiveChanged(false),
                    ),
                  )
                : KeyedSubtree(key: const ValueKey('title'), child: title),
          ),
        ),
        IconButton(
          tooltip: label,
          isSelected: searchActive,
          onPressed: () => onSearchActiveChanged(!searchActive),
          icon: const Icon(LucideIcons.search),
        ),
      ],
    );
  }
}
