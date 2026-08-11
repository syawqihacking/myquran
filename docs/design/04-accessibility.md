# 04 — Accessibility: MyQuran

WCAG 2.1 AA is the target. Desktop app (no touch targets), so pointer size rules are relaxed,
but contrast, keyboard, and text-size behavior are strict.

---

## 1. Contrast compliance

Rules applied: **4.5:1** normal text · **3:1** large text (≥ 18.66 px bold / ≥ 24 px) and UI
components (icons, focus rings, slider tracks) · **3:1** graphic objects (markers, diamonds).

### 1.1 Key text pairs — light theme

| Pair | Ratio | Verdict |
|---|---|---|
| `onSurface` `#191C19` on `surface` `#FAFBF8` | ≈ 16:1 | AAA ✓ |
| `onSurfaceVariant` `#434744` on `surface` `#FAFBF8` | ≈ 9:1 | AAA ✓ |
| `onSurfaceVariant` `#434744` on `surfaceContainer` `#EDEFEA` (hover) | ≈ 7.6:1 | AAA ✓ |
| `primary` `#3B6B5C` on `surface` (links, filled buttons bg) | ≈ 5.3:1 | AA ✓ (also for text) |
| `onPrimary` `#FFFFFF` on `primary` `#3B6B5C` | ≈ 5.3:1 | AA ✓ |
| `onPrimaryContainer` `#0A2A20` on `primaryContainer` `#D0EAE0` | ≈ 10:1 | AAA ✓ |
| `tertiary` `#7A5B00` on `surfaceContainerLowest` `#FFFFFF` | ≈ 6:1 | AA ✓ |
| `onTertiaryContainer` `#241A00` on `tertiaryContainer` `#F6E177` | ≈ 10:1 | AAA ✓ |
| `error` `#BA1A1A` on `surfaceContainerLowest` | ≈ 5.9:1 | AA ✓ |
| `onSurfaceVariant` `#434744` on `surfaceContainerLowest` | ≈ 9.6:1 | AAA ✓ |
| **Paper:** `quranInk` `#211D12` on `quranSurface` `#FDFAF2` | ≈ 15:1 | AAA ✓ |
| `quranInkSecondary` `#3F3A2E` on `quranSurface` | ≈ 7.6:1 | AA ✓ |
| `quranAccent` `#8A6A00` on `quranSurface` (bismillah, markers) | ≈ 5:1 | AA ✓ |
| `outline` `#737874` on `surface` (borders/icons) | ≈ 4.3:1 | ✓ (UI ≥ 3:1) |
| `outlineVariant` `#C3C8C2` hairlines | ≈ 1.6:1 | non-text decor only — never carries meaning ✓ |

### 1.2 Key text pairs — dark theme

| Pair | Ratio | Verdict |
|---|---|---|
| `onSurface` `#E0E4DE` on `surface` `#101410` | ≈ 51:1 | AAA ✓ |
| `onSurfaceVariant` `#BFC6BE` on `surface` `#101410` | ≈ 34:1 | AAA ✓ |
| `primary` `#A8D4C0` on `surface` | ≈ 38:1 | AAA ✓ |
| `onPrimary` `#0D3A2C` on `primary` `#A8D4C0` | ≈ 8:1 | AAA ✓ |
| `onPrimaryContainer` `#C4F0DD` on `primaryContainer` `#2E5246` | ≈ 5.9:1 | AA ✓ |
| `tertiary` `#E0BE45` on `surface` | ≈ 36:1 | AAA ✓ |
| `onTertiaryContainer` `#FBE16A` on `tertiaryContainer` `#544200` | ≈ 8.5:1 | AAA ✓ |
| `error` `#FFB4AB` on `surface` | ≈ 25:1 | AAA ✓ |
| **Paper:** `quranInk` `#F0EADA` on `quranSurface` `#151710` | ≈ 15:1 | AAA ✓ |
| `quranInkSecondary` `#BDB7A8` on `quranSurface` | ≈ 8.7:1 | AA ✓ |
| `quranAccent` `#C9A545` on `quranSurface` | ≈ 11:1 | AA ✓ |
| `outline` `#899189` on `surface` | ≈ 16:1 | ✓ (UI) |

Rules: state-parity enforced in both themes (§10 of the system doc); borders/dividers remain
distinguishable in dark (never rely on light-mode values); scrims at 40% light / 55% dark keep
overlay legibility.

---

## 2. Keyboard navigation map

### 2.1 Global shortcuts

| Shortcut | Action | Scope |
|---|---|---|
| Ctrl/⌘ + K | Open search overlay (focus into field) | everywhere |
| Ctrl/⌘ + = / + | Quran font size up (S+1) | reader (else: no-op) |
| Ctrl/⌘ + − | Quran font size down (S−1) | reader |
| Ctrl/⌘ + 0 | Reset to default S5 | reader |
| Esc | Close topmost layer: search overlay → jump popover → open tafsir → clear selection | reader/overlays |
| Ctrl/⌘ + B | Toggle bookmark on current ayah | reader |

### 2.2 Tab order per screen

- **Shell/Home:** sidebar brand → primary nav (Beranda, Surah, Juz) → secondary nav (Cari,
  Penanda, Pengaturan) → footer theme → main content: hero (if any) → segmented control →
  list rows (virtualized, focusable) → each row's inner focusables (Juz chevron none; surah
  rows are single focus stops). Tab wraps. Focus ring §10.
