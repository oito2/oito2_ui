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

// Writes every oito2_ui string, in English and Brazilian Portuguese, as a
// JSON fixture: getters by name, and methods by name with the sample
// arguments they were called with.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oito2_ui/oito2_ui.dart';

import 'support.dart';

typedef Getter = String Function(Oito2Localizations l);

/// Every string getter of [Oito2Localizations].
final Map<String, Getter> getters = {
  'minimizeWindow': (l) => l.minimizeWindow,
  'maximizeWindow': (l) => l.maximizeWindow,
  'restoreWindow': (l) => l.restoreWindow,
  'closeWindow': (l) => l.closeWindow,
  'resizePane': (l) => l.resizePane,
  'moreOptions': (l) => l.moreOptions,
  'scrollBack': (l) => l.scrollBack,
  'scrollForward': (l) => l.scrollForward,
  'justNow': (l) => l.justNow,
  'commandPaletteHint': (l) => l.commandPaletteHint,
  'noCommandsFound': (l) => l.noCommandsFound,
  'pressShortcut': (l) => l.pressShortcut,
  'noShortcut': (l) => l.noShortcut,
  'clearShortcut': (l) => l.clearShortcut,
  'noResults': (l) => l.noResults,
  'close': (l) => l.close,
  'dismiss': (l) => l.dismiss,
  'notifications': (l) => l.notifications,
  'resizeSheet': (l) => l.resizeSheet,
  'tourBack': (l) => l.tourBack,
  'tourNext': (l) => l.tourNext,
  'tourDone': (l) => l.tourDone,
  'tourSkip': (l) => l.tourSkip,
  'showPassword': (l) => l.showPassword,
  'hidePassword': (l) => l.hidePassword,
  'capsLockOn': (l) => l.capsLockOn,
  'increase': (l) => l.increase,
  'decrease': (l) => l.decrease,
  'editText': (l) => l.editText,
  'hue': (l) => l.hue,
  'saturation': (l) => l.saturation,
  'brightness': (l) => l.brightness,
  'lightness': (l) => l.lightness,
  'opacity': (l) => l.opacity,
  'red': (l) => l.red,
  'green': (l) => l.green,
  'blue': (l) => l.blue,
  'saturationAndBrightness': (l) => l.saturationAndBrightness,
  'weekNumberHeading': (l) => l.weekNumberHeading,
  'copied': (l) => l.copied,
  'copyFailed': (l) => l.copyFailed,
  'moveWithArrowKeys': (l) => l.moveWithArrowKeys,
  'mainMenu': (l) => l.mainMenu,
  'moveUp': (l) => l.moveUp,
  'moveDown': (l) => l.moveDown,
  'moveLeft': (l) => l.moveLeft,
  'moveRight': (l) => l.moveRight,
  'itemsPerPage': (l) => l.itemsPerPage,
  'stepCompleted': (l) => l.stepCompleted,
  'stepCurrent': (l) => l.stepCurrent,
  'stepError': (l) => l.stepError,
  'removeTagHint': (l) => l.removeTagHint,
  'hexColor': (l) => l.hexColor,
  'infoInformation': (l) => l.infoInformation,
  'infoSuccess': (l) => l.infoSuccess,
  'infoWarning': (l) => l.infoWarning,
  'infoDanger': (l) => l.infoDanger,
  'infoImportant': (l) => l.infoImportant,
  'loading': (l) => l.loading,
  'statusOnline': (l) => l.statusOnline,
  'statusAway': (l) => l.statusAway,
  'statusBusy': (l) => l.statusBusy,
  'statusOffline': (l) => l.statusOffline,
  'qrCode': (l) => l.qrCode,
  'qrTooLong': (l) => l.qrTooLong,
  'signature': (l) => l.signature,
  'signHere': (l) => l.signHere,
  'signed': (l) => l.signed,
  'empty': (l) => l.empty,
  'undo': (l) => l.undo,
  'clear': (l) => l.clear,
  'imageCropper': (l) => l.imageCropper,
  'rotateLeft': (l) => l.rotateLeft,
  'rotateRight': (l) => l.rotateRight,
  'flipHorizontally': (l) => l.flipHorizontally,
  'zoomIn': (l) => l.zoomIn,
  'zoomOut': (l) => l.zoomOut,
  'reset': (l) => l.reset,
  'dropFilesHere': (l) => l.dropFilesHere,
  'chooseFiles': (l) => l.chooseFiles,
  'chooseFile': (l) => l.chooseFile,
  'download': (l) => l.download,
  'downloadUnavailable': (l) => l.downloadUnavailable,
};

