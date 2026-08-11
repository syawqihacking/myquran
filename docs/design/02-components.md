# 02 — Components: MyQuran

Every component below lists anatomy, exact sizes, states, and dark-mode notes. All values are
logical px. Colors reference 01-design-system.md tokens.

---

## 1. Sidebar (full) & compact rail

**Purpose:** primary navigation. Two states controlled by window width — see 03-screens.md for
breakpoints (full ≥ 1040, rail 800–1039).

### Full sidebar (264 wide, edge-to-edge, height 100%)
- Background `surface`. Right edge: 1 px hairline `outlineVariant`.
- Content column padding: 12; sections stack: brand (top) → primary nav → spacer → secondary
  nav → footer.
- **Brand mark:** 32×32 rounded 10 tile, fill `primary`, centered Amiri Quran "ق" 18 px in
  `onPrimary`. Beside it label "MyQuran" 16/500 `onSurface`. Bottom of brand: 8 px.
- **Section eyebrow:** Overline S 11/600, `onSurfaceVariant`, all-caps, padding 16 20 8. Two
  sections: "BACA" (Beranda, Daftar Surah, Daftar Juz) and "LAINNYA" (Cari, Penanda, Pengaturan).
- **Nav item:** full-width pill, height 44, radius-full, padding 0 20. Icon 20 `onSurfaceVariant`
  + label Label L 14/500 `onSurfaceVariant`; icon–label gap 12. States:
  - default: transparent bg
  - hover: `secondaryContainer` @ 50%
  - active: `primaryContainer` fill, icon+label `onPrimaryContainer`, label weight 600; a 2 px
    rounded indicator bar at the leading edge? No — the filled pill IS the indicator (color +
    weight, not color alone).
  - focus-visible: global focus ring (see §7).
  - pressed: `secondaryContainer` full.
- **Footer (bottom):** theme quick-toggle icon button 36 (`settings_brightness`, tooltip
  "Ganti tema") + version caption "v1.0.0" Body S `outline`. Separated by hairline `outlineVariant`.
- **Shortcut hint:** "Cari" nav item shows trailing hint chip "Ctrl K" (Overline S, `outlineVariant`
  bg, rounded 6) when window ≥ 1280 wide.

### Compact rail (76 wide)
- Icons 22, centered; brand mark shrinks to 28 tile. Eyebrows hidden. Each item 48 high,
  tooltip shows label (see §8). Active item keeps `primaryContainer` pill (44 radius-full).
- Nav order and semantics identical (no reordering at breakpoints).

**Dark notes:** same tokens; `secondaryContainer` hover uses dark values automatically. Hairline
stays `#3E463F`. Brand tile `#A8D4C0`/`#0D3A2C`.

---

## 2. Reader top chrome bar (56 high, sticky)

**Purpose:** lightweight context + actions in the reader. Background `surface` with 1 px bottom
hairline `outlineVariant`. Height 56.
- **Left:** back icon-button 40 (tooltip "Kembali", `arrow_back`).
- **Center:** surah context — Latin name 14/500 `onSurface` + "Juz 3 · Makkiyah" 12/400
  `onSurfaceVariant` stacked; or single-line Title M when narrow. Centered, truncate with ellipsis.
- **Right (cluster, gap 8):**
  - Font size: two 32 text-buttons "A−" / "A+" (Label L 600, `onSurfaceVariant`; hover `primary`,
    tooltips "Perkecil teks Arab (Ctrl −)", "Perbesar teks Arab (Ctrl +)").
  - Jump-to-ayah: labeled control — pill 40, radius-full, `surfaceContainerLow` fill,
    "Ayat 45" 13/500 `onSurface` + `expand_more` 16. Opens §14 popover. Tooltip "Lompat ke ayat".
  - Theme quick icon-button 36 (same as sidebar footer).
- Below bar: **reading progress indicator** — 3 px `primary` fill on `surfaceContainerHighest`
  track; width = scroll % of surah; animates 150 ms. Not a percentage label; the jump control
  carries the numeric position.

**Dark notes:** identical; bar bg `#101410`, hairline `#3E463F`, track `#313631`.

---

## 3. Buttons

