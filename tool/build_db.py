#!/usr/bin/env python3
"""Build MyQuran's prebuilt SQLite database (assets/db/quran.db).

Offline-first Flutter Al-Qur'an reader data pipeline. Python 3 stdlib only.

Sources (cached in tool/data/, cache-aware & rerunnable):
  - quran-uthmani.txt      Tanzil Uthmani text (marks, sajdah, tatweel)
  - quran-data.xml         Tanzil per-surah metadata + juz/page/sajda markers
  - id.indonesian          Tanzil Indonesian (Kemenag) translation
  - quran.json             gadingnst/quran-api: per-ayah tafsir (short/long)
  - daftar_surat_kemenag.json   Indonesian surah names (Kemenag mirror)

The DB schema below is canonical: a parallel lane implements the same schema
in Dart drift. Do not deviate.
"""

import json
import os
import re
import sqlite3
import sys
import unicodedata
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT / "tool" / "data"
DB_PATH = ROOT / "assets" / "db" / "quran.db"

# ---------------------------------------------------------------- downloads

SOURCES = {
    # name -> (url, minimum acceptable byte size to consider cached)
    "quran-uthmani.txt": (
        "https://tanzil.net/pub/download/index.php?quranType=uthmani&marks=true"
        "&sajdah=true&tatweel=true&outType=txt-2&agree=true",
        1_000_000,
    ),
    "quran-data.xml": (
        "https://tanzil.net/res/text/metadata/quran-data.xml",
        10_000,
    ),
    "id.indonesian": (
        "https://tanzil.net/trans/id.indonesian",
        1_000_000,
    ),
    "quran.json": (
        "https://raw.githubusercontent.com/gadingnst/quran-api/main/data/quran.json",
        10_000_000,
    ),
    "daftar_surat_kemenag.json": (
        "https://raw.githubusercontent.com/ianoit/Al-Quran-JSON-Indonesia-Kemenag/"
        "master/Daftar%20Surat.json",
        1_000,
    ),
}


def ensure_download(name: str, url: str, min_bytes: int) -> Path:
    """Download url to tool/data/name unless an existing file is large enough."""
    dest = DATA_DIR / name
    if dest.exists() and dest.stat().st_size >= min_bytes:
        print(f"  [cached] {name} ({dest.stat().st_size} bytes)")
        return dest
    print(f"  [fetch ] {name} <- {url}")
    tmp = dest.with_suffix(dest.suffix + ".part")
    req = urllib.request.Request(url, headers={"User-Agent": "myquran-data-pipeline/1.0"})
    with urllib.request.urlopen(req, timeout=120) as resp, open(tmp, "wb") as fh:
        while True:
            chunk = resp.read(1 << 16)
            if not chunk:
                break
            fh.write(chunk)
    size = tmp.stat().st_size
    if size < min_bytes:
        tmp.unlink(missing_ok=True)
        raise RuntimeError(f"{name}: download too small ({size} bytes)")
    os.replace(tmp, dest)
    return dest


def ensure_all_sources() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    for name, (url, min_bytes) in SOURCES.items():
        ensure_download(name, url, min_bytes)


# ---------------------------------------------------------------- loaders

def load_tanzil_text(path: Path) -> list[tuple[int, int, str]]:
    """Parse 'surah|ayah|text' files; skip blank lines and '#' comments."""
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        surah_s, ayah_s, text = line.split("|", 2)
        rows.append((int(surah_s), int(ayah_s), text))
    return rows


def _intattr(el: ET.Element, name: str) -> int:
    val = el.get(name)
    if val is None:
        raise RuntimeError(f"quran-data.xml: <{el.tag}> missing attribute {name!r}")
    return int(val)


def _strattr(el: ET.Element, name: str) -> str:
    val = el.get(name)
    if val is None:
        raise RuntimeError(f"quran-data.xml: <{el.tag}> missing attribute {name!r}")
    return val


