"""Stage 2: resolve each page's resources into modules + quiz sources.

A page's index.html links its videos and problem sets in document order as
``resources/<slug>/index.html``. We load each ``resources/<slug>/data.json``
and classify:

  - Video with a youtube_key       -> VIDEO module (embed URL)
  - Document PDF (Problem Sets /
    Exams + their Solutions)        -> quiz source (paired prb <-> sol)

Lecture Notes PDFs are NOT page-linked in this scrape, so they are matched to
chapters separately by the session number embedded in their filename
(``...Ses<N>...`` / ``...ses<N>...``) and attached as SLIDE modules.

Everything else (captions, images, clip transcript PDFs) is skipped.

Output: build/modules.json
"""

from __future__ import annotations

import re
from pathlib import Path

from common import (RESOURCES_DIR, SRC_DIR, det_uuid, dump_build, load_build,
                    load_json, static_path_for)

_RES_LINK = re.compile(r"resources/([a-z0-9._-]+)/index\.html")
_SESSION_NUM = re.compile(r"session-(\d+)")
_SES_IN_FILE = re.compile(r"[Ss]es(\d+)")

_PROBLEM_TYPES = {"Problem Sets", "Exams"}
_SOLUTION_TYPES = {"Problem Set Solutions", "Exam Solutions"}


def _ordered_slugs(index_html: Path) -> list[str]:
    text = index_html.read_text(encoding="utf-8", errors="ignore")
    out, seen = [], set()
    for m in _RES_LINK.finditer(text):
        slug = m.group(1)
        if slug not in seen:
            seen.add(slug)
            out.append(slug)
    return out


def _resource(slug: str) -> dict | None:
    data = RESOURCES_DIR / slug / "data.json"
    return load_json(data) if data.exists() else None


def _session_to_chapter(structure: dict) -> dict[int, int]:
    """Map a session number -> chapter index (position in chapters list)."""
    mapping: dict[int, int] = {}
    for i, ch in enumerate(structure["chapters"]):
        for page in ch["pages"]:
            m = _SESSION_NUM.search(page["slug"])
            if m:
                mapping[int(m.group(1))] = i
    return mapping


def build() -> dict:
    structure = load_build("structure.json")
    chapters = [{
        "slug": ch["slug"], "id": ch["id"], "title": ch["title"],
        "description": ch["description"], "order_index": ch["order_index"],
        "xp_reward": ch["xp_reward"], "modules": [], "quiz_sources": [],
    } for ch in structure["chapters"]]

    ses_to_ch = _session_to_chapter(structure)
    seen_slugs: set[str] = set()

    # --- pass 1: page-linked videos + problem/exam quiz sources -------------
    for i, ch in enumerate(structure["chapters"]):
        out = chapters[i]
        problems: dict[str, dict] = {}
        for page in ch["pages"]:
            index_html = SRC_DIR / page["rel_path"] / "index.html"
            if not index_html.exists():
                continue
            for slug in _ordered_slugs(index_html):
                res = _resource(slug)
                if res is None or slug in seen_slugs:
                    continue
                rtype = res.get("resource_type")
                lrt = set(res.get("learning_resource_types") or [])

                if rtype == "Video" and res.get("youtube_key"):
                    seen_slugs.add(slug)
                    out["modules"].append({
                        "id": det_uuid("module", slug),
                        "slug": slug,
                        "title": res.get("title", slug).strip(),
                        "module_type": "VIDEO",
                        "content_url": f"https://www.youtube.com/embed/"
                                       f"{res['youtube_key'].strip()}",
                        "order_index": len(out["modules"]),
                        "page": page["slug"],
                    })
                    continue

                if (rtype == "Document"
                        and res.get("file_type") == "application/pdf"
                        and lrt & (_PROBLEM_TYPES | _SOLUTION_TYPES)):
                    local = static_path_for(res.get("file"))
                    if local is None:
                        continue
                    seen_slugs.add(slug)
                    entry = {
                        "id": det_uuid("module", slug), "slug": slug,
                        "title": res.get("title", slug).strip(),
                        "description": (res.get("description") or "").strip(),
                        "local_path": str(local).replace("\\", "/"),
                        "lrt": sorted(lrt), "page": page["slug"],
                    }
                    # Host the original PDF as a SLIDE module (practice)...
                    out["modules"].append({**entry, "module_type": "SLIDE",
                                           "order_index": len(out["modules"])})
                    # ...and register problem/exam pairs as quiz sources.
                    base = _pair_key(slug)
                    rec = problems.setdefault(
                        base, {"base": base, "problem": None, "solution": None})
                    role = "solution" if (lrt & _SOLUTION_TYPES) else "problem"
                    rec[role] = entry
        out["quiz_sources"] = [v for v in problems.values() if v["problem"]]

    # --- pass 2: lecture-notes PDFs matched by session number --------------
    for res_dir in sorted(RESOURCES_DIR.iterdir()):
        data = res_dir / "data.json"
        if not data.exists():
            continue
        res = load_json(data)
        lrt = set(res.get("learning_resource_types") or [])
        if ("Lecture Notes" not in lrt
                or res.get("file_type") != "application/pdf"):
            continue
        slug = res_dir.name
        if slug in seen_slugs:
            continue
        m = _SES_IN_FILE.search(res.get("file") or res.get("title") or "")
        if not m:
            continue
        ch_idx = ses_to_ch.get(int(m.group(1)))
        if ch_idx is None:
            continue
        local = static_path_for(res.get("file"))
        if local is None:
            continue
        seen_slugs.add(slug)
        out = chapters[ch_idx]
        out["modules"].append({
            "id": det_uuid("module", slug), "slug": slug,
            "title": res.get("title", slug).strip(),
            "description": (res.get("description") or "").strip(),
            "local_path": str(local).replace("\\", "/"),
            "lrt": sorted(lrt), "module_type": "SLIDE",
            "order_index": len(out["modules"]),
            "page": None,
        })

    data = {"course": structure["course"], "chapters": chapters}
    dump_build("modules.json", data)
    n_vid = sum(1 for c in chapters for m in c["modules"]
                if m["module_type"] == "VIDEO")
    n_slide = sum(1 for c in chapters for m in c["modules"]
                  if m["module_type"] == "SLIDE")
    n_qs = sum(len(c["quiz_sources"]) for c in chapters)
    print(f"resources: {n_vid} VIDEO, {n_slide} SLIDE modules, "
          f"{n_qs} quiz sources")
    return data


def _pair_key(slug: str) -> str:
    """Strip a prb/sol suffix so a problem and its solution share a key."""
    return re.sub(r"(prb|sol)(-\d+)?$", "", slug).rstrip("_-")


if __name__ == "__main__":
    build()
