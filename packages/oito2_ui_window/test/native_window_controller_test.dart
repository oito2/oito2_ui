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

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oito2_ui/oito2_ui.dart';
import 'package:oito2_ui_window/oito2_ui_window.dart';
import 'package:oito2_ui_window/src/native_window_controller.dart';
import 'package:oito2_ui_window/src/native_window_port.dart';

/// A [NativeWindowPort] that records the calls it gets and lets the tests
/// send window events to its listeners.
class _FakeWindowPort implements NativeWindowPort {
  final List<String> calls = [];
  bool maximized = false;

  /// Answers the state queries in place of the defaults when set.
  Future<bool> Function(String method)? query;

  final List<NativeWindowListener> listeners = [];

  Future<bool> _query(String method, bool value) async {
    calls.add(method);
    final query = this.query;
    if (query != null) return query(method);
    return value;
  }

  Future<void> _call(String method) async => calls.add(method);

  /// Sends [event] to the listeners and returns what they return.
  List<FutureOr<void>> emit(NativeWindowEvent event) => [
    for (final listener in List.of(listeners)) listener(event),
  ];

  /// Sends a close request to the listeners and completes with whether one
  /// of them cancelled it, once every listener has finished with it.
  Future<bool> requestClose() async {
    var cancelled = false;
    final results = emit(NativeWindowCloseRequested(() => cancelled = true));
    for (final result in results) {
      await result;
    }
    return cancelled;
  }

  @override
  Future<bool> isMaximized() => _query('isMaximized', maximized);

  @override
  Future<bool> isFullScreen() => _query('isFullScreen', false);

  @override
  Future<bool> isFocused() => _query('isFocused', true);

  @override
  Future<void> minimize() => _call('minimize');

  @override
  Future<void> maximize() => _call('maximize');

  @override
  Future<void> unmaximize() => _call('unmaximize');

  @override
  Future<void> close() => _call('close');

  @override
  Future<void> startDragging() => _call('startDragging');

  @override
  Future<void> showSystemMenu() => _call('showSystemMenu');

  @override
  void Function() addListener(NativeWindowListener listener) {
    listeners.add(listener);
    return () => listeners.remove(listener);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeWindowPort port;
  late List<String> calls;

  setUp(() {
    port = _FakeWindowPort();
    calls = port.calls;
  });

  Future<void> sendEvent(NativeWindowEvent event) async => port.emit(event);

  Future<Oito2NativeWindowController> attach({bool canShowMenu = true}) async {
    final controller = await attachNativeWindowController(
      port,
      canShowMenu: canShowMenu,
    );
    addTearDown(controller.dispose);
    return controller;
  }

  test('attach reads the initial window state', () async {
    port.maximized = true;
    final controller = await attach();
    expect(
      controller.state.value,
      const Oito2WindowState(isMaximized: true, canShowMenu: true),
    );
    expect(calls, containsAll(['isMaximized', 'isFullScreen', 'isFocused']));
  });

  test('actions call the native window', () async {
    final controller = await attach();
    calls.clear();
    await controller.minimize();
    await controller.close();
    await controller.startDrag();
    await controller.showMenu();
    expect(calls, ['minimize', 'close', 'startDragging', 'showSystemMenu']);
  });

  test('toggleMaximize maximizes or restores', () async {
    final controller = await attach();
    calls.clear();
    await controller.toggleMaximize();
    expect(calls, ['isMaximized', 'maximize']);

    port.maximized = true;
    calls.clear();
    await controller.toggleMaximize();
    expect(calls, ['isMaximized', 'unmaximize']);
  });

  test('showMenu does nothing when the platform has no window menu', () async {
    final controller = await attach(canShowMenu: false);
    calls.clear();
    await controller.showMenu();
    expect(calls, isEmpty);
  });

  test('window events update the state', () async {
    final controller = await attach();

    await sendEvent(const NativeWindowMaximized());
    expect(controller.state.value.isMaximized, isTrue);
    // Leaving the maximized state comes as a restore, which re-reads it.
    port.maximized = false;
    await sendEvent(const NativeWindowRestored());
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.value.isMaximized, isFalse);

    await sendEvent(const NativeWindowBlurred());
    expect(controller.state.value.isActive, isFalse);
    await sendEvent(const NativeWindowFocused());
    expect(controller.state.value.isActive, isTrue);

    await sendEvent(const NativeWindowEnteredFullScreen());
    expect(controller.state.value.isFullScreen, isTrue);
    await sendEvent(const NativeWindowExitedFullScreen());
    expect(controller.state.value.isFullScreen, isFalse);
  });

  test('restore re-reads the window state', () async {
    final controller = await attach();
    port.maximized = true;
    calls.clear();
    await sendEvent(const NativeWindowRestored());
    await Future<void>.delayed(Duration.zero);
    expect(calls, contains('isMaximized'));
    expect(controller.state.value.isMaximized, isTrue);
  });

