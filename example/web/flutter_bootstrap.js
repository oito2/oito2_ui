{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Fonts for characters the bundled fonts lack are looked up on this
    // site instead of a third-party CDN; none are published, so such
    // characters show without a fallback font.
    fontFallbackBaseUrl: 'fonts/fallback/',
  },
});
