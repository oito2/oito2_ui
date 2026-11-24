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

import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import '../docs/doc_widgets.dart';

// #region model
/// A file transfer whose progress changes on its own; the row of the
/// transfer listens to [progress], so only that row rebuilds.
class _Transfer {
  _Transfer(this.id) : name = 'file-${id.toString().padLeft(5, '0')}.dat';

  final int id;
  final String name;
  final progress = ValueNotifier<double>(0);
}
// #endregion

/// Documents [Oito2VirtualList] with 10,000 rows updated live and an
/// infinite list loaded through an [Oito2AsyncListController].
class VirtualListPage extends StatefulWidget {
  /// Creates the virtual list page.
  const VirtualListPage({super.key});

  @override
  State<VirtualListPage> createState() => _VirtualListPageState();
}

class _VirtualListPageState extends State<VirtualListPage> {
  // #region live-data
  final _transfers = [for (var i = 0; i < 10000; i++) _Transfer(i)];
  late final _collection = Oito2ListCollection(
    _transfers,
    valueOf: (t) => '${t.id}',
    labelOf: (t) => t.name,
  );
  late final _selection = Oito2SelectionController(
    collection: _collection,
    mode: Oito2SelectionMode.multiple,
  );
  final _random = math.Random(8);
  Timer? _timer;

  /// Advances 5 random transfers every 100 ms: 50 updates per second.
  void _tick(Timer _) {
    for (var i = 0; i < 5; i++) {
      final progress = _transfers[_random.nextInt(_transfers.length)].progress;
      progress.value = progress.value >= 1 ? 0 : progress.value + 0.1;
    }
  }
  // #endregion

