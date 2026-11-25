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
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import '../window/window_controller.dart';
import 'form.dart';
import 'widget_helpers.dart';

/// The answer to the dialog of [showOito2UnsavedChangesDialog].
enum Oito2UnsavedChangesAction {
  /// Stay and keep the changes.
  keepEditing,

  /// Leave and drop the changes.
  discard,

  /// Save the changes, then leave.
  save,
}

/// Asks whether to leave unsaved changes, in a dialog with the localized
/// "Keep editing" and "Discard" buttons and, when [canSave], "Save".
///
/// "Keep editing" takes the focus, so Enter doesn't drop the changes.
/// Returns the picked action, or [Oito2UnsavedChangesAction.keepEditing]
/// when the dialog is dismissed.
Future<Oito2UnsavedChangesAction> showOito2UnsavedChangesDialog(
  BuildContext context, {
  bool canSave = false,
}) async {
  final action = await showDialog<Oito2UnsavedChangesAction>(
    context: context,
    builder: (context) => _UnsavedChangesDialog(canSave: canSave),
  );
  return action ?? Oito2UnsavedChangesAction.keepEditing;
}

/// The dialog of [showOito2UnsavedChangesDialog].
class _UnsavedChangesDialog extends StatelessWidget {
  const _UnsavedChangesDialog({required this.canSave});

  final bool canSave;

  @override
  Widget build(BuildContext context) {
    final strings = Oito2Localizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    void pick(Oito2UnsavedChangesAction action) =>
        Navigator.pop(context, action);
    return AlertDialog(
      title: Text(strings.unsavedChangesTitle),
      content: Text(strings.unsavedChangesMessage),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => pick(Oito2UnsavedChangesAction.keepEditing),
          child: Text(strings.keepEditing),
        ),
        if (canSave) ...[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: semanticColorsOf(context).errorText,
            ),
            onPressed: () => pick(Oito2UnsavedChangesAction.discard),
            child: Text(strings.discardChanges),
          ),
          FilledButton(
            onPressed: () => pick(Oito2UnsavedChangesAction.save),
            child: Text(strings.saveChanges),
          ),
        ] else
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => pick(Oito2UnsavedChangesAction.discard),
            child: Text(strings.discardChanges),
          ),
      ],
    );
  }
}

/// Asked before the user leaves a part of the app; completes with whether
/// the user may leave.
typedef Oito2LeaveHandler = Future<bool> Function();

/// Collects the [Oito2UnsavedChangesGuard]s with unsaved changes below an
/// [Oito2UnsavedChangesScope], so a shell that switches pages without
/// popping a route can ask them first.
///
/// [Oito2MasterDetailPage] and [Oito2NavigationPage] ask the closest scope
/// before they switch to another item; call [confirmLeave] before other
/// switches, such as from a command or an address change.
class Oito2UnsavedChangesController {
  /// Creates a controller with no handlers.
  Oito2UnsavedChangesController();

  final List<Oito2LeaveHandler> _handlers = [];

  /// Whether a guard with unsaved changes is registered.
  bool get hasUnsavedChanges => _handlers.isNotEmpty;

  /// Adds [handler], asked by [confirmLeave].
  void addHandler(Oito2LeaveHandler handler) => _handlers.add(handler);

  /// Removes [handler], added by [addHandler].
  void removeHandler(Oito2LeaveHandler handler) => _handlers.remove(handler);

  /// Asks every handler, the last added first, until one refuses.
  ///
  /// Returns true when there are no handlers or all of them allow
  /// leaving.
  Future<bool> confirmLeave() async {
    for (final handler in _handlers.reversed.toList()) {
      if (!await handler()) return false;
    }
    return true;
  }
}

/// Provides an [Oito2UnsavedChangesController] to the guards and the
/// page switchers below it.
class Oito2UnsavedChangesScope extends InheritedWidget {
  /// Creates a scope that provides [controller] to [child].
  const Oito2UnsavedChangesScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The controller the guards register with.
  final Oito2UnsavedChangesController controller;