def load_metadata(path: Path) -> dict:
    """Parse Tanzil quran-data.xml into per-surah dict + juz/page/sajda data."""
    root = ET.parse(path).getroot()

    suras_el = root.find("suras")
    if suras_el is None:
        raise RuntimeError("quran-data.xml: missing <suras>")
    surahs = {}
    for s in suras_el.findall("sura"):
        surahs[_intattr(s, "index")] = {
            "index": _intattr(s, "index"),
            "ayas": _intattr(s, "ayas"),
            "start": _intattr(s, "start"),
            "name": _strattr(s, "name"),
            "tname": _strattr(s, "tname"),
            "ename": _strattr(s, "ename"),
            "type": _strattr(s, "type"),  # Meccan | Medinan
            "order": _intattr(s, "order"),
        }

    def markers(parent_tag: str, child_tag: str) -> list[tuple[int, int, int]]:
        parent = root.find(parent_tag)
        if parent is None:
            raise RuntimeError(f"quran-data.xml: missing <{parent_tag}>")
        out = []
        for el in parent.findall(child_tag):
            out.append(
                (_intattr(el, "sura"), _intattr(el, "aya"), _intattr(el, "index"))
            )
        return out

    sajdas = set()
    sajdas_el = root.find("sajdas")
    if sajdas_el is not None:
        for s in sajdas_el.findall("sajda"):
            sajdas.add((_intattr(s, "sura"), _intattr(s, "aya")))

    return {
        "surahs": surahs,
        "pages": markers("pages", "page"),
        "juzs": markers("juzs", "juz"),
        "sajdas": sajdas,
    }


def load_indonesian_names(path: Path) -> dict[int, str]:
    data = json.loads(path.read_text(encoding="utf-8"))["data"]
    names = {}
    for row in data:
        idx = int(row["id"])
        terjemahan = row.get("surat_terjemahan", "").strip()
        if not terjemahan:
            raise RuntimeError(f"Indonesian surah name empty for surah {idx}")
        names[idx] = terjemahan
    if len(names) != 114:
        raise RuntimeError(f"Indonesian surah list has {len(names)} entries, expected 114")
    if set(names) != set(range(1, 115)):
        raise RuntimeError("Indonesian surah list ids are not 1..114")
    return names


def load_tafsir(path: Path) -> dict[int, tuple[str, str]]:
    """gadingnst quran.json -> {global_ayah_id: (short, long)}."""
    doc = json.loads(path.read_text(encoding="utf-8"))
    data = doc["data"]
    tafsir = {}
    for surah in data:
        for verse in surah["verses"]:
            gid = verse["number"]["inQuran"]
            t = verse["tafsir"]["id"]
            short = t.get("short", "")
            long = t.get("long", "")
            if not short or not long:
                raise RuntimeError(f"tafsir missing text for ayah {gid}")
            tafsir[gid] = (short, long)
    if len(tafsir) != 6236 or set(tafsir) != set(range(1, 6237)):
        raise RuntimeError(
            f"tafsir ids do not cover 1..6236 exactly (got {len(tafsir)} entries)"
        )
    return tafsir


# ------------------------------------------------------------ normalization

# Letter folds (step 5). U+0670 (dagger alef) is folded to alef separately
# BEFORE combining marks are stripped, since it is itself a combining mark.
ARABIC_FOLDS = {
    "\u0623": "\u0627",  # أ -> ا
    "\u0625": "\u0627",  # إ -> ا
    "\u0622": "\u0627",  # آ -> ا
    "\u0671": "\u0627",  # ٱ (alef wasla) -> ا
    "\u0624": "\u0627",  # ؤ -> ا
    "\u0649": "\u064A",  # ى -> ي
    "\u0629": "\u0647",  # ة -> ه
}


