# 03 — Screens: MyQuran

Window model, per-screen layout, breakpoints, and empty states. All widths in logical px.

---

## 0. Window & layout foundation

| Constraint | Value |
|---|---|
| Min window | 800 × 600 |
| Design target | 1280 × 720 to 1920 × 1080+ |
| Very wide rule | content never stretches full-width; the reading column centers in the remaining space with at least 96 px side margins |
| Sidebar breakpoint | ≥ 1040 → full sidebar (264); 800–1039 → compact rail (76) |
| Shell geometry | sidebar (fixed width) + content area (flex). Top chrome bar only in Reader. |

**Centering rule (all screens):** content columns use `maxWidth` + horizontal centering —
Home/Bookmarks/Settings: 760. Reader: `readingWidth = clamp(680, quranSize×21, 1040)`. Search
overlay: fixed 640 card regardless of window. Very wide windows (> 1680): extra space stays as
quiet margins; no stretching, no growing panels.

---

## 1. App shell

```
┌──────────┬──────────────────────────────────────────────┐
│ 264 sidebar │ content area (flex)                         │
│ (or 76 rail) │  [screen body, scrolled independently]     │
└──────────┴──────────────────────────────────────────────┘
```

- Sidebar fixed; content scrolls. Only one scroll region at a time (lists scroll inside body;
  no nested scrollbars in the sidebar).
- Rail mode: icons-only, tooltips, same nav order. Brand tile shrinks to 28.
- Route transitions: Home/Bookmarks/Settings/Search = fade 200 ms; into Reader = 400 ms
  cross-fade with slight upward motion (8 px) on the reader column only.

---

## 2. Home

Layout: content column 760, centered, padding 48 horizontal / 40 vertical.

**Stack (top→bottom):**
1. **Header:** eyebrow "AL-QUR'AN" Overline S + "Beranda" Headline S 28/36 `onSurface` +
   caption Body M `onSurfaceVariant` "Baca Al-Qur'an dengan tenang — tanpa sambungan internet."
2. **Continue reading hero** (§4 of components) — *only when lastRead exists*. Full width of
   the 760 column.
3. **Segmented control** "Surah | Juz" (§5).
4. **View list** — `ListView.builder`, keyed items:

**Surah view** — 114 items of §6. First item row starts 8 px below the control; no header
row inside the list (the segmented control labels it). Optional scroll-position label pinned
under the control: none (keep clean).

**Juz view** — 30 items of §7. Rows show "Juz 1" + Arabic range + Latin range + surah-number
range. Opening a juz jumps into Reader at the juz's first ayah with a small toast/snackbar?
No toast — the Reader header meta shows the juz; the jump is obvious from the surah header.

**Empty states:**
- No last-read: hero hidden; in its place a quiet hint card (radius 16, `surfaceContainerLow`
  fill, padding 20): icon `auto_stories` 48 `outline`, text "Belum ada riwayat baca." + text
  button "Mulai dari Al-Fatihah" → reader surah 1.
- (Surah/Juz lists are static data — no empty state.)

**Light/dark example:** light = chrome `#FAFBF8`, hero pill `#D0EAE0`@55, list rows white-ish
overlay; dark = chrome `#101410`, hero `#1E3A30`, rows `#181C18` hover.

---

## 3. Reader (surah)

**Chrome:** top bar 56 (§2) + content = paper column.

```
┌────────────────────────────────────────────────┐
│ top chrome bar (back · title · font · jump)     │ 56
│ ─ 3px progress bar                             │
├────────────────────────────────────────────────┤
│        paper column, centered, readingWidth     │
│  ┌──────────────────────────────────────────┐  │
│  │ Surah header (§14)                        │  │
│  │ bismillah (§15) — unless surah 1 or 9     │  │
│  │ ◆ ornament                                │  │
│  │ Ayah 1 (§16)                              │  │
│  │ Ayah 2                                    │  │
│  │ … (virtualized list)                      │  │
│  │ End-of-surah block                        │  │
│  └──────────────────────────────────────────┘  │
└────────────────────────────────────────────────┘
```

- Paper column spans the full content height (background `quranSurface` from top bar bottom to
  window bottom); horizontal margins ≥ 48 (narrow) / 64 (wide). The paper visually ends at the
  window edges? No — paper is a centered column with `readingWidth`; margins show chrome
  surface, so paper reads as an island. Both chrome and paper regions are the same scroll
  viewport (paper scrolls; margins are static chrome) — **decision:** the whole content area
  scrolls as one; paper column background fills the scroll container width? If paper were
  island-width, its background would scroll away at top/bottom leaving chrome gaps. Simpler
  and calmer: **paper fills the entire content area** (full bleed to the window edge), and the
  *text column* is centered at `readingWidth` with generous margins on the paper. This keeps
  one surface, no seams. Paper island-on-chrome was the original idea; full-bleed paper is the
  production decision because scroll seams look unfinished.
- **Surah header** (§14) centered within the text column. Then bismillah (rules §15), ornament,
  then ayah list (`ListView.builder`, keyed, states from app model).
