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

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/oito2_localizations.dart';
import 'alert.dart';
import 'info.dart';
import 'row_drag.dart' show announceTo;
import 'widget_helpers.dart';

/// Tracks the fields of an [Oito2Form]: validates them, leads the user to
/// the first invalid one and tells whether any value changed.
///
/// Fields register themselves while they sit below an [Oito2Form] that
/// uses this controller: the oito2 entries do it on their own, and a
/// Flutter `FormField` does it inside an [Oito2FormFieldAdapter]. A field
/// outside any form behaves as on its own.
///
/// Errors show under a field once it loses focus or is submitted; after a
/// [validate] that finds errors, [showsErrors] turns true and every field
/// shows its error at once, also while it is being fixed.
///
/// Listeners are notified when a field changes its value or error, when
/// fields come and go, and after [validate], [markClean] and [reset].
class Oito2FormController extends ChangeNotifier {
  /// Creates a form controller.
  Oito2FormController();

  final List<Oito2FormFieldMixin> _fields = [];

  /// The registered fields in the order of the widget tree, as of the last
  /// [validate].
  List<Oito2FormFieldMixin> _treeOrder = const [];

  /// The element of the [Oito2Form] that uses this controller.
  BuildContext? _context;

  bool _showsErrors = false;
  bool _disposed = false;
  bool _notifyScheduled = false;

  /// Whether every field shows its error now, which is true after a
  /// [validate] that found errors, until [reset].
  bool get showsErrors => _showsErrors;

  /// The registered fields, in the order of the widget tree as of the last
  /// [validate], followed by the fields registered since, in registration
  /// order.
  List<Oito2FormFieldMixin> get fields {
    final order = _treeOrder;
    final known = [
      for (final field in order)
        if (_fields.contains(field)) field,
    ];
    return List.unmodifiable([
      ...known,
      for (final field in _fields)
        if (!order.contains(field)) field,
    ]);
  }

  /// The current errors of the fields, in the order of [fields].
  ///
  /// Each error is computed from the field's current value, so a fixed
  /// field leaves the list as soon as its value is valid.
  List<Oito2FormError> get errors => [
    for (final field in fields)
      if (field.formFieldError case final message?)
        Oito2FormError._(field, message),
  ];

  /// Whether any field holds a value other than its clean value: the
  /// initial value, or the value of the last [markClean].
  bool get isDirty => _fields.any((field) => field.isFormFieldDirty);

  /// Validates every field and returns whether all of them are valid.
  ///
  /// When some are not, every field shows its error, the first invalid
  /// field in the order of the widget tree takes the focus and scrolls
  /// into view, and assistive technologies politely hear the number of
  /// errors. [focusFirstError] and [announce] turn those two steps off.
  bool validate({bool focusFirstError = true, bool announce = true}) {
    _treeOrder = _collectTreeOrder();
    for (final field in _fields) {
      field.showFormFieldError();
    }
    final errors = this.errors;
    _showsErrors = errors.isNotEmpty || _showsErrors;
    _notifyNow();
    if (errors.isEmpty) return true;
    if (focusFirstError) errors.first.reveal();
    final context = _context;
    if (announce && context != null && context.mounted) {
      announceTo(
        context,
        Oito2Localizations.of(context).formErrorCount(errors.length),
      );
    }
    return false;
  }

  /// Validates the form and, when it is valid, calls [onValid] and waits
  /// for it.
  ///
  /// Returns whether the form was valid.
  Future<bool> submit(FutureOr<void> Function() onValid) async {
    if (!validate()) return false;
    await onValid();
    return true;
  }

  /// Takes the current value of every field as its clean value, as after
  /// the values are saved, so [isDirty] turns false.
  void markClean() {
    for (final field in _fields) {
      field.markFormFieldClean();
    }
    _notifyNow();
  }

  /// Puts every field back to its clean value, where the field supports
  /// it, and hides the errors until the fields lose focus or the form is
  /// validated again.
  void reset() {
    _showsErrors = false;
    for (final field in [..._fields]) {
      field.resetFormField();
    }
    _notifyNow();
  }

