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

/// Holds the number of pages and the selected page of a navigation
/// widget, such as `Oito2MasterDetailPage` or `Oito2NavigationPage`.
///
/// An [index] of -1 means no page is selected.
class Oito2PageController extends ChangeNotifier {
  /// Creates a controller for [length] pages with [initialIndex] selected.
  ///
  /// Throws an [AssertionError] in debug mode when [length] is negative or
  /// [initialIndex] is not between -1 and `length - 1`.
  Oito2PageController({required int length, int initialIndex = -1})
    : assert(length >= 0),
      assert(initialIndex >= -1 && initialIndex < length),
      _length = length,
      _index = initialIndex;

  int _length;
  int _index;

  /// The number of pages.
  int get length => _length;

  /// Changes the number of pages and clears the selection when the
  /// selected page is beyond the new length.
  ///
  /// Throws an [AssertionError] in debug mode when the value is negative.
  set length(int value) {
    assert(value >= 0);
    if (value == _length) return;
    _length = value;
    if (_index >= value) _index = -1;
    notifyListeners();
  }

  /// The selected page, or -1 when none is selected.
  int get index => _index;

  /// Selects the page at the given index, or clears the selection with -1.
  ///
  /// Throws an [AssertionError] in debug mode when the index is not between
  /// -1 and `length - 1`.
  set index(int value) {
    assert(value >= -1 && value < _length, 'index $value out of range');
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }

  /// Whether a page is selected.
  bool get hasSelection => _index >= 0;
}
