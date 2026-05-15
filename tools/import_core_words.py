#!/usr/bin/env python3
"""Convert `Words done (2)(1).xlsx` to assets/data/core_welsh_words.json."""

from __future__ import annotations

import json
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "data"
OUTPUT = ASSETS / "core_welsh_words.json"
XLSX_CANDIDATES = [
    ASSETS / "Words done (2)(1).xlsx",
    ROOT / "Words done (2)(1).xlsx",
    ASSETS / "words_done.xlsx",
]

NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
ENGLISH_HINTS = ("english", "en", "meaning", "translation")
WELSH_HINTS = ("welsh", "cy", "cymraeg", "word")


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


def _read_sheet_rows(zf: zipfile.ZipFile) -> list[list[str]]:
    sheet_name = "xl/worksheets/sheet1.xml"
    if sheet_name not in zf.namelist():
        raise FileNotFoundError("sheet1.xml not found in workbook")
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


def _detect_columns(rows: list[list[str]]) -> tuple[int, int, int]:
    """Return (start_row_index, english_col, welsh_col)."""
    if not rows:
        return 0, 0, 1

    header = [_normalize_header(c) for c in rows[0]]
    en_idx = -1
    cy_idx = -1
    for i, cell in enumerate(header):
        if any(h in cell for h in ENGLISH_HINTS):
            en_idx = i
        if any(h in cell for h in WELSH_HINTS):
            cy_idx = i

    if en_idx >= 0 and cy_idx >= 0:
        return 1, en_idx, cy_idx

    # No headers — column A English, column B Welsh (per buyer sheet).
    return 0, 0, 1


def _parse_pairs(rows: list[list[str]]) -> list[tuple[str, str]]:
    start, en_col, cy_col = _detect_columns(rows)
    seen: set[tuple[str, str]] = set()
    pairs: list[tuple[str, str]] = []

    for row in rows[start:]:
        if len(row) <= max(en_col, cy_col):
            continue
        english = row[en_col].strip()
        welsh = row[cy_col].strip()
        if not english or not welsh:
            continue
        key = (english.casefold(), welsh.casefold())
        if key in seen:
            continue
        seen.add(key)
        pairs.append((english, welsh))
    return pairs


def _load_pairs_from_xlsx(path: Path) -> list[tuple[str, str]]:
    with zipfile.ZipFile(path) as zf:
        rows = _read_sheet_rows(zf)
    return _parse_pairs(rows)


def _build_json(pairs: list[tuple[str, str]]) -> list[dict]:
    deck_id = "core_welsh_words"
    deck_name = "Core Welsh Words"
    badge = "Core Welsh Word"
    words = []
    for i, (english, welsh) in enumerate(pairs, start=1):
        words.append(
            {
                "id": f"core_{i:03d}",
                "deckId": deck_id,
                "deckName": deck_name,
                "english": english,
                "welsh": welsh,
                "badge": badge,
                "image": None,
                "order": i,
            }
        )
    return words


def main() -> int:
    xlsx = next((p for p in XLSX_CANDIDATES if p.exists()), None)
    if xlsx is None:
        print(
            "ERROR: Place the Excel file at one of:\n"
            + "\n".join(f"  - {p}" for p in XLSX_CANDIDATES),
            file=sys.stderr,
        )
        return 1

    pairs = _load_pairs_from_xlsx(xlsx)
    if not pairs:
        print("ERROR: No word pairs found in spreadsheet.", file=sys.stderr)
        return 1

    ASSETS.mkdir(parents=True, exist_ok=True)
    payload = _build_json(pairs)
    OUTPUT.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"Wrote {len(payload)} words to {OUTPUT} from {xlsx.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