  /// Scrolls [field] into view and focuses it.
  void revealField(Oito2FormFieldMixin field) {
    if (!field.mounted) return;
    final context = field.context;
    unawaited(
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: motionDuration(context, const Duration(milliseconds: 200)),
        curve: Curves.easeOutCubic,
      ),
    );
    field.formFieldFocusNode?.requestFocus();
  }

  /// Returns the registered fields found below the form, in the order of
  /// the widget tree.
  List<Oito2FormFieldMixin> _collectTreeOrder() {
    final context = _context;
    if (context is! Element || !context.mounted) return const [];
    final found = <Oito2FormFieldMixin>[];
    void visit(Element element) {
      if (element is StatefulElement) {
        final state = element.state;
        if (state is Oito2FormFieldMixin && _fields.contains(state)) {
          found.add(state);
        }
      }
      element.visitChildren(visit);
    }

    context.visitChildren(visit);
    return found;
  }

  void _register(Oito2FormFieldMixin field) {
    if (_fields.contains(field)) return;
    _fields.add(field);
    _scheduleNotify();
  }

  void _unregister(Oito2FormFieldMixin field) {
    if (!_fields.remove(field)) return;
    _scheduleNotify();
  }

  /// Notifies the listeners now, unless the controller is disposed.
  void _notifyNow() {
    if (_disposed) return;
    _notifyScheduled = false;
    notifyListeners();
  }

  /// Notifies the listeners now, or after the frame when the widget tree
  /// is being built, since listeners may rebuild widgets.
  void _scheduleNotify() {
    if (_disposed) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase != SchedulerPhase.persistentCallbacks &&
        phase != SchedulerPhase.midFrameMicrotasks) {
      _notifyNow();
      return;
    }
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_notifyScheduled) _notifyNow();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _disposed = true;
    _fields.clear();
    _context = null;
    super.dispose();
  }
}

/// The error of one field of an [Oito2Form].
@immutable
class Oito2FormError {
  const Oito2FormError._(this._field, this.message);

  final Oito2FormFieldMixin _field;

  /// The error message.
  final String message;

  /// The name of the field, or null when it has none.
  String? get label => _field.formFieldLabel;

  /// Scrolls the field into view and focuses it.
  void reveal() => _field.form?.revealField(_field);

  @override
  bool operator ==(Object other) =>
      other is Oito2FormError &&
      identical(other._field, _field) &&
      other.message == message;

  @override
  int get hashCode => Object.hash(identityHashCode(_field), message);

  @override
  String toString() => 'Oito2FormError(${label ?? ''}: $message)';
}

/// Groups fields under an [Oito2FormController].
///
/// The fields below it register with [controller], which validates them,
/// tracks whether they changed and leads the user to the first invalid
/// one. Show the errors at the top of the form with an
/// [Oito2FormErrorSummary].
class Oito2Form extends StatefulWidget {
  /// Creates a form that registers the fields of [child] with
  /// [controller].
  const Oito2Form({super.key, required this.controller, required this.child});

  /// The controller the fields register with.
  final Oito2FormController controller;

  /// The form content.
  final Widget child;

  /// Returns the controller of the closest enclosing [Oito2Form], or null
  /// when there is none, and rebuilds [context] when the controller
  /// notifies its listeners.
  static Oito2FormController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Oito2FormScope>()?.notifier;

  /// Returns the controller of the closest enclosing [Oito2Form].
  ///
  /// Throws a [FlutterError] when there is none.
  static Oito2FormController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw FlutterError('Oito2Form.of() called with no Oito2Form above.');
    }
    return controller;
  }

  @override
  State<Oito2Form> createState() => _Oito2FormState();
}

class _Oito2FormState extends State<Oito2Form> {
  @override
  void initState() {
    super.initState();
    widget.controller._context = context;
  }

