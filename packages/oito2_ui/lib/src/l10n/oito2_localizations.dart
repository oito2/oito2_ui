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

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Strings of the oito2_ui widgets that `MaterialLocalizations` doesn't
/// cover, such as window controls, pane and sheet handles, relative
/// times, the command palette, form fields, pickers and file uploads.
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

  /// A time so close to now that it reads as "now".
  String get justNow;

  /// Returns a time [count] [unit]s in the past, such as "3 minutes ago".
  String timeAgo(int count, Oito2TimeUnit unit);

  /// Returns a time [count] [unit]s in the future, such as "in 3 minutes".
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

  /// The brightness (HSV value) of a color.
  String get brightness;

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

  /// Announced when the platform refuses a copy to the clipboard.
  String get copyFailed;

  /// The hint of a widget the arrow keys move.
  String get moveWithArrowKeys;

  /// The tooltip of the button that opens an app's main menu.
  String get mainMenu;

  /// The accessibility action that moves a widget up.
  String get moveUp;

  /// The accessibility action that moves a widget down.
  String get moveDown;

  /// The accessibility action that moves a widget left.
  String get moveLeft;

  /// The accessibility action that moves a widget right.
  String get moveRight;

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

  /// Hint of a tree row with a change not applied yet.
  String get pendingChange;

  /// Label of the handle that resizes the table column [column].
  String resizeColumn(String column);

  /// The state of a table column header the table isn't sorted by.
  String get notSorted;

  /// The state of a table column header sorted in ascending order.
  String get sortedAscending;

  /// The state of a table column header sorted in descending order.
  String get sortedDescending;

  /// Shown at the end of a list while its next page loads.
  String get loadingMore;

  /// Shown at the end of a list when a page failed to load.
  String get loadFailed;

  /// The button that tries a failed action again.
  String get retry;

  /// The placeholder of a list without items.
  String get noItems;

  /// The button that shows the [count] items a list keeps hidden, such as
  /// alerts beyond the visible ones.
  String showMore(int count);

  /// The button that hides the items shown by [showMore] again.
  String get showFewer;

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

  /// The invitation of a file drop zone where files can be dropped.
  String get dropFilesHere;

  /// The button that opens the file chooser for several files.
  String get chooseFiles;

  /// The button that opens the file chooser for one file.
  String get chooseFile;

  /// The file types a file upload accepts, listed in [types].
  String acceptedFileTypes(String types);

  /// The largest file a file upload accepts, as a formatted [size].
  String maxFileSizeHint(String size);

  /// Why the file [name] was refused: its type isn't accepted.
  String fileTypeNotAccepted(String name);

  /// Why the file [name] was refused: it is larger than [size].
  String fileTooLarge(String name, String size);

  /// Why the file [name] was refused: the upload already holds [max] files.
  String tooManyFiles(String name, int max);

  /// Why [name] was refused: it is a folder, not a file.
  String folderNotAccepted(String name);

  /// The button that saves a file to the device.
  String get download;

  /// Why a download button is disabled on platforms that can't save files.
  String get downloadUnavailable;

  /// The accessibility label of a password strength meter.
  String get passwordStrength;

  /// The lowest password strength.
  String get passwordVeryWeak;

  /// The second password strength.
  String get passwordWeak;

  /// The middle password strength.
  String get passwordFair;

  /// The fourth password strength.
  String get passwordGood;

  /// The highest password strength.
  String get passwordStrong;

  /// The password suggestion for a common password.
  String get passwordAvoidCommon;

  /// The password suggestion for a password with the user's name or email.
  String get passwordAvoidPersonalInfo;

  /// The password suggestion for a password made of a common word.
  String get passwordAvoidWords;

  /// The password suggestion for a password with a year or a date.
  String get passwordAvoidDates;

  /// The password suggestion for a password with a run such as "abcd".
  String get passwordAvoidSequences;

  /// The password suggestion for a password with repeated characters.
  String get passwordAvoidRepeats;

  /// The password suggestion for a short password.
  String get passwordAddLength;

  /// The password suggestion for a password with few kinds of characters.
  String get passwordMixCharacters;

  /// The accessibility label of a weekly schedule grid.
  String get weekSchedule;

  /// The accessibility label of a weekly schedule cell: the [day] name,
  /// the time from [start] to [end] and the [value] label.
  String scheduleSlot(String day, String start, String end, String value);

  /// The amount used of a total, both already formatted, such as
  /// "1.2 GB of 15 GB".
  String usageOf(String used, String total);

  /// The accessibility label of a code editor.
  String get codeEditor;

  /// The accessibility label of a mark on line [line] of a code editor,
  /// counted from 1: its [kind], such as "Error", and its [message].
  String lineMessage(int line, String kind, String message);

  /// The title of a drop zone that takes files and folders.
  String get dropFilesOrFoldersHere;

  /// The kind of a folder in a file list.
  String get folderItem;

  /// The accessibility label of a list of accounts.
  String get accounts;

  /// The menu entry that adds an account.
  String get addAccount;

  /// The accessibility label of an account switcher whose [current]
  /// account is the one in use.
  String switchAccount(String current);

  /// A number of pending items, such as unread messages, shown on an
  /// account.
  String pendingCount(int count);

  /// The accessibility label of a path bar.
  String get pathBar;

  /// The button that shows the hidden segments of a path bar.
  String get showPathSegments;

  /// The button that turns a path bar into a text field.
  String get editPath;

  /// The state of the last segment of a path bar, where the user is.
  String get currentLocation;

  /// The tooltip of the handle that drags a row to a new place.
  String get dragToReorder;

  /// Tells that a dragged item can't be dropped where the pointer is, or
  /// that a keyboard move isn't allowed there.
  String get cantDropHere;

  /// The label of a drag of [count] items at once.
  String dragItemCount(int count);

  /// Announces that [item] moved to [position] (from 1) of the [count]
  /// items of a list.
  String movedToPosition(String item, int position, int count);

  /// Announces that [item] moved into the branch [parent] of a tree, at
  /// [position] (from 1) among its children.
  String movedInto(String item, String parent, int position);

  /// Announces that [item] moved to the top level of a tree, at
  /// [position] (from 1).
  String movedToTopLevel(String item, int position);

  /// The action that moves a tree node into the branch above it, as its
  /// last child.
  String get indentItem;

  /// The action that moves a tree node out of its branch, after it.
  String get outdentItem;

  /// The action that moves a table column one place to the left.
  String get moveColumnLeft;

  /// The action that moves a table column one place to the right.
  String get moveColumnRight;

  /// Announces that the table column [column] moved to [position] (from 1)
  /// of the [count] shown columns.
  String movedColumn(String column, int position, int count);

  /// The menu item that puts the columns of a table back as the app
  /// first showed them.
  String get resetColumns;

  /// The error of a required field left empty.
  String get fieldRequired;

  /// The error of a form field whose value its validator refuses, when the
  /// validator gives no message.
  String get invalidValue;

  /// The headline of a form error summary with [count] errors.
  String formErrorSummary(int count);

  /// Announces that a validated form has [count] errors.
  String formErrorCount(int count);

  /// The accessibility hint of a link that leads to a form field.
  String get goToField;

  /// The title of the dialog that asks whether to leave unsaved changes.
  String get unsavedChangesTitle;

  /// The message of the dialog that asks whether to leave unsaved changes.
  String get unsavedChangesMessage;

  /// The button that stays on a page with unsaved changes.
  String get keepEditing;

  /// The button that leaves a page and drops its unsaved changes.
  String get discardChanges;

  /// The button that saves the changes before leaving a page.
  String get saveChanges;
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

  /// Returns [count] followed by the singular or plural English [unit].
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
  String get brightness => 'Brightness';

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
  String get copyFailed => "Couldn't copy";

  @override
  String get moveWithArrowKeys => 'Use the arrow keys to move it';

  @override
  String get mainMenu => 'Main menu';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get moveLeft => 'Move left';

  @override
  String get moveRight => 'Move right';

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
  String get pendingChange => 'Pending change';

  @override
  String resizeColumn(String column) => 'Resize column $column';

  @override
  String get notSorted => 'Not sorted';

  @override
  String get sortedAscending => 'Sorted ascending';

  @override
  String get sortedDescending => 'Sorted descending';

  @override
  String get loadingMore => 'Loading more…';

  @override
  String get loadFailed => "Couldn't load the items";

  @override
  String get retry => 'Retry';

  @override
  String get noItems => 'No items';

  @override
  String showMore(int count) => 'Show $count more';

  @override
  String get showFewer => 'Show fewer';

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

  @override
  String get dropFilesHere => 'Drop files here';

  @override
  String get chooseFiles => 'Choose files';

  @override
  String get chooseFile => 'Choose a file';

  @override
  String acceptedFileTypes(String types) => 'Accepted: $types';

  @override
  String maxFileSizeHint(String size) => 'Up to $size each';

  @override
  String fileTypeNotAccepted(String name) =>
      '$name: this file type is not accepted';

  @override
  String fileTooLarge(String name, String size) => '$name: larger than $size';

  @override
  String tooManyFiles(String name, int max) => max == 1
      ? '$name: only 1 file can be added'
      : '$name: only $max files can be added';

  @override
  String folderNotAccepted(String name) => '$name: folders are not accepted';

  @override
  String get download => 'Download';

  @override
  String get downloadUnavailable =>
      'Downloads are not available on this device';

  @override
  String get passwordStrength => 'Password strength';

  @override
  String get passwordVeryWeak => 'Very weak';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordFair => 'Fair';

  @override
  String get passwordGood => 'Good';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get passwordAvoidCommon => 'Avoid common passwords';

  @override
  String get passwordAvoidPersonalInfo => 'Avoid your name or email';

  @override
  String get passwordAvoidWords => 'Avoid common words';

  @override
  String get passwordAvoidDates => 'Avoid dates';

  @override
  String get passwordAvoidSequences => 'Avoid sequences';

  @override
  String get passwordAvoidRepeats => 'Avoid repeated characters';

  @override
  String get passwordAddLength => 'Add more characters';

  @override
  String get passwordMixCharacters => 'Mix letters, numbers and symbols';

  @override
  String get weekSchedule => 'Weekly schedule';

  @override
  String scheduleSlot(String day, String start, String end, String value) =>
      '$day $start–$end, $value';

  @override
  String usageOf(String used, String total) => '$used of $total';

  @override
  String get codeEditor => 'Code editor';

  @override
  String lineMessage(int line, String kind, String message) =>
      'Line $line, $kind: $message';

  @override
  String get dropFilesOrFoldersHere => 'Drop files or folders here';

  @override
  String get folderItem => 'Folder';

  @override
  String get accounts => 'Accounts';

  @override
  String get addAccount => 'Add account';

  @override
  String switchAccount(String current) => 'Switch account, current: $current';

  @override
  String pendingCount(int count) => '$count pending';

  @override
  String get pathBar => 'Path';

  @override
  String get showPathSegments => 'Show hidden path segments';

  @override
  String get editPath => 'Edit path';

  @override
  String get currentLocation => 'Current location';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get cantDropHere => "Can't drop here";

  @override
  String dragItemCount(int count) => count == 1 ? '1 item' : '$count items';

  @override
  String movedToPosition(String item, int position, int count) =>
      'Moved $item to position $position of $count';

  @override
  String movedInto(String item, String parent, int position) =>
      'Moved $item into $parent, position $position';

  @override
  String movedToTopLevel(String item, int position) =>
      'Moved $item to the top level, position $position';

  @override
  String get indentItem => 'Indent';

  @override
  String get outdentItem => 'Outdent';

  @override
  String get moveColumnLeft => 'Move column left';

  @override
  String get moveColumnRight => 'Move column right';

  @override
  String movedColumn(String column, int position, int count) =>
      'Moved column $column to position $position of $count';

  @override
  String get resetColumns => 'Reset columns';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidValue => 'Invalid value';

  @override
  String formErrorSummary(int count) =>
      count == 1 ? 'Fix 1 error to continue' : 'Fix $count errors to continue';

  @override
  String formErrorCount(int count) =>
      count == 1 ? '1 error in the form' : '$count errors in the form';

  @override
  String get goToField => 'Go to the field';

  @override
  String get unsavedChangesTitle => 'Discard unsaved changes?';

  @override
  String get unsavedChangesMessage => 'The changes made here will be lost.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discardChanges => 'Discard';

  @override
  String get saveChanges => 'Save';
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

  /// Returns [count] followed by the singular or plural Portuguese [unit].
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
  String get brightness => 'Brilho';

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
  String get copyFailed => 'Não foi possível copiar';

  @override
  String get moveWithArrowKeys => 'Use as setas do teclado para mover';

  @override
  String get mainMenu => 'Menu principal';

  @override
  String get moveUp => 'Mover para cima';

  @override
  String get moveDown => 'Mover para baixo';

  @override
  String get moveLeft => 'Mover para a esquerda';

  @override
  String get moveRight => 'Mover para a direita';

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
  String get pendingChange => 'Alteração pendente';

  @override
  String resizeColumn(String column) => 'Redimensionar coluna $column';

  @override
  String get notSorted => 'Sem ordenação';

  @override
  String get sortedAscending => 'Ordem crescente';

  @override
  String get sortedDescending => 'Ordem decrescente';

  @override
  String get loadingMore => 'Carregando mais…';

  @override
  String get loadFailed => 'Não foi possível carregar os itens';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get noItems => 'Nenhum item';

  @override
  String showMore(int count) => 'Mostrar mais $count';

  @override
  String get showFewer => 'Mostrar menos';

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

  @override
  String get dropFilesHere => 'Solte os arquivos aqui';

  @override
  String get chooseFiles => 'Escolher arquivos';

  @override
  String get chooseFile => 'Escolher um arquivo';

  @override
  String acceptedFileTypes(String types) => 'Aceitos: $types';

  @override
  String maxFileSizeHint(String size) => 'Até $size cada';

  @override
  String fileTypeNotAccepted(String name) =>
      '$name: este tipo de arquivo não é aceito';

  @override
  String fileTooLarge(String name, String size) => '$name: maior que $size';

  @override
  String tooManyFiles(String name, int max) => max == 1
      ? '$name: só é possível adicionar 1 arquivo'
      : '$name: só é possível adicionar $max arquivos';

  @override
  String folderNotAccepted(String name) => '$name: pastas não são aceitas';

  @override
  String get download => 'Baixar';

  @override
  String get downloadUnavailable =>
      'Downloads não estão disponíveis neste dispositivo';

  @override
  String get passwordStrength => 'Força da senha';

  @override
  String get passwordVeryWeak => 'Muito fraca';

  @override
  String get passwordWeak => 'Fraca';

  @override
  String get passwordFair => 'Razoável';

  @override
  String get passwordGood => 'Boa';

  @override
  String get passwordStrong => 'Forte';

  @override
  String get passwordAvoidCommon => 'Evite senhas comuns';

  @override
  String get passwordAvoidPersonalInfo => 'Evite seu nome ou e-mail';

  @override
  String get passwordAvoidWords => 'Evite palavras comuns';

  @override
  String get passwordAvoidDates => 'Evite datas';

  @override
  String get passwordAvoidSequences => 'Evite sequências';

  @override
  String get passwordAvoidRepeats => 'Evite caracteres repetidos';

  @override
  String get passwordAddLength => 'Use mais caracteres';

  @override
  String get passwordMixCharacters => 'Misture letras, números e símbolos';

  @override
  String get weekSchedule => 'Agenda semanal';

  @override
  String scheduleSlot(String day, String start, String end, String value) =>
      '$day $start–$end, $value';

  @override
  String usageOf(String used, String total) => '$used de $total';

  @override
  String get codeEditor => 'Editor de código';

  @override
  String lineMessage(int line, String kind, String message) =>
      'Linha $line, $kind: $message';

  @override
  String get dropFilesOrFoldersHere => 'Solte arquivos ou pastas aqui';

  @override
  String get folderItem => 'Pasta';

  @override
  String get accounts => 'Contas';

  @override
  String get addAccount => 'Adicionar conta';

  @override
  String switchAccount(String current) => 'Trocar de conta, atual: $current';

  @override
  String pendingCount(int count) =>
      count == 1 ? '1 pendente' : '$count pendentes';

  @override
  String get pathBar => 'Caminho';

  @override
  String get showPathSegments => 'Mostrar partes ocultas do caminho';

  @override
  String get editPath => 'Editar caminho';

  @override
  String get currentLocation => 'Local atual';

  @override
  String get dragToReorder => 'Arraste para reordenar';

  @override
  String get cantDropHere => 'Não é possível soltar aqui';

  @override
  String dragItemCount(int count) => count == 1 ? '1 item' : '$count itens';

  @override
  String movedToPosition(String item, int position, int count) =>
      'Item "$item" movido para a posição $position de $count';

  @override
  String movedInto(String item, String parent, int position) =>
      'Item "$item" movido para $parent, posição $position';

  @override
  String movedToTopLevel(String item, int position) =>
      'Item "$item" movido para o nível superior, posição $position';

  @override
  String get indentItem => 'Aumentar recuo';

  @override
  String get outdentItem => 'Diminuir recuo';

  @override
  String get moveColumnLeft => 'Mover coluna para a esquerda';

  @override
  String get moveColumnRight => 'Mover coluna para a direita';

  @override
  String movedColumn(String column, int position, int count) =>
      'Coluna "$column" movida para a posição $position de $count';

  @override
  String get resetColumns => 'Redefinir colunas';

  @override
  String get fieldRequired => 'Este campo é obrigatório';

  @override
  String get invalidValue => 'Valor inválido';

  @override
  String formErrorSummary(int count) => count == 1
      ? 'Corrija 1 erro para continuar'
      : 'Corrija $count erros para continuar';

  @override
  String formErrorCount(int count) =>
      count == 1 ? '1 erro no formulário' : '$count erros no formulário';

  @override
  String get goToField => 'Ir para o campo';

  @override
  String get unsavedChangesTitle => 'Descartar as alterações não salvas?';

  @override
  String get unsavedChangesMessage =>
      'As alterações feitas aqui serão perdidas.';

  @override
  String get keepEditing => 'Continuar editando';

  @override
  String get discardChanges => 'Descartar';

  @override
  String get saveChanges => 'Salvar';
}

/// Loads [Oito2Localizations.forLocale] synchronously for English and
/// Portuguese locales.
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
