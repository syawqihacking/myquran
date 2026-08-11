# 00 — Design Direction: MyQuran

> One-page statement of intent. Everything else in this folder derives from this page.
> App: **MyQuran** — an offline-first desktop Al-Qur'an reader (Flutter, Linux first).
> Reading model: continuous per-ayah scroll, not a 604-page mushaf layout.

---

## 1. The mood

MyQuran should feel like sitting down with a well-made book in a quiet room at dawn: warm paper,
deep evergreen, a single restrained brass accent. Not a website, not a dashboard, not a database.
A **reading instrument** — calm, spacious, and confident enough to stay out of the way of the text.

The app frame is quiet and precise (editorial, Swiss-leaning chrome). The scripture sits on a
warm "paper" reading surface that is visibly different from the chrome — a deliberate, quiet
moment of material difference that says *this column is the book*. Nothing competes with the
Arabic script for attention.

**Mood board in words:** soft morning light on a desk · a hand-bound edition with a plain
evergreen cover and a thin gold line · Amiri Naskh calligraphy · generous margins ·
precisely aligned furniture · no ornament except a small diamond.

## 2. Principles

1. **The text is the hero.** The Arabic script and its translation are the only things allowed to
   be loud. Chrome is quiet: neutral surfaces, hairline rules, muted ink. Every component earns
   its place by serving reading.
2. **Paper over glass.** The reading column is a warm paper surface in both themes (light:
   warm off-white; dark: warm near-black). Chrome is M3-neutral. This separation is the single
   strongest identity move in the system.
3. **Serene motion.** Movement exists to orient and reveal, never to decorate. Slow, soft,
   staggered reveals on page entry; 150–300 ms state transitions; nothing bounces or spins.
4. **Restraint as respect.** Islamic character is carried by script, proportion, and two
   restrained cues: the evergreen/brass pairing and a small diamond rule ornament. No heavy
   ornamentation, no clichés (no crescent-and-star, no green-with-gold-everything).
5. **Readability is a feature.** Every decision — line-height, contrast, font scale, letter-
   spacing rules, column width — is checked against the constraint that harakat must never be
   clipped and Uthmani shaping must never break.
6. **Desktop polish.** Hover states, focus rings, tooltips, native-feeling scrollbars, and
   keyboard access are treated as first-class. The app should feel *considered* at 1280×720 and
   *magnificent* at 1920×1080 and very wide windows.
7. **Honest hierarchy.** One accent (evergreen primary), one highlight (brass tertiary), one
   hierarchy of ink. If something can't be explained with these three, it doesn't go in.

## 3. What we deliberately avoid

- **SaaS/dashboard look** — dense tables, KPI cards, sidebar-with-badges-and-avatars, status
  dots, progress rings everywhere.
- **Database-admin look** — raw tables for surah lists, cramped rows, bordered cells.
- **Generic AI-template look** — purple gradients, glassmorphism, blob shapes, emoji as icons,
  generic "modern" cards with rounded-corners-and-shadow stacking.
- **Cluttered Islamic decor** — Islamic-pattern wallpapers, tile backgrounds, heavy gold
  borders, ornamented headers. One diamond, a hairline, Amiri Naskh: enough.
- **Mushaf-page layout** — no facing pages, no page-turn animation, no 604-page model. Reading
  is a continuous scroll of ayahs.
- **Dashboard-style "stats everywhere"** — no read-o-meter, no gamification, no badges or
  rewards. One progress bar in the reader, one "continue" card on Home. Exception: the Stats
  screen may show a quiet streak counter (consecutive reading days) as a plain, unadorned
  number — a consistency metric, not a reward. No flame icons, no celebratory copy.
- **Bold Arabic text** — Amiri Quran has no bold weight, and forcing it distorts the script.
  Arabic hierarchy comes from size and color only.
- **Justified Arabic** — justification stretches inter-word spacing and distorts harakat
  rhythm. Arabic is right-aligned or centered, never justified.
- **Letter-spacing on Arabic** — any `letterSpacing != 0` breaks Uthmani ligatures/harakat
  (Flutter issue #143975). Global rule: Arabic styles are `letterSpacing: 0`.
- **Hover-only affordances** — every action must also be reachable by keyboard, with visible
  focus rings.

## 4. How the direction lands per surface

| Surface | Intent |
|---|---|
| Chrome (sidebar, toolbars, lists) | Neutral M3 surfaces, hairline rules, Inter, quiet |
| Reading column | Warm paper, Amiri Quran, generous line-height, the book |
| Accent | Evergreen primary for interaction; brass gold reserved for scriptural cues (bismillah, markers, bookmark) |
| Motion | Page-entry stagger, soft reveals; everything else 150–300 ms |
| Empty states | Calm, useful, with a next step — never a blank screen |

## 5. Language & tone of UI copy

Bahasa Indonesia, plain and respectful. No marketing voice, no exclamation marks, no "Selamat
datang!". Short verbs, clear nouns. Examples used throughout the specs:

- "Lanjutkan Membaca", "Daftar Surah", "Cari di Al-Qur'an", "Tidak ada hasil untuk
  \u201c…\u201d", "Belum ada penanda baca", "Selesai membaca Surah Al-Fatihah".
