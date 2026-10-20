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

import 'package:flutter/widgets.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Icons named after the freedesktop.org Icon Naming Specification, drawn
/// with the Lucide icons oito2_ui uses.
///
/// Linux integrations refer to icons by these names, for example in
/// `.desktop` files, notifications and tray items; [byName] turns such a
/// name into an icon. Each value keeps its specification name in
/// [iconName], such as `document-open`.
///
/// ```dart
/// Icon(Oito2FreedesktopIcons.documentOpen.icon);
/// Icon(Oito2FreedesktopIcons.byName('dialog-warning')?.icon);
/// ```
enum Oito2FreedesktopIcons {
  // Actions.
  /// `address-book-new`.
  addressBookNew('address-book-new', LucideIcons.book_user),

  /// `application-exit`.
  applicationExit('application-exit', LucideIcons.log_out),

  /// `appointment-new`.
  appointmentNew('appointment-new', LucideIcons.calendar_plus),

  /// `call-start`.
  callStart('call-start', LucideIcons.phone),

  /// `call-stop`.
  callStop('call-stop', LucideIcons.phone_off),

  /// `contact-new`.
  contactNew('contact-new', LucideIcons.user_plus),

  /// `document-new`.
  documentNew('document-new', LucideIcons.file_plus),

  /// `document-open`.
  documentOpen('document-open', LucideIcons.folder_open),

  /// `document-open-recent`.
  documentOpenRecent('document-open-recent', LucideIcons.file_clock),

  /// `document-page-setup`.
  documentPageSetup('document-page-setup', LucideIcons.file_cog),

  /// `document-print`.
  documentPrint('document-print', LucideIcons.printer),

  /// `document-print-preview`.
  documentPrintPreview('document-print-preview', LucideIcons.file_search),

  /// `document-properties`.
  documentProperties('document-properties', LucideIcons.file_cog),

  /// `document-revert`.
  documentRevert('document-revert', LucideIcons.undo_2),

  /// `document-save`.
  documentSave('document-save', LucideIcons.save),

  /// `document-save-as`.
  documentSaveAs('document-save-as', LucideIcons.save_all),

  /// `document-send`.
  documentSend('document-send', LucideIcons.send),

  /// `edit-clear`.
  editClear('edit-clear', LucideIcons.eraser),

  /// `edit-copy`.
  editCopy('edit-copy', LucideIcons.copy),

  /// `edit-cut`.
  editCut('edit-cut', LucideIcons.scissors),

  /// `edit-delete`.
  editDelete('edit-delete', LucideIcons.trash),

  /// `edit-find`.
  editFind('edit-find', LucideIcons.search),

  /// `edit-find-replace`.
  editFindReplace('edit-find-replace', LucideIcons.replace),

  /// `edit-paste`.
  editPaste('edit-paste', LucideIcons.clipboard_paste),

  /// `edit-redo`.
  editRedo('edit-redo', LucideIcons.redo_2),

  /// `edit-select-all`.
  editSelectAll('edit-select-all', LucideIcons.square_dashed_mouse_pointer),

  /// `edit-undo`.
  editUndo('edit-undo', LucideIcons.undo_2),

  /// `folder-new`.
  folderNew('folder-new', LucideIcons.folder_plus),

  /// `format-indent-less`.
  formatIndentLess('format-indent-less', LucideIcons.list_indent_decrease),

  /// `format-indent-more`.
  formatIndentMore('format-indent-more', LucideIcons.list_indent_increase),

  /// `format-justify-center`.
  formatJustifyCenter('format-justify-center', LucideIcons.text_align_center),

  /// `format-justify-fill`.
  formatJustifyFill('format-justify-fill', LucideIcons.text_align_justify),

  /// `format-justify-left`.
  formatJustifyLeft('format-justify-left', LucideIcons.text_align_start),

  /// `format-justify-right`.
  formatJustifyRight('format-justify-right', LucideIcons.text_align_end),

  /// `format-text-bold`.
  formatTextBold('format-text-bold', LucideIcons.bold),

  /// `format-text-italic`.
  formatTextItalic('format-text-italic', LucideIcons.italic),

  /// `format-text-strikethrough`.
  formatTextStrikethrough(
    'format-text-strikethrough',
    LucideIcons.strikethrough,
  ),