| Variant | Fill | Text/icon | Height | Radius | Use |
|---|---|---|---|---|---|
| Filled | `primary` | `onPrimary` | 40 | 12 | primary actions ("Lanjutkan", "Surah berikutnya") |
| Tonal | `primaryContainer` | `onPrimaryContainer` | 40 | 12 | secondary on chrome ("Buka Surah", "Coba lagi") |
| Tonal (on paper) | `quranHighlight`-like: `#D0EAE0`@60 light / `#2E5246`@60 dark | `onPrimaryContainer` | 36 | 12 | actions inside the reading column ("Buka tafsir") |
| Text | transparent | `primary` | 40 | 12 | tertiary ("Batal", "Kembali ke Beranda") |
| Icon | transparent; hover `secondaryContainer`@50 | `onSurfaceVariant`; active `primary` | 40×40 (tap 44 min hit) | 12 | inline actions (bookmark, close) |

- Padding: Filled/Tonal/Text: 0 20 (label 14/500). Icon: 8.
- States (all variants): hover = bg 8% `onSurface` overlay over fill (or fill→`surfaceContainerHigh`
  for icon); pressed = 12% overlay; focus-visible = §7 ring; disabled = fill `surfaceContainerHighest`,
  text `onSurfaceVariant` @ 38%, no shadow, cursor default.
- Buttons animate 100–200 ms `easeInOutCubic`; no ripple-style bursts — calm fill/press.

**Dark notes:** identical behavior; overlays use white 8/12% which reads correctly on dark fills.

---

## 4. Cards & hero

**Card (generic panel):** radius 16, bg `surfaceContainerLowest`, shadow 0 (flat); border 1 px
`outlineVariant` optional. Padding 20. Used for: search overlay, settings sections, dialog body.
**Hero (continue reading):** radius 16, bg gradient? No — flat `primaryContainer`@55 light /
`#1E3A30` dark with 1 px `outlineVariant` border, padding 24, min-height 120. Content:
- Eyebrow "LANJUTKAN MEMBACA" Overline S `onPrimaryContainer`.
- Surah Arabic name (Amiri Quran 24, `onPrimaryContainer`... on paper? The hero sits on chrome,
  so Arabic uses Amiri Quran 24 in `onSurface`) — no, hero is a chrome card; Arabic surah name
  in Amiri Quran 24 `onSurface`, Latin name Title M below, then meta "Ayat 45 dari 110 · Juz 15".
- Trailing: filled button "Lanjutkan" aligned bottom-end.
- Hover: border color→`primary`@40, shadow 1 appears. Keyboard: the whole card is one
  focusable (Enter = open reader) with visible ring.

**Dark notes:** hero fill `#1E3A30`, border `#3E463F`, Arabic `#F0EADA`, meta `#BFC6BE`.

---

## 5. Segmented control (Surah / Juz)

M3 `SegmentedButton` restyled: height 40, radius 20 (pill), bg `surfaceContainer`, segment
padding 0 20, label 14/500 `onSurfaceVariant`. Selected segment: fill `surfaceContainerLowest`,
text `onSurface` 600, subtle shadow 1 (pop). Unselected hover: `secondaryContainer`@40. Focus
ring per segment. 2 segments only ("Surah", "Juz"). Used on Home; a small "1–114" / "1–30"
Overline S `outline` sits inside the selected segment trailing? No — keep label only; counts
live in the view header eyebrow.

---

## 6. Surah list item

**Anatomy** (height ~72, full-width row, padding 8 16, radius 12):
- **Index badge:** fixed 36 wide, Overline S 12/600 `outline` tabular, left.
- **Names block** (middle, expanded): row 1 — Arabic name (Noto Sans Arabic 18/500 `onSurface`)
  + 8 px gap + Latin name Title M 16/500 `onSurface` (baseline aligned). Row 2 — Indonesian name
  Body M `onSurfaceVariant`.
- **Meta block** (right, right-aligned): row 1 — "286 ayat" Body S `onSurfaceVariant` (tabular);
  row 2 — "Makkiyah" chip: Body S 12/500, pill radius-full, padding 4 10, bg `secondaryContainer`@45,
  text `onSecondaryContainer`; revelation type "Madaniyah" same style.