def normalize(text: str) -> str:
    """Normalized Arabic search key. MUST match the Dart lane's implementation
    (same rules + test vectors). See section 6 of the pipeline spec."""
    # 1. NFC
    text = unicodedata.normalize("NFC", text)
    out = []
    skip_ayadigits = False   # U+06DD followed by Arabic-Indic digits
    after_tatweel = False    # U+0640 directly precedes a dagger alef U+0670
    for ch in text:
        cp = ord(ch)
        # 3. tatweel is always dropped; the "ـٰ" (tatweel+dagger) rendering of
        # a superscript alef is dropped entirely (e.g. ٱلرَّحْمَـٰنِ -> الرحمن),
        # whereas a bare dagger alef folds to a full alef (صِرَٰطَ -> صراط).
        if cp == 0x0640:
            after_tatweel = True
            continue
        if cp == 0x0670:
            if after_tatweel:
                after_tatweel = False
                continue
            out.append("\u0627")
            continue
        folded = ARABIC_FOLDS.get(ch)
        if folded is not None:
            after_tatweel = False
            out.append(folded)
            continue
        # 3. Quranic annotation signs (incl. U+06E5/U+06E6)
        if 0x06D6 <= cp <= 0x06ED or 0x08F0 <= cp <= 0x08FF:
            continue
        # 3. U+06DD END OF AYAH + immediately-following Arabic-Indic digits
        if cp == 0x06DD:
            skip_ayadigits = True
            continue
        if skip_ayadigits:
            if 0x0660 <= cp <= 0x0669:
                continue
            skip_ayadigits = False
        # 2. combining marks
        if unicodedata.category(ch) in ("Mn", "Me"):
            continue
        # 4. format chars to drop / replace
        if cp == 0x061C or 0x200C <= cp <= 0x200F:
            continue
        if cp == 0x00A0 or cp == 0x200B:
            after_tatweel = False
            out.append(" ")
            continue
        after_tatweel = False
        out.append(ch)
    # 6. collapse whitespace runs to one space; trim
    return " ".join("".join(out).split())


NORMALIZE_VECTORS = [
    ("بِسْمِ ٱللَّهِ", "بسم الله"),
    ("ٱلرَّحْمَـٰنِ", "الرحمن"),
    ("الَّذِينَ", "الذين"),
    ("وَمَا أَدْرَاكَ", "وما ادراك"),
    ("ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ", "الحمد لله رب العلمين"),
    ("الرَّحِيمِ", "الرحيم"),
    ("مَلِكِ يَوْمِ الدِّينِ", "ملك يوم الدين"),
    ("صِرَٰطَ", "صراط"),
]


def self_test_normalize() -> bool:
    ok = True
    for inp, expected in NORMALIZE_VECTORS:
        got = normalize(inp)
        if got != expected:
            ok = False
            print(f"  FAIL normalize({inp!r}) = {got!r} expected {expected!r}")
    return ok


# ------------------------------------------------------------ basmala logic

# Expected Tanzil basmala prefix (identical to surah 1 ayah 1 text). The exact
# strings are re-derived from the downloaded data at build time (the Tanzil
# export stores the fatha/shadda marks in non-canonical order, so the literal
# below is NFC-equivalent but not byte-identical to the file).
BASMALA_EXACT = "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ"
# Surahs 95 & 97 render the basmala with a shadda on its first letter
# (idgham with the surah's opening word). Both must be stripped.
BASMALA_SHADDA = "بِّسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ"
# Indonesian basmala used on ayah-1 translations (id.indonesian does not
# actually carry it, but strip defensively).
BASMALA_ID = "Dengan nama Allah Yang Maha Pengasih, Maha Penyayang."


def derive_basmala(surah1_ayah1: str) -> None:
    """Set the data-exact basmala prefixes from surah 1 ayah 1's own text."""
    global BASMALA_EXACT, BASMALA_SHADDA
    if unicodedata.normalize("NFC", surah1_ayah1) != unicodedata.normalize(
        "NFC", BASMALA_EXACT
    ):
        raise RuntimeError(
            "surah 1 ayah 1 is not the expected basmala: "
            f"{surah1_ayah1[:40]!r}"
        )
    BASMALA_EXACT = surah1_ayah1
    BASMALA_SHADDA = surah1_ayah1[0] + "\u0651" + surah1_ayah1[1:]