  /// `format-text-underline`.
  formatTextUnderline('format-text-underline', LucideIcons.underline),

  /// `go-bottom`.
  goBottom('go-bottom', LucideIcons.arrow_down_to_line),

  /// `go-down`.
  goDown('go-down', LucideIcons.arrow_down),

  /// `go-first`.
  goFirst('go-first', LucideIcons.chevrons_left),

  /// `go-home`.
  goHome('go-home', LucideIcons.house),

  /// `go-jump`.
  goJump('go-jump', LucideIcons.corner_down_right),

  /// `go-last`.
  goLast('go-last', LucideIcons.chevrons_right),

  /// `go-next`.
  goNext('go-next', LucideIcons.arrow_right),

  /// `go-previous`.
  goPrevious('go-previous', LucideIcons.arrow_left),

  /// `go-top`.
  goTop('go-top', LucideIcons.arrow_up_to_line),

  /// `go-up`.
  goUp('go-up', LucideIcons.arrow_up),

  /// `help-about`.
  helpAbout('help-about', LucideIcons.info),

  /// `help-contents`.
  helpContents('help-contents', LucideIcons.circle_question_mark),

  /// `help-faq`.
  helpFaq('help-faq', LucideIcons.message_circle_question_mark),

  /// `insert-image`.
  insertImage('insert-image', LucideIcons.image_plus),

  /// `insert-link`.
  insertLink('insert-link', LucideIcons.link),

  /// `insert-text`.
  insertText('insert-text', LucideIcons.type),

  /// `list-add`.
  listAdd('list-add', LucideIcons.plus),

  /// `list-remove`.
  listRemove('list-remove', LucideIcons.minus),

  /// `mail-forward`.
  mailForward('mail-forward', LucideIcons.forward),

  /// `mail-mark-important`.
  mailMarkImportant('mail-mark-important', LucideIcons.flag),

  /// `mail-mark-read`.
  mailMarkRead('mail-mark-read', LucideIcons.mail_open),

  /// `mail-message-new`.
  mailMessageNew('mail-message-new', LucideIcons.mail_plus),

  /// `mail-reply-all`.
  mailReplyAll('mail-reply-all', LucideIcons.reply_all),

  /// `mail-reply-sender`.
  mailReplySender('mail-reply-sender', LucideIcons.reply),

  /// `mail-send`.
  mailSend('mail-send', LucideIcons.send),

  /// `media-eject`.
  mediaEject('media-eject', LucideIcons.disc),

  /// `media-playback-pause`.
  mediaPlaybackPause('media-playback-pause', LucideIcons.pause),

  /// `media-playback-start`.
  mediaPlaybackStart('media-playback-start', LucideIcons.play),

  /// `media-playback-stop`.
  mediaPlaybackStop('media-playback-stop', LucideIcons.square),

  /// `media-record`.
  mediaRecord('media-record', LucideIcons.circle_dot),

  /// `media-seek-backward`.
  mediaSeekBackward('media-seek-backward', LucideIcons.rewind),

  /// `media-seek-forward`.
  mediaSeekForward('media-seek-forward', LucideIcons.fast_forward),

  /// `media-skip-backward`.
  mediaSkipBackward('media-skip-backward', LucideIcons.skip_back),

  /// `media-skip-forward`.
  mediaSkipForward('media-skip-forward', LucideIcons.skip_forward),

  /// `object-flip-horizontal`.
  objectFlipHorizontal('object-flip-horizontal', LucideIcons.arrow_left_right),

  /// `object-flip-vertical`.
  objectFlipVertical('object-flip-vertical', LucideIcons.arrow_up_down),

  /// `object-rotate-left`.
  objectRotateLeft('object-rotate-left', LucideIcons.rotate_ccw),

  /// `object-rotate-right`.
  objectRotateRight('object-rotate-right', LucideIcons.rotate_cw),

  /// `process-stop`.
  processStop('process-stop', LucideIcons.octagon_x),

  /// `system-lock-screen`.
  systemLockScreen('system-lock-screen', LucideIcons.lock),

  /// `system-log-out`.
  systemLogOut('system-log-out', LucideIcons.log_out),

  /// `system-reboot`.
  systemReboot('system-reboot', LucideIcons.rotate_cw),