- States: default transparent; hover `secondaryContainer`@45 fill; focus ring; pressed
  `secondaryContainer`; active (currently open surah — only meaningful when returning from
  reader) → `primaryContainer`@50 fill + Arabic/Latin `onPrimaryContainer`.
- Separator: none — whitespace + consistent height, hairline only if density setting asks.

**Dark notes:** hover `#3C453E`@45; chip `#3C453E` text `#DCE6DC`; index badge `#899189`.

---

## 7. Juz row (Home → Juz view)

Same row skeleton (height 72): leading "Juz 1" Label L 600 `onSurface` (fixed 56 wide) →
Arabic range (Noto Sans Arabic 16/500, RTL, "الفاتحة — البقرة") + Latin range Body M
"Al-Fatihah — Al-Baqarah" + surah-number range "1–2" Body S `onSurfaceVariant` on row 2 →
trailing chevron `chevron_right` 20 `onSurfaceVariant`. Row is focusable; Enter opens Juz 1.
Hover/pressed/focus same as surah item.

---

## 8. Tooltips

- Desktop overlay, bg `inverseSurface`, text `onInverseSurface` 12/500, padding 8 12, radius 6,
  shadow 1, max width 280, single or two lines.
- Delay: 500 ms hover, 0 ms on keyboard focus. Arrow: 6 px notch pointing to anchor.
- Enter: fade+2 px rise 100 ms; exit: fade 80 ms.
- Used for: rail icon labels, icon buttons, jump control, font-size buttons.

**Dark notes:** `#E0E4DE` bg / `#2E312E` text (inverse roles) — automatically correct.

---

## 9. Scrollbars

Native-feeling, always-on (desktop), but visually designed:
- Width 8; track transparent; thumb radius 4, `outlineVariant` light / `#3E463F` dark.
- Thumb color transitions 150 ms: idle → 60% opacity; hover/drag → `outline` / `#899189` 90%.
- Flutter: custom `ScrollBehavior` + thin painted thumb; keep native overscroll physics.
- Reader list: same scrollbar, overlay style (does not consume layout width).

---

## 10. Focus rings (global)

- 2 px rounded-rect ring, color `primary`, offset 2 px outside the widget bounds, radius = widget
  radius + 2. Ring visible **only on keyboard focus** (`FocusNode` + `Focused` state); mouse
  click focus shows no ring (unless keyboard mode active). No `outline: none` anywhere.
- Applies to: nav items, all buttons, list rows, segmented segments, search results, sliders,
  switches, text fields, dialog buttons.

---

## 11. Empty states

Anatomy (centered, padding 96 48): icon 48 `outline` → title Title M `onSurface` → message
Body M `onSurfaceVariant` (max width 360) → optional text button `primary` ("Cari surah lain",
"Mulai membaca"). One CTA max. Cases: no last-read (Home hero hidden — Home shows hint instead,
see 03-screens), no bookmarks, no search results, no jump result. Never blank.

---

## 12. Dialog (confirm remove bookmark)

- Scrim `#000000`@40 (light) / 55 (dark); dialog width 360, radius 16, bg
  `surfaceContainerLowest`, padding 24, shadow 3.
- Title "Hapus penanda ini?" Title M; body Body M `onSurfaceVariant` (optional preview line of
  the ayah, truncated 1 line); actions row right-aligned: text "Batal" + tonal "Hapus"
  (`errorContainer` fill / `onErrorContainer` text). Esc cancels; Enter activates focused.
- Focus: first focus on "Batal" when opened; Tab cycles; trap inside dialog.

---

## 13. Settings rows & sections

- **Section:** card radius 16, bg `surfaceContainerLowest`, border `outlineVariant` 1 px; header
  Overline S eyebrow outside the card; inner rows separated by 1 px hairline `outlineVariant`
  (24 inset).
- **Row:** min-height 56, padding 16 20. Leading: icon 20 `onSurfaceVariant` (optional) or
  none. Middle: label Body L 16/500 `onSurface` + sublabel Body S `onSurfaceVariant` (optional).
  Trailing: control (switch / slider / segmented / text value).