def strip_basmala_arabic(text: str, surah_id: int) -> str:
    """Return ayah-1 uthmani text with the basmala removed (surahs != 1, 9)."""
    if surah_id in (1, 9):
        return text
    for prefix in (BASMALA_EXACT, BASMALA_SHADDA):
        if text.startswith(prefix):
            text = text[len(prefix):]
            # drop the single separator space that follows the basmala
            if text.startswith(" "):
                text = text[1:]
            return text
    raise RuntimeError(
        f"surah {surah_id} ayah 1 does not start with the basmala: {text[:40]!r}"
    )


def strip_basmala_indonesian(text: str, surah_id: int) -> str:
    if surah_id in (1, 9) or not text.startswith(BASMALA_ID):
        return text
    text = text[len(BASMALA_ID):]
    if text.startswith(" "):
        text = text[1:]
    return text


# ------------------------------------------------------------ db building

SCHEMA = """
CREATE TABLE surahs(
  id INTEGER PRIMARY KEY,              -- 1..114
  name_arabic TEXT NOT NULL,
  name_latin TEXT NOT NULL,
  name_indonesian TEXT NOT NULL,
  revelation_type INTEGER NOT NULL,    -- 0=Makki, 1=Madani
  ayah_count INTEGER NOT NULL,
  first_juz INTEGER NOT NULL,
  first_page INTEGER NOT NULL,
  has_bismillah INTEGER NOT NULL       -- 0 for surah 1 and 9, else 1
);
CREATE TABLE ayahs(
  id INTEGER PRIMARY KEY,              -- global 1..6236
  surah_id INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  text_uthmani TEXT NOT NULL,
  translation TEXT NOT NULL,
  juz INTEGER NOT NULL,
  page INTEGER NOT NULL,
  sajda INTEGER NOT NULL DEFAULT 0,
  UNIQUE(surah_id, ayah_number)
);
CREATE INDEX idx_ayahs_juz ON ayahs(juz);
CREATE TABLE tafsir(
  ayah_id INTEGER PRIMARY KEY,
  text_short TEXT NOT NULL,
  text_long TEXT NOT NULL
);
CREATE VIRTUAL TABLE ayah_fts USING fts5(
  search_ar, translation,
  content='',
  tokenize='unicode61 remove_diacritics 2'
);
"""
# NOTE: the original spec wrote "content='', rowid=ayah_id" but `rowid=` is not
# a valid FTS5 table option in any SQLite release. A contentless FTS5 table
# always has an implicit rowid; we supply it explicitly on INSERT so the FTS
# rowid == ayah.id (1..6236), which is the intended semantics.