  /// Returns the controller of the closest enclosing scope, or null when
  /// there is none.
  ///
  /// With [listen], [context] rebuilds when the scope gets another
  /// controller.
  static Oito2UnsavedChangesController? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<Oito2UnsavedChangesScope>()
        : context.getInheritedWidgetOfExactType<Oito2UnsavedChangesScope>();
    return scope?.controller;
  }

  @override
  bool updateShouldNotify(Oito2UnsavedChangesScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Asks before the user leaves [child] while it has unsaved changes.
///
/// The changes come from [form], dirty while any of its fields changed,
/// or from [isDirty]. While there are changes, the guard:
///
/// - blocks popping its route, such as with a back button, and asks with
///   [showOito2UnsavedChangesDialog] instead, popping only when the user
///   discards the changes or [onSave] saves them;
/// - registers with the closest [Oito2UnsavedChangesScope], which page
///   switchers ask before switching;
/// - registers with the window controller of the closest
///   [Oito2WindowScope] when it implements [Oito2WindowCloseGuard], so
///   closing the window asks too.
///
/// With [onSave], the dialog offers "Save": the guard calls it and leaves
/// only when it completes with true, so a save that fails validation
/// keeps the page.
class Oito2UnsavedChangesGuard extends StatefulWidget {
  /// Creates a guard over [child].
  ///
  /// Throws an [AssertionError] in debug mode unless exactly one of [form]
  /// and [isDirty] is given.
  const Oito2UnsavedChangesGuard({
    super.key,
    this.form,
    this.isDirty,
    this.onSave,
    required this.child,
  }) : assert((form == null) != (isDirty == null));

  /// The form whose changes are guarded.
  final Oito2FormController? form;

  /// Tells whether there are unsaved changes, in place of [form].
  final ValueListenable<bool>? isDirty;

  /// Saves the changes and completes with whether they were saved; the
  /// dialog offers "Save" only when it is given.
  final Future<bool> Function()? onSave;

  /// The guarded content.
  final Widget child;

  @override
  State<Oito2UnsavedChangesGuard> createState() =>
      _Oito2UnsavedChangesGuardState();
}

class _Oito2UnsavedChangesGuardState extends State<Oito2UnsavedChangesGuard> {
  bool _dirty = false;
  bool _asking = false;
  Oito2UnsavedChangesController? _scope;
  Oito2WindowCloseGuard? _window;

  /// The scope and window the handler is registered with, if any.
  Oito2UnsavedChangesController? _registeredScope;
  Oito2WindowCloseGuard? _registeredWindow;

  Listenable get _source => widget.form ?? widget.isDirty!;

  bool get _readDirty => widget.form?.isDirty ?? widget.isDirty!.value;

  @override
  void initState() {
    super.initState();
    _source.addListener(_onChanged);
    _dirty = _readDirty;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = Oito2UnsavedChangesScope.maybeOf(context);
    _window = switch (Oito2WindowScope.maybeOf(context)) {
      final Oito2WindowCloseGuard guard => guard,
      _ => null,
    };
    _sync();
  }

  @override
  void didUpdateWidget(Oito2UnsavedChangesGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.form ?? oldWidget.isDirty!;
    if (old != _source) {
      old.removeListener(_onChanged);
      _source.addListener(_onChanged);
    }
    _dirty = _readDirty;
    _sync();
  }

  @override
  void dispose() {
    _source.removeListener(_onChanged);
    _dirty = false;
    _sync();
    super.dispose();
  }

  /// Follows a change of the dirty state.
  void _onChanged() {
    final dirty = _readDirty;
    if (dirty == _dirty) return;
    setState(() => _dirty = dirty);
    _sync();
  }

  /// Registers the handler with the scope and the window while there are
  /// changes, and removes it otherwise.
  void _sync() {
    final scope = _dirty ? _scope : null;
    if (!identical(scope, _registeredScope)) {
      _registeredScope?.removeHandler(_confirm);
      _registeredScope = scope?..addHandler(_confirm);
    }
    final window = _dirty ? _window : null;
    if (!identical(window, _registeredWindow)) {
      _registeredWindow?.removeCloseHandler(_confirm);
      _registeredWindow = window?..addCloseHandler(_confirm);
    }
  }

  /// Asks whether to leave and completes with the answer: true without
  /// changes, after discarding, or after a successful save; false while
  /// the dialog is already open.
  Future<bool> _confirm() async {
    if (!mounted || !_readDirty) return true;
    if (_asking) return false;
    _asking = true;
    try {
      final onSave = widget.onSave;
      final action = await showOito2UnsavedChangesDialog(
        context,
        canSave: onSave != null,
      );
      return switch (action) {
        Oito2UnsavedChangesAction.keepEditing => false,
        Oito2UnsavedChangesAction.discard => true,
        Oito2UnsavedChangesAction.save => await onSave!(),
      };
    } finally {
      _asking = false;
    }
  }

  /// Asks before a blocked pop and pops with [result] when the user
  /// leaves.
  Future<void> _onPop(bool didPop, Object? result) async {
    if (didPop) return;
    if (!await _confirm() || !mounted) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !_dirty,
    onPopInvokedWithResult: (didPop, result) =>
        unawaited(_onPop(didPop, result)),
    child: widget.child,
  );
}