/// One call of a method of [Oito2Localizations]: its name, its arguments
/// (time units by name) and the function that calls it.
typedef MaterialGetter = String Function(MaterialLocalizations m);

/// The Flutter Material strings that oito2_ui widgets use, by the name the
/// fixtures give them.
final Map<String, MaterialGetter> materialGetters = {
  'back': (m) => m.backButtonTooltip,
  'searchField': (m) => m.searchFieldLabel,
  'previousPage': (m) => m.previousPageTooltip,
  'nextPage': (m) => m.nextPageTooltip,
  'clearText': (m) => m.clearButtonTooltip,
  'copy': (m) => m.copyButtonLabel,
  'ok': (m) => m.okButtonLabel,
  'cancel': (m) => m.cancelButtonLabel,
  'dateInput': (m) => m.dateInputLabel,
  'dateHelp': (m) => m.dateHelpText,
  'invalidDateFormat': (m) => m.invalidDateFormatLabel,
  'dateOutOfRange': (m) => m.dateOutOfRangeLabel,
  'timeInput': (m) => m.timePickerInputHelpText,
  'invalidTime': (m) => m.invalidTimeLabel,
  'am': (m) => m.anteMeridiemAbbreviation,
  'pm': (m) => m.postMeridiemAbbreviation,
  'previousMonth': (m) => m.previousMonthTooltip,
  'nextMonth': (m) => m.nextMonthTooltip,
  'today': (m) => m.currentDateLabel,
  'selectDate': (m) => m.datePickerHelpText,
};

typedef Call = (String, List<Object>, String Function(Oito2Localizations l));

List<Call> calls() => [
  ('pageOf', [2, 5], (l) => l.pageOf(2, 5)),
  ('partOf', [1, 3], (l) => l.partOf(1, 3)),
  for (final unit in Oito2TimeUnit.values)
    for (final count in [1, 3]) ...[
      ('timeAgo', [count, unit.name], (l) => l.timeAgo(count, unit)),
      ('timeFromNow', [count, unit.name], (l) => l.timeFromNow(count, unit)),
    ],
  ('resultCount', [1], (l) => l.resultCount(1)),
  ('resultCount', [3], (l) => l.resultCount(3)),
  ('resultCount', [0], (l) => l.resultCount(0)),
  ('tourProgress', [2, 4], (l) => l.tourProgress(2, 4)),
  ('codeEntry', [6], (l) => l.codeEntry(6)),
  ('ratingValue', ['3.5', 5], (l) => l.ratingValue('3.5', 5)),
  ('removeItem', ['Tag'], (l) => l.removeItem('Tag')),
  ('weekNumber', [12], (l) => l.weekNumber(12)),
  ('pageNumber', [3], (l) => l.pageNumber(3)),
  ('stepOf', [2, 5], (l) => l.stepOf(2, 5)),
  ('dateRange', ['1/2', '3/4'], (l) => l.dateRange('1/2', '3/4')),
  ('moreCount', [4], (l) => l.moreCount(4)),
  ('acceptedFileTypes', ['PNG, JPG'], (l) => l.acceptedFileTypes('PNG, JPG')),
  ('maxFileSizeHint', ['2 MB'], (l) => l.maxFileSizeHint('2 MB')),
  ('fileTypeNotAccepted', ['a.txt'], (l) => l.fileTypeNotAccepted('a.txt')),
  ('fileTooLarge', ['a.png', '2 MB'], (l) => l.fileTooLarge('a.png', '2 MB')),
  ('tooManyFiles', ['a.png', 1], (l) => l.tooManyFiles('a.png', 1)),
  ('tooManyFiles', ['a.png', 3], (l) => l.tooManyFiles('a.png', 3)),
  ('folderNotAccepted', ['docs'], (l) => l.folderNotAccepted('docs')),
];

Map<String, Object> export(Oito2Localizations l, MaterialLocalizations m) => {
  'localeName': l.localeName,
  'material': {
    for (final MapEntry(:key, :value) in materialGetters.entries) key: value(m),
  },
  'getters': {
    for (final MapEntry(:key, :value) in getters.entries) key: value(l),
  },
  'calls': [
    for (final (name, args, call) in calls())
      {'name': name, 'args': args, 'result': call(l)},
  ],
};

void main() {
  test('exports the localizations', () async {
    final portuguese = await GlobalMaterialLocalizations.delegate.load(
      const Locale('pt', 'BR'),
    );
    final file = writeFixture('l10n.json', {
      'en': export(
        const Oito2LocalizationsEn(),
        const DefaultMaterialLocalizations(),
      ),
      'pt-BR': export(const Oito2LocalizationsPtBr(), portuguese),
    });
    expect(file.existsSync(), isTrue);
  });
}