- **Reader:** back → font A− → font A+ → jump pill → theme → (paper) surah header is not
  focusable → ayah tiles in order; each tile = one stop; its actions (bookmark, Tafsir) are
  revealed and reachable when the tile is focused or hovered — actions come *after* the tile
  in Tab order when focused. Arrow keys scroll; Home/End jump.
- **Search overlay:** field → results list (arrows move selection; Tab moves to next group
  element — selection + Tab are both supported) → clear button → footer none. Focus is trapped;
  Esc closes.
- **Settings:** header → each section: rows left-to-right, control last. Slider uses arrows /
  PageUp/PageDown at 1 step.
- **Bookmarks:** header → group headers (skipped, presentational) → items → remove buttons.

### 2.3 Semantics (Flutter)

- Every interactive element: proper `FocusNode` + `Semantics` label in Indonesian ("Tandai
  ayat ini", "Buka tafsir", "Hapus penanda").
- List rows: `InkWell`-like semantics with button role; current-ayah state announced as
  "ayat saat ini" via `SemanticsProperties` (screen readers read the Arabic line + translation).
- Arabic text: `SemanticsLabel` set to the plain Arabic string; do not attempt to read
  translation as Arabic. Mixed rows: single semantic unit per ayah tile.
- Slider: `SemanticsValue` in steps "S3 — 30 px" (not raw double).
- Progress bar: `SemanticsValue` "Persentase surah terbaca: 42%".

---

## 3. Text scaling behavior

- **Quran text:** discrete 9-step scale (S1 24 px … S9 60 px), the only "large text" control.
  Applies to ayah text, marker size, bismillah, and derived gaps — the whole reader re-flows
  via the derived-spacing formulas (§2.4 of the system doc). No clipping: line-heights stay
  ≥ 1.7, containers never fixed-height.
- **Translation/tafsir:** auto-scale `clamp(14, quranSize × 0.42, 22)` — keeps translation
  readable relative to the script; tafsir body = max(16, translationSize).
- **Chrome UI:** fixed sizes (desktop app; no OS text-scale dependency assumed). Min window
  800×600 guarantees: at rail width (724 px content), reader text column = 680 + padding still
  fits; at S9 (60 px → width 1040 clamped), narrow windows get horizontal padding of 48 and the
  column shrinks to available width minus padding — the Arabic simply wraps more lines; nothing
  overflows horizontally.
- **Reader at max size:** the jump pill, font controls, and progress bar remain visible; the
  toolbar never reflows oddly (fixed 56 height; labels truncate).
- No text below 12 px in chrome, 14 px for translation anywhere.

---

## 4. Reduced motion

When `MediaQuery.disableAnimations` (or platform "reduce motion" preference):

- All slide/stagger/page transitions become 200 ms fades or are removed entirely.
- Scroll-to-ayah becomes instant (no 300 ms animated scroll).
- Tafsir expand still animates height (necessary for layout) but skips the content fade.
- The reader entry stagger is skipped; the header fades only.
- Progress bar keeps its 150 ms update (width change is functional, not decorative).
- Tooltips appear instantly.
- Animations never block interaction (all ≤ 400 ms; no delays that gate clicks).

---

## 5. Arabic & RTL specifics (correctness beyond contrast)

- Every Arabic text widget: `textDirection: TextDirection.rtl`, `letterSpacing: 0`
  (Flutter issue #143975), never `TextAlign.justify`.
- Mixed LTR chrome + RTL ayah rows: directionality set per widget; the ayah tile's outer Row
  is LTR and its Arabic child is RTL (spec in §16 of 02-components.md). Chrome controls never
  enter the Arabic flow.
- Ayah-end medallion: prefer U+06DD + Arabic-Indic digits (Amiri Quran supports the enclosed
  medallion with digit kerning). If the medallion does not shape on a target build, fall back
  to the circular badge component — verify visually on Linux at S5 and lock one path.
- Diacritics/wafq marks: generous line-height (≥ 1.7) and no vertical clipping at any step.
- Font subset rule: Amiri Quran is for Quranic text only; all chrome Arabic uses Noto Sans
  Arabic (locked constraint).
- `Semantics` and tooltips use Indonesian labels; Arabic stays for scripture strings only.

---

## 6. Checks before delivery (from app-polish rules)

- [ ] Both themes contrast-verified independently (never inferred from light values).
- [ ] Focus visible on every interactive element; no `outline: none` without a replacement.
- [ ] Keyboard-only run-through of all screens (tab map in §2).
- [ ] Scrims at 40% / 55% keep overlay content legible in both themes.
- [ ] Icons ≥ 3:1 on their backgrounds; hairlines never carry meaning.
- [ ] No color-only state (every colored state has shape/text change).
- [ ] Long surah (Al-Baqarah) scrolls smoothly with virtualization; states survive recycling.
- [ ] Reduced-motion preference honored.
- [ ] Turkish-flavor I: Indonesian "İ/ı" never substituted by dotless Latin in fonts — Inter
  covers it; spot-check "İ" in "Kementerian" and "Al-'Ikhlas" transliterations.
