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
import 'package:flutter/widgets.dart';

/// Strings of the oito2_ui widgets that `MaterialLocalizations` doesn't
/// cover: window controls, pane resizing, scroll arrows, page and segment
/// labels.
///
/// Register [delegate] in the app's `localizationsDelegates`. Without it,
/// [of] falls back to English. A label passed explicitly to a widget
/// always wins over these strings.
abstract class Oito2Localizations {
  /// Creates localizations for [localeName].
  const Oito2Localizations(this.localeName);

  /// The locale these strings are written for, such as `en` or `pt_BR`.
  final String localeName;

  /// The delegate that loads [Oito2Localizations] for the app's locale.
  static const LocalizationsDelegate<Oito2Localizations> delegate =
      _Oito2LocalizationsDelegate();

  /// The locales with translated strings: English and Brazilian
  /// Portuguese.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('pt', 'BR'),
  ];

  /// Returns the strings of the closest [Localizations], or null when
  /// [delegate] isn't registered.
  static Oito2Localizations? maybeOf(BuildContext context) =>
      Localizations.of<Oito2Localizations>(context, Oito2Localizations);

  /// Returns the strings of the closest [Localizations], or the English
  /// strings when [delegate] isn't registered.
  static Oito2Localizations of(BuildContext context) =>
      maybeOf(context) ?? const Oito2LocalizationsEn();

  /// Returns the strings for [locale]: Portuguese for any `pt` locale,
  /// English otherwise.
  static Oito2Localizations forLocale(Locale locale) =>
      switch (locale.languageCode) {
        'pt' => const Oito2LocalizationsPtBr(),
        _ => const Oito2LocalizationsEn(),
      };

  /// Label of the window button that minimizes the window.
  String get minimizeWindow;

  /// Label of the window button that maximizes the window.
  String get maximizeWindow;

  /// Label of the window button that restores a maximized window.
  String get restoreWindow;

  /// Label of the window button that closes the window.
  String get closeWindow;

  /// Label of the handle that resizes a side pane.
  String get resizePane;

  /// Label of the arrow that opens a split button's menu.
  String get moreOptions;

  /// Tooltip of the arrow that scrolls a chip bar back.
  String get scrollBack;

  /// Tooltip of the arrow that scrolls a chip bar forward.
  String get scrollForward;

  /// Label of a page indicator dot: page [page] of [count], counted
  /// from 1.
  String pageOf(int page, int count);

  /// Label of a segment of a segmented entry: part [part] of [count],
  /// counted from 1.
  String partOf(int part, int count);

  /// A moment less than a minute away from now.
  String get justNow;

  /// A time [count] [unit]s in the past, such as "3 minutes ago".
  String timeAgo(int count, Oito2TimeUnit unit);

  /// A time [count] [unit]s in the future, such as "in 3 minutes".
  String timeFromNow(int count, Oito2TimeUnit unit);

  /// The hint of the command palette search field.
  String get commandPaletteHint;

  /// Shown when no command matches the command palette search.
  String get noCommandsFound;

  /// Shown by a shortcut recorder while it waits for keys.
  String get pressShortcut;

  /// Shown by a shortcut recorder without a shortcut.
  String get noShortcut;

  /// Label of the button that clears a recorded shortcut.
  String get clearShortcut;

  /// Announced when a search or autocomplete finds nothing.
  String get noResults;

  /// Announced with the number of search or autocomplete results.
  String resultCount(int count);

  /// The label of a button that closes a panel, sheet or card.
  String get close;

  /// The label of a button that dismisses a notification.
  String get dismiss;

  /// The accessibility label of the notification area.
  String get notifications;

  /// The accessibility label of a sheet's resize handle.
  String get resizeSheet;

  /// The button that returns to the previous step of a tour.
  String get tourBack;

  /// The button that moves to the next step of a tour.
  String get tourNext;

  /// The button that finishes a tour on its last step.
  String get tourDone;

  /// The button that ends a tour before its last step.
  String get tourSkip;

  /// The position of a tour step, such as "Step 2 of 5".
  String tourProgress(int step, int total);

  /// The button that shows a hidden password.
  String get showPassword;

  /// The button that hides a shown password.
  String get hidePassword;

  /// Warns that Caps Lock is on while typing a password.
  String get capsLockOn;

  /// The button that raises a number.
  String get increase;

  /// The button that lowers a number.
  String get decrease;

  /// The accessibility label of a code entry with [length] characters.
  String codeEntry(int length);

  /// The accessibility value of a rating, such as "3.5 of 5 stars".
  String ratingValue(String value, int max);

  /// The button that removes [label] from a list, such as a tag.
  String removeItem(String label);

  /// The accessibility hint of a label that can be edited.
  String get editText;

  /// The hue of a color.
  String get hue;

  /// The saturation of a color.
  String get saturation;

  /// The lightness of a color.
  String get lightness;

  /// The opacity of a color.
  String get opacity;

  /// The red channel of a color.
  String get red;

  /// The green channel of a color.
  String get green;

  /// The blue channel of a color.
  String get blue;

  /// The saturation and brightness area of a color picker.
  String get saturationAndBrightness;

  /// The heading of the week number column of a calendar.
  String get weekNumberHeading;

  /// The accessibility label of a week number.
  String weekNumber(int week);

  /// Announced after a copy to the clipboard.
  String get copied;

  /// The label of a page button, such as "Page 3".
  String pageNumber(int page);

  /// The label of a page size selector.
  String get itemsPerPage;

  /// The position of a step, such as "Step 2 of 4".
  String stepOf(int step, int count);

  /// The state of a finished step.
  String get stepCompleted;

  /// The state of the current step.
  String get stepCurrent;

  /// The state of a step that needs attention.
  String get stepError;

  /// How to remove a focused tag, for assistive technologies.
  String get removeTagHint;

  /// The prefix of the hexadecimal color field.
  String get hexColor;

  /// A range of two formatted dates, such as '3/1/2026 – 3/7/2026'.
  String dateRange(String start, String end);

  /// Label of an information message for assistive technologies.
  String get infoInformation;

  /// Label of a success message for assistive technologies.
  String get infoSuccess;

  /// Label of a warning message for assistive technologies.
  String get infoWarning;

  /// Label of an error message for assistive technologies.
  String get infoDanger;

  /// Label of an important message for assistive technologies.
  String get infoImportant;

  /// Announced while content loads.
  String get loading;

  /// An online presence status.
  String get statusOnline;

  /// An away presence status.
  String get statusAway;

  /// A busy presence status.
  String get statusBusy;

  /// An offline presence status.
  String get statusOffline;

  /// The label of a bubble standing for [count] hidden items.
  String moreCount(int count);

  /// The accessibility label of a QR code.
  String get qrCode;

  /// Shown when data doesn't fit in a QR code.
  String get qrTooLong;

  /// The accessibility label of a signature pad.
  String get signature;

  /// The placeholder of an empty signature pad.
  String get signHere;

  /// The state of a signature pad with strokes.
  String get signed;

  /// The state of something with no content.
  String get empty;

  /// The button that undoes the last change.
  String get undo;

  /// The button that removes all content.
  String get clear;

  /// The accessibility label of an image cropper.
  String get imageCropper;

  /// The button that turns an image a quarter left.
  String get rotateLeft;

  /// The button that turns an image a quarter right.
  String get rotateRight;

  /// The button that mirrors an image.
  String get flipHorizontally;

  /// The button that enlarges a view.
  String get zoomIn;

  /// The button that shrinks a view.
  String get zoomOut;

  /// The button that restores the initial state.
  String get reset;
}

