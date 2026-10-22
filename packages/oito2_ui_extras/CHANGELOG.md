# Changelog

All notable changes to this package are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial package skeleton.
- `Oito2QrCode`, `Oito2QrErrorLevel` and `oito2QrModules`: painted QR codes through the pure-Dart `qr` package, with error-correction levels, rounded modules and a center image.
- `Oito2SignaturePad` and `Oito2SignatureController`: freehand signing with speed and pressure-driven width, undo, clear, `addStroke` and SVG and PNG export; it keeps the pointer from scroll views around it.
- `Oito2ImageCropper`, `Oito2CropController` and `Oito2CropPreview`: a crop box with an aspect ratio or a circle, zoom, pan, quarter turns, flip, keyboard and wheel control, a live preview and the crop at the image's resolution.
- `Oito2NavigationMenu` and `Oito2NavigationMenuItem`: a website-style header menu with flyout panels on `Oito2Popover` and a line that slides under the current item.
- `Oito2ImageCropper.maxDecodedDimension` (4096 by default) decodes large images scaled down to bound their memory, and `onError` reports an image that fails to load.

### Changed

- `Oito2QrCode` with a center image uses the high error level and clears the image area from the modules only.
- `Oito2SignatureController.strokes` returns read-only copies of the strokes.

### Fixed

- `Oito2CropController` keeps its own handle to the image, so `crop()` and `Oito2CropPreview` keep working after the `Oito2ImageCropper` that loaded it is gone.
- `Oito2SignaturePad` draws one stroke at a time and only with the primary mouse button, and repaints a stroke without rebuilding the pad.
- `Oito2QrCode` reuses the encoding of the same data and level, so a rebuild doesn't encode or repaint it again.
- `Oito2ImageCropper` resets the zoom, pan, rotation and flip for a new picture, and `Oito2CropPreview` follows a resized crop box.
- `Oito2NavigationMenu` rejects a negative `selectedIndex`, and `toPngBytes` releases its image when encoding fails.