- **End-of-surah block** (centered, padding 48 0 64): ornament diamond rule; "Selesai membaca
  Surah Al-Fatihah" Title M `quranInkSecondary`; then Filled "Surah berikutnya" (`onPrimary`,
  shows "Al-Baqarah" as caption inside? — keep single label "Surah berikutnya", the next surah
  name appears as a sub-caption Body M `quranInkSecondary` above the button) + text button
  "Kembali ke Beranda".
- **Progress & position:** top progress bar (§2) shows scroll % within the surah; toolbar jump
  pill mirrors current ayah. A small floating "Ayat 45 · Juz 3" label? No — redundant with the
  toolbar pill.

**Keyboard:** ↑/↓ (or PgUp/PgDn) scroll; Home/End = top/bottom of surah; Ctrl/⌘ + /− = font
size; Ctrl/⌘+B = toggle bookmark on current ayah (enhancement); Esc = close open tafsir /
popover.

**Light/dark example:** light = chrome `#FAFBF8` bar, paper `#FDFAF2`, Arabic `#211D12`,
translation `#3F3A2E`, brass `#8A6A00`; dark = chrome `#101410`, paper `#151710`, Arabic
`#F0EADA`, translation `#BDB7A8`, brass `#C9A545`. The warm paper is the anchor of the reading
experience in both modes.

**Very wide (> 1680):** readingWidth caps at 1040; everything centers; margins grow. No
two-column stretch.

---

## 4. Search overlay

- Triggered globally (Ctrl/⌘+K) or via sidebar. Card 640 wide, centered at 24% of window
  height. Full spec in §19 of 02-components.md.
- The overlay appears above any screen; on open, focus is in the field. Type = live search
  (debounce 150 ms); grouped results; ↑/↓/Enter/Esc.
- Opening a result → closes overlay → Reader opened at the ayah with a brief (1.2 s)
  highlight pulse on that ayah (existing current-ayah wash, no new motion).

---

## 5. Bookmarks

Layout: column 760 centered, padding 48/40.
- **Header:** eyebrow "PENANDA BACA" + "Penanda" Headline S + caption Body M "Ayat yang kamu
  tandai tersimpan di perangkat ini."
- **List:** grouped by surah (headers §20), virtualized. Row = §20 bookmark item.
- **Empty state:** icon `bookmarks_outlined` 48, "Belum ada penanda baca", message "Tandai
  ayat dengan ikon bookmark saat membaca — ayat akan muncul di sini.", text button
  "Mulai membaca".
- Item actions: jump (row click/Enter), remove (trailing icon → §12 dialog).

**Dark notes:** standard dark chrome tokens; Arabic preview `#F0EADA`.

---

## 6. Settings

Layout: column 640 centered, padding 48/40. Sections in order (§13 rows):

1. **Tampilan**
   - Mode tema — segmented "Sistem / Terang / Gelap" (default Sistem). Sublabel: "Ikuti tema
     sistem operasi." Uses `settings_brightness`/`light_mode`/`dark_mode` per option.
   - Ukuran teks Arab — slider S1–S9 (§13) + live preview panel: radius 12, `quranSurface`
     fill, Amiri Quran sample at the selected size ("قُلْ هُوَ ٱللَّهُ أَحَدٌ"), centered,
     `quranInk`; right of slider: current step "38" (tabular) + "Setel ulang" text button.
     Sublabel: "Lebih besar untuk kenyamanan baca jarak jauh; terjemahan menyesuaikan secara
     otomatis."
   - Tampilkan terjemahan — switch, default ON. When OFF, ayah tiles render Arabic only
     (actions still available).
   - Perataan teks Arab — segmented "Rata kanan / Rata tengah" (default kanan; never justify).
     Note under: "Perataan tengah dapat membantu pada ayat pendek."
2. **Baca**
   - Tafsir default terbuka — switch OFF (default closed).
   - Penanda terakhir: "Pulihkan posisi baca terakhir saat membuka surah" — switch ON.
3. **Data & Sumber**
   - Row (info, no control): "Teks, terjemahan, dan tafsir — Quran Kementerian Agama RI.
     Semua data tersimpan offline di perangkat."
   - Row: "Versi data" — trailing value "2025.1" (tabular).
   - Row: "Lisensi" — link-style text button "Baca lisensi" (dialog: fonts SIL OFL — Amiri
     Quran, Inter, Noto Sans Arabic; data Kemenag RI; app MIT).
4. **Pintasan keyboard** — list of shortcuts (static table rows): "Cari — Ctrl K", "Perbesar
   teks Arab — Ctrl +", "Perkecil teks Arab — Ctrl −", "Tutup panel — Esc".

Settings changes apply instantly (no save button). Slider drag applies live to the preview;
applies to the reader immediately.

**Dark notes:** preview panel `#151710` / sample `#F0EADA`; rows `#0B0E0B`.

---

## 7. Screen flow summary

| From | Action | To |
|---|---|---|
| Home | continue hero / surah row / juz row / segmented switch | Reader (surah or juz first ayah) |
| Any | Ctrl/⌘+K | Search overlay → Reader @ ayah |
| Reader | back | Home (last-read updated) |
| Reader | toolbar theme | theme toggles instantly |
| Sidebar | any nav item | Home / Surah list / Juz list / Bookmarks / Settings |
| Bookmarks | row | Reader @ ayah |

Empty states are defined inline per screen above (Home no-history, Bookmarks empty, Search no
results, Reader none — data is static).
