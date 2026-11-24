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

// Writes the results of the pure rules behind oito2_ui widgets (info
// severity, alert stack order, sort cycle, usage bar tone, column widths,
// breadcrumb collapse and week schedule layout) as a JSON fixture.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'support.dart';

/// A short name for the info types in the alert cases.
typedef _I = Oito2InfoType;

/// Alert stacks: the types in the order they were added, the visible
/// limit, whether the stack is expanded and the indexes leaving.
const alertCases = <(List<Oito2InfoType>, int, bool, Set<int>)>[
  ([], 3, false, {}),
  ([_I.information], 3, false, {}),
  (
    [_I.success, _I.warning, _I.danger, _I.information, _I.important],
    3,
    false,
    {},
  ),
  (
    [_I.success, _I.warning, _I.danger, _I.information, _I.important],
    3,
    true,
    {},
  ),
  ([_I.warning, _I.warning, _I.warning, _I.warning], 2, false, {}),
  ([_I.information, _I.danger, _I.information, _I.danger], 1, false, {}),
  ([_I.information, _I.danger, _I.information, _I.danger], 4, false, {}),
  ([_I.information, _I.danger, _I.information, _I.danger], 9, false, {}),
  ([_I.danger, _I.warning, _I.information, _I.success], 2, false, {0}),
  ([_I.danger, _I.warning, _I.information, _I.success], 2, false, {3}),
  ([_I.danger, _I.warning, _I.information, _I.success], 2, false, {1, 2}),
  ([_I.danger, _I.warning, _I.information, _I.success], 2, true, {0, 3}),
  (
    [_I.success, _I.important, _I.success, _I.important, _I.warning],
    3,
    false,
    {},
  ),
];

/// Usage bars: value, total, warning threshold and danger threshold.
const usageCases = <(double, double, double, double)>[
  (0, 1, 0.7, 0.9),
  (0.5, 1, 0.7, 0.9),
  (0.6999, 1, 0.7, 0.9),
  (0.7, 1, 0.7, 0.9),
  (0.8999, 1, 0.7, 0.9),
  (0.9, 1, 0.7, 0.9),
  (1, 1, 0.7, 0.9),
  (1.0001, 1, 0.7, 0.9),
  (1.5, 1, 0.7, 0.9),
  (-0.2, 1, 0.7, 0.9),
  (7, 10, 0.7, 0.9),
  (9, 10, 0.7, 0.9),
  (6, 10, 0.7, 0.9),
  (12, 10, 0.7, 0.9),
  (5, 0, 0.7, 0.9),
  (5, -1, 0.7, 0.9),
  (0, 0, 0.7, 0.9),
  (12000000000, 15000000000, 0.7, 0.9),
  (14000000000, 15000000000, 0.7, 0.9),
  (0.5, 1, 0.5, 0.8),
  (0.49, 1, 0.5, 0.8),
  (0.8, 1, 0.5, 0.8),
  (0.95, 1, 0.9, 1.2),
  (1.05, 1, 0.9, 1.2),
  (0.95, 1, 1.0, 0.9),
  (0.5, 1, 0, 1),
];

/// A column of the width cases: a fixed width, or flex shares and a
/// minimum.
typedef ColumnSpec = (String id, double? fixed, double flex, double min);

/// Column width cases: columns, available width and overrides.
const widthCases = <(List<ColumnSpec>, double, Map<String, double>)>[
  ([('a', null, 1, 0)], 300, {}),
  ([('a', null, 1, 0), ('b', null, 1, 0), ('c', null, 1, 0)], 100, {}),
  ([('a', null, 1, 0), ('b', null, 2, 0)], 300, {}),
  ([('a', 100, 1, 0), ('b', null, 1, 0)], 300, {}),
  ([('a', 100, 1, 0), ('b', 50, 1, 0)], 300, {}),
  ([('a', 100, 1, 0), ('b', null, 1, 80), ('c', null, 3, 0)], 300, {}),
  ([('a', 100, 1, 0), ('b', null, 1, 80), ('c', null, 3, 0)], 180, {}),
  ([('a', 200, 1, 0), ('b', null, 1, 60)], 150, {}),
  ([('a', 200, 1, 0), ('b', 200, 1, 0)], 300, {}),
  ([('a', null, 1, 0), ('b', null, 1, 0)], 0, {}),
  ([('a', 100, 1, 0), ('b', null, 1, 0)], 300, {'a': 160}),
  ([('a', null, 1, 0), ('b', null, 1, 0)], 300, {'a': 120}),
  ([('a', null, 2, 40), ('b', null, 1, 0)], 300, {'b': 250}),
  ([('a', 100, 1, 0), ('b', null, 1, 0)], 300, {'zzz': 50}),
  ([('a', 100, 1, 0), ('b', null, 1.5, 0), ('c', null, 0.5, 30)], 420.5, {}),
];