- **Switch:** M3 restyled — width 52 height 32, track ON `primary`/OFF `surfaceContainerHighest`,
  thumb white, 150 ms. Labels: ON "Aktif" handled by switch semantic only; text labels are
  static row labels.
- **Slider (Quran font size):** M3 slider themed `primary`; 9 stops S1–S9, tick marks at each
  stop; live Arabic preview (Amiri Quran, current size, one short ayah line, `quranInk` on
  `quranSurface` swatch) updates instantly; current step label "38" tabular + reset text button
  "Setel ulang" appears when value ≠ default. See 03-screens Settings for layout.
- **Segmented (theme):** 3 segments "Sistem / Terang / Gelap", same restyled segmented control.

**Dark notes:** rows `#0B0E0B`; hairlines `#3E463F`; switch OFF track `#313631`.

---

## 14. Surah header (reader, on paper)

Structure (centered, padding 64 48 40 top / 40 bottom):
- **Revelation eyebrow:** "MAKKIYAH · 7 AYAT · JUZ 1" Overline S 11/600 `quranAccent` (the one
  brass text moment), letter-spacing 0.4 (Latin only).
- **Arabic surah name:** Amiri Quran 44/62, `quranInk`, centered, `letterSpacing: 0`. The name is
  scripture typography, so Amiri — not Noto — even though lists use Noto.
- **Latin name:** Title L 22/28 in `quranInkSecondary` 22/500 (paper token — the header sits on
  paper, not chrome). Below it the Indonesian name Body L `quranInkSecondary`.
- **Ornament rule:** centered row — 40 px hairline `quranRule` + 6 px diamond (rotated 45°
  square, fill `quranAccent`, radius 1) + 40 px hairline `quranRule`. Gap above/below 20.
- Background: the reader column's paper; behind the header a barely-visible radial `quranHeaderGlow`
  (4% light / 5% dark) for depth — must not be perceivable as a gradient "box".

**Dark notes:** everything swaps to dark paper tokens; eyebrow stays brass `#C9A545`.

## 15. Bismillah

- Rendered for all surahs except **1** (Al-Fatihah) and **9** (At-Tawbah).
- Amiri Quran, size `0.92 × quranSize` (S5 → 35), line-height 2.0, centered, `letterSpacing: 0`,
  color `quranAccent` (brass) — a deliberate, restrained scriptural cue.
- Surrounded by vertical rhythm: 24 above, 32 below (scales with `quranSize`).
- After bismillah: ornament diamond rule (same as header ornament, smaller: 24 px hairlines).
- Implementation note: render as one RTL text block of
  "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ". A calligraphic OFL bismillah asset may replace this
  later (non-breaking layout change; keep the same box metrics).

## 16. Ayah tile — the centerpiece

**Layout model:** the page is LTR chrome; each ayah tile is an LTR `Row` whose children handle
their own directionality. Column = `quranSurface` paper, centered with `readingWidth` (§2.4).

**Anatomy** (block, padding: 24 24 top / 24 bottom; gap between ayahs = `ayahGap`):
1. **Arabic block** (full width, RTL): a `Row(textDirection: rtl)` with the Arabic text as an
   expanded child (`TextDirection.rtl`, `TextAlign.right`) and the **ayah-end marker** as the
   trailing child (so it sits at the visual end/left of the first line — correct mushaf
   position).
   - Arabic style: Amiri Quran, current step, `letterSpacing: 0`, `quranInk`, line-height per
     table.
   - **Ayah marker:** circular badge, diameter `clamp(28, round(quranSize×0.90), 56)` (34 @ S5),
     border 1.5 `quranAccent`@70, fill transparent (`quranSurface`), numeral Arabic-Indic
     (e.g., ٥) in Amiri Quran at 0.55× marker size, `quranAccent`. Positioned at the visual end
     of the Arabic line (left side in RTL flow), matching Madina Mushaf placement where the
     medallion closes the ayah.
   - Preferred implementation: U+06DD "ARABIC END OF AYAH" with Arabic-Indic digits, which
     Amiri Quran renders as the ornate medallion (supported, includes digit-kerning fixes).
     **Fallback spec:** the circular badge above, used if the medallion doesn't shape in a
     given Flutter/Skia build — verify on Linux at S5 and lock the choice.
