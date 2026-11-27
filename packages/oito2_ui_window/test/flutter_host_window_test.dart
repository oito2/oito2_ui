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

import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui_window/src/flutter_host_window.dart';

/// A top-level window of the fake desktop.
typedef _Window = ({int processId, bool hasOwner, bool hostsFlutterView});

/// [TopLevelWindows] over a fixed list of windows, keyed by handle.
class _FakeTopLevelWindows implements TopLevelWindows {
  _FakeTopLevelWindows(this.windows);

  final Map<int, _Window> windows;

  @override
  int get currentProcessId => 7;

  @override
  Iterable<int> get handles => windows.keys;

  @override
  int processIdOf(int handle) => windows[handle]!.processId;

  @override
  bool hasOwner(int handle) => windows[handle]!.hasOwner;

  @override
  bool hostsFlutterView(int handle) => windows[handle]!.hostsFlutterView;
}

int _find(Map<int, _Window> windows) =>
    soleFlutterHostWindow(_FakeTopLevelWindows(windows));

void main() {
  const host = (processId: 7, hasOwner: false, hostsFlutterView: true);

  test('finds the only window of this process hosting a Flutter view', () {
    expect(
      _find({
        1: (processId: 3, hasOwner: false, hostsFlutterView: true),
        2: (processId: 7, hasOwner: false, hostsFlutterView: false),
        3: (processId: 7, hasOwner: true, hostsFlutterView: true),
        4: host,
      }),
      4,
    );
  });

  test('answers 0 when there is no such window', () {
    expect(_find({}), 0);
    expect(
      _find({1: (processId: 3, hasOwner: false, hostsFlutterView: true)}),
      0,
    );
  });

  test('answers 0 when more than one window qualifies', () {
    expect(_find({1: host, 2: host}), 0);
  });

  test('finds nothing off Windows', () {
    expect(findSoleFlutterHostWindow(), 0);
  }, testOn: '!windows');
}