  /// `system-run`.
  systemRun('system-run', LucideIcons.play),

  /// `system-search`.
  systemSearch('system-search', LucideIcons.search),

  /// `system-shutdown`.
  systemShutdown('system-shutdown', LucideIcons.power),

  /// `tools-check-spelling`.
  toolsCheckSpelling('tools-check-spelling', LucideIcons.spell_check),

  /// `view-fullscreen`.
  viewFullscreen('view-fullscreen', LucideIcons.maximize),

  /// `view-refresh`.
  viewRefresh('view-refresh', LucideIcons.refresh_cw),

  /// `view-restore`.
  viewRestore('view-restore', LucideIcons.minimize),

  /// `view-sort-ascending`.
  viewSortAscending('view-sort-ascending', LucideIcons.arrow_up_narrow_wide),

  /// `view-sort-descending`.
  viewSortDescending(
    'view-sort-descending',
    LucideIcons.arrow_down_wide_narrow,
  ),

  /// `window-close`.
  windowClose('window-close', LucideIcons.x),

  /// `window-new`.
  windowNew('window-new', LucideIcons.app_window),

  /// `zoom-fit-best`.
  zoomFitBest('zoom-fit-best', LucideIcons.scan),

  /// `zoom-in`.
  zoomIn('zoom-in', LucideIcons.zoom_in),

  /// `zoom-original`.
  zoomOriginal('zoom-original', LucideIcons.search),

  /// `zoom-out`.
  zoomOut('zoom-out', LucideIcons.zoom_out),

  // Applications.
  /// `accessories-calculator`.
  accessoriesCalculator('accessories-calculator', LucideIcons.calculator),

  /// `accessories-text-editor`.
  accessoriesTextEditor('accessories-text-editor', LucideIcons.file_pen),

  /// `help-browser`.
  helpBrowser('help-browser', LucideIcons.book_open),

  /// `multimedia-volume-control`.
  multimediaVolumeControl('multimedia-volume-control', LucideIcons.volume_2),

  /// `preferences-desktop-accessibility`.
  preferencesDesktopAccessibility(
    'preferences-desktop-accessibility',
    LucideIcons.accessibility,
  ),

  /// `preferences-desktop-font`.
  preferencesDesktopFont('preferences-desktop-font', LucideIcons.type),

  /// `preferences-desktop-keyboard`.
  preferencesDesktopKeyboard(
    'preferences-desktop-keyboard',
    LucideIcons.keyboard,
  ),

  /// `preferences-desktop-locale`.
  preferencesDesktopLocale('preferences-desktop-locale', LucideIcons.languages),

  /// `preferences-desktop-theme`.
  preferencesDesktopTheme('preferences-desktop-theme', LucideIcons.palette),

  /// `preferences-system`.
  preferencesSystem('preferences-system', LucideIcons.settings),

  /// `system-file-manager`.
  systemFileManager('system-file-manager', LucideIcons.folder),

  /// `utilities-terminal`.
  utilitiesTerminal('utilities-terminal', LucideIcons.terminal),

  /// `utilities-system-monitor`.
  utilitiesSystemMonitor('utilities-system-monitor', LucideIcons.activity),

  // Categories.
  /// `applications-games`.
  applicationsGames('applications-games', LucideIcons.gamepad_2),

  /// `applications-graphics`.
  applicationsGraphics('applications-graphics', LucideIcons.brush),

  /// `applications-internet`.
  applicationsInternet('applications-internet', LucideIcons.globe),

  /// `applications-multimedia`.
  applicationsMultimedia('applications-multimedia', LucideIcons.clapperboard),

  /// `applications-office`.
  applicationsOffice('applications-office', LucideIcons.briefcase),

  /// `applications-science`.
  applicationsScience('applications-science', LucideIcons.flask_conical),

  /// `applications-utilities`.
  applicationsUtilities('applications-utilities', LucideIcons.wrench),

  /// `applications-development`.
  applicationsDevelopment('applications-development', LucideIcons.code),

  // Devices.
  /// `audio-card`.
  audioCard('audio-card', LucideIcons.audio_lines),

  /// `audio-input-microphone`.
  audioInputMicrophone('audio-input-microphone', LucideIcons.mic),

  /// `battery`.
  battery('battery', LucideIcons.battery),

