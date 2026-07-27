# Legacy icon sources

These SVGs are **not bundled with the app**. Flutter's `assets/icons/` entry in
`pubspec.yaml` is not recursive, so files in this subdirectory are excluded from
the asset bundle automatically.

They are kept for one reason: they are the source art that `assets/fonts/nahpu_font.ttf`
was generated from, via <https://github.com/nahpu/nahpu-icon-generator>. The glyph
codepoints in `lib/services/types/nahpu_icons.dart` map 1:1 onto the sixteen
`<name>_filled` / `<name>_outlined` pairs here.

Do not add new icons here. New UI icons belong directly in `assets/icons/`, drawn
on the 48x48 two-weight grid described in that directory's `README.md`.

## Regenerating the font

The font is currently byte-identical to what these files produced, so the six
glyphs actually referenced in Dart (`ratFilled/Outlined`, `birdFilled/Outlined`,
`amphibianFilled/Outlined`) keep working untouched.

Regenerating from the newer 48-grid art is a separate task: it requires the
generator repo above and will renumber glyph codepoints, so `nahpu_icons.dart`
must be regenerated in the same pass. Ten of the sixteen glyphs (`bat`, `mite`,
`mouse`, `snake`, `tick` x filled/outlined) are referenced nowhere and should be
dropped at that point.

## Contents

- Font sources (16): `amphibian`, `bat`, `bird`, `mite`, `mouse`, `rat`, `snake`,
  `tick` — each `_filled` and `_outlined`.
- Never wired up (6): `bird_skull*`, `bird_skeleton*`. Superseded by the
  `bird_skull.svg` / `bird_skeleton.svg` in `assets/icons/`, which are reachable
  through `SpecimenPartIcon`.

`amphibian_filled`, `mouse_filled`, `rat_filled` and `snake_filled` are
machine-traced: thousands of `L` commands each, roughly 52 KB combined. They are
not editable by hand and should be redrawn rather than tweaked.
