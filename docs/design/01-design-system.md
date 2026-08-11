# 01 — Design System: MyQuran

All values are implementation-ready. Sizes are in logical pixels (dp); Flutter handles device
pixel ratio on desktop automatically.

---

## 1. Color

### 1.1 Generation rule (locked)

```text
light = ColorScheme.fromSeed(seedColor: Color(0xFF1D6B58), brightness: Brightness.light,
                             dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot)
dark  = ColorScheme.fromSeed(seedColor: Color(0xFF1D6B58), brightness: Brightness.dark,
                             dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot)
Then copyWith() the roles in §1.3/§1.4 to pin the exact values below.
No dynamic color on desktop.
```

Rationale: `tonalSpot` deliberately de-saturates the seed, keeping the palette calm even though
the seed is a strong green. `copyWith` pins the design-critical roles so the design is
reproducible regardless of `material-color-utilities` version drift. Roles **not** listed here
(rarely used: `primaryFixed`, `onPrimaryFixed`, `surfaceBright`, `surfaceDim`, `surfaceTint`)
keep algorithm defaults; `surfaceTint` is forced transparent on elevated components so surfaces
stay flat and paper-like (see §4).

### 1.2 Seed & family

| Token | Hex | Role |
|---|---|---|
| Seed "Evergreen" | `#1D6B58` | deep muted pine-teal (hue ≈ 165°, chroma ≈ 40) — the brand root |
| Family | evergreen | primary is always green; reading surface is warm paper; tertiary is brass gold |
| Mood | "book + paper + brass" | reading-product palette validated against warm-paper (#FFFBEB family) + amber accent research |

### 1.3 Light theme (full role table)

| M3 role | Hex | Usage in MyQuran |
|---|---|---|
| `primary` | `#3B6B5C` | active nav item, filled buttons, links, focus ring, selected segmented segment, switch ON |
| `onPrimary` | `#FFFFFF` | text/icons on primary |
| `primaryContainer` | `#D0EAE0` | selected nav pill fill, current-ayah highlight wash, tonal buttons |
| `onPrimaryContainer` | `#0A2A20` | text/icons on primaryContainer |
| `secondary` | `#5A645D` | secondary icon actions, quieter emphasis |
| `onSecondary` | `#FFFFFF` | |
| `secondaryContainer` | `#DEE9E2` | hover fill for icon buttons, list hover tint |
| `onSecondaryContainer` | `#16201A` | |
| `tertiary` | `#7A5B00` | brass-gold text (AA-safe) — bismillah, bookmark icon, ornaments |
| `onTertiary` | `#FFFFFF` | |
| `tertiaryContainer` | `#F6E177` | subtle gold fills (chip selected, marker ring fill) |
| `onTertiaryContainer` | `#241A00` | |
| `error` | `#BA1A1A` | destructive text/icons |
| `onError` | `#FFFFFF` | |
| `errorContainer` | `#FFDAD6` | destructive action background |
| `onErrorContainer` | `#410002` | |
| `surface` | `#FAFBF8` | app chrome base |
| `surfaceContainerLowest` | `#FFFFFF` | dialogs, popovers, search overlay card |
| `surfaceContainerLow` | `#F3F5F1` | search field bg, tafsir panel chrome |
| `surfaceContainer` | `#EDEFEA` | hover fills, inputs |
| `surfaceContainerHigh` | `#E7E9E4` | pressed fills |
| `surfaceContainerHighest` | `#E1E4DE` | disabled fills |
| `onSurface` | `#191C19` | primary text (chrome) |
| `onSurfaceVariant` | `#434744` | secondary text, meta rows |
| `outline` | `#737874` | borders, strokes (≥ 3:1 for UI) |
| `outlineVariant` | `#C3C8C2` | hairline dividers (non-critical) |
| `inverseSurface` / `onInverseSurface` | `#2E312E` / `#EFF1EC` | inverse surfaces (snackbar) |
| `inversePrimary` | `#9ED0BF` | |
| `shadow` | `#000000` | shadows at elevation opacities (§4) |
| `scrim` | `#000000` @ 40% | search overlay + dialogs (40–60% rule) |

### 1.4 Dark theme (full role table)

| M3 role | Hex | Usage in MyQuran |
|---|---|---|
| `primary` | `#A8D4C0` | active nav, links, focus ring, selected segment |
| `onPrimary` | `#0D3A2C` | |
| `primaryContainer` | `#2E5246` | selected nav fill, current-ayah highlight wash |
| `onPrimaryContainer` | `#C4F0DD` | |
| `secondary` | `#C0C9C1` | secondary icons |
| `onSecondary` | `#262E28` | |
| `secondaryContainer` | `#3C453E` | icon-button hover |
| `onSecondaryContainer` | `#DCE6DC` | |
| `tertiary` | `#E0BE45` | brass-gold text on dark |
| `onTertiary` | `#3A2E00` | |
| `tertiaryContainer` | `#544200` | gold-tinted fills |
| `onTertiaryContainer` | `#FBE16A` | |
| `error` | `#FFB4AB` | |
| `onError` | `#690005` | |
| `errorContainer` | `#93000A` | |
| `onErrorContainer` | `#FFDAD6` | |
| `surface` | `#101410` | chrome base (deep olive-black) |
| `surfaceContainerLowest` | `#0B0E0B` | dialogs, popovers |
| `surfaceContainerLow` | `#181C18` | search field bg, panels |
| `surfaceContainer` | `#1C211C` | hover fills |
| `surfaceContainerHigh` | `#262B26` | pressed fills |
| `surfaceContainerHighest` | `#313631` | disabled fills |
| `onSurface` | `#E0E4DE` | primary text |
| `onSurfaceVariant` | `#BFC6BE` | secondary text |
| `outline` | `#899189` | borders |
| `outlineVariant` | `#3E463F` | hairlines |
| `inverseSurface` / `onInverseSurface` | `#E0E4DE` / `#2E312E` | |
| `inversePrimary` | `#3B6B5C` | |
| `scrim` | `#000000` @ 55% | scrim slightly stronger in dark |

### 1.5 Custom tokens — the reading surface ("paper")

These extend M3. The reading column uses them; all chrome uses the M3 roles above. This
chrome/paper split is the core identity device.

| Token | Light | Dark | Usage |
|---|---|---|---|
| `quranSurface` | `#FDFAF2` | `#151710` | reading column background ("warm paper") |
| `quranInk` | `#211D12` | `#F0EADA` | Arabic script text (peak contrast on paper) |
| `quranInkSecondary` | `#3F3A2E` | `#BDB7A8` | translation + tafsir text on paper |
| `quranAccent` | `#8A6A00` | `#C9A545` | bismillah, marker ring, ornament diamond, filled bookmark |
| `quranRule` | `#E7E1D2` | `#2C2B22` | hairlines on paper (ayah separators, ornament rule) |
| `quranHighlight` | `#D0EAE0` @ 45% | `#2E5246` @ 45% | current-reading ayah wash |
| `quranBookmarkTint` | `#F6E177` @ 30% | `#544200` @ 30% | soft gold wash behind bookmarked ayah |
| `quranHeaderGlow` | `#3B6B5C` @ 4% | `#A8D4C0` @ 5% | radial wash behind surah header (atmosphere, barely visible) |

### 1.6 Usage rules

- **One accent at a time.** Evergreen `primary` for interaction; brass `tertiary`/`quranAccent`
  only for scriptural cues and bookmarks. Never use both at equal strength in one view.
- **Text on paper** always uses `quranInk`/`quranInkSecondary`/`quranAccent` — never M3
  `onSurface` — so the reading column stays warm even in light mode.
- **Hairlines** (`outlineVariant` / `quranRule`) are 1 px and used sparingly; separation in the
  reader comes mostly from whitespace.
- **No color-only meaning.** Every colored state also has shape/text change (e.g., active nav =
  filled pill + label weight; bookmark = filled icon + gold wash).

---

## 2. Typography

### 2.1 Fonts (locked)

| Family | Faces bundled | Use |
|---|---|---|
| **Amiri Quran** (SIL OFL) | regular only — **no bold/italic** | all Quranic Arabic: ayah text, bismillah, surah name in reader header, ayah-end numerals |
| **Inter** (SIL OFL) | 400 / 500 / 600 / 700 | all Latin/chrome UI + Indonesian content |
| **Noto Sans Arabic** (SIL OFL) | 400 / 500 / 600 / 700 | Arabic in UI chrome: surah names in navigation/lists, juz labels, search Arabic previews |

**Hierarchy for Arabic comes from size and color, never weight** (Amiri Quran has one weight).

### 2.2 Critical rules (locked, flutter issue #143975)

1. **Every Arabic style: `letterSpacing: 0.0`.** Any positive tracking breaks Uthmani
   ligature/harakat shaping. Also set `FontFeature.oldStyleFigures()` off where it interferes.
2. **Never justify Arabic text** (`TextAlign.justify`). Stretched word spacing distorts the
   rhythm of harakat. Use right-aligned (`start` in RTL) or centered.
3. **Generous line-height.** Amiri Quran already has tall metrics for waqf marks; total line
   box must stay ≥ 1.7×. Never clip diacritics (no fixed-height containers around Arabic).
4. **RTL per widget.** Each Arabic text widget gets `textDirection: TextDirection.rtl`;
   chrome rows stay LTR. Mixed rows (ayah tile) combine an LTR row with RTL children — see
   components.
5. **Latin digits in chrome; Arabic-Indic inside Arabic contexts** (ayah markers, Arabic
   previews). Surah list "286 ayat" uses Latin digits.

### 2.3 UI type scale (Inter; Noto Sans Arabic substitutes for Arabic strings)

| Style | Size / Line | Weight | Tracking | Use |
|---|---|---|---|---|
| Display S | 36 / 44 | 600 | 0 | Home hero headline ("Al-Qur'an") |
| Headline S | 28 / 36 | 600 | 0 | Screen titles (Pengaturan, Penanda, Cari) |
| Title L | 22 / 28 | 500 | 0 | Section headers, reader surah Latin name |
| Title M | 16 / 24 | 500 | 0 | List primary text, surah Latin name in lists |
| Body L | 16 / 26 | 400 | 0 | Settings descriptions, tafsir body text |
| Body M | 14 / 22 | 400 | 0 | Meta rows, secondary info |
| Body S | 12 / 18 | 400 | 0 | Captions, chip labels (never body copy) |
| Label L | 14 / 20 | 500 | 0 | Buttons, nav items, tabs |
| Label M | 12 / 16 | 500 | 0 | Section labels, meta labels, badges |
| Overline S | 11 / 16 | 600 | 0.4 | All-caps eyebrows ("SURAH 1–114", "JUZ 1–30") — the only allowed tracking, Latin only |

Notes: body text never smaller than 12 px in chrome. Numbers that appear in columns (surah
index, ayah counts) use Inter tabular figures.

### 2.4 Quran type scale (Amiri Quran) — the font-size setting

Nine discrete steps (S1–S9), default **S5 = 38 px**. Extensible to S10 = 68 for large screens.

| Step | Size | Line-height | Line box | Translation size* |
|---|---|---|---|---|
| S1 | 24 | 1.90 | 45.6 | 14 (min) |
| S2 | 27 | 1.90 | 51.3 | 14 |
| S3 | 30 | 1.85 | 55.5 | 14 |
| S4 | 34 | 1.80 | 61.2 | 15 |
| **S5** | **38** | **1.80** | **68.4** | **16** (default) |
| S6 | 43 | 1.75 | 75.3 | 18 |
| S7 | 48 | 1.75 | 84.0 | 20 |
| S8 | 54 | 1.70 | 91.8 | 21 |
| S9 | 60 | 1.70 | 102.0 | 22 (max) |
| S10 (optional) | 68 | 1.65 | 112.2 | 22 |

- All steps: `letterSpacing: 0`, `TextDirection.rtl`, weight 400.
- *Translation size formula for any future step: `clamp(14, round(quranSize × 0.42), 22)`.
- Derived spacing (all scale with the setting — never fixed):
  - Ayah gap (space between tiles): `clamp(24, round(quranSize × 0.85), 56)` → 32 @ S5.
  - Translation top gap: `clamp(12, round(quranSize × 0.40), 24)` → 16 @ S5.
  - Ayah marker size: `clamp(28, round(quranSize × 0.90), 56)` → 34 @ S5.
  - Bismillah size: `round(quranSize × 0.92)`, line-height 2.0, centered.
  - Reader column width: `clamp(680, quranSize × 21, 1040)` → 798 @ S5.

### 2.5 Related Arabic styles (chrome, Noto Sans Arabic)

| Style | Size / Line | Weight | Use |
|---|---|---|---|
| Arabic name (list item) | 18 / 24 | 500 | surah Arabic name in Home/Bookmarks/Search lists |
| Arabic name (juz row) | 16 / 22 | 500 | range surah names in Juz view |
| Arabic small | 14 / 20 | 400 | Arabic preview excerpts in Search results |
| Arabic name (reader header) | 44 / 62 | 400 Amiri Quran | the large surah name — scripture typography, fixed (independent of quran scale) |

All chrome Arabic: `letterSpacing: 0`.

---

## 3. Spacing

Base unit 4 px.

| Token | Value | Typical use |
|---|---|---|
| `sp-1` | 4 | icon–text gap, hairline insets |
| `sp-2` | 8 | tight inline gaps, tooltip padding |
| `sp-3` | 12 | compact internal padding |
| `sp-4` | 16 | default control padding, card padding |
| `sp-5` | 20 | list item padding, section gutter |
| `sp-6` | 24 | screen padding, panel padding |
| `sp-7` | 32 | ayah block vertical rhythm, hero padding |
| `sp-8` | 40 | section separation |
| `sp-9` | 48 | large screen padding, reader top/bottom |
| `sp-10` | 64 | header spacing, generous sections |
| `sp-11` | 96 | very wide-window outer margin, empty-state spacing |

Reader-specific rhythm at S5: ayah block top 32 / bottom 32, Arabic→translation 16, ayah gap
32. Reading column horizontal padding: 48 (narrow windows), 64 (wide).

---

## 4. Elevation & shadow

Flat-first editorial system. Shadows only where surfaces overlap.

| Level | Shadow (light) | Dark equivalent | Use |
|---|---|---|---|
| 0 | none | none | default surfaces, lists, reader paper |
| 1 | `0 1 2 rgba(0,0,0,0.08)` | `0 1 2 rgba(0,0,0,0.35)` | popovers, tooltips, jump-to-ayah menu |
| 2 | `0 4 12 rgba(0,0,0,0.12)` | `0 4 12 rgba(0,0,0,0.45)` | search overlay card, dropdown menus |
| 3 | `0 12 28 rgba(0,0,0,0.20)` | `0 12 28 rgba(0,0,0,0.55)` | dialogs |

Rules: no shadows on flat chrome; `surfaceTintColor` transparent (flat M3); scrim behind
overlays per §1.3/1.4; hover states use background color, never shadow.

## 5. Border radius

| Token | Value | Use |
|---|---|---|
| `radius-sm` | 8 | small chips, inputs, focus ring corners |
| `radius-md` | 12 | buttons, list hover fills, tafsir panel, tooltips, markers |
| `radius-lg` | 16 | cards, hero, search overlay, dialog |
| `radius-full` | 999 | pills (nav pill, segmented control), badges, circular markers |

Sidebar is edge-to-edge (radius 0). Reader paper column: radius 0 top, 12 bottom on its
isolated band? No — the paper is a full-height column inset by margins; radius 16 only on the
hero and panels, not the paper itself.

## 6. Iconography

- Family: **Material Icons, Rounded** (bundled with Flutter). One family everywhere; no emoji,
  no mixed sets (app-polish rule).
- Sizes: nav 20 · inline actions 18 · buttons 20 · empty states 48 · marker numerals are text,
  not icons.
- Color: `onSurfaceVariant` default; `primary` when active/selected; `tertiary`/`quranAccent`
  only for bookmark-filled and ornament; `error` for destructive.
- Stroke weight: Rounded default; consistent optical weight; icons are filled for active
  states (e.g., `bookmark` when bookmarked vs `bookmark_border`).
- Key glyph map (Rounded): Beranda `home` · Surah `menu_book` · Juz `format_list_numbered` ·
  Cari `search` · Penanda `bookmarks` / single `bookmark`/`bookmark_border` · Pengaturan
  `settings` · back `arrow_back` · tafsir `description` · close `close` · chevron
  `expand_more`/`expand_less` · theme `light_mode`/`dark_mode`/`settings_brightness` · delete
  `delete_outline` · empty states `auto_stories`, `search_off`, `bookmarks_outlined`.

## 7. Motion & timing

| Token | Value | Use |
|---|---|---|
| `dur-quick` | 100 ms | hover fill, pressed states, tooltip fade |
| `dur-base` | 200 ms | state changes, focus, checkbox/switch, icon swaps |
| `dur-panel` | 300 ms | tafsir expand (AnimatedSize), search overlay open, popover |
| `dur-page` | 400 ms | screen transitions (Home→Reader) |
| Curve enter | `easeOutCubic` | reveals, staggers |
| Curve state | `easeInOutCubic` | color/size/position state changes |
| Curve exit | `easeInCubic` | exits faster than entries (UX rule) |
| Stagger | 80 ms reader / 30 ms lists | page-entry cascade, `Interval`-based, ≤ 6 items |

Prescribed moments (high-impact, sparse):
1. **Reader entry:** surah header fades+sinks 8 px (400 ms), then first 6 ayah tiles fade in
   at 80 ms stagger, 200 ms each. After that, plain rendering (the list is virtualized —
   never animate on scroll).
2. **Tafsir expand:** AnimatedSize 300 ms with content fade; chevron rotates 200 ms.
3. **Current-ayah highlight:** background wash animates 300 ms, scroll is programmatic
   (300 ms, easeInOutCubic); highlight never chases the user's manual scroll.
4. **Progress bar:** width animates 150 ms easeOut.
5. **Search overlay:** scrim fades 200 ms, card fades+sinks 6 px 300 ms, results cascade
   20 ms stagger.

Reduced motion: when `MediaQuery.disableAnimations` — all slides/staggers become 200 ms fades
or are removed; scroll-to-ayah becomes instant. See 04-accessibility.md.