  /// `camera-photo`.
  cameraPhoto('camera-photo', LucideIcons.camera),

  /// `camera-video`.
  cameraVideo('camera-video', LucideIcons.video),

  /// `camera-web`.
  cameraWeb('camera-web', LucideIcons.webcam),

  /// `computer`.
  computer('computer', LucideIcons.monitor),

  /// `drive-harddisk`.
  driveHarddisk('drive-harddisk', LucideIcons.hard_drive),

  /// `drive-optical`.
  driveOptical('drive-optical', LucideIcons.disc),

  /// `drive-removable-media`.
  driveRemovableMedia('drive-removable-media', LucideIcons.usb),

  /// `input-gaming`.
  inputGaming('input-gaming', LucideIcons.gamepad),

  /// `input-keyboard`.
  inputKeyboard('input-keyboard', LucideIcons.keyboard),

  /// `input-mouse`.
  inputMouse('input-mouse', LucideIcons.mouse),

  /// `input-tablet`.
  inputTablet('input-tablet', LucideIcons.tablet),

  /// `media-flash`.
  mediaFlash('media-flash', LucideIcons.memory_stick),

  /// `network-wired`.
  networkWired('network-wired', LucideIcons.ethernet_port),

  /// `network-wireless`.
  networkWireless('network-wireless', LucideIcons.wifi),

  /// `phone`.
  phone('phone', LucideIcons.smartphone),

  /// `printer`.
  printer('printer', LucideIcons.printer),

  /// `scanner`.
  scanner('scanner', LucideIcons.scan),

  /// `video-display`.
  videoDisplay('video-display', LucideIcons.monitor),

  // Emblems.
  /// `emblem-default`.
  emblemDefault('emblem-default', LucideIcons.circle_check),

  /// `emblem-documents`.
  emblemDocuments('emblem-documents', LucideIcons.file_text),

  /// `emblem-favorite`.
  emblemFavorite('emblem-favorite', LucideIcons.heart),

  /// `emblem-important`.
  emblemImportant('emblem-important', LucideIcons.circle_alert),

  /// `emblem-mail`.
  emblemMail('emblem-mail', LucideIcons.mail),

  /// `emblem-photos`.
  emblemPhotos('emblem-photos', LucideIcons.image),

  /// `emblem-readonly`.
  emblemReadonly('emblem-readonly', LucideIcons.lock),

  /// `emblem-shared`.
  emblemShared('emblem-shared', LucideIcons.share_2),

  /// `emblem-symbolic-link`.
  emblemSymbolicLink('emblem-symbolic-link', LucideIcons.link),

  /// `emblem-system`.
  emblemSystem('emblem-system', LucideIcons.settings),

  /// `emblem-unreadable`.
  emblemUnreadable('emblem-unreadable', LucideIcons.file_x),

  // Places.
  /// `folder`.
  folder('folder', LucideIcons.folder),

  /// `folder-remote`.
  folderRemote('folder-remote', LucideIcons.folder_sync),

  /// `network-server`.
  networkServer('network-server', LucideIcons.server),

  /// `network-workgroup`.
  networkWorkgroup('network-workgroup', LucideIcons.network),

  /// `start-here`.
  startHere('start-here', LucideIcons.house),

  /// `user-bookmarks`.
  userBookmarks('user-bookmarks', LucideIcons.bookmark),

  /// `user-desktop`.
  userDesktop('user-desktop', LucideIcons.monitor),

  /// `user-home`.
  userHome('user-home', LucideIcons.house),

  /// `user-trash`.
  userTrash('user-trash', LucideIcons.trash),

  // Status.
  /// `appointment-soon`.
  appointmentSoon('appointment-soon', LucideIcons.calendar_clock),

  /// `audio-volume-high`.
  audioVolumeHigh('audio-volume-high', LucideIcons.volume_2),

  /// `audio-volume-low`.
  audioVolumeLow('audio-volume-low', LucideIcons.volume_1),

  /// `audio-volume-medium`.
  audioVolumeMedium('audio-volume-medium', LucideIcons.volume_1),

  /// `audio-volume-muted`.
  audioVolumeMuted('audio-volume-muted', LucideIcons.volume_x),