2. **Translation block:** below Arabic, gap `clamp(12, round(quranSize×0.40), 24)` (16 @ S5).
   Inter, `clamp(14, round(quranSize×0.42), 22)` (16 @ S5), line-height 1.6, `quranInkSecondary`,
   `TextAlign.left` (LTR). The ayah number lives in the marker, so the translation opens with a
   leading tabular number in `quranAccent` 12 px: "5. Dengan nama Allah…" — clean and scannable.
3. **Action row:** height 0 (invisible until hover/focus). On hover/focus, actions float at the
   block's top-start edge (overlaid on the paper, padded 8): bookmark icon-button 32 + text
   button "Tafsir" 13/500 `primary` (a label, not a chevron — the chevron lives inside the
   tafsir row). Appearance: fade + 4 px rise, 150 ms. Never pushes layout.

**States:**

| State | Arabic/translation | Tile background | Marker | Actions |
|---|---|---|---|---|
| Default | `quranInk` / `quranInkSecondary` | transparent | outline `quranAccent`@70 | hidden |
| Hover (mouse) | unchanged | `quranHighlight` @ 22% (subtle warm-tint, not green wash) — use `#2E5246`@14% dark | accent@90 | visible |
| Focus (keyboard) | unchanged | same as hover | — | visible + global focus ring on the tile |
| Bookmarked | unchanged | `quranBookmarkTint` (soft gold wash 30%) | fill `quranAccent`@20 + outline accent | bookmark icon **filled** gold `#8A6A00`/`#C9A545` |
| Current-reading (auto) | unchanged | `quranHighlight` @ 45% | accent | visible if hovered/focused; bookmark icon reflects state |
| Bookmarked + current | unchanged | gold wash + 3 px `primary` edge bar on the start (right) side, radius 1.5 | accent fill | — |
| Pressed | — | `quranHighlight` @ 60% | — | — |

**Current-reading definition:** the ayah nearest the top of the viewport after scroll settles
(300 ms debounce). Highlight animates 300 ms; the highlight never follows manual scrolling
continuously — it snaps to the settled ayah. Toolbar "Ayat 45" mirrors this.

**RTL/mixed-row rules:** chrome elements (actions) must not appear *inside* the Arabic RTL text
flow; actions live in the outer LTR row. No `TextAlign.justify` on Arabic. Never letter-space.

**Virtualization:** the surah list uses `ListView.builder` (potentially 286 ayah tiles in
Al-Baqarah) — items keyed by surah+ayah (`ValueKey('2:255')`), states derived from app model,
not widget-local (bookmark/current must survive recycling).

## 17. Tafsir inline panel

- Opens below the ayah's translation (accordion). Header row: "Tafsir · Kementerian Agama RI"
  Label L 14/600 `onSurface` + chevron `expand_more` (rotates 180°). One source only — no chip.
  Body: Inter Body L 16/26 in `quranInkSecondary` (paper token), max width = readingWidth,
  paragraph spacing 16.
- Surface: rounded 12, bg `quranHighlight` @ 35% (paper-family tint), padding 20, 1 px
  `quranRule` border. Chevron animates 200 ms; expand/collapse 300 ms AnimatedSize.
- Only one tafsir open at a time (opening another closes the current, 200 ms). Esc closes the
  open tafsir. Tab order: actions → tafsir body (skip text? body is one focus stop).
- Keyboard: Enter/Space on the "Tafsir" action toggles.

**Dark notes:** panel `#2E5246`@35% + `#2C2B22` border; body `#BDB7A8`.

## 18. Jump-to-ayah popover

- Trigger: toolbar "Ayat 45" pill. Popover width 240, radius 12, bg `surfaceContainerLowest`,
  shadow 1, anchored to the pill, 8 px gap.
