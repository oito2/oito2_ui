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

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'fake_window_controller.dart';

const _linux = Oito2Platform(
  targetPlatform: TargetPlatform.linux,
  isWeb: false,
);
const _windows = Oito2Platform(
  targetPlatform: TargetPlatform.windows,
  isWeb: false,
);
const _macos = Oito2Platform(
  targetPlatform: TargetPlatform.macOS,
  isWeb: false,
);
const _web = Oito2Platform(targetPlatform: TargetPlatform.linux, isWeb: true);
const _android = Oito2Platform(
  targetPlatform: TargetPlatform.android,
  isWeb: false,
);

/// Pumps a scaffold with [appBar] under [settings], a window scope holding
/// [controller] and the light theme for the settings platform.
Future<void> _pump(
  WidgetTester tester, {
  required Oito2SystemSettings settings,
  required PreferredSizeWidget appBar,
  Oito2WindowController? controller,
}) {
  return tester.pumpWidget(
    Oito2SystemScope(
      settings: settings,
      child: Oito2WindowScope(
        controller: controller,
        child: MaterialApp(
          theme: Oito2Theme.light(platform: settings.platform),
          home: Scaffold(appBar: appBar, body: const SizedBox()),
        ),
      ),
    ),
  );
}

/// The types of the window controls on screen, in tree order.
List<Oito2WindowControlType> _controlTypes(WidgetTester tester) => tester
    .widgetList<Oito2WindowControl>(find.byType(Oito2WindowControl))
    .map((c) => c.type)
    .toList();