  /// `battery-caution`.
  batteryCaution('battery-caution', LucideIcons.battery_warning),

  /// `battery-low`.
  batteryLow('battery-low', LucideIcons.battery_low),

  /// `dialog-error`.
  dialogError('dialog-error', LucideIcons.circle_x),

  /// `dialog-information`.
  dialogInformation('dialog-information', LucideIcons.info),

  /// `dialog-password`.
  dialogPassword('dialog-password', LucideIcons.key_round),

  /// `dialog-question`.
  dialogQuestion('dialog-question', LucideIcons.circle_question_mark),

  /// `dialog-warning`.
  dialogWarning('dialog-warning', LucideIcons.triangle_alert),

  /// `folder-drag-accept`.
  folderDragAccept('folder-drag-accept', LucideIcons.folder_input),

  /// `folder-open`.
  folderOpen('folder-open', LucideIcons.folder_open),

  /// `image-loading`.
  imageLoading('image-loading', LucideIcons.loader),

  /// `image-missing`.
  imageMissing('image-missing', LucideIcons.image_off),

  /// `mail-attachment`.
  mailAttachment('mail-attachment', LucideIcons.paperclip),

  /// `mail-unread`.
  mailUnread('mail-unread', LucideIcons.mail),

  /// `network-error`.
  networkError('network-error', LucideIcons.wifi_off),

  /// `network-idle`.
  networkIdle('network-idle', LucideIcons.wifi),

  /// `network-offline`.
  networkOffline('network-offline', LucideIcons.wifi_off),

  /// `network-receive`.
  networkReceive('network-receive', LucideIcons.download),

  /// `network-transmit`.
  networkTransmit('network-transmit', LucideIcons.upload),

  /// `printer-error`.
  printerError('printer-error', LucideIcons.printer),

  /// `software-update-available`.
  softwareUpdateAvailable(
    'software-update-available',
    LucideIcons.circle_arrow_up,
  ),

  /// `software-update-urgent`.
  softwareUpdateUrgent('software-update-urgent', LucideIcons.circle_alert),

  /// `sync-error`.
  syncError('sync-error', LucideIcons.refresh_cw_off),

  /// `sync-synchronizing`.
  syncSynchronizing('sync-synchronizing', LucideIcons.refresh_cw),

  /// `task-due`.
  taskDue('task-due', LucideIcons.clock_alert),

  /// `user-available`.
  userAvailable('user-available', LucideIcons.circle_check),

  /// `user-away`.
  userAway('user-away', LucideIcons.clock),

  /// `user-idle`.
  userIdle('user-idle', LucideIcons.moon),

  /// `user-offline`.
  userOffline('user-offline', LucideIcons.circle_minus),

  /// `user-trash-full`.
  userTrashFull('user-trash-full', LucideIcons.trash),

  /// `weather-clear`.
  weatherClear('weather-clear', LucideIcons.sun),

  /// `weather-few-clouds`.
  weatherFewClouds('weather-few-clouds', LucideIcons.cloud_sun),

  /// `weather-fog`.
  weatherFog('weather-fog', LucideIcons.cloud_fog),

  /// `weather-overcast`.
  weatherOvercast('weather-overcast', LucideIcons.cloud),

  /// `weather-severe-alert`.
  weatherSevereAlert('weather-severe-alert', LucideIcons.cloud_alert),

  /// `weather-showers`.
  weatherShowers('weather-showers', LucideIcons.cloud_rain),

  /// `weather-snow`.
  weatherSnow('weather-snow', LucideIcons.cloud_snow),

  /// `weather-storm`.
  weatherStorm('weather-storm', LucideIcons.cloud_lightning);

  const Oito2FreedesktopIcons(this.iconName, this.icon);

  /// The name in the Icon Naming Specification, such as `edit-copy`.
  final String iconName;

  /// The icon.
  final IconData icon;

  static final Map<String, Oito2FreedesktopIcons> _byName = {
    for (final value in values) value.iconName: value,
  };

  /// The icon for a specification [name], such as `document-save`, or
  /// null for a name without a mapping. A trailing `-symbolic` is ignored.
  static Oito2FreedesktopIcons? byName(String name) =>
      _byName[name.endsWith('-symbolic')
          ? name.substring(0, name.length - '-symbolic'.length)
          : name];
}
