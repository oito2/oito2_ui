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

/// The direction of an [Oito2SortDescriptor].
enum Oito2SortDirection {
  /// Smallest first.
  ascending,

  /// Largest first.
  descending,
}

/// What a list is sorted by: a [column] name and a [direction].
@immutable
class Oito2SortDescriptor {
  /// Creates a sort descriptor.
  const Oito2SortDescriptor(
    this.column, [
    this.direction = Oito2SortDirection.ascending,
  ]);

  /// The sorted column or field.
  final String column;

  /// The sort direction.
  final Oito2SortDirection direction;

  @override
  bool operator ==(Object other) =>
      other is Oito2SortDescriptor &&
      other.column == column &&
      other.direction == direction;

  @override
  int get hashCode => Object.hash(column, direction);
}

/// The parameters of one page load of an [Oito2AsyncListController].
@immutable
class Oito2AsyncListRequest<C> {
  /// Creates a load request.
  const Oito2AsyncListRequest({
    required this.cursor,
    required this.filterText,
    required this.sort,
    required this._isCancelled,
  });

  /// The cursor of the next page, or null for the first page.
  final C? cursor;

  /// The current filter text.
  final String filterText;

  /// The current sort, or null.
  final Oito2SortDescriptor? sort;

  final bool Function() _isCancelled;

  /// Whether a newer request superseded this one; long loads can stop
  /// early when it becomes true, since their result will be ignored.
  bool get isCancelled => _isCancelled();
}

/// One page of items loaded by an [Oito2AsyncListController].
@immutable
class Oito2AsyncListPage<T, C> {
  /// Creates a page with [items] and the [cursor] of the next page, or
  /// null when it is the last one.
  const Oito2AsyncListPage(this.items, {this.cursor});

  /// The loaded items.
  final List<T> items;

  /// The cursor of the next page, or null after the last page.
  final C? cursor;
}

/// Loads a list page by page through [load], with filter text, sorting,
/// loading and error states, and stale results ignored.
///
/// [reload] replaces the items with the first page and [loadMore] appends
/// the next one while [hasMore]. Changing the filter text or the sort
/// reloads, unless a [sort] function sorts the loaded items locally. A
/// load started while another is running supersedes it: the older result
/// is dropped and its request reports [Oito2AsyncListRequest.isCancelled].
class Oito2AsyncListController<T, C> extends ChangeNotifier {
  /// Creates a controller; it doesn't load until [reload] is called.
  Oito2AsyncListController({
    required this.load,
    this.sort,
    List<T> initialItems = const [],
    String initialFilterText = '',
    Oito2SortDescriptor? initialSort,
  }) : _items = List.unmodifiable(initialItems),
       _filterText = initialFilterText,
       _sortDescriptor = initialSort;

  /// Loads one page.
  final Future<Oito2AsyncListPage<T, C>> Function(
    Oito2AsyncListRequest<C> request,
  )
  load;

  /// Sorts loaded items locally; when null, a sort change reloads.
  final List<T> Function(List<T> items, Oito2SortDescriptor sort)? sort;

  List<T> _items;
  String _filterText;
  Oito2SortDescriptor? _sortDescriptor;
  C? _cursor;
  bool _loaded = false;
  bool _loading = false;
  bool _loadingMore = false;
  Object? _error;
  StackTrace? _stackTrace;
  int _generation = 0;
  bool _disposed = false;

  /// The loaded items.
  List<T> get items => _items;

  /// The filter text sent with each load.
  String get filterText => _filterText;

  /// The current sort, or null.
  Oito2SortDescriptor? get sortDescriptor => _sortDescriptor;

  /// Whether the first page is loading.
  bool get isLoading => _loading;

  /// Whether a further page is loading.
  bool get isLoadingMore => _loadingMore;

  /// The error of the last load, or null when it succeeded.
  Object? get error => _error;

  /// The stack trace of [error], or null.
  StackTrace? get stackTrace => _stackTrace;

  /// Whether more pages remain after a load.
  bool get hasMore => _loaded && _cursor != null;

  /// Replaces the items with the first page.
  Future<void> reload() => _run(more: false);

  /// Appends the next page, when [hasMore] and no load is running.
  Future<void> loadMore() {
    if (!hasMore || _loading || _loadingMore) return Future.value();
    return _run(more: true);
  }

  /// Sets the filter text and reloads.
  Future<void> setFilterText(String text) {
    if (text == _filterText) return Future.value();
    _filterText = text;
    return reload();
  }

  /// Sets the sort: sorts the items locally with [sort] when given,
  /// otherwise reloads.
  Future<void> setSort(Oito2SortDescriptor? descriptor) {
    _sortDescriptor = descriptor;
    final local = sort;
    if (local != null && descriptor != null) {
      _items = List.unmodifiable(local([..._items], descriptor));
      _notify();
      return Future.value();
    }
    return reload();
  }

  Future<void> _run({required bool more}) async {
    final generation = ++_generation;
    _error = null;
    _stackTrace = null;
    if (more) {
      _loadingMore = true;
    } else {
      _loading = true;
      _loadingMore = false;
    }
    _notify();
    try {
      final page = await load(
        Oito2AsyncListRequest(
          cursor: more ? _cursor : null,
          filterText: _filterText,
          sort: _sortDescriptor,
          isCancelled: () => generation != _generation || _disposed,
        ),
      );
      if (generation != _generation || _disposed) return;
      var items = more ? [..._items, ...page.items] : page.items;
      final local = sort;
      final descriptor = _sortDescriptor;
      if (local != null && descriptor != null) items = local(items, descriptor);
      _items = List.unmodifiable(items);
      _cursor = page.cursor;
      _loaded = true;
    } on Object catch (error, stackTrace) {
      if (generation != _generation || _disposed) return;
      _error = error;
      _stackTrace = stackTrace;
      if (!more) {
        // A failed first page invalidates the paging of the previous load,
        // so loadMore can't mix its cursor with the new filter or sort.
        _cursor = null;
        _loaded = false;
      }
    } finally {
      if (generation == _generation && !_disposed) {
        _loading = false;
        _loadingMore = false;
        _notify();
      }
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
