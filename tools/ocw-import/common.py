"""Shared helpers for the OCW -> Mathify import pipeline.

Every stage reads/writes a small JSON artifact under ``build/`` so an expensive
or failed stage (Cloudinary upload, Claude extraction) is never repeated.
"""

from __future__ import annotations

import html
import json
import os
import re
import uuid
from pathlib import Path

# --- paths ------------------------------------------------------------------

# tools/ocw-import/common.py -> repo root is two parents up.
REPO_ROOT = Path(__file__).resolve().parents[2]


def _load_dotenv(path: Path) -> None:
    """Load KEY=VALUE lines from the project-root .env into os.environ.

    Mirrors com.mathify.util.MidtransConfig: a real OS environment variable of
    the same name always wins, so we only fill in keys that are unset. Keeps the
    pipeline dependency-free (no python-dotenv) and lets CLOUDINARY_URL /
    ANTHROPIC_API_KEY live in the same gitignored .env the Java app already uses.
    """
    if not path.exists():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key, value = key.strip(), value.strip().strip('"').strip("'")
        if key:
            os.environ.setdefault(key, value)


_load_dotenv(REPO_ROOT / ".env")

# The scraped OCW dump. Override with OCW_SRC if it ever moves.
SRC_DIR = Path(os.environ.get("OCW_SRC", REPO_ROOT / "single_variable_calculus"))

PAGES_DIR = SRC_DIR / "pages"
RESOURCES_DIR = SRC_DIR / "resources"
STATIC_DIR = SRC_DIR / "static_resources"

BUILD_DIR = Path(__file__).resolve().parent / "build"

# Course identity. All overridable by env so a new OCW dump can be imported
# without editing code: set OCW_SRC + OCW_COURSE_SLUG (+ optionally OCW_CATEGORY
# / OCW_ATTRIBUTION) and re-run the pipeline.
#
# COURSE_SLUG seeds the uuid5 IDs and the Cloudinary public_id namespace; bump
# it only when re-keying a whole course.
COURSE_SLUG = os.environ.get("OCW_COURSE_SLUG", "single-variable-calculus")
COURSE_CATEGORY = os.environ.get("OCW_CATEGORY", "Calculus")

# No license column exists, so CC BY-NC-SA attribution is appended to the course
# description (same stopgap as insert_course_1.sql). Override per source dump.
ATTRIBUTION = os.environ.get(
    "OCW_ATTRIBUTION",
    " [Source: MIT OpenCourseWare, 18.01SC Single Variable Calculus, Fall 2010. "
    "Instructors: David Jerison et al. License: CC BY-NC-SA. https://ocw.mit.edu]")

# Deterministic-ID namespace. Fixed constant -> re-runs produce identical UUIDs,
# so regenerating insert_course_2.sql yields a stable, reviewable diff (an
# improvement over insert_course_1.sql's random literals).
NAMESPACE = uuid.UUID("6f1d2b1e-0c2a-5a7b-9d3e-a1b2c3d4e5f6")

# Document learning_resource_types we keep as SLIDE / quiz-source PDFs.
KEEP_DOC_TYPES = {
    "Lecture Notes",
    "Problem Sets",
    "Problem Set Solutions",
    "Exams",
    "Exam Solutions",
}


# --- ids & strings ----------------------------------------------------------

def det_uuid(*parts: str) -> str:
    """Deterministic UUIDv5 from a stable key, namespaced to this course."""
    key = COURSE_SLUG + ":" + ":".join(parts)
    return str(uuid.uuid5(NAMESPACE, key))


def sql_str(value) -> str:
    """Render a Python value as a SQL literal (NULL-aware, quote-escaped)."""
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


_WS = re.compile(r"\s+")
_SHORTCODE = re.compile(r"\{\{.*?\}\}")  # Hugo shortcode junk: {{< sup "x" >}}


def clean_text(text: str) -> str:
    """Strip OCW nav boilerplate / shortcode junk and collapse whitespace."""
    if not text:
        return ""
    text = text.replace("« Previous | Next »", " ")
    text = text.replace("Previous | Next", " ")
    text = _SHORTCODE.sub(" ", text)
    text = html.unescape(text)            # &rsquo; -> ', &gt; -> >, ...
    text = text.replace(" > ", " ").replace(" &gt; ", " ")
    return _WS.sub(" ", text).strip()


def slugify(text: str) -> str:
    text = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return text or "x"


# --- io ---------------------------------------------------------------------

def load_json(path: Path):
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def dump_build(name: str, data) -> Path:
    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    path = BUILD_DIR / name
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2, ensure_ascii=False)
    return path


def load_build(name: str):
    return load_json(BUILD_DIR / name)


def static_path_for(file_field: str) -> Path | None:
    """Map a resource ``file`` field to its local static_resources/ path.

    The ``file`` field looks like ``/courses/.../<hex32>_<name>.pdf`` and the
    bytes live at ``static_resources/<hex32>_<name>.pdf``.
    """
    if not file_field:
        return None
    candidate = STATIC_DIR / os.path.basename(file_field)
    return candidate if candidate.exists() else None
