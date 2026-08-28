# Icons

Every SVG directly in this directory is bundled with the app (`pubspec.yaml` →
`flutter: assets: - assets/icons/`) and loaded by path through `SvgPicture.asset`.

These are separate from the **icon font**. `NahpuIcons`
(`assets/fonts/nahpu_font.ttf`, `lib/services/types/nahpu_icons.dart`) is built
from its own 24-grid sources in the
[nahpu-icon-generator](https://github.com/nahpu/nahpu-icon-generator) repo and
rendered with `Icon(...)` rather than `SvgPicture`. Only the built `.ttf` and the
generated Dart class live here — never the font's SVG sources. The two grids are
not interchangeable: the font is 24x24 at stroke 2, these are 48x48 at stroke 3.

`test/icon_asset_test.dart` enforces most of what follows. Run `flutter test` after
adding or editing an icon.

## Grid and stroke system

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 48 48"
     fill="none" stroke="currentColor" stroke-width="3"
     stroke-linecap="round" stroke-linejoin="round">
  <path d="…" />                    <!-- primary silhouette, inherits stroke-width 3 -->
  <g stroke-width="2">
    <path d="…" />                  <!-- interior detail -->
  </g>
</svg>
```

- **48x48 viewBox.** Twice the resolution of the old 24 grid, so anatomy can be
  drawn with real coordinates instead of rounded-off ones.
- **Two weights only.** `3` for the silhouette that carries recognition, `2` for
  interior detail. On the 48 grid these render exactly as `2` and `1.33` did on
  the 24 grid, so nothing got visually heavier.
- **`stroke="currentColor"`, `fill="none"`.** Required — see below.

## The two constraints that shape every icon

**One flat color.** Every call site wraps the icon in
`ColorFilter.mode(color, BlendMode.srcIn)`, and `getIconColor`
(`lib/styles/decoration.dart`) returns `colorScheme.outline`. So:

- Fill vs. stroke contrast does nothing. Overlapping strokes do not darken.
- Detail must come from **line separation and negative space**, never shading.
- `fill="currentColor"` is fine where a solid shape is genuinely wanted (see
  `qr-code.svg`), but it will be the same flat color as everything else.

**One asset, four render sizes.** The same file is drawn at:

| Size | Widget | Where |
|---|---|---|
| 28px | `TileSvgIcon` | specimen part rows, coordinate rows, effort rows |
| 64px | `CommonEmptyForm` | empty states |
| 80px | `QrIcon` | QR view |
| 116px | `FileFormatIcon` | export/bundle format pickers |

28px in the muted outline color is the binding constraint. A line that vanishes there is
wasted work, so **budget 3–4 interior detail strokes** for anything reachable at
28px. Icons that only ever render at 64px or larger (`forest`, `agendas`,
`planner`, `box`, `image-gallery`, the file formats) can afford more.

## Adding an icon

1. Draw on the 48 grid with the two weights above.
2. Add it directly in this directory.
3. Reference it from Dart by path. If it is a specimen part, add it to
   `partIconPath` or `preparationIconPath` in `lib/services/types/specimens.dart`
   rather than hardcoding the string at the call site. If it is a collecting
   method, add it to `CollMethodIcon` in `lib/services/types/events.dart`
   the same way.
4. `flutter test` — the asset test checks the viewBox, the color declaration,
   that every path referenced from `lib/` exists, and that no two icons are
   byte-identical.

That last check exists for a reason: before this system, ten of the icons here
were exact duplicates of another file, and `agendas.svg`/`planner.svg` were the
same calendar shown in two different empty states.
