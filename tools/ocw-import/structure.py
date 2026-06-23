"""Stage 1: build the course -> chapter (= Part) -> page hierarchy.

Mapping (locked with the user):
  - Course  = the whole dump.
  - Chapter = each Part (part-a/b/c) of each Unit, plus per-unit exam folders
              and the top-level final-exam. Unit info is folded into the title.
  - Pages   = the session-* and problem-set-* dirs inside a Part, in order.
    (resources.py later turns each page's resources into modules/quiz sources.)

Output: build/structure.json
"""

from __future__ import annotations

import re
from pathlib import Path

from common import (COURSE_CATEGORY, COURSE_SLUG, PAGES_DIR, SRC_DIR,
                    clean_text, det_uuid, dump_build, load_json)

# Top-level pages dir is informational only; not a content chapter.
SKIP_UNITS = {"syllabus"}

_UNIT_NUM = re.compile(r"^\s*(\d+)\.")
_PART_LETTER = re.compile(r"part-([a-z])-")
_SESSION_NUM = re.compile(r"session-(\d+)")
_PSET_NUM = re.compile(r"problem-set-(\d+)")
_EXAM_NUM = re.compile(r"exam-(\d+)")


def _title_of(dir_path: Path) -> str:
    data = dir_path / "data.json"
    if data.exists():
        return load_json(data).get("title", dir_path.name).strip()
    return dir_path.name


def _desc_of(dir_path: Path) -> str:
    data = dir_path / "data.json"
    if data.exists():
        return clean_text(load_json(data).get("content", ""))
    return ""


def _part_sort_key(part_dir: Path):
    """Parts (part-a/b/c) before exam folders, each in natural order."""
    letter = _PART_LETTER.search(part_dir.name)
    if letter:
        return (0, letter.group(1))
    exam = _EXAM_NUM.search(part_dir.name)
    if exam:
        return (1, int(exam.group(1)))
    return (2, part_dir.name)


def _page_sort_key(name: str):
    """Sessions first (by number), then problem sets (by number)."""
    m = _SESSION_NUM.search(name)
    if m:
        return (0, int(m.group(1)))
    m = _PSET_NUM.search(name)
    if m:
        return (1, int(m.group(1)))
    return (2, name)


def _collect_pages(part_dir: Path) -> list[dict]:
    pages = []
    for child in sorted(part_dir.iterdir(), key=lambda p: _page_sort_key(p.name)):
        if not child.is_dir() or not (child / "index.html").exists():
            continue
        kind = "problem_set" if child.name.startswith("problem-set") else "session"
        pages.append({
            "slug": child.name,
            "rel_path": str(child.relative_to(SRC_DIR)).replace("\\", "/"),
            "title": _title_of(child),
            "kind": kind,
        })
    return pages


def _unit_dirs() -> list[Path]:
    """Unit dirs ordered by their leading number; final-exam appended last."""
    units, final = [], None
    for d in PAGES_DIR.iterdir():
        if not d.is_dir() or d.name in SKIP_UNITS:
            continue
        if d.name == "final-exam":
            final = d
            continue
        units.append(d)
    units.sort(key=lambda d: _unit_number(d))
    if final is not None:
        units.append(final)
    return units


def _unit_number(unit_dir: Path) -> int:
    m = _UNIT_NUM.match(_title_of(unit_dir))
    return int(m.group(1)) if m else 99


def build() -> dict:
    root = load_json(SRC_DIR / "data.json")
    course = {
        "slug": COURSE_SLUG,
        "id": det_uuid("course"),
        "title": root.get("course_title", "Single Variable Calculus").strip(),
        "description": clean_text(root.get("course_description", "")),
        "category": COURSE_CATEGORY,
    }

    chapters: list[dict] = []
    order = 0
    for unit_dir in _unit_dirs():
        unit_num = _unit_number(unit_dir)
        unit_is_final = unit_dir.name == "final-exam"

        # A "Part" is any subdir that itself holds session/problem-set/exam
        # content. part-* and exam-* qualify; final-exam is its own single
        # chapter (it has no part subdirs).
        part_dirs = [c for c in unit_dir.iterdir()
                     if c.is_dir() and (c.name.startswith("part-")
                                        or c.name.startswith("exam-"))]
        # Parts (a, b, c) first, then exam folders, matching OCW unit order.
        part_dirs.sort(key=_part_sort_key)

        targets = part_dirs if part_dirs else [unit_dir]
        for part_dir in targets:
            pages = _collect_pages(part_dir)
            if not pages and (part_dir / "index.html").exists():
                # Chapter dir with no child pages (e.g. final-exam): its own
                # index.html references the resources directly.
                pages = [{
                    "slug": part_dir.name,
                    "rel_path": str(part_dir.relative_to(SRC_DIR)).replace("\\", "/"),
                    "title": _title_of(part_dir),
                    "kind": "exam" if "exam" in part_dir.name else "session",
                }]
            if not pages:
                continue
            order += 1
            rel = str(part_dir.relative_to(SRC_DIR)).replace("\\", "/")
            chapters.append({
                "slug": rel,
                "id": det_uuid("chapter", rel),
                "title": _chapter_title(unit_num, unit_dir, part_dir,
                                        unit_is_final),
                "description": _desc_of(part_dir) or _desc_of(unit_dir),
                "order_index": order,
                "xp_reward": 100,
                "pages": pages,
            })

    data = {"course": course, "chapters": chapters}
    dump_build("structure.json", data)
    print(f"structure: {len(chapters)} chapters, "
          f"{sum(len(c['pages']) for c in chapters)} pages")
    return data


def _chapter_title(unit_num: int, unit_dir: Path, part_dir: Path,
                   unit_is_final: bool) -> str:
    if unit_is_final:
        return _title_of(part_dir)
    part_title = _title_of(part_dir)
    letter = _PART_LETTER.search(part_dir.name)
    exam = _EXAM_NUM.search(part_dir.name)
    if letter:
        # "Part A: Definition and Basic Rules" -> "Unit 1A: Definition ..."
        body = re.sub(r"^Part\s+[A-Za-z]:\s*", "", part_title)
        return f"Unit {unit_num}{letter.group(1).upper()}: {body}"
    if exam:
        return f"Unit {unit_num} - {part_title}"
    return f"Unit {unit_num}: {part_title}"


if __name__ == "__main__":
    build()
