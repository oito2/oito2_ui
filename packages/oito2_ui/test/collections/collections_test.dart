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

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';

typedef _Fruit = ({String id, String name, String group, bool disabled});

final _fruits = Oito2ListCollection<_Fruit>(
  const [
    (id: 'apple', name: 'Apple', group: 'Pome', disabled: false),
    (id: 'banana', name: 'Banana', group: 'Berry', disabled: true),
    (id: 'cherry', name: 'Cherry', group: 'Drupe', disabled: false),
    (id: 'pear', name: 'Pêra', group: 'Pome', disabled: false),
    (id: 'plum', name: 'Plum', group: 'Drupe', disabled: false),
  ],
  valueOf: (f) => f.id,
  labelOf: (f) => f.name,
  isDisabled: (f) => f.disabled,
  groupOf: (f) => f.group,
);

void main() {
  group('Oito2ListCollection', () {
    test('looks items up by value', () {
      expect(_fruits.length, 5);
      expect(_fruits.values, ['apple', 'banana', 'cherry', 'pear', 'plum']);
      expect(_fruits.find('cherry')?.name, 'Cherry');
      expect(_fruits.indexOf('pear'), 3);
      expect(_fruits.has('kiwi'), isFalse);
      expect(_fruits.labelOf(_fruits.items.first), 'Apple');
      expect(_fruits.isEnabled('banana'), isFalse);
    });

    test('strings are their own value and label', () {
      final list = Oito2ListCollection(['a', 'b']);
      expect(list.valueOf('a'), 'a');
      expect(list.labelOf('b'), 'b');
    });

    test('navigation skips disabled items', () {
      expect(_fruits.firstValue, 'apple');
      expect(_fruits.lastValue, 'plum');
      expect(_fruits.nextValue('apple'), 'cherry');
      expect(_fruits.previousValue('cherry'), 'apple');
      expect(_fruits.nextValue('plum'), isNull);
      expect(_fruits.nextValue('plum', loop: true), 'apple');
      expect(_fruits.previousValue('apple', loop: true), 'plum');
    });

    test('typeahead ignores case and accents and wraps around', () {
      expect(_fruits.search('p'), 'pear');
      expect(_fruits.search('p', from: 'pear'), 'plum');
      expect(_fruits.search('p', from: 'plum'), 'pear');
      expect(_fruits.search('PERA'), 'pear');
      expect(_fruits.search('b'), isNull);
    });

    test('groups keep the order of first appearance', () {
      expect(
        [for (final g in _fruits.groups) g.group],
        ['Pome', 'Berry', 'Drupe'],
      );
      expect(
        [for (final f in _fruits.groups.first.items) f.id],
        ['apple', 'pear'],
      );
    });

    test('filters and reorders into new collections', () {
      expect(_fruits.filter('er').values, ['cherry', 'pear']);
      expect(_fruits.reorder(0, 4).values, [
        'banana',
        'cherry',
        'pear',
        'plum',
        'apple',
      ]);
      expect(_fruits.values.first, 'apple');
    });
  });

  group('Oito2ListCollection validation and suggestions', () {
    test('rejects duplicate values and reorders within range', () {
      expect(() => Oito2ListCollection(['a', 'a']), throwsArgumentError);
      expect(
        () => Oito2ListCollection(['a', 'b']).reorder(0, 5),
        throwsRangeError,
      );
    });

    test('suggests enabled matches, leaving out excluded labels', () {
      expect(
        [for (final f in _fruits.suggestions('p')) f.id],
        ['apple', 'pear', 'plum'],
      );
      expect([
        for (final f in _fruits.suggestions('pe', exclude: {'Pêra'})) f.id,
      ], isEmpty);
      expect([for (final f in _fruits.suggestions('BAN')) f.id], isEmpty);
    });
  });

  group('Oito2SelectionController', () {
    test('single mode replaces and toggles with forceToggle', () {
      final selection = Oito2SelectionController(collection: _fruits);
      selection.select('apple');
      selection.select('cherry');
      expect(selection.selectedValues, ['cherry']);
      selection.select('cherry', forceToggle: true);
      expect(selection.isEmpty, isTrue);
    });

    test('never selects disabled or unknown values', () {
      final selection = Oito2SelectionController(
        collection: _fruits,
        mode: Oito2SelectionMode.multiple,
        initialValues: ['banana', 'kiwi', 'apple'],
      );
      expect(selection.selectedValues, ['apple']);
      selection.select('banana');
      expect(selection.isSelected('banana'), isFalse);
    });

    test('extends ranges from the anchor and keeps collection order', () {
      final selection = Oito2SelectionController(
        collection: _fruits,
        mode: Oito2SelectionMode.multiple,
      );
      selection.click('plum');
      selection.click('apple', extend: true);
      expect(selection.selectedValues, ['apple', 'cherry', 'pear', 'plum']);
      selection.click('pear', toggle: true);
      expect(selection.selectedValues, ['apple', 'cherry', 'plum']);
      selection.click('cherry');
      expect(selection.selectedValues, ['cherry']);
    });

    test('reports all, some and none for a select-all check box', () {
      final selection = Oito2SelectionController(
        collection: _fruits,
        mode: Oito2SelectionMode.multiple,
      );
      expect(selection.isSomeSelected, isFalse);
      selection.select('apple');
      expect(selection.isSomeSelected, isTrue);
      selection.selectAll();
      expect(selection.isAllSelected, isTrue);
      expect(selection.isSomeSelected, isFalse);
      expect(selection.selectedValues, hasLength(4));
    });

    test('non-deselectable selections stay selected', () {
      final selection = Oito2SelectionController(
        collection: _fruits,
        deselectable: false,
        initialValues: ['apple'],
      );
      selection.toggle('apple');
      selection.select('apple', forceToggle: true);
      expect(selection.selectedValues, ['apple']);
    });

    test('none mode selects nothing', () {
      final selection = Oito2SelectionController(
        collection: _fruits,
        mode: Oito2SelectionMode.none,
      );
      selection.select('apple');
      expect(selection.isEmpty, isTrue);
    });

    test('a new collection drops the values that left it', () {
      final selection = Oito2SelectionController(
        collection: _fruits,
        mode: Oito2SelectionMode.multiple,
        initialValues: ['apple', 'plum'],
      );
      var notified = 0;
      selection.addListener(() => notified++);
      selection.collection = _fruits.filter('p');
      expect(selection.selectedValues, ['apple', 'plum']);
      selection.collection = _fruits.filter('plu');
      expect(selection.selectedValues, ['plum']);
      expect(notified, 1);
    });

    test('notifies on changes only', () {
      final selection = Oito2SelectionController(collection: _fruits);
      var notified = 0;
      selection.addListener(() => notified++);
      selection.select('apple');
      selection.select('apple');
      selection.clear();
      selection.clear();
      expect(notified, 2);
    });

    test('replace, select all and set values notify on changes only', () {
      final selection = Oito2SelectionController(
        collection: _fruits,
        mode: Oito2SelectionMode.multiple,
      );
      var notified = 0;
      selection.addListener(() => notified++);
      selection.replace('apple');
      selection.replace('apple');
      selection.selectAll();
      selection.selectAll();
      selection.setSelectedValues(['cherry', 'plum']);
      selection.setSelectedValues(['cherry', 'plum']);
      expect(notified, 3);
      selection.click('apple', extend: true);
      expect(selection.selectedValues, {'apple', 'cherry', 'pear', 'plum'});
    });
  });

  group('Oito2TreeCollection', () {
    final tree = Oito2TreeCollection<void>.fromPaths([
      'src/app.dart',
      'src/widgets/button.dart',
      'src/widgets/field.dart',
      'test/app_test.dart',
      'README.md',
    ]);

    test('builds branches and leaves from paths', () {
      expect(
        [for (final n in tree.roots) n.value],
        ['src', 'test', 'README.md'],
      );
      expect(tree.find('src/widgets')?.isBranch, isTrue);
      expect(tree.find('src/app.dart')?.isBranch, isFalse);
      expect(tree.find('src/widgets/field.dart')?.label, 'field.dart');
    });

    test('rejects duplicate values and lists leaves', () {
      expect(
        () => Oito2TreeCollection<void>([
          const Oito2TreeNode(value: 'a'),
          const Oito2TreeNode(value: 'a'),
        ]),
        throwsArgumentError,
      );
      expect(tree.leavesOf('src'), [
        'src/app.dart',
        'src/widgets/button.dart',
        'src/widgets/field.dart',
      ]);
      expect(tree.leavesOf('README.md'), ['README.md']);
      expect(tree.leavesOf('missing'), isEmpty);
    });

    test('answers parents, siblings, ancestors and depth', () {
      expect(tree.parentOf('src/widgets/button.dart'), 'src/widgets');
      expect(tree.parentOf('src'), isNull);
      expect(tree.ancestorsOf('src/widgets/field.dart'), [
        'src',
        'src/widgets',
      ]);
      expect(tree.depthOf('src/widgets/field.dart'), 2);
      expect(tree.indexPathOf('src/widgets/field.dart'), [0, 1, 1]);
      expect(tree.nodeAt([0, 1, 1])?.value, 'src/widgets/field.dart');
      expect(
        [for (final n in tree.siblingsOf('test')) n.value],
        ['src', 'test', 'README.md'],
      );
      expect(tree.descendantsOf('src'), [
        'src/app.dart',
        'src/widgets',
        'src/widgets/button.dart',
        'src/widgets/field.dart',
      ]);
    });

    test('lists and walks the visible nodes of expanded branches', () {
      final expanded = {'src'};
      expect(
        [for (final e in tree.visible(expanded)) e.node.value],
        ['src', 'src/app.dart', 'src/widgets', 'test', 'README.md'],
      );
      expect(tree.nextVisible('src/widgets', expanded), 'test');
      expect(tree.previousVisible('test', expanded), 'src/widgets');
      expect(tree.nextVisible('README.md', expanded), isNull);
    });

    test('filters keep the ancestors of matches', () {
      final found = tree.search('FIELD');
      expect(found.values, ['src', 'src/widgets', 'src/widgets/field.dart']);
    });

    test('inserts, removes, moves and replaces into new trees', () {
      final inserted = tree.insert('test', const [
        Oito2TreeNode(value: 'test/widget_test.dart'),
      ], index: 0);
      expect(
        [for (final n in inserted.childrenOf('test')) n.value],
        ['test/widget_test.dart', 'test/app_test.dart'],
      );

      final removed = tree.remove(['src/widgets']);
      expect(removed.has('src/widgets/button.dart'), isFalse);
      expect(removed.has('src/app.dart'), isTrue);

      final moved = tree.move(['README.md', 'src/app.dart'], 'test');
      expect(
        [for (final n in moved.childrenOf('test')) n.value],
        ['test/app_test.dart', 'src/app.dart', 'README.md'],
      );
      expect(moved.parentOf('README.md'), 'test');

      // Moving into a moved node or a descendant, or into an unknown node,
      // is refused instead of dropping the nodes.
      expect(() => tree.move(['src'], 'src/widgets'), throwsArgumentError);
      expect(() => tree.move(['src'], 'src'), throwsArgumentError);
      expect(() => tree.move(['README.md'], 'nope'), throwsArgumentError);
      expect(
        () => tree.insert('nope', const [Oito2TreeNode(value: 'x')]),
        throwsArgumentError,
      );

      final replaced = tree.replace(
        'README.md',
        const Oito2TreeNode(value: 'README.md', label: 'Read me'),
      );
      expect(replaced.find('README.md')?.label, 'Read me');
      expect(tree.find('README.md')?.label, 'README.md');
    });
  });

  group('Oito2AsyncListController', () {
    Oito2AsyncListController<int, int> numbers({
      List<int> Function(List<int>, Oito2SortDescriptor)? sort,
      List<Oito2AsyncListRequest<int>>? requests,
    }) {
      return Oito2AsyncListController<int, int>(
        sort: sort,
        load: (request) async {
          requests?.add(request);
          final start = request.cursor ?? 0;
          final all = [for (var i = 0; i < 25; i++) i]
              .where((i) => '$i'.contains(request.filterText))
              .toList();
          final page = all.skip(start).take(10).toList();
          final next = start + 10;
          return Oito2AsyncListPage(
            page,
            cursor: next < all.length ? next : null,
          );
        },
      );
    }

    test('loads pages until the cursor runs out', () async {
      final list = numbers();
      expect(list.hasMore, isFalse);
      await list.reload();
      expect(list.items, hasLength(10));
      expect(list.hasMore, isTrue);
      await list.loadMore();
      await list.loadMore();
      expect(list.items, hasLength(25));
      expect(list.hasMore, isFalse);
    });

    test('a failed reload stops paging with the old cursor', () async {
      var fail = false;
      final requests = <Oito2AsyncListRequest<int>>[];
      final list = Oito2AsyncListController<int, int>(
        load: (request) async {
          requests.add(request);
          if (fail) throw StateError('offline');
          return Oito2AsyncListPage([1, 2], cursor: 2);
        },
      );
      await list.reload();
      expect(list.hasMore, isTrue);
      fail = true;
      await list.setFilterText('x');
      expect(list.error, isA<StateError>());
      expect(list.stackTrace, isNotNull);
      expect(list.hasMore, isFalse);
      final sent = requests.length;
      await list.loadMore();
      expect(requests, hasLength(sent));
    });

    test('filter text reloads from the first page', () async {
      final requests = <Oito2AsyncListRequest<int>>[];
      final list = numbers(requests: requests);
      await list.reload();
      await list.setFilterText('2');
      expect(requests.last.cursor, isNull);
      expect(list.items, [2, 12, 20, 21, 22, 23, 24]);
    });

    test('a local sort reorders without loading', () async {
      final requests = <Oito2AsyncListRequest<int>>[];
      final list = numbers(
        requests: requests,
        sort: (items, sort) => sort.direction == Oito2SortDirection.descending
            ? (items..sort((a, b) => b - a))
            : (items..sort()),
      );
      await list.reload();
      await list.setSort(
        const Oito2SortDescriptor('value', Oito2SortDirection.descending),
      );
      expect(requests, hasLength(1));
      expect(list.items.first, 9);
    });

    test('a newer load supersedes a slower one', () async {
      final first = Completer<Oito2AsyncListPage<String, int>>();
      final requests = <Oito2AsyncListRequest<int>>[];
      final list = Oito2AsyncListController<String, int>(
        load: (request) {
          requests.add(request);
          return requests.length == 1
              ? first.future
              : Future.value(const Oito2AsyncListPage(['new']));
        },
      );
      final slow = list.reload();
      expect(list.isLoading, isTrue);
      await list.reload();
      expect(requests.first.isCancelled, isTrue);
      first.complete(const Oito2AsyncListPage(['old']));
      await slow;
      expect(list.items, ['new']);
      expect(list.isLoading, isFalse);
    });

    test('keeps the error of a failed load', () async {
      final list = Oito2AsyncListController<int, int>(
        load: (_) => Future.error(StateError('offline')),
      );
      await list.reload();
      expect(list.error, isA<StateError>());
      expect(list.isLoading, isFalse);
    });
  });
}