void main() {
  group('Oito2TitleBar', () {
    testWidgets('lays out buttons on both sides in layout order', (
      tester,
    ) async {
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_linux),
        appBar: const Oito2TitleBar(
          title: Text('Files'),
          buttonLayout: Oito2WindowButtonLayout(
            leading: [Oito2WindowButton.close],
            trailing: [Oito2WindowButton.minimize, Oito2WindowButton.maximize],
          ),
        ),
      );
      expect(_controlTypes(tester), [
        Oito2WindowControlType.close,
        Oito2WindowControlType.minimize,
        Oito2WindowControlType.maximize,
      ]);
      final close = tester.getCenter(find.byType(Oito2WindowControl).first);
      final title = tester.getCenter(find.text('Files'));
      expect(close.dx, lessThan(title.dx));
      expect(
        tester.getSize(find.byType(Oito2TitleBar)).height,
        Oito2Sizes.titleBarHeight,
      );
    });

    testWidgets('buttons call the controller and swap maximize/restore', (
      tester,
    ) async {
      final controller = FakeWindowController();
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_linux),
        appBar: Oito2TitleBar(controller: controller),
      );
      await tester.tap(find.bySemanticsLabel('Minimize'));
      await tester.tap(find.bySemanticsLabel('Maximize'));
      await tester.pump();
      expect(find.bySemanticsLabel('Restore'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Close'));
      expect(controller.calls, ['minimize', 'toggleMaximize', 'close']);
    });

    testWidgets('onClose replaces the controller close action', (tester) async {
      final controller = FakeWindowController();
      var closed = false;
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_linux),
        appBar: Oito2TitleBar(
          controller: controller,
          onClose: () => closed = true,
        ),
      );
      await tester.tap(find.bySemanticsLabel('Close'));
      expect(closed, isTrue);
      expect(controller.calls, isEmpty);
    });

    testWidgets('dragging, double clicking and secondary clicking the bar', (
      tester,
    ) async {
      final controller = FakeWindowController(
        const Oito2WindowState(canShowMenu: true),
      );
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_linux),
        appBar: Oito2TitleBar(
          title: const Text('Files'),
          controller: controller,
        ),
      );
      final title = tester.getCenter(find.text('Files'));

      await tester.dragFrom(title, const Offset(80, 0));
      expect(controller.calls, ['startDrag']);

      await tester.tapAt(title);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(title);
      await tester.pumpAndSettle();
      expect(controller.calls.last, 'toggleMaximize');

      await tester.tapAt(title, buttons: kSecondaryMouseButton);
      await tester.pumpAndSettle();
      expect(controller.calls.last, 'showMenu');
    });

    testWidgets('secondary click skips the menu when unsupported', (
      tester,
    ) async {
      final controller = FakeWindowController();
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_linux),
        appBar: Oito2TitleBar(
          title: const Text('Files'),
          controller: controller,
        ),
      );
      await tester.tapAt(
        tester.getCenter(find.text('Files')),
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();
      expect(controller.calls, isEmpty);
    });

    testWidgets('undecorated hides the buttons and hidden hides the bar', (
      tester,
    ) async {
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_linux),
        appBar: const Oito2TitleBar(
          title: Text('Files'),
          style: Oito2TitleBarStyle.undecorated,
        ),
      );
      expect(find.byType(Oito2WindowControl), findsNothing);
      expect(find.text('Files'), findsOneWidget);

      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_linux),
        appBar: const Oito2TitleBar(
          title: Text('Files'),
          style: Oito2TitleBarStyle.hidden,
        ),
      );
      expect(find.text('Files'), findsNothing);
      expect(
        const Oito2TitleBar(style: Oito2TitleBarStyle.hidden)
            .preferredSize
            .height,
        0,
      );
    });

    testWidgets('preferredSizeOf follows the theme height and style', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          theme: Oito2Theme.light(platform: _linux)
              .copyWith(extensions: const [Oito2TitleBarThemeData(height: 52)]),
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(Oito2TitleBar.preferredSizeOf(context).height, 52);
      expect(Oito2TitleBar.preferredSizeOf(context, height: 40).height, 40);
      expect(
        Oito2TitleBar.preferredSizeOf(
          context,
          style: Oito2TitleBarStyle.hidden,
        ).height,
        0,
      );
    });

    testWidgets('dims its content while the window is inactive', (
      tester,
    ) async {
      final controller = FakeWindowController();
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_linux),
        appBar: Oito2TitleBar(
          title: const Text('Files'),
          controller: controller,
        ),
      );
      double opacity() =>
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
      expect(opacity(), 1);
      controller.value = const Oito2WindowState(isActive: false);
      await tester.pumpAndSettle();
      expect(opacity(), 0.7);
    });

    testWidgets('uses the theme title bar colors', (tester) async {
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_linux),
        appBar: const Oito2TitleBar(title: Text('Files')),
      );
      final box = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Oito2TitleBar),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.color, Oito2ColorTheme.light().chrome.titleBar);
    });
  });

  group('Oito2WindowTitleBar', () {
    testWidgets('Linux uses the system style and layout', (tester) async {
      final settings =
          Oito2SystemSettings.fallback(
            _linux,
            desktopEnvironment: Oito2DesktopEnvironment.kde,
          ).copyWith(
            windowButtonLayout: Oito2WindowButtonLayout.parseKde(
              buttonsOnLeft: 'X',
              buttonsOnRight: 'IA',
            ),
          );
      final controller = FakeWindowController();
      await _pump(
        tester,
        settings: settings,
        controller: controller,
        appBar: const Oito2WindowTitleBar(
          title: Text('Files'),
          platform: _linux,
        ),
      );
      final controls = tester.widgetList<Oito2WindowControl>(
        find.byType(Oito2WindowControl),
      );
      expect(controls.map((c) => c.style).toSet(), {
        Oito2WindowControlStyle.breeze,
      });
      expect(_controlTypes(tester), [
        Oito2WindowControlType.close,
        Oito2WindowControlType.minimize,
        Oito2WindowControlType.maximize,
      ]);
      await tester.tap(find.bySemanticsLabel('Close'));
      expect(controller.calls, ['close']);
    });

    for (final (sides, expected) in [
      (Oito2WindowButtonSides.leading, [Oito2WindowControlType.close]),
      (
        Oito2WindowButtonSides.trailing,
        [Oito2WindowControlType.minimize, Oito2WindowControlType.maximize],
      ),
    ]) {
      testWidgets('split bars show only the ${sides.name} buttons', (
        tester,
      ) async {
        final settings =
            Oito2SystemSettings.fallback(
              _linux,
              desktopEnvironment: Oito2DesktopEnvironment.kde,
            ).copyWith(
              windowButtonLayout: Oito2WindowButtonLayout.parseKde(
                buttonsOnLeft: 'X',
                buttonsOnRight: 'IA',
              ),
            );
        await _pump(
          tester,
          settings: settings,
          controller: FakeWindowController(),
          appBar: Oito2WindowTitleBar(
            title: const Text('Files'),
            platform: _linux,
            buttonSides: sides,
            backgroundColor: const Color(0xFF123456),
          ),
        );
        expect(_controlTypes(tester), expected);
        expect(
          tester
              .widget<Oito2TitleBar>(find.byType(Oito2TitleBar))
              .backgroundColor,
          const Color(0xFF123456),
        );
      });
    }

    testWidgets('macOS keeps the traffic light room only on the leading bar', (
      tester,
    ) async {
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_macos),
        controller: FakeWindowController(),
        appBar: const Oito2WindowTitleBar(
          leading: Icon(Icons.menu),
          platform: _macos,
          buttonSides: Oito2WindowButtonSides.trailing,
        ),
      );
      expect(tester.getTopLeft(find.byIcon(Icons.menu)).dx, lessThan(72));
    });

    testWidgets('Windows draws Windows-style buttons', (tester) async {
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_windows),
        controller: FakeWindowController(),
        appBar: const Oito2WindowTitleBar(platform: _windows),
      );
      final styles = tester
          .widgetList<Oito2WindowControl>(find.byType(Oito2WindowControl))
          .map((c) => c.style)
          .toSet();
      expect(styles, {Oito2WindowControlStyle.windows});
    });

    testWidgets('macOS leaves room for the native traffic lights', (
      tester,
    ) async {
      final controller = FakeWindowController();
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_macos),
        controller: controller,
        appBar: const Oito2WindowTitleBar(
          title: Text('Files'),
          leading: Icon(Icons.menu),
          platform: _macos,
        ),
      );
      expect(find.byType(Oito2WindowControl), findsNothing);
      expect(tester.getTopLeft(find.byIcon(Icons.menu)).dx, greaterThan(72));

      controller.value = const Oito2WindowState(isFullScreen: true);
      await tester.pump();
      expect(tester.getTopLeft(find.byIcon(Icons.menu)).dx, lessThan(72));
    });

    testWidgets('the web shows no window buttons and no drag area', (
      tester,
    ) async {
      final controller = FakeWindowController();
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_web),
        controller: controller,
        appBar: const Oito2WindowTitleBar(title: Text('Files'), platform: _web),
      );
      expect(find.text('Files'), findsOneWidget);
      expect(find.byType(Oito2WindowControl), findsNothing);
      expect(find.byType(Oito2TitleBarGestureDetector), findsNothing);
      expect(
        tester.getSize(find.byType(Oito2TitleBar)).height,
        Oito2Sizes.titleBarHeight,
      );
    });

    testWidgets('touch platforms get a regular AppBar', (tester) async {
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_android),
        appBar: const Oito2WindowTitleBar(
          title: Text('Files'),
          platform: _android,
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Oito2TitleBar), findsNothing);
      expect(
        const Oito2WindowTitleBar(platform: _android).preferredSize,
        const Size.fromHeight(kToolbarHeight),
      );
    });

    testWidgets('works without a window controller', (tester) async {
      await _pump(
        tester,
        settings: Oito2SystemSettings.fallback(_linux),
        appBar: const Oito2WindowTitleBar(
          title: Text('Files'),
          platform: _linux,
        ),
      );
      expect(find.byType(Oito2WindowControl), findsNWidgets(3));
      await tester.tap(find.bySemanticsLabel('Close'));
      expect(tester.takeException(), isNull);
    });
  });

  group('Oito2DialogTitleBar', () {
    testWidgets('its close button pops the dialog', (tester) async {
      await tester.pumpWidget(
        Oito2SystemScope(
          settings: Oito2SystemSettings.fallback(_linux),
          child: MaterialApp(
            theme: Oito2Theme.light(platform: _linux),
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const Dialog(
                    child: Oito2DialogTitleBar(title: Text('Preferences')),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Preferences'), findsOneWidget);
      expect(_controlTypes(tester), [Oito2WindowControlType.close]);

      await tester.tap(find.byType(Oito2WindowControl));
      await tester.pumpAndSettle();
      expect(find.text('Preferences'), findsNothing);
    });

    testWidgets('shows a leading icon before the title', (tester) async {
      await tester.pumpWidget(
        Oito2SystemScope(
          settings: Oito2SystemSettings.fallback(_linux),
          child: MaterialApp(
            theme: Oito2Theme.light(platform: _linux),
            home: Scaffold(
              body: Oito2DialogTitleBar(
                leading: const Oito2AnimatedIcon(Oito2AnimatedIcons.ok),
                title: const Text('Saved'),
                onClose: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final icon = tester.getRect(find.byType(Oito2AnimatedIcon));
      final title = tester.getRect(find.text('Saved'));
      expect(icon.right, lessThanOrEqualTo(title.left));
    });

    testWidgets('falls back to the GNOME style without system buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        Oito2SystemScope(
          settings: Oito2SystemSettings.fallback(_web),
          child: MaterialApp(
            home: Scaffold(
              body: Oito2DialogTitleBar(
                title: const Text('About'),
                onClose: () {},
              ),
            ),
          ),
        ),
      );
      final control = tester.widget<Oito2WindowControl>(
        find.byType(Oito2WindowControl),
      );
      expect(control.style, Oito2WindowControlStyle.gnome);
    });
  });
}