/// The units of a relative time, from [second] to [year].
enum Oito2TimeUnit {
  /// Seconds.
  second,

  /// Minutes.
  minute,

  /// Hours.
  hour,

  /// Days.
  day,

  /// Weeks.
  week,

  /// Months.
  month,

  /// Years.
  year,
}

/// The English [Oito2Localizations].
class Oito2LocalizationsEn extends Oito2Localizations {
  /// Creates the English strings.
  const Oito2LocalizationsEn() : super('en');

  @override
  String get minimizeWindow => 'Minimize';

  @override
  String get maximizeWindow => 'Maximize';

  @override
  String get restoreWindow => 'Restore';

  @override
  String get closeWindow => 'Close';

  @override
  String get resizePane => 'Resize pane';

  @override
  String get moreOptions => 'More options';

  @override
  String get scrollBack => 'Scroll back';

  @override
  String get scrollForward => 'Scroll forward';

  @override
  String pageOf(int page, int count) => 'Page $page of $count';

  @override
  String partOf(int part, int count) => 'Part $part of $count';

  @override
  String get justNow => 'now';

  static String _unit(int count, Oito2TimeUnit unit) {
    final name = unit.name;
    return count == 1 ? '1 $name' : '$count ${name}s';
  }

  @override
  String timeAgo(int count, Oito2TimeUnit unit) => '${_unit(count, unit)} ago';

  @override
  String timeFromNow(int count, Oito2TimeUnit unit) =>
      'in ${_unit(count, unit)}';

  @override
  String get commandPaletteHint => 'Type a command';