  test('a failed refresh keeps the last state', () async {
    final controller = await attach();
    port.query = (method) async {
      throw const NativeWindowUnavailableException();
    };
    await expectLater(controller.refresh(), completes);
    expect(controller.state.value.isActive, isTrue);
  });

  test('a refresh that ends after dispose changes nothing', () async {
    final controller = await attachNativeWindowController(
      port,
      canShowMenu: true,
    );
    final gate = Completer<void>();
    port.query = (method) async {
      await gate.future;
      return false;
    };
    final refresh = controller.refresh();
    controller.dispose();
    gate.complete();
    await expectLater(refresh, completes);
  });

  test('a window event overtakes a refresh in flight', () async {
    final controller = await attach();
    final gate = Completer<void>();
    port.query = (method) async {
      await gate.future;
      return false;
    };
    final refresh = controller.refresh();
    await sendEvent(const NativeWindowMaximized());
    gate.complete();
    await refresh;
    expect(controller.state.value.isMaximized, isTrue);
  });

  test('without a native window, initialization returns null', () async {
    expect(await Oito2Window.ensureInitialized(), isNull);
  });

  test('close handlers hold back the native close while added', () async {
    final controller = await attach();
    final gate = Completer<bool>();
    Future<bool> waiting() => gate.future;
    controller.addCloseHandler(waiting);

    // The request stays pending until the handler answers.
    var settled = false;
    final request = port.requestClose()..then((_) => settled = true);
    await Future<void>.delayed(Duration.zero);
    expect(settled, isFalse);
    gate.complete(false);
    expect(await request, isTrue);

    // Without handlers the request goes through at once.
    controller.removeCloseHandler(waiting);
    expect(await port.requestClose(), isFalse);
  });

  test('a close request asks the handlers before closing', () async {
    final controller = await attach();
    final asked = <String>[];
    var allowFirst = false;
    controller
      ..addCloseHandler(() async {
        asked.add('first');
        return allowFirst;
      })
      ..addCloseHandler(() async {
        asked.add('second');
        return true;
      });

    expect(await port.requestClose(), isTrue);
    expect(asked, ['second', 'first']);

    allowFirst = true;
    asked.clear();
    expect(await port.requestClose(), isFalse);
    expect(asked, ['second', 'first']);
  });

  test('a close request without handlers leaves the window alone', () async {
    await attach();
    calls.clear();
    expect(await port.requestClose(), isFalse);
    expect(calls, isEmpty);
  });

  test('a close request while the handlers are asked is ignored', () async {
    final controller = await attach();
    final gate = Completer<bool>();
    var asked = 0;
    controller.addCloseHandler(() {
      asked++;
      return gate.future;
    });
    final first = port.requestClose();
    final second = port.requestClose();
    // The second request is vetoed at once; the first one decides.
    expect(await second, isTrue);
    gate.complete(true);
    expect(await first, isFalse);
    expect(asked, 1);
  });

  test('a close handler that throws keeps the window open and reports '
      'the error', () async {
    final controller = await attach();
    final reported = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = reported.add;
    addTearDown(() => FlutterError.onError = previous);
    var asked = 0;
    var fail = true;
    controller
      ..addCloseHandler(() async {
        asked++;
        return true;
      })
      ..addCloseHandler(() async {
        if (fail) throw StateError('broken handler');
        return true;
      });

    expect(await port.requestClose(), isTrue);
    expect(reported.single.exception, isA<StateError>());
    expect(reported.single.library, 'oito2_ui_window');
    expect(asked, 0);

    // The next close request asks the handlers again.
    fail = false;
    expect(await port.requestClose(), isFalse);
    expect(asked, 1);
  });

  test('a close handler that answers after dispose keeps the window '
      'open', () async {
    final controller = await attachNativeWindowController(
      port,
      canShowMenu: true,
    );
    final gate = Completer<bool>();
    controller.addCloseHandler(() => gate.future);
    final request = port.requestClose();
    controller.dispose();
    gate.complete(true);
    expect(await request, isTrue);
  });

  test('dispose lets the native close through again', () async {
    final controller = await attach();
    controller.addCloseHandler(() async => false);
    expect(await port.requestClose(), isTrue);
    controller.dispose();
    calls.clear();
    expect(await port.requestClose(), isFalse);
    expect(calls, isEmpty);
    // Disposing again does nothing.
    controller.dispose();
  });

  test('dispose stops listening to window events', () async {
    final controller = await attachNativeWindowController(
      port,
      canShowMenu: true,
    );
    expect(port.listeners, hasLength(1));
    controller.dispose();
    expect(port.listeners, isEmpty);
  });
}