/// Breadcrumb cases: segment widths, maximum width, "…" button width,
/// least segment width and edit width.
const breadcrumbCases = <(List<double>, double, double, double, double)>[
  ([], 100, 28, 0, 0),
  ([80], 200, 28, 0, 0),
  ([300], 200, 28, 0, 0),
  ([100, 100, 100], 340, 28, 0, 0),
  ([100, 100, 100], 339, 28, 0, 0),
  ([100, 100, 100], 268, 28, 0, 0),
  ([100, 100, 100], 148, 28, 0, 0),
  ([100, 100, 100], 120, 28, 0, 0),
  ([100, 100, 100, 100], 460, 28, 0, 0),
  ([100, 100, 100, 100], 388, 28, 0, 0),
  ([100, 100, 100, 100], 387, 28, 0, 0),
  ([100, 100, 100, 100], 268, 28, 0, 0),
  ([100, 100, 100, 100], 267, 28, 0, 0),
  ([60, 80, 120, 90, 70, 150], 500, 28, 0, 0),
  ([60, 80, 120, 90, 70, 150], 400, 28, 0, 0),
  ([60, 80, 120, 90, 70, 150], 300, 28, 0, 0),
  ([60, 80, 120, 90, 70, 150], 100, 28, 0, 0),
  ([10, 10, 100], 196, 28, 0, 32),
  ([10, 10, 100], 196, 48, 48, 52),
  ([10, 10, 100], 300, 48, 48, 52),
  ([100, 100], 220, 28, 0, 0),
  ([100, 100], 219, 28, 0, 0),
  ([100, 100], 20, 28, 0, 0),
];

/// Week schedule index cases: day, slot and slots a day.
const indexCases = <(int, int, int)>[
  (0, 0, 24),
  (0, 23, 24),
  (1, 0, 24),
  (6, 23, 24),
  (3, 12, 24),
  (0, 47, 48),
  (6, 47, 48),
  (2, 5, 48),
  (4, 0, 1),
  (6, 0, 1),
];

Map<String, Object?>? sortJson(Oito2SortDescriptor? sort) => sort == null
    ? null
    : {'column': sort.column, 'direction': sort.direction.name};

Map<String, Object> exportAlerts() => {
  'infoSeverity': [
    for (final type in Oito2InfoType.values)
      {'type': type.name, 'severity': type.severity},
  ],
  'alertStack': [
    for (final (types, maxVisible, expanded, leaving) in alertCases)
      () {
        final (:visible, :hidden) = Oito2AlertStack.arrange(
          types,
          maxVisible: maxVisible,
          expanded: expanded,
          leaving: leaving,
        );
        return {
          'types': [for (final type in types) type.name],
          'maxVisible': maxVisible,
          'expanded': expanded,
          'leaving': leaving.toList()..sort(),
          'visible': visible,
          'hidden': hidden,
        };
      }(),
  ],
};

List<Map<String, Object?>> exportSortCycle() {
  const states = [
    null,
    Oito2SortDescriptor('name'),
    Oito2SortDescriptor('name', Oito2SortDirection.descending),
    Oito2SortDescriptor('size'),
    Oito2SortDescriptor('size', Oito2SortDirection.descending),
  ];
  return [
    for (final current in states)
      {
        'current': sortJson(current),
        'activated': 'name',
        'next': sortJson(Oito2DataTable.nextSort(current, 'name')),
      },
  ];
}