- Content: label "Lompat ke ayat" Label M `onSurfaceVariant`; text field (Outlined border
  `outline`, focus `primary`, radius 8, height 40, accepts Latin digits 1–N; hint "1–286");
  error state `error` text "Nomor di luar jangkauan (1–286)" when invalid; buttons row:
  text "Batal" + tonal "Lompat". Enter = jump + close; Esc = close. On jump: smooth scroll
  (300 ms), ayah becomes current + highlight, focus moves to that ayah tile.

## 19. Search overlay

- **Trigger:** Ctrl/Cmd+K (global), or sidebar "Cari" item. Opens as an overlay: scrim
  `#000000`@40/55 (fade 200 ms) over the whole window, card centered at 24% height, width
  640, radius 16, bg `surfaceContainerLowest`, shadow 2, padding 0.
- **Field row** (padding 16, bottom hairline `outlineVariant`): `search` icon 20
  `onSurfaceVariant`, auto-focused text field (Inter Body L, `onSurface`, hint "Cari surah,
  ayat, atau terjemahan", no letter-spacing), trailing: Esc hint chip "Esc" + clear icon-button.
- **Grouped results** (max-height 480, scrollbar §9, ListView.builder):
  - Group label row: Overline S eyebrow "SURAH" / "AYAT" / "TERJEMAHAN" + count Body S
    `onSurfaceVariant`. Groups appear in that order; cap 5 / 8 / 8 with "dan N lainnya"
    footnote? No — cap and show "Tampilkan semua" text button only if group > cap (jumps to a
    results screen — MVP: omit, keep caps).
  - **Surah result:** index badge (36, `outline` Overline) + Arabic name (Noto Sans Arabic
    18/500) + Latin name Body M + meta chip "114 ayat · Makkiyah"; match highlight on Arabic
    or Latin name.
  - **Ayah result:** meta line first? No — Arabic excerpt (Noto 14/400 `onSurface`, RTL, max
    1 line, ellipsis) → translation excerpt (Inter Body M, max 1 line) → meta row Body S
    `onSurfaceVariant` "Al-Baqarah · Ayat 255 · Juz 3". Match highlighting:
    - in translation: `primaryContainer`@60 rounded 4 highlight box, text `onSurface` 600.
    - in Arabic: 2 px gold underline (`quranAccent`) under the matched range + tile hover bg;
      never re-color harakat.
  - **Terjemahan result:** translation excerpt (highlight box as above, max 2 lines) → Arabic
    excerpt (max 1 line) → same meta row.
- **Navigation:** ↑/↓ move selection (row shows `secondaryContainer`@45 fill), Enter opens
  reader at the ayah, Esc closes (or returns focus to field when a row is selected? — Esc
  always closes the overlay; single-layer). Focus is trapped; Tab cycles field ↔ list.
- **Empty query:** show "Pencarian terakhir" (recent, up to 5, history chips) or, if none,
  "Surah populer" (Al-Fatihah, Al-Baqarah, Yasin, Al-Kahfi, Ar-Rahman, Al-Mulk).
- **No results:** empty-state §11 ("Tidak ada hasil untuk \u201c…\u201d" + "Periksa ejaan atau
  coba kata lain").

**Dark notes:** card `#0B0E0B`; highlight box `#2E5246`@60 with text `#C4F0DD`; gold underline
`#C9A545`.

## 20. Bookmark item

- Row height ~96, padding 8 16, radius 12, full-width, focusable (Enter = open at ayah).
- Content: leading bookmark icon 20 `quranAccent` (filled) → middle: Arabic preview (Noto
  Sans Arabic 18/500 `onSurface`, RTL, 1 line ellipsis) on row 1; translation preview (Inter
  Body M, 1 line ellipsis) row 2; meta Body S `onSurfaceVariant` "Al-Baqarah · Ayat 255 ·
  Juz 3" row 3 → trailing: delete icon-button 32 (`delete_outline`, tooltip "Hapus penanda",
  opens §12 dialog). Hover/pressed/focus same as surah item.
- List is grouped by surah with sticky group headers ("Al-Baqarah" Title M + surah number
  badge) — sticky via pinned header; MVP allows non-sticky headers. Sorted surah asc → ayah asc.
- Items keyed `ValueKey('bm:2:255')`.

**Dark notes:** Arabic `#F0EADA`, translation `#BFC6BE`, meta `#899189`.