def build_db() -> None:
    # -- load sources -----------------------------------------------------
    print("[1/5] Ensuring data sources (cache-aware)...")
    ensure_all_sources()

    print("[2/5] Loading sources...")
    uthmani = load_tanzil_text(DATA_DIR / "quran-uthmani.txt")
    indonesian = load_tanzil_text(DATA_DIR / "id.indonesian")
    meta = load_metadata(DATA_DIR / "quran-data.xml")
    indo_names = load_indonesian_names(DATA_DIR / "daftar_surat_kemenag.json")
    tafsir = load_tafsir(DATA_DIR / "quran.json")

    if len(uthmani) != 6236:
        raise RuntimeError(f"uthmani rows={len(uthmani)} expected 6236")
    if len(indonesian) != 6236:
        raise RuntimeError(f"translation rows={len(indonesian)} expected 6236")

    surahs_meta = meta["surahs"]
    by_sura = {}
    for surah, ayah, text in uthmani:
        by_sura.setdefault(surah, {})[ayah] = text
    trans_by_sura = {}
    for surah, ayah, text in indonesian:
        trans_by_sura.setdefault(surah, {})[ayah] = text

    derive_basmala(by_sura[1][1])

    def global_pos(surah: int, ayah: int) -> int:
        return surahs_meta[surah]["start"] + ayah

    def lookup(markers: list[tuple[int, int, int]], surah: int, ayah: int) -> int:
        pos = global_pos(surah, ayah)
        best = 0
        for ms, ma, mi in markers:
            if global_pos(ms, ma) <= pos:
                best = mi
        return best

    print("[3/5] Arabic normalization self-test...")
    if not self_test_normalize():
        raise RuntimeError("normalization self-test failed")

    # -- assemble rows ----------------------------------------------------
    print("[4/5] Building database...")
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    if DB_PATH.exists():
        DB_PATH.unlink()

    ayah_rows = []
    surah_rows = []
    fts_rows = []
    surah_meta = {}

    ayah_id = 0
    for surah in range(1, 115):
        m = surahs_meta[surah]
        ayas = m["ayas"]
        if len(by_sura.get(surah, {})) != ayas:
            raise RuntimeError(
                f"surah {surah}: {len(by_sura.get(surah, {}))} rows, metadata says {ayas}"
            )
        juz_min, page_min = 10**9, 10**9
        surah_ayah_rows = []
        for ayah in range(1, ayas + 1):
            ayah_id += 1
            text = by_sura[surah][ayah]
            translation = trans_by_sura[surah][ayah]
            # global id must match Tanzil canonical order
            expected_id = global_pos(surah, ayah)
            if ayah_id != expected_id:
                raise RuntimeError(
                    f"id mismatch at surah {surah} ayah {ayah}: {ayah_id} != {expected_id}"
                )
            # basmala stripping applies to ayah 1 only (surahs != 1, 9)
            if ayah == 1:
                text_uthmani = strip_basmala_arabic(text, surah)
                translation = strip_basmala_indonesian(translation, surah)
            else:
                text_uthmani, translation = text, translation
            juz = lookup(meta["juzs"], surah, ayah)
            page = lookup(meta["pages"], surah, ayah)
            sajda = 1 if (surah, ayah) in meta["sajdas"] else 0
            juz_min = min(juz_min, juz)
            page_min = min(page_min, page)
            ayah_rows.append(
                (ayah_id, surah, ayah, text_uthmani, translation, juz, page, sajda)
            )
            fts_rows.append((ayah_id, normalize(text_uthmani), translation))
            surah_ayah_rows.append(ayah_id)

        surah_rows.append(
            (
                surah,
                m["name"],
                m["tname"],
                indo_names[surah],
                0 if m["type"] == "Meccan" else 1,
                ayas,
                juz_min,
                page_min,
                0 if surah in (1, 9) else 1,
            )
        )
        surah_meta[surah] = (juz_min, page_min)

    if ayah_id != 6236:
        raise RuntimeError(f"ayah_id total {ayah_id}, expected 6236")
    if len(tafsir) != 6236:
        raise RuntimeError(f"tafsir {len(tafsir)}, expected 6236")

    with sqlite3.connect(DB_PATH) as conn:
        cur = conn.cursor()
        cur.executescript(SCHEMA)
        cur.executemany(
            "INSERT INTO surahs(id,name_arabic,name_latin,name_indonesian,"
            "revelation_type,ayah_count,first_juz,first_page,has_bismillah)"
            " VALUES (?,?,?,?,?,?,?,?,?)",
            surah_rows,
        )
        cur.executemany(
            "INSERT INTO ayahs(id,surah_id,ayah_number,text_uthmani,translation,"
            "juz,page,sajda) VALUES (?,?,?,?,?,?,?,?)",
            ayah_rows,
        )
        cur.executemany(
            "INSERT INTO tafsir(ayah_id,text_short,text_long) VALUES (?,?,?)",
            [(gid, short, long) for gid, (short, long) in sorted(tafsir.items())],
        )
        # contentless FTS5: every insert must supply every indexed column
        cur.executemany(
            "INSERT INTO ayah_fts(rowid, search_ar, translation) VALUES (?,?,?)",
            fts_rows,
        )
        # final statement: schema version
        cur.execute("PRAGMA user_version = 2")
        conn.commit()

    print("[5/5] Verification...")
    verify_db()

    print(f"\nDB ready: {DB_PATH} ({DB_PATH.stat().st_size:,} bytes)")