List<Map<String, Object?>> exportUsage() => [
  for (final (value, total, warningAt, dangerAt) in usageCases)
    () {
      final bar = Oito2UsageBar(
        value: value,
        total: total,
        warningAt: warningAt,
        dangerAt: dangerAt,
      );
      return {
        'value': value,
        'total': total,
        'warningAt': warningAt,
        'dangerAt': dangerAt,
        'fraction': bar.fraction,
        'tone': bar.tone?.name,
      };
    }(),
];

List<Map<String, Object>> exportWidths() => [
  for (final (specs, available, overrides) in widthCases)
    {
      'columns': [
        for (final (id, fixed, flex, min) in specs)
          {
            'id': id,
            'width': fixed == null
                ? {'flex': flex, 'min': min}
                : {'fixed': fixed},
          },
      ],
      'available': available,
      'overrides': overrides,
      'widths': Oito2TableColumn.resolveWidths(
        [
          for (final (id, fixed, flex, min) in specs)
            Oito2TableColumn<Object?>(
              id: id,
              label: id,
              width: fixed == null
                  ? Oito2ColumnWidth.flex(flex, min: min)
                  : Oito2ColumnWidth.fixed(fixed),
            ),
        ],
        available,
        overrides: overrides,
      ),
    },
];

Map<String, Object> exportBreadcrumb() => {
  'separatorWidth': Oito2Breadcrumb.separatorWidth,
  'buttonWidth': Oito2Breadcrumb.buttonWidth,
  'editGap': Oito2Spacing.xs,
  'minTouchTarget': Oito2Sizes.minTouchTarget,
  'cases': [
    for (final (widths, maxWidth, buttonWidth, minSegment, edit)
        in breadcrumbCases)
      () {
        final (
          :collapsedStart,
          :collapsedEnd,
          :lastTruncated,
        ) = Oito2Breadcrumb.collapse(
          widths,
          maxWidth: maxWidth,
          buttonWidth: buttonWidth,
          minSegmentWidth: minSegment,
          editWidth: edit,
        );
        bool hidden(int i) => i >= collapsedStart && i < collapsedEnd;
        return {
          'widths': widths,
          'maxWidth': maxWidth,
          'buttonWidth': buttonWidth,
          'minSegmentWidth': minSegment,
          'editWidth': edit,
          'visible': [
            for (var i = 0; i < widths.length; i++)
              if (!hidden(i)) i,
          ],
          'collapsed': [
            for (var i = 0; i < widths.length; i++)
              if (hidden(i)) i,
          ],
          'lastTruncated': lastTruncated,
        };
      }(),
  ],
};

Map<String, Object> exportWeekSchedule(
  Map<String, MaterialLocalizations> locales,
) => {
  'indexOf': [
    for (final (day, slot, slotsPerDay) in indexCases)
      {
        'day': day,
        'slot': slot,
        'slotsPerDay': slotsPerDay,
        'index': Oito2WeekScheduleGrid.indexOf(
          day,
          slot,
          slotsPerDay: slotsPerDay,
        ),
      },
  ],
  'dayOrder': {
    for (final MapEntry(key: name, value: m) in locales.entries)
      name: {
        'firstDayOfWeekIndex': m.firstDayOfWeekIndex,
        'days': [
          for (var row = 0; row < 7; row++)
            Oito2WeekScheduleGrid.dayOfRow(
              row,
              firstDayOfWeekIndex: m.firstDayOfWeekIndex,
            ),
        ],
      },
  },
};

void main() {
  test('exports the widget rules', () async {
    final locales = <String, MaterialLocalizations>{
      'en': const DefaultMaterialLocalizations(),
      'en-GB': await GlobalMaterialLocalizations.delegate.load(
        const Locale('en', 'GB'),
      ),
      'pt-BR': await GlobalMaterialLocalizations.delegate.load(
        const Locale('pt', 'BR'),
      ),
    };
    final file = writeFixture('widgets.json', {
      ...exportAlerts(),
      'sortCycle': exportSortCycle(),
      'usageBar': exportUsage(),
      'columnWidths': exportWidths(),
      'breadcrumb': exportBreadcrumb(),
      'weekSchedule': exportWeekSchedule(locales),
    });
    expect(file.existsSync(), isTrue);
  });
}
