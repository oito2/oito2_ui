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

import 'package:flutter/foundation.dart';

import 'list_collection.dart';

/// How many items an [Oito2SelectionController] can select.
enum Oito2SelectionMode {
  /// Nothing can be selected.
  none,

  /// One item at most.
  single,

  /// Any number of items.
  multiple,
}

/// The selected values of an [Oito2ListCollection], with the desktop
/// selection gestures: plain click, Control/Command click to toggle and
/// Shift click to extend a range from the anchor.
///
/// Disabled items and values outside the collection are never selected.
/// [selectedValues] keeps the collection order.
class Oito2SelectionController extends ChangeNotifier {
  /// Creates a selection over [collection].
  Oito2SelectionController({
    required this._collection,
    this.mode = Oito2SelectionMode.single,
    this.deselectable = true,
    this.resetOnCollectionChange = false,
    Iterable<String> initialValues = const [],
  }) {
    _selected.addAll(initialValues.where(canSelect));
    if (mode == Oito2SelectionMode.single && _selected.length > 1) {
      final first = firstSelectedValue!;
      _selected
        ..clear()
        ..add(first);
    }
  }

  /// How many items can be selected.
  final Oito2SelectionMode mode;

  /// Whether a selected item can be deselected by selecting it again in
  /// single mode, or by toggling it.
  final bool deselectable;

  /// Whether replacing the [collection] clears the selection; otherwise
  /// only the values that left the collection are dropped.
  final bool resetOnCollectionChange;

  Oito2ListCollection<Object?> _collection;
  final Set<String> _selected = {};
  String? _anchor;

  /// The collection the values belong to.
  Oito2ListCollection<Object?> get collection => _collection;

  set collection(Oito2ListCollection<Object?> value) {
    _collection = value;
    final before = _selected.length;
    if (resetOnCollectionChange) {
      _selected.clear();
    } else {
      _selected.removeWhere((v) => !value.isEnabled(v));
    }
    if (!value.has(_anchor)) _anchor = null;
    if (_selected.length != before || resetOnCollectionChange) {
      notifyListeners();
    }
  }

  /// The selected values, in collection order.
  List<String> get selectedValues {
    final list = _selected.toList()
      ..sort((a, b) => _collection.indexOf(a) - _collection.indexOf(b));
    return List.unmodifiable(list);
  }

  /// Whether nothing is selected.
  bool get isEmpty => _selected.isEmpty;

  /// The first selected value in collection order, or null.
  String? get firstSelectedValue {
    final values = selectedValues;
    return values.isEmpty ? null : values.first;
  }

  /// The last selected value in collection order, or null.
  String? get lastSelectedValue {
    final values = selectedValues;
    return values.isEmpty ? null : values.last;
  }

  /// The value range selections extend from: the last value selected by
  /// [select], [toggle] or [replace].
  String? get anchorValue => _anchor;

  /// Whether [value] is selected.
  bool isSelected(String? value) => _selected.contains(value);

  /// Whether [value] can be selected: it is an enabled item and the mode
  /// allows selection.
  bool canSelect(String value) =>
      mode != Oito2SelectionMode.none && _collection.isEnabled(value);

  /// Whether every enabled item is selected.
  bool get isAllSelected {
    final enabled = _collection.values.where(_collection.isEnabled);
    return enabled.isNotEmpty && enabled.every(_selected.contains);
  }

  /// Whether some, but not all, enabled items are selected; drives a
  /// mixed "select all" check box.
  bool get isSomeSelected => _selected.isNotEmpty && !isAllSelected;

  /// Selects [value]. In single mode it replaces the selection; selecting
  /// the selected value again deselects it when [deselectable] and
  /// [forceToggle] are set.
  void select(String value, {bool forceToggle = false}) {
    if (!canSelect(value)) return;
    _anchor = value;
    if (mode == Oito2SelectionMode.single) {
      if (_selected.contains(value)) {
        if (forceToggle && deselectable) {
          _selected.clear();
          notifyListeners();
        }
        return;
      }
      _selected
        ..clear()
        ..add(value);
    } else if (!_selected.add(value)) {
      return;
    }
    notifyListeners();
  }

  /// Deselects [value].
  void deselect(String value) {
    if (_selected.remove(value)) notifyListeners();
  }

  /// Selects [value] when it isn't selected, otherwise deselects it if
  /// [deselectable].
  void toggle(String value) {
    if (_selected.contains(value)) {
      if (!deselectable) return;
      _anchor = value;
      deselect(value);
    } else {
      select(value);
    }
  }

  /// Makes [value] the only selected value; null clears the selection.
  void replace(String? value) {
    if (value != null && !canSelect(value)) return;
    _anchor = value;
    _setSelected([?value]);
  }

  /// Replaces the selection with [values], notifying only when it changes.
  void _setSelected(Iterable<String> values) {
    final next = values.toSet();
    if (setEquals(next, _selected.toSet())) return;
    _selected
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  /// Selects the enabled values from [anchorValue] to [targetValue], both
  /// included, replacing the previous selection. In single mode it selects
  /// [targetValue] only.
  void extend(String anchorValue, String targetValue) {
    if (mode != Oito2SelectionMode.multiple) {
      select(targetValue);
      return;
    }
    var from = _collection.indexOf(anchorValue);
    var to = _collection.indexOf(targetValue);
    if (from < 0 || to < 0) return;
    if (from > to) (from, to) = (to, from);
    _selected
      ..clear()
      ..addAll([
        for (final value in _collection.values.sublist(from, to + 1))
          if (canSelect(value)) value,
      ]);
    _anchor = anchorValue;
    notifyListeners();
  }

  /// Applies a pointer click on [value] with the desktop conventions:
  /// [extend] (Shift) selects the range from the anchor, [toggle]
  /// (Control or Command) toggles the value, and a plain click selects
  /// only it.
  void click(String value, {bool extend = false, bool toggle = false}) {
    final anchor = _anchor;
    if (extend && anchor != null && mode == Oito2SelectionMode.multiple) {
      this.extend(anchor, value);
    } else if (toggle && mode == Oito2SelectionMode.multiple) {
      this.toggle(value);
    } else if (mode == Oito2SelectionMode.single) {
      select(value, forceToggle: true);
    } else {
      replace(value);
    }
  }

  /// Selects every enabled item, in multiple mode.
  void selectAll() {
    if (mode != Oito2SelectionMode.multiple) return;
    _setSelected([..._selected, ..._collection.values.where(canSelect)]);
  }

  /// Deselects everything.
  void clear() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }

  /// Replaces the selection with [values], keeping only the selectable
  /// ones (and the first of them in single mode). The last of them becomes
  /// the anchor of Shift ranges.
  void setSelectedValues(Iterable<String> values) {
    final valid = values.where(canSelect).toList();
    final next = mode == Oito2SelectionMode.single ? valid.take(1) : valid;
    _anchor = next.isEmpty ? null : next.last;
    _setSelected(next);
  }
}
