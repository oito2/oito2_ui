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
