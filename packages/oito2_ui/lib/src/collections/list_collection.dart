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

import 'package:flutter/foundation.dart';

import 'text_folding.dart';

/// An immutable list of items with the accessors a list, select or
/// autocomplete needs: a unique string value, a display label, a disabled
/// flag and an optional group per item.
///
/// Navigation methods skip disabled items. Methods that change the list
/// return a new collection.
@immutable
class Oito2ListCollection<T> {
  /// Creates a collection of [items].
  ///
  /// [valueOf] gives each item's unique value and defaults to the item
  /// itself when it is a [String], or its `toString()` otherwise.
  /// [labelOf] defaults to [valueOf]. Items are enabled unless
  /// [isDisabled] says otherwise, and ungrouped unless [groupOf] returns
  /// a group name.
  ///
  /// Throws an [ArgumentError] when two items share a value.
  Oito2ListCollection(
    Iterable<T> items, {
    String Function(T item)? valueOf,
    this._labelOf,
    this._isDisabled,
    this._groupOf,
  }) : items = List.unmodifiable(items),
       _valueOf = valueOf ?? _defaultValue {
    for (var i = 0; i < this.items.length; i++) {
      final value = _valueOf(this.items[i]);
      if (_indexes.containsKey(value)) {
        throw ArgumentError.value(value, 'items', 'Duplicate value');
      }
      _indexes[value] = i;
    }
  }

  static String _defaultValue(Object? item) =>
      item is String ? item : item.toString();

  /// The items, in order.
  final List<T> items;

  final String Function(T item) _valueOf;
  final String Function(T item)? _labelOf;
  final bool Function(T item)? _isDisabled;
  final String? Function(T item)? _groupOf;
  final Map<String, int> _indexes = {};

  /// The number of items.
  int get length => items.length;

  /// Whether the collection has no items.
  bool get isEmpty => items.isEmpty;

  /// The values of every item, in order.
  late final List<String> values = List.unmodifiable([
    for (final item in items) valueOf(item),
  ]);

  /// The labels folded by [foldText], in item order.
  late final List<String> _foldedLabels = [
    for (final item in items) foldText(labelOf(item)),
  ];

  /// Returns the unique value of [item].
  String valueOf(T item) => _valueOf(item);

  /// Returns the display label of [item].
  String labelOf(T item) => _labelOf?.call(item) ?? _valueOf(item);

  /// Whether [item] can't be selected or focused.
  bool isDisabled(T item) => _isDisabled?.call(item) ?? false;

  /// Returns the group of [item], or null when it has none.
  String? groupOf(T item) => _groupOf?.call(item);

  /// Whether an item has [value].
  bool has(String? value) => _indexes.containsKey(value);

  /// Returns the index of the item with [value], or -1 when there is none.
  int indexOf(String? value) => _indexes[value] ?? -1;

  /// Returns the item with [value], or null when there is none.
  T? find(String? value) {
    final index = indexOf(value);
    return index < 0 ? null : items[index];
  }

  /// Whether the item with [value] exists and is enabled.
  bool isEnabled(String? value) {
    final item = find(value);
    return item != null && !isDisabled(item);
  }

  /// The value of the first enabled item, or null.
  String? get firstValue => _scan(-1, 1, loop: false);

  /// The value of the last enabled item, or null.
  String? get lastValue => _scan(length, -1, loop: false);

  /// Returns the value of the first enabled item after [value], or null at
  /// the end. With [loop], the search wraps around to the start.
  ///
  /// When [value] isn't in the collection, the search starts before the
  /// first item.
  String? nextValue(String value, {bool loop = false}) =>
      _scan(indexOf(value), 1, loop: loop);

  /// Returns the value of the first enabled item before [value], or null
  /// at the start. With [loop], the search wraps around to the end.
  ///
  /// When [value] isn't in the collection, the search starts after the
  /// last item.
  String? previousValue(String value, {bool loop = false}) {
    final index = indexOf(value);
    return _scan(index < 0 ? length : index, -1, loop: loop);
  }

  /// Returns the value of the first enabled item found by moving [step]
  /// positions at a time from the index [from], wrapping around with
  /// [loop] and stopping at either end otherwise.
  String? _scan(int from, int step, {required bool loop}) {
    for (var n = 1; n <= length; n++) {
      var index = from + step * n;
      if (loop) {
        index %= length;
      } else if (index < 0 || index >= length) {
        return null;
      }
      final item = items[index];
      if (!isDisabled(item)) return valueOf(item);
    }
    return null;
  }

  /// Returns the value of the first enabled item whose label starts with
  /// [query], ignoring case and accents, searching after the item with
  /// value [from] (from the first item when [from] is null or unknown) and
  /// wrapping around; null when none matches or [query] is empty.
  ///
  /// It implements typeahead: typing letters while a list has focus moves
  /// to the next matching item.
  String? search(String query, {String? from}) {
    if (query.isEmpty || isEmpty) return null;
    final needle = foldText(query);
    final start = indexOf(from);
    for (var n = 1; n <= length; n++) {
      final index = (start + n) % length;
      final item = items[index];
      if (!isDisabled(item) && _foldedLabels[index].startsWith(needle)) {
        return valueOf(item);
      }
    }
    return null;
  }

  /// The items grouped by [groupOf], in the order each group first
  /// appears; ungrouped items form a group named null.
  List<({String? group, List<T> items})> get groups {
    final order = <String?>[];
    final byGroup = <String?, List<T>>{};
    for (final item in items) {
      final group = groupOf(item);
      byGroup
          .putIfAbsent(group, () {
            order.add(group);
            return [];
          })
          .add(item);
    }
    return [for (final group in order) (group: group, items: byGroup[group]!)];
  }

  /// Returns a collection of [items] with the same accessors.
  ///
  /// Throws an [ArgumentError] when two of [items] share a value.
  Oito2ListCollection<T> copyWith(Iterable<T> items) => Oito2ListCollection(
    items,
    valueOf: _valueOf,
    labelOf: _labelOf,
    isDisabled: _isDisabled,
    groupOf: _groupOf,
  );

  /// Returns a collection of the items for which [test] returns true.
  Oito2ListCollection<T> where(bool Function(T item) test) =>
      copyWith(items.where(test));

  /// Returns a collection of the items whose label contains [query],
  /// ignoring case and accents.
  Oito2ListCollection<T> filter(String query) {
    final needle = foldText(query);
    return copyWith([
      for (var i = 0; i < length; i++)
        if (_foldedLabels[i].contains(needle)) items[i],
    ]);
  }

  /// Returns the enabled items whose label contains [query], ignoring case
  /// and accents, in order, leaving out those whose label is in [exclude]:
  /// the suggestions for a text typed in a field.
  List<T> suggestions(String query, {Set<String> exclude = const {}}) {
    final needle = foldText(query);
    return [
      for (var i = 0; i < length; i++)
        if (!isDisabled(items[i]) &&
            _foldedLabels[i].contains(needle) &&
            !exclude.contains(labelOf(items[i])))
          items[i],
    ];
  }

  /// Returns the collection with the item at [from] moved to [to].
  ///
  /// Throws a [RangeError] when either index is outside the items.
  Oito2ListCollection<T> reorder(int from, int to) {
    RangeError.checkValidIndex(from, items, 'from');
    RangeError.checkValidIndex(to, items, 'to');
    final list = [...items];
    list.insert(to, list.removeAt(from));
    return copyWith(list);
  }
}
