#!/usr/bin/env python3
"""Convert buyer spreadsheet to bundled vocabulary JSON files.

Expected columns (with or without headers):
  English | Welsh | Section

Deck labels are mapped to app deck ids, e.g. Easy -> starter_words,
Top 1000 -> core_welsh_words, Days and Months -> days_and_months.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "data"
CORE_OUTPUT = ASSETS / "core_welsh_words.json"
STARTER_OUTPUT = ASSETS / "starter_words.json"
TOPIC_OUTPUT = ASSETS / "topic_decks_words.json"
XLSX_CANDIDATES = [
    ROOT / "Top1000 Complete.xlsx",
    ASSETS / "Top1000 Complete.xlsx",
    ASSETS / "Words done (2)(1).xlsx",
    ASSETS / "words_done.xlsx",
    ROOT / "Words done (2)(1).xlsx",
]

NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
ENGLISH_HINTS = ("english", "en", "meaning", "translation")
WELSH_HINTS = ("welsh", "cy", "cymraeg", "word")
DECK_HINTS = ("deck", "section", "category", "topic")

DECK_ALIASES: dict[str, tuple[str, str, str, str]] = {
    "easy": ("starter_words", "Starter Words", "Starter Word", "starter"),
    "starter words": ("starter_words", "Starter Words", "Starter Word", "starter"),
    "starter": ("starter_words", "Starter Words", "Starter Word", "starter"),
    "top1000": ("core_welsh_words", "Core Welsh Words", "Core Welsh Word", "core"),
    "top 1000": ("core_welsh_words", "Core Welsh Words", "Core Welsh Word", "core"),
    "core welsh words": ("core_welsh_words", "Core Welsh Words", "Core Welsh Word", "core"),
    "core": ("core_welsh_words", "Core Welsh Words", "Core Welsh Word", "core"),
    "days and months": ("days_and_months", "Days and Months", "Days & Months", "days"),
    "phrases": ("phrases", "Phrases", "Phrase", "phrases"),
    "talking about me": ("talking_about_me", "Talking about me", "About me", "me"),
    "patterns about me": ("talking_about_me", "Talking about me", "About me", "me"),
    "animals": ("animals", "Animals", "Animal", "animals"),
    "dates": ("dates", "Dates", "Date", "dates"),
    "dates (advanced)": ("dates", "Dates", "Date", "dates"),
    "nature": ("nature", "Nature", "Nature", "nature"),
}


def _col_letters(cell_ref: str) -> str:
    return "".join(ch for ch in cell_ref if ch.isalpha())


def _read_shared_strings(zf: zipfile.ZipFile) -> list[str]:
    if "xl/sharedStrings.xml" not in zf.namelist():
        return []
    root = ET.fromstring(zf.read("xl/sharedStrings.xml"))
    strings: list[str] = []
    for si in root.findall("m:si", NS):
        parts = [t.text or "" for t in si.findall(".//m:t", NS)]
        strings.append("".join(parts))
    return strings


def _read_sheet_rows(zf: zipfile.ZipFile, sheet_name: str) -> list[list[str]]:
    if sheet_name not in zf.namelist():
        raise FileNotFoundError(f"{sheet_name} not found in workbook")
    shared = _read_shared_strings(zf)
    root = ET.fromstring(zf.read(sheet_name))
    rows: dict[int, dict[int, str]] = {}
    for row in root.findall(".//m:sheetData/m:row", NS):
        r_idx = int(row.attrib.get("r", "0"))
        rows[r_idx] = {}
        for cell in row.findall("m:c", NS):
            ref = cell.attrib.get("r", "")
            col = 0
            for ch in _col_letters(ref):
                col = col * 26 + (ord(ch.upper()) - 64)
            value_el = cell.find("m:v", NS)
            if value_el is None or value_el.text is None:
                continue
            raw = value_el.text
            if cell.attrib.get("t") == "s":
                text = shared[int(raw)]
            else:
                text = raw
            rows[r_idx][col] = text.strip()
    result: list[list[str]] = []
    for r_idx in sorted(rows):
        cols = rows[r_idx]
        max_col = max(cols) if cols else 0
        result.append([cols.get(i, "") for i in range(1, max_col + 1)])
    return result


def _normalize_header(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().lower())


def _detect_columns(rows: list[list[str]]) -> tuple[int, int, int, int | None]:
    """Return (start_row_index, english_col, welsh_col, deck_col_or_none)."""
    if not rows:
        return 0, 0, 1, 2

    header = [_normalize_header(c) for c in rows[0]]
    en_idx = cy_idx = deck_idx = -1
    for i, cell in enumerate(header):
        if any(h in cell for h in ENGLISH_HINTS):
            en_idx = i
        if any(h in cell for h in WELSH_HINTS):
            cy_idx = i
        if any(h in cell for h in DECK_HINTS):
            deck_idx = i

    if en_idx >= 0 and cy_idx >= 0:
        return 1, en_idx, cy_idx, deck_idx if deck_idx >= 0 else None

    # Default: English | Welsh | Section
    return 0, 0, 1, 2 if len(rows[0]) > 2 else None


def _resolve_deck(raw: str) -> tuple[str, str, str, str] | None:
    key = _normalize_header(raw)
    if not key:
        return None
    if key in DECK_ALIASES:
        return DECK_ALIASES[key]
    slug = re.sub(r"[^a-z0-9]+", "_", key).strip("_")
    title = raw.strip() or key.title()
    badge = title if len(title) <= 16 else title[:14] + "…"
    prefix = slug.split("_")[0][:8] or "deck"
    return slug, title, badge, prefix


def _parse_rows(rows: list[list[str]]) -> dict[str, list[tuple[str, str]]]:
    start, en_col, cy_col, deck_col = _detect_columns(rows)
    grouped: dict[str, list[tuple[str, str]]] = defaultdict(list)

    for row in rows[start:]:
        if len(row) <= max(en_col, cy_col):
            continue
        english = row[en_col].strip()
        welsh = row[cy_col].strip()
        if not english or not welsh:
            continue

        deck_raw = row[deck_col].strip() if deck_col is not None and deck_col < len(row) else ""
        resolved = _resolve_deck(deck_raw)
        if resolved is None:
            continue
        deck_id, _, _, _ = resolved
        grouped[deck_id].append((english, welsh))

    return grouped


def _load_rows_from_xlsx(path: Path) -> list[list[str]]:
    with zipfile.ZipFile(path) as zf:
        sheets = sorted(
            name
            for name in zf.namelist()
            if name.startswith("xl/worksheets/sheet") and name.endswith(".xml")
        )
        all_rows: list[list[str]] = []
        for sheet in sheets:
            rows = _read_sheet_rows(zf, sheet)
            if rows:
                all_rows.extend(rows)
        return all_rows


def _deck_meta(deck_id: str) -> tuple[str, str, str, str]:
    for value in DECK_ALIASES.values():
        if value[0] == deck_id:
            return value
    slug = deck_id
    deck_name = deck_id.replace("_", " ").title()
    badge = deck_name
    prefix = slug.split("_")[0][:8] or "deck"
    return slug, deck_name, badge, prefix


def _build_entries(
    grouped: dict[str, list[tuple[str, str]]],
) -> tuple[list[dict], list[dict], list[dict]]:
    core: list[dict] = []
    starter: list[dict] = []
    topic: list[dict] = []
    counters: dict[str, int] = defaultdict(int)

    for deck_id in sorted(grouped):
        slug, deck_name, badge, prefix = _deck_meta(deck_id)

        if slug == "core_welsh_words":
            target = core
        elif slug == "starter_words":
            target = starter
        else:
            target = topic

        for english, welsh in grouped[deck_id]:
            counters[prefix] += 1
            target.append(
                {
                    "id": f"{prefix}_{counters[prefix]:03d}",
                    "deckId": slug,
                    "deckName": deck_name,
                    "english": english,
                    "welsh": welsh,
                    "badge": badge,
                    "image": None,
                    "order": counters[prefix],
                }
            )

    return core, starter, topic


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--replace",
        action="store_true",
        help="Replace JSON outputs entirely from the spreadsheet (recommended).",
    )
    args = parser.parse_args()

    xlsx = next((p for p in XLSX_CANDIDATES if p.exists()), None)
    if xlsx is None:
        print(
            "ERROR: Place the Excel file at one of:\n"
            + "\n".join(f"  - {p}" for p in XLSX_CANDIDATES),
            file=sys.stderr,
        )
        return 1

    grouped = _parse_rows(_load_rows_from_xlsx(xlsx))
    if not grouped:
        print("ERROR: No word rows found in spreadsheet.", file=sys.stderr)
        return 1

    core_new, starter_new, topic_new = _build_entries(grouped)
    ASSETS.mkdir(parents=True, exist_ok=True)

    # Full import from buyer spreadsheet replaces placeholder JSON.
    if not args.replace:
        print("Tip: use --replace for a full import from Top1000 Complete.xlsx")

    CORE_OUTPUT.write_text(
        json.dumps(core_new, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    STARTER_OUTPUT.write_text(
        json.dumps(starter_new, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    TOPIC_OUTPUT.write_text(
        json.dumps(topic_new, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    counts = {deck: len(words) for deck, words in grouped.items()}
    print(f"Imported from {xlsx.name}")
    for deck_id in sorted(counts):
        slug, name, _, _ = _deck_meta(deck_id)
        print(f"  {name}: {counts[deck_id]}")
    print(
        f"Wrote {len(core_new)} core, {len(starter_new)} starter, "
        f"{len(topic_new)} topic ({len(core_new) + len(starter_new) + len(topic_new)} total)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