def verify_db() -> None:
    def q(sql, *args):
        with sqlite3.connect(DB_PATH) as conn:
            return conn.execute(sql, args).fetchall()

    surah_count = q("SELECT COUNT(*) FROM surahs")[0][0]
    ayah_count = q("SELECT COUNT(*) FROM ayahs")[0][0]
    tafsir_count = q("SELECT COUNT(*) FROM tafsir")[0][0]
    fts_count = q("SELECT COUNT(*) FROM ayah_fts")[0][0]
    match_rows = [r[0] for r in q(
        "SELECT rowid FROM ayah_fts WHERE ayah_fts MATCH ? ORDER BY rowid LIMIT 5",
        "الرحمن",
    )]
    s2a1 = q("SELECT text_uthmani FROM ayahs WHERE surah_id=2 AND ayah_number=1")[0][0]
    s1a1 = q("SELECT text_uthmani FROM ayahs WHERE surah_id=1 AND ayah_number=1")[0][0]
    s9a1 = q("SELECT text_uthmani FROM ayahs WHERE surah_id=9 AND ayah_number=1")[0][0]
    version = q("PRAGMA user_version")[0][0]
    size = DB_PATH.stat().st_size

    ok = True

    def check(label, cond):
        nonlocal ok
        ok = ok and bool(cond)
        print(f"  {label}: {'OK' if cond else 'FAIL'}")

    check(f"surah count == 114 (got {surah_count})", surah_count == 114)
    check(f"ayah count == 6236 (got {ayah_count})", ayah_count == 6236)
    check(f"tafsir count == 6236 (got {tafsir_count})", tafsir_count == 6236)
    check(f"ayah_fts count == 6236 (got {fts_count})", fts_count == 6236)
    check(f"FTS MATCH 'الرحمن' returns rowids {match_rows}", len(match_rows) > 0)
    check(
        "surah 2 ayah 1 does NOT start with basmala "
        f"(got {s2a1[:20]!r})",
        not s2a1.startswith("بِسْمِ"),
    )
    check(
        "surah 1 ayah 1 DOES start with basmala (it IS the ayah)",
        s1a1 == BASMALA_EXACT,
    )
    check(
        "surah 9 ayah 1 lacks basmala " f"(got {s9a1[:20]!r})",
        not s9a1.startswith("بِسْمِ") and not s9a1.startswith("بِّسْمِ"),
    )
    check(f"user_version == 2 (got {version})", version == 2)
    check(f"DB file size: {size:,} bytes", size > 1_000_000)

    # structural spot checks
    sums = q("SELECT SUM(ayah_count) FROM surahs")[0][0]
    check(f"SUM(ayah_count) == 6236 (got {sums})", sums == 6236)
    per_sura = q(
        "SELECT surah_id, COUNT(*) FROM ayahs GROUP BY surah_id ORDER BY surah_id"
    )
    meta_mismatch = 0
    for sid, cnt in per_sura:
        if cnt != q("SELECT ayah_count FROM surahs WHERE id=?", sid)[0][0]:
            meta_mismatch += 1
    check(f"per-surah ayah_count matches rows (mismatches={meta_mismatch})", meta_mismatch == 0)
    fts_ids = q("SELECT rowid FROM ayah_fts ORDER BY rowid")
    check("ayah_fts rowids == 1..6236", [r[0] for r in fts_ids] == list(range(1, 6237)))

    if not ok:
        raise RuntimeError("verification FAILED")


def main() -> None:
    if sys.version_info < (3, 9):
        sys.exit("python3 >= 3.9 required")
    try:
        build_db()
    except RuntimeError as exc:
        print(f"ERROR: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