  @override
  void didUpdateWidget(Oito2Form oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (identical(oldWidget.controller._context, context)) {
        oldWidget.controller._context = null;
      }
      widget.controller._context = context;
    }
  }

  @override
  void dispose() {
    if (identical(widget.controller._context, context)) {
      widget.controller._context = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Oito2FormRegistration(
    controller: widget.controller,
    child: _Oito2FormScope(notifier: widget.controller, child: widget.child),
  );
}

/// Provides the controller of an [Oito2Form] to its fields.
class _Oito2FormScope extends InheritedNotifier<Oito2FormController> {
  const _Oito2FormScope({required super.notifier, required super.child});
}

/// Provides the controller of an [Oito2Form] to the fields that register
/// with it, notifying them only when the controller is replaced.
class _Oito2FormRegistration extends InheritedWidget {
  const _Oito2FormRegistration({
    required this.controller,
    required super.child,
  });

  final Oito2FormController controller;

  @override
  bool updateShouldNotify(_Oito2FormRegistration oldWidget) =>
      !identical(controller, oldWidget.controller);
}

/// Lets the state of a field take part in an [Oito2Form].
///
/// The state registers with the closest [Oito2Form] while it is mounted
/// and answers the form through the members it implements: its label,
/// the focus node to focus, its current error and whether its value
/// changed. A state outside any form keeps working on its own.
///
/// Call [notifyFormFieldChanged] whenever the value or the error changes,
/// so the form summary and the dirty state follow. Override
/// [participatesInForm] to let the widget leave the form.
///
/// The state rebuilds when [formShowsErrors] changes, not on every change
/// of the form, so a change in one field doesn't rebuild the others.
mixin Oito2FormFieldMixin<W extends StatefulWidget> on State<W> {
  Oito2FormController? _form;

  /// The [formShowsErrors] value of the last build, to rebuild only when
  /// it changes.
  bool _formShowedErrors = false;

  /// The controller of the form the field is registered with, or null
  /// outside a form.
  Oito2FormController? get form => _form;

  /// The name of the field in the error summary, or null to show only the
  /// message.
  String? get formFieldLabel;

  /// The node focused when the form leads the user to the field.
  FocusNode? get formFieldFocusNode;

  /// The error of the current value, or null when it is valid.
  ///
  /// Reading it doesn't change the field.
  String? get formFieldError;

  /// Whether the value differs from the clean value: the initial value,
  /// or the value at the last [markFormFieldClean].
  bool get isFormFieldDirty;

  /// Makes the current error, if any, visible under the field; does
  /// nothing by default.
  void showFormFieldError() {}

  /// Puts the field back to its clean value; does nothing by default.
  void resetFormField() {}

  /// Takes the current value as the clean value; does nothing by default.
  void markFormFieldClean() {}

  /// Whether the form shows every error now, after a validation that
  /// found errors; false outside a form.
  bool get formShowsErrors => _form?.showsErrors ?? false;

  /// Tells the form that the value or the error of the field changed.
  void notifyFormFieldChanged() => _form?._scheduleNotify();

  /// Whether the field registers with the closest [Oito2Form]; true by
  /// default.
  ///
  /// A field that doesn't take part is left out of validation, the error
  /// summary and the dirty state, and shows its own errors as outside a
  /// form.
  bool get participatesInForm => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncForm();
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncForm();
  }

  /// Registers with the closest form while [participatesInForm], and
  /// leaves the form otherwise.
  ///
  /// The lookup depends only on which controller the form holds, so a
  /// change of the form's state doesn't rebuild the field.
  void _syncForm() {
    final form = participatesInForm
        ? context
              .dependOnInheritedWidgetOfExactType<_Oito2FormRegistration>()
              ?.controller
        : null;
    if (identical(form, _form)) return;
    _form?.removeListener(_onFormChanged);
    _form?._unregister(this);
    _form = form;
    form?._register(this);
    form?.addListener(_onFormChanged);
    _formShowedErrors = formShowsErrors;
  }

  /// Rebuilds the field when the form starts or stops showing every
  /// error.
  void _onFormChanged() {
    final shows = formShowsErrors;
    if (shows == _formShowedErrors || !mounted) return;
    setState(() => _formShowedErrors = shows);
  }

  @override
  void dispose() {
    _form?.removeListener(_onFormChanged);
    _form?._unregister(this);
    _form = null;
    super.dispose();
  }
}

/// Registers a Flutter `FormField`, such as a `TextFormField`, with the
/// closest [Oito2Form].
///
/// The adapter finds the first `FormField` in [child] and wraps it in a
/// Flutter `Form` of its own, so the field reports its changes; a field
/// inside it doesn't register with an outer `Form`. Its error comes from
/// the field's `validator`, its clean value is its value at start or at
/// the last `markClean`, and the form focuses the first focusable widget
/// in [child].
class Oito2FormFieldAdapter extends StatefulWidget {
  /// Creates an adapter for the form field in [child].
  const Oito2FormFieldAdapter({super.key, this.label, required this.child});

  /// The name of the field in the error summary.
  final String? label;

  /// The subtree that holds the form field.
  final Widget child;

  @override
  State<Oito2FormFieldAdapter> createState() => _Oito2FormFieldAdapterState();
}

