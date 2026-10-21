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
