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

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../collections/list_collection.dart';
import '../l10n/oito2_localizations.dart';
import '../tokens/geometry.dart';
import 'icon_buttons.dart';
import 'menus.dart';
import 'widget_helpers.dart';

/// The page numbers a pagination shows for [page] of [count], with null
/// for an ellipsis.
///
/// It keeps [boundaryCount] pages at each end and [siblingCount] pages on
/// each side of [page], and always returns the same number of items for a
/// given [count], so the buttons don't shift as the page changes. An
/// ellipsis never stands for a single page.
List<int?> oito2PaginationItems(
  int page,
  int count, {
  int siblingCount = 1,
  int boundaryCount = 1,
}) {
  assert(siblingCount >= 0 && boundaryCount >= 0);
  if (count <= 0) return const [];
  List<int> range(int start, int end) => [for (var i = start; i <= end; i++) i];
  final startPages = range(1, math.min(boundaryCount, count));
  final endPages = range(
    math.max(count - boundaryCount + 1, boundaryCount + 1),
    count,
  );
  final siblingsStart = math.max(
    math.min(page - siblingCount, count - boundaryCount - siblingCount * 2 - 1),
    boundaryCount + 2,
  );
  final siblingsEnd = math.min(
    math.max(page + siblingCount, boundaryCount + siblingCount * 2 + 2),
    endPages.isNotEmpty ? endPages.first - 2 : count - 1,
  );
  return [
    ...startPages,
    if (siblingsStart > boundaryCount + 2)
      null
    else if (boundaryCount + 1 < count - boundaryCount)
      boundaryCount + 1,
    ...range(siblingsStart, siblingsEnd),
    if (siblingsEnd < count - boundaryCount - 1)
      null
    else if (count - boundaryCount > boundaryCount)
      count - boundaryCount,
    ...endPages,
  ];
}

/// Page navigation: previous and next buttons around page number buttons
/// with ellipses, and an optional page size selector.
///
/// Narrower than [compactWidth] it shows only the buttons around "Page 3
/// of 10", with the page size selector wrapped below. Pages count from 1.
class Oito2Pagination extends StatelessWidget {
  /// Creates a pagination.
  const Oito2Pagination({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onChanged,
    this.siblingCount = 1,
    this.boundaryCount = 1,
    this.pageSize,
    this.pageSizes = const [],
    this.onPageSizeChanged,
    this.compactWidth = 420,
  }) : assert(pageCount >= 1),
       assert(page >= 1 && page <= pageCount),
       assert(siblingCount >= 0 && boundaryCount >= 0);

  /// The current page, from 1.
  final int page;

  /// The number of pages.
  final int pageCount;

  /// Called with the page to show.
  final ValueChanged<int>? onChanged;

  /// The pages shown on each side of the current one.
  final int siblingCount;

  /// The pages always shown at each end.
  final int boundaryCount;

  /// The current page size, for the selector; one of [pageSizes] when
  /// they are given.
  final int? pageSize;

  /// The page sizes offered; the selector shows when it has entries.
  final List<int> pageSizes;

  /// Called with the chosen page size.
  final ValueChanged<int>? onPageSizeChanged;

  /// The width below which the compact form shows.
  final double compactWidth;

  @override
  Widget build(BuildContext context) {
    assert(
      pageSizes.isEmpty || pageSize == null || pageSizes.contains(pageSize),
      'pageSize must be one of pageSizes.',
    );
    final material = MaterialLocalizations.of(context);
    final strings = Oito2Localizations.of(context);
    final onChanged = this.onChanged;
    final previous = Oito2IconButton(
      tooltip: material.previousPageTooltip,
      onPressed: onChanged != null && page > 1
          ? () => onChanged(page - 1)
          : null,
      icon: Icon(directionalChevron(context, forward: false)),
    );
    final next = Oito2IconButton(
      tooltip: material.nextPageTooltip,
      onPressed: onChanged != null && page < pageCount
          ? () => onChanged(page + 1)
          : null,
      icon: Icon(directionalChevron(context, forward: true)),
    );
    final sizes = pageSizes;
    final sizeSelector = sizes.isEmpty || onPageSizeChanged == null
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Oito2Spacing.sm,
            children: [
              Flexible(
                child: Text(
                  strings.itemsPerPage,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 96,
                child: Oito2Select<int>(
                  collection: Oito2ListCollection(sizes),
                  value: '${pageSize ?? sizes.first}',
                  semanticLabel: strings.itemsPerPage,
                  onChanged: (v) => onPageSizeChanged!(int.parse(v)),
                ),
              ),
            ],
          );
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < compactWidth;
        final pages = compact
            ? <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Oito2Spacing.sm,
                  ),
                  child: Text(strings.pageOf(page, pageCount)),
                ),
              ]
            : [
                for (final item in oito2PaginationItems(
                  page,
                  pageCount,
                  siblingCount: siblingCount,
                  boundaryCount: boundaryCount,
                ))
                  item == null
                      ? const ExcludeSemantics(
                          child: SizedBox(
                            width: 24,
                            child: Center(child: Text('…')),
                          ),
                        )
                      : _PageButton(
                          page: item,
                          current: item == page,
                          onPressed: onChanged == null
                              ? null
                              : () => onChanged(item),
                        ),
              ];
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Oito2Spacing.lg,
          runSpacing: Oito2Spacing.sm,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Oito2Spacing.xxs,
              children: [previous, ...pages, next],
            ),
            ?sizeSelector,
          ],
        );
      },
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.current,
    required this.onPressed,
  });

  final int page;
  final bool current;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final height = controlHeightOf(context);
    final fill = selectedFillOf(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: current,
      label: Oito2Localizations.of(context).pageNumber(page),
      excludeSemantics: true,
      onTap: onPressed,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size(height, height),
          padding: const EdgeInsets.symmetric(horizontal: Oito2Spacing.sm),
          backgroundColor: current ? fill.fill : null,
          foregroundColor: current ? fill.onFill : scheme.onSurface,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text('$page'),
      ),
    );
  }
}