class _Oito2FormFieldAdapterState extends State<Oito2FormFieldAdapter>
    with Oito2FormFieldMixin {
  final _focusNode = FocusNode(
    debugLabel: 'Oito2FormFieldAdapter',
    canRequestFocus: false,
    skipTraversal: true,
  );

  /// The clean value, once it is read after the first frame.
  Object? _clean;
  bool _hasClean = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasClean) return;
      _clean = _field?.value;
      _hasClean = true;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// The first form field state in the subtree, if any.
  FormFieldState<Object?>? get _field {
    if (!mounted) return null;
    FormFieldState<Object?>? found;
    void visit(Element element) {
      if (found != null) return;
      if (element is StatefulElement && element.state is FormFieldState) {
        found = element.state as FormFieldState<Object?>;
        return;
      }
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
    return found;
  }

  @override
  String? get formFieldLabel => widget.label;

  @override
  FocusNode? get formFieldFocusNode => _focusNode.descendants
      .where((node) => node.canRequestFocus && !node.skipTraversal)
      .firstOrNull;

  @override
  String? get formFieldError {
    final field = _field;
    if (field == null || field.isValid) return null;
    return field.errorText ?? Oito2Localizations.of(context).invalidValue;
  }

  @override
  bool get isFormFieldDirty {
    final field = _field;
    return field != null && _hasClean && field.value != _clean;
  }

  @override
  void showFormFieldError() => _field?.validate();

  @override
  void markFormFieldClean() {
    _clean = _field?.value;
    _hasClean = true;
  }

  @override
  void resetFormField() {
    final field = _field;
    if (field == null || !_hasClean) return;
    field.reset();
    field.didChange(_clean);
  }

  /// Validates the field again while its error shows, so the error
  /// follows the value, and tells the form about the change.
  void _onChanged() {
    final field = _field;
    if (field != null && (formShowsErrors || field.hasError)) field.validate();
    notifyFormFieldChanged();
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _focusNode,
    child: Form(onChanged: _onChanged, child: widget.child),
  );
}

/// The errors of an [Oito2Form] in an [Oito2Alert] of the danger type,
/// such as "Fix 2 errors to continue", with one link per error that
/// scrolls to its field and focuses it.
///
/// The summary shows after a validation that found errors and goes away
/// once every error is fixed. It is a live region, so assistive
/// technologies announce it when it appears.
class Oito2FormErrorSummary extends StatelessWidget {
  /// Creates an error summary of [controller], or of the closest
  /// [Oito2Form] when it is null.
  const Oito2FormErrorSummary({super.key, this.controller, this.title});

  /// The form controller; defaults to the closest [Oito2Form].
  final Oito2FormController? controller;

  /// The headline; defaults to the localized "Fix N errors to continue".
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller == null) {
      final form = Oito2Form.maybeOf(context);
      return form == null ? const SizedBox.shrink() : _build(context, form);
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _build(context, controller),
    );
  }

  Widget _build(BuildContext context, Oito2FormController form) {
    if (!form.showsErrors) return const SizedBox.shrink();
    final errors = form.errors;
    if (errors.isEmpty) return const SizedBox.shrink();
    final strings = Oito2Localizations.of(context);
    final (_, foreground) = infoColorsOf(context, Oito2InfoType.danger, 0.08);
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: foreground,
    );
    return Oito2Alert(
      type: Oito2InfoType.danger,
      title: title ?? Text(strings.formErrorSummary(errors.length)),
      message: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final error in errors)
            _ErrorLink(
              error: error,
              foreground: foreground,
              textStyle: textStyle,
              hint: strings.goToField,
            ),
        ],
      ),
    );
  }
}

/// A link-styled button that leads to the field of [error].
class _ErrorLink extends StatelessWidget {
  const _ErrorLink({
    required this.error,
    required this.foreground,
    required this.textStyle,
    required this.hint,
  });

  final Oito2FormError error;
  final Color foreground;
  final TextStyle? textStyle;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final label = error.label;
    final text = label == null ? error.message : '$label: ${error.message}';
    final padding = Theme.of(context).textButtonTheme.style?.padding
        ?.resolve(const {})
        ?.resolve(Directionality.of(context));
    final startShift = Directionality.of(context) == TextDirection.ltr
        ? -(padding?.left ?? 0)
        : padding?.right ?? 0;
    // The label lines up with the alert message while the focus ring
    // keeps the button padding.
    return Transform.translate(
      offset: Offset(startShift, 0),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          alignment: AlignmentDirectional.centerStart,
          textStyle: textStyle,
          padding: padding,
        ),
        onPressed: error.reveal,
        child: Semantics(hint: hint, child: Text(text)),
      ),
    );
  }
}