  // #region async-data
  late final _pages = Oito2AsyncListController<String, int>(
    load: (request) async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (_failNext) {
        _failNext = false;
        throw StateError('The server did not answer.');
      }
      final start = request.cursor ?? 0;
      final end = math.min(start + 30, 300);
      return Oito2AsyncListPage([
        for (var i = start; i < end; i++) 'Message ${i + 1}',
      ], cursor: end < 300 ? end : null);
    },
  );
  var _messages = Oito2ListCollection<String>(const []);
  late final _messageSelection = Oito2SelectionController(
    collection: _messages,
  );

  /// Rebuilds the collection from the loaded items.
  void _onPages() {
    setState(() {
      _messages = Oito2ListCollection(_pages.items);
      _messageSelection.collection = _messages;
    });
  }
  // #endregion

  // #region reorder-data
  var _queue = Oito2ListCollection([for (var i = 1; i <= 200; i++) 'Track $i']);
  late final _queueSelection = Oito2SelectionController(collection: _queue);
  bool _handles = true;

  /// Moves the track at [from] to [to], the index it ends at once taken
  /// out of its place.
  void _reorder(int from, int to) {
    final items = [..._queue.items];
    items.insert(to, items.removeAt(from));
    setState(() => _queue = _queue.copyWith(items));
    _queueSelection.collection = _queue;
  }
  // #endregion

  bool _failNext = false;
  String _activated = 'None';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), _tick);
    _pages.addListener(_onPages);
    unawaited(_pages.reload());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _selection.dispose();
    for (final transfer in _transfers) {
      transfer.progress.dispose();
    }
    _pages
      ..removeListener(_onPages)
      ..dispose();
    _messageSelection.dispose();
    _queueSelection.dispose();
    super.dispose();
  }

  /// Starts or stops the live updates.
  void _setLive(bool live) {
    setState(() {
      _timer?.cancel();
      _timer = live
          ? Timer.periodic(const Duration(milliseconds: 100), _tick)
          : null;
    });
  }

  /// A bordered box of 360 pixels tall around [child].
  Widget _border(Widget child) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 360,
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: Oito2Radius.mediumAll,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Virtual List',
      description:
          'A list that builds only the rows in view, for thousands of items, '
          'with the selection and keyboard of the list box.',
      source: 'lib/src/pages/virtual_list_page.dart',
      children: [
        ExamplePanel(
          regions: const ['model', 'live-data', 'preview'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Oito2Spacing.sm,
            children: [
              Oito2SwitchButton(
                value: _timer != null,
                onChanged: _setLive,
                title: const Text('Live updates (50 per second)'),
              ),
              _border(
                // #region preview
                Oito2VirtualList<_Transfer>(
                  collection: _collection,
                  controller: _selection,
                  semanticLabel: 'Transfers',
                  onActivate: (t) => setState(() => _activated = t.name),
                  itemBuilder: (context, transfer, selected) => Row(
                    spacing: Oito2Spacing.sm,
                    children: [
                      Expanded(
                        child: Text(
                          transfer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Only this part rebuilds when the progress changes.
                      ValueListenableBuilder(
                        valueListenable: transfer.progress,
                        builder: (context, progress, _) => SizedBox(
                          width: 120,
                          child: Oito2LinearProgressIndicator(
                            value: progress,
                            semanticsLabel: transfer.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // #endregion
              ),
              ListenableBuilder(
                listenable: _selection,
                builder: (context, _) => Text(
                  'Selected: ${_selection.selectedValues.length} · '
                  'Last activated: $_activated',
                ),
              ),
            ],
          ),
        ),
        const DocHeading('Usage'),
        const DocText(
          'Give `Oito2VirtualList` an `Oito2ListCollection` of the items and '
          'an `Oito2SelectionController` over it, as to `Oito2ListBox`, and a '
          'bounded height. Only the rows in view, plus `cacheExtent` pixels '
          'around them, are built, so `itemBuilder` must be cheap. Every row '
          'is `itemExtent` tall (the control height by default); with '
          '`variableHeight`, rows are as tall as their content.',
        ),
        const DocText(
          'Rows are keyed by their item value, so a row keeps its state when '
          'items move. When the list rebuilds, the rows in view rebuild; to '
          'update one row often, build its changing part from a listenable '
          'of that item, as the progress bars above do with a '
          '`ValueListenableBuilder`: 50 updates per second rebuild only '
          'those bars, never the other rows.',
        ),
        const DocCode("import 'package:oito2_ui/oito2_ui.dart';"),
        const DocNote(
          'For lists of up to a few hundred items with group headings, use '
          '`Oito2ListBox`; for rows in columns, `Oito2DataTable`.',
        ),
        const DocHeading('Examples'),
        const DocHeading('Infinite scroll', level: 3),
        const DocText(
          'With `asyncController`, the list loads the next page of an '
          '`Oito2AsyncListController` when its end comes near, shows a '
          'loading row while it loads, and an error row with a retry button '
          'when the page failed. The app builds the collection from the '
          "controller's items. `onReachEnd` runs at the same moment, for "
          'other data sources.',
        ),
        ExamplePanel(
          regions: const ['async-data', 'async'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Oito2Spacing.sm,
            children: [
              Oito2SwitchButton(
                value: _failNext,
                onChanged: (value) => setState(() => _failNext = value),
                title: const Text('Fail the next page'),
              ),
              _border(
                // #region async
                Oito2VirtualList<String>(
                  collection: _messages,
                  controller: _messageSelection,
                  asyncController: _pages,
                  semanticLabel: 'Messages',
                ),
                // #endregion
              ),
            ],
          ),
        ),
        const DocHeading('Reordering', level: 3),
        const DocText(
          'With `onReorder`, the user drags a row to a new place, the list '
          'scrolling while the pointer is near its top or bottom edge, or '
          'moves the active row with `Alt+Up` and `Alt+Down`. With '
          '`dragHandle`, only the grip at the start of each row drags it, '
          'so a touch on the rest of the row still scrolls; without it, a '
          'mouse drags the whole row and a touch drags it after a long '
          'press. The callback receives the item index and the index it '
          'ends at once taken out of its place; the app moves the item. '
          '`Oito2DataTable` takes the same `onReorder`.',
        ),
        ExamplePanel(
          regions: const ['reorder-data', 'reorder'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Oito2Spacing.sm,
            children: [
              Oito2SwitchButton(
                value: _handles,
                onChanged: (value) => setState(() => _handles = value),
                title: const Text('Drag handles'),
              ),
              _border(
                // #region reorder
                Oito2VirtualList<String>(
                  collection: _queue,
                  controller: _queueSelection,
                  semanticLabel: 'Play queue',
                  dragHandle: _handles,
                  onReorder: _reorder,
                ),
                // #endregion
              ),
            ],
          ),
        ),
        const DocHeading('Accessibility'),
        const DocText(
          'The list is a semantics container labeled by `semanticLabel`, '
          'with the number of rows; each row reports its position, whether '
          'it is selected, enabled and active. The loading and error rows '
          'are live regions. Set `autofocus` to give the list the focus when '
          'it shows. With `onReorder`, rows offer the "Move up" and "Move '
          'down" actions, and every move is announced with the new '
          'position.',
        ),
        const DocHeading('Keyboard', level: 3),
        const DocTable(
          header: ['Key', 'Action'],
          rows: [
            [
              '`Down arrow` / `Up arrow`',
              'Moves the active row; a single-selection list also selects it.',
            ],
            [
              '`Page Down` / `Page Up`',
              'Moves the active row by the rows in view.',
            ],
            ['`Home` / `End`', 'Moves to the first or the last row.'],
            [
              '`Shift` + movement keys',
              'Extends the selection, in a multiple-selection list.',
            ],
            [
              '`Space`',
              'Toggles the active row, in a multiple-selection list.',
            ],
            [
              '`Ctrl+A` / `Cmd+A`',
              'Selects all, in a multiple-selection list.',
            ],
            ['`Enter`', 'Activates the active row.'],
            [
              '`Alt+Up` / `Alt+Down`',
              'Moves the active row up or down by one, with `onReorder`.',
            ],
            ['`Escape`', 'Cancels a drag in progress, with `onReorder`.'],
            ['Letters', 'Jump to the next row whose label matches.'],
          ],
        ),
        ...apiReferenceWidgets([
          'Oito2VirtualList',
          'Oito2ListCollection',
          'Oito2SelectionController',
          'Oito2AsyncListController',
        ]),
      ],
    );
  }
}
