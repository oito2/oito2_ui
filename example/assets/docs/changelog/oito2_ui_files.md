# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial package on the official `file_selector` plugin.
- `Oito2FileDropZone`: a dashed zone that opens the file chooser (one or several files, filtered by `XTypeGroup`s) and receives dropped files.
- `Oito2FileDropTargetBuilder`, `oito2PlatformDropTarget` and `oito2CanDropFiles`: files dragged from the desktop are received on the web; other platforms get no drops unless a builder from another source is passed.
- `Oito2FileUploadController`, `Oito2RejectedFile`, `Oito2FileRejection` and `oito2FileMatchesTypes`: accepted types, a size limit and a file count limit, with the refused files and their reasons.
- `Oito2FileUpload`: a drop zone with a hint built from the limits, the refusals of the last addition and the file list with sizes, image previews and remove buttons.
- `Oito2Downloads` and `Oito2DownloadTrigger`: saving bytes as a file through a download on the web and the "Save as" dialog on Linux, Windows and macOS; the trigger builds the data on demand, shows a spinner and is disabled where files can't be saved.

### Fixed

- `Oito2FileUploadController.add` calls made while an earlier one is still checking files wait for it, so `maxFiles` holds across them.
- `Oito2FileDropZone` reports when it is disabled to assistive technologies.
- On the web, a dropped item the browser can't read, such as a folder, is skipped instead of losing the whole drop.