  @override
  String get noCommandsFound => 'No commands found';

  @override
  String get pressShortcut => 'Press a shortcut';

  @override
  String get noShortcut => 'No shortcut';

  @override
  String get clearShortcut => 'Clear shortcut';

  @override
  String get noResults => 'No results';

  @override
  String resultCount(int count) => count == 1 ? '1 result' : '$count results';
  @override
  String get close => 'Close';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get notifications => 'Notifications';

  @override
  String get resizeSheet => 'Resize sheet';

  @override
  String get tourBack => 'Back';

  @override
  String get tourNext => 'Next';

  @override
  String get tourDone => 'Done';

  @override
  String get tourSkip => 'Skip tour';

  @override
  String tourProgress(int step, int total) => 'Step $step of $total';
  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get capsLockOn => 'Caps Lock is on';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String codeEntry(int length) => 'Code of $length characters';

  @override
  String ratingValue(String value, int max) => '$value of $max stars';

  @override
  String removeItem(String label) => 'Remove $label';

  @override
  String get editText => 'Press Enter to edit';

  @override
  String get hue => 'Hue';

  @override
  String get saturation => 'Saturation';

  @override
  String get lightness => 'Lightness';

  @override
  String get opacity => 'Opacity';

  @override
  String get red => 'Red';

  @override
  String get green => 'Green';

  @override
  String get blue => 'Blue';

  @override
  String get saturationAndBrightness => 'Saturation and brightness';

  @override
  String get weekNumberHeading => 'Wk';

  @override
  String weekNumber(int week) => 'Week $week';
  @override
  String get copied => 'Copied';

  @override
  String pageNumber(int page) => 'Page $page';

  @override
  String get itemsPerPage => 'Items per page';

  @override
  String stepOf(int step, int count) => 'Step $step of $count';

  @override
  String get stepCompleted => 'Completed';

  @override
  String get stepCurrent => 'Current';

  @override
  String get stepError => 'Needs attention';

  @override
  String get removeTagHint => 'Press Delete to remove';

  @override
  String get hexColor => 'Hex';

  @override
  String dateRange(String start, String end) => '$start – $end';

  @override
  String get infoInformation => 'Information';

  @override
  String get infoSuccess => 'Success';

  @override
  String get infoWarning => 'Warning';

  @override
  String get infoDanger => 'Error';

  @override
  String get infoImportant => 'Important';

  @override
  String get loading => 'Loading';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusAway => 'Away';

  @override
  String get statusBusy => 'Busy';

  @override
  String get statusOffline => 'Offline';

  @override
  String moreCount(int count) => '$count more';
  @override
  String get qrCode => 'QR code';

  @override
  String get qrTooLong => 'Too much data for a QR code';

  @override
  String get signature => 'Signature';

  @override
  String get signHere => 'Sign here';

  @override
  String get signed => 'Signed';

  @override
  String get empty => 'Empty';

  @override
  String get undo => 'Undo';

  @override
  String get clear => 'Clear';

  @override
  String get imageCropper => 'Image cropper';

  @override
  String get rotateLeft => 'Rotate left';

  @override
  String get rotateRight => 'Rotate right';

  @override
  String get flipHorizontally => 'Flip horizontally';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get reset => 'Reset';
}

/// The Brazilian Portuguese [Oito2Localizations].
class Oito2LocalizationsPtBr extends Oito2Localizations {
  /// Creates the Brazilian Portuguese strings.
  const Oito2LocalizationsPtBr() : super('pt_BR');

  @override
  String get minimizeWindow => 'Minimizar';

  @override
  String get maximizeWindow => 'Maximizar';

  @override
  String get restoreWindow => 'Restaurar';

  @override
  String get closeWindow => 'Fechar';

  @override
  String get resizePane => 'Redimensionar painel';

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get scrollBack => 'Rolar para trás';

  @override
  String get scrollForward => 'Rolar para frente';

  @override
  String pageOf(int page, int count) => 'Página $page de $count';

  @override
  String partOf(int part, int count) => 'Parte $part de $count';

  @override
  String get justNow => 'agora';

  static String _unit(int count, Oito2TimeUnit unit) {
    final (one, many) = switch (unit) {
      Oito2TimeUnit.second => ('segundo', 'segundos'),
      Oito2TimeUnit.minute => ('minuto', 'minutos'),
      Oito2TimeUnit.hour => ('hora', 'horas'),
      Oito2TimeUnit.day => ('dia', 'dias'),
      Oito2TimeUnit.week => ('semana', 'semanas'),
      Oito2TimeUnit.month => ('mês', 'meses'),
      Oito2TimeUnit.year => ('ano', 'anos'),
    };
    return count == 1 ? '1 $one' : '$count $many';
  }

  @override
  String timeAgo(int count, Oito2TimeUnit unit) => 'há ${_unit(count, unit)}';

  @override
  String timeFromNow(int count, Oito2TimeUnit unit) =>
      'em ${_unit(count, unit)}';

  @override
  String get commandPaletteHint => 'Digite um comando';

  @override
  String get noCommandsFound => 'Nenhum comando encontrado';

  @override
  String get pressShortcut => 'Pressione um atalho';

  @override
  String get noShortcut => 'Sem atalho';

  @override
  String get clearShortcut => 'Limpar atalho';

  @override
  String get noResults => 'Nenhum resultado';

  @override
  String resultCount(int count) =>
      count == 1 ? '1 resultado' : '$count resultados';

  @override
  String get close => 'Fechar';

  @override
  String get dismiss => 'Dispensar';

  @override
  String get notifications => 'Notificações';

  @override
  String get resizeSheet => 'Redimensionar painel';

  @override
  String get tourBack => 'Voltar';

  @override
  String get tourNext => 'Próximo';

  @override
  String get tourDone => 'Concluir';

  @override
  String get tourSkip => 'Pular tour';

  @override
  String tourProgress(int step, int total) => 'Passo $step de $total';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get capsLockOn => 'Caps Lock está ativado';

  @override
  String get increase => 'Aumentar';

  @override
  String get decrease => 'Diminuir';

  @override
  String codeEntry(int length) => 'Código de $length caracteres';

  @override
  String ratingValue(String value, int max) => '$value de $max estrelas';

  @override
  String removeItem(String label) => 'Remover $label';

  @override
  String get editText => 'Pressione Enter para editar';

  @override
  String get hue => 'Matiz';

  @override
  String get saturation => 'Saturação';

  @override
  String get lightness => 'Luminosidade';

  @override
  String get opacity => 'Opacidade';

  @override
  String get red => 'Vermelho';

  @override
  String get green => 'Verde';

  @override
  String get blue => 'Azul';

  @override
  String get saturationAndBrightness => 'Saturação e brilho';

  @override
  String get weekNumberHeading => 'Sem';

  @override
  String weekNumber(int week) => 'Semana $week';

  @override
  String get copied => 'Copiado';

  @override
  String pageNumber(int page) => 'Página $page';

  @override
  String get itemsPerPage => 'Itens por página';

  @override
  String stepOf(int step, int count) => 'Passo $step de $count';

  @override
  String get stepCompleted => 'Concluído';

  @override
  String get stepCurrent => 'Atual';

  @override
  String get stepError => 'Requer atenção';

  @override
  String get removeTagHint => 'Pressione Delete para remover';

  @override
  String get hexColor => 'Hex';

  @override
  String dateRange(String start, String end) => '$start – $end';

  @override
  String get infoInformation => 'Informação';

  @override
  String get infoSuccess => 'Sucesso';

  @override
  String get infoWarning => 'Aviso';

  @override
  String get infoDanger => 'Erro';

  @override
  String get infoImportant => 'Importante';

  @override
  String get loading => 'Carregando';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusAway => 'Ausente';

  @override
  String get statusBusy => 'Ocupado';

  @override
  String get statusOffline => 'Offline';

  @override
  String moreCount(int count) => 'Mais $count';

  @override
  String get qrCode => 'Código QR';

  @override
  String get qrTooLong => 'Dados demais para um código QR';

  @override
  String get signature => 'Assinatura';

  @override
  String get signHere => 'Assine aqui';

  @override
  String get signed => 'Assinado';

  @override
  String get empty => 'Vazio';

  @override
  String get undo => 'Desfazer';

  @override
  String get clear => 'Limpar';

  @override
  String get imageCropper => 'Recorte de imagem';

  @override
  String get rotateLeft => 'Girar à esquerda';

  @override
  String get rotateRight => 'Girar à direita';

  @override
  String get flipHorizontally => 'Espelhar horizontalmente';

  @override
  String get zoomIn => 'Ampliar';

  @override
  String get zoomOut => 'Reduzir';

  @override
  String get reset => 'Redefinir';
}

class _Oito2LocalizationsDelegate
    extends LocalizationsDelegate<Oito2Localizations> {
  const _Oito2LocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'pt';

  @override
  Future<Oito2Localizations> load(Locale locale) =>
      SynchronousFuture(Oito2Localizations.forLocale(locale));

  @override
  bool shouldReload(_Oito2LocalizationsDelegate old) => false;
}
