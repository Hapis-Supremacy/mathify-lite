"""Stage 4: turn problem-set / exam PDFs into typed quiz questions.

For each chapter's quiz sources (a problem PDF + its solution PDF) we ask a
vision-capable model for typed questions whose answer keys come from the
solution PDF. The model must read the *rendered* math (plain pdftotext mangles
calculus), so the PDFs are handed over as images, never as extracted text:

  - claude  (paid):  native PDF `document` blocks - the model reads the PDF
                     directly. Needs ANTHROPIC_API_KEY.
  - ollama  (free):  PDF pages are rasterized to PNGs (PyMuPDF) and sent to a
                     local vision model. Needs Ollama running locally; no key,
                     no per-call cost.

Both providers share the same SYSTEM prompt and RESPONSE_SCHEMA, so output is the
same shape and the rest of the pipeline is unchanged. Every result is run through
`_normalize` so a loosely-conforming response still yields valid rows.

  >>> REVIEW GATE <<<
Stop after this stage and review build/quizzes.json for math / answer-key
accuracy before emit_sql.py turns it into SQL. Low-confidence questions in
particular should be human-checked - especially with the local provider, which
is less accurate than Claude on hard calculus.

Usage:
  python quiz_extract.py                          # claude (needs ANTHROPIC_API_KEY)
  python quiz_extract.py --provider ollama        # free, local (needs Ollama)
  python quiz_extract.py --max-sources 2          # cap sources per chapter
  python quiz_extract.py --dry-run                # no model; placeholder set
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import sys
from pathlib import Path

from common import REPO_ROOT, dump_build, load_build, BUILD_DIR, load_json

CLAUDE_MODEL = "claude-opus-4-8"
DEFAULT_OLLAMA_MODEL = "qwen2.5vl:7b"
CACHE = "quizzes.json"

# How many pages of each PDF the local provider rasterizes. Problem sets are
# 1-3pp; the longest exam is 17pp. Cap to bound latency / context.
OLLAMA_MAX_PAGES = 8
OLLAMA_DPI = 170
# Page images are token-heavy (~1.5-2k tokens each), so the default 4096-token
# window overflows. Raise it; override with OLLAMA_NUM_CTX for big exams.
OLLAMA_NUM_CTX = 32768
# Cap output tokens: small models under constrained JSON decoding can loop and
# generate until the whole context is full. A few questions fit well under this.
OLLAMA_NUM_PREDICT = 2048


# Prefer real assessments (unit problem sets, exams) over worked examples when
# capping how many sources we spend tokens on per chapter.
def _source_rank(base: str) -> int:
    b = base.lower()
    if "final" in b:
        return 0
    if "exam" in b:
        return 1
    if "pset" in b:
        return 2
    return 3  # worked examples (ex01, ...)


SYSTEM = (
    "You convert MIT OpenCourseWare single-variable-calculus problem sets and "
    "exams into self-contained quiz questions for a gamified learning app. "
    "You are given a PROBLEM pdf and its SOLUTION pdf. Use the solution pdf to "
    "determine correct answers. Rules: (1) Only produce a question if you can "
    "fully reconstruct it from the text - skip anything that depends on a "
    "figure/graph you cannot render in plain text. (2) Prefer FILL_BLANK with a "
    "single numeric or short exact answer; use MULTIPLE_CHOICE when a numeric "
    "answer is unnatural. (3) Write prompts as plain text math (use ^, /, "
    "sqrt(), pi, integral notation in words) - no LaTeX, no images. (4) Set "
    "confidence honestly: 'high' only when the answer is unambiguous from the "
    "solution. (5) Assign a difficulty. Keep each prompt self-contained."
)

RESPONSE_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "questions": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "properties": {
                    "prompt": {"type": "string"},
                    "question_type": {"type": "string",
                                      "enum": ["MULTIPLE_CHOICE", "FILL_BLANK"]},
                    "difficulty": {"type": "string",
                                   "enum": ["beginner", "intermediate", "advanced"]},
                    "confidence": {"type": "string",
                                   "enum": ["high", "medium", "low"]},
                    "points": {"type": "integer"},
                    # MCQ only (empty for FILL_BLANK)
                    "options": {
                        "type": "array",
                        "items": {
                            "type": "object",
                            "additionalProperties": False,
                            "properties": {
                                "text": {"type": "string"},
                                "is_correct": {"type": "boolean"},
                            },
                            "required": ["text", "is_correct"],
                        },
                    },
                    # FILL_BLANK only (empty for MCQ)
                    "answers": {"type": "array", "items": {"type": "string"}},
                },
                "required": ["prompt", "question_type", "difficulty",
                             "confidence", "points", "options", "answers"],
            },
        }
    },
    "required": ["questions"],
}


def _instruction(per_source: int) -> str:
    return (f"Produce up to {per_source} quiz questions from these PDFs. The "
            "first document/images are the problem set, the rest are the "
            "solutions. Return JSON matching the schema.")


# --- providers --------------------------------------------------------------

def _doc_block(path: Path) -> dict:
    data = base64.standard_b64encode(path.read_bytes()).decode("ascii")
    return {"type": "document",
            "source": {"type": "base64", "media_type": "application/pdf",
                       "data": data}}


class ClaudeExtractor:
    """Paid provider: send native PDF document blocks to the Claude API."""

    name = "claude"

    def __init__(self) -> None:
        if not os.environ.get("ANTHROPIC_API_KEY"):
            sys.exit("ANTHROPIC_API_KEY not set; use --dry-run or "
                     "--provider ollama.")
        import anthropic
        self.client = anthropic.Anthropic()
        self.model = CLAUDE_MODEL

    def extract(self, prb: Path, sol: Path | None, per_source: int) -> list:
        content = [{"type": "text", "text": _instruction(per_source)},
                   _doc_block(prb)]
        if sol and sol.exists():
            content.append(_doc_block(sol))
        resp = self.client.messages.create(
            model=self.model,
            max_tokens=8000,
            system=SYSTEM,
            messages=[{"role": "user", "content": content}],
            output_config={"format": {"type": "json_schema",
                                      "schema": RESPONSE_SCHEMA}},
        )
        text = next((b.text for b in resp.content if b.type == "text"), "{}")
        return json.loads(text).get("questions", [])


def _pdf_to_pngs(path: Path, max_pages: int = OLLAMA_MAX_PAGES,
                 dpi: int = OLLAMA_DPI) -> list[bytes]:
    """Rasterize the first `max_pages` pages of a PDF to PNG bytes."""
    import fitz  # PyMuPDF
    # OCW PDFs carry malformed accessibility tags; silence the harmless
    # "No common ancestor in structure tree" warnings (rendering is unaffected).
    fitz.TOOLS.mupdf_display_errors(False)
    out: list[bytes] = []
    with fitz.open(str(path)) as doc:
        for i, page in enumerate(doc):
            if i >= max_pages:
                break
            out.append(page.get_pixmap(dpi=dpi).tobytes("png"))
    return out


class OllamaExtractor:
    """Free provider: rasterize PDFs and send pages to a local vision model."""

    name = "ollama"

    def __init__(self) -> None:
        import ollama
        self.model = os.environ.get("OLLAMA_MODEL", DEFAULT_OLLAMA_MODEL)
        self.num_ctx = int(os.environ.get("OLLAMA_NUM_CTX", OLLAMA_NUM_CTX))
        self.num_predict = int(os.environ.get("OLLAMA_NUM_PREDICT",
                                              OLLAMA_NUM_PREDICT))
        host = os.environ.get("OLLAMA_HOST")
        self.client = ollama.Client(host=host) if host else ollama

    def extract(self, prb: Path, sol: Path | None, per_source: int) -> list:
        images = _pdf_to_pngs(prb)
        if sol and sol.exists():
            images += _pdf_to_pngs(sol)
        resp = self.client.chat(
            model=self.model,
            messages=[
                {"role": "system", "content": SYSTEM},
                {"role": "user", "content": _instruction(per_source),
                 "images": images},
            ],
            format=RESPONSE_SCHEMA,
            options={"temperature": 0, "num_ctx": self.num_ctx,
                     "num_predict": self.num_predict},
        )
        text = resp.message.content if hasattr(resp, "message") \
            else resp["message"]["content"]
        return json.loads(text or "{}").get("questions", [])


def _make_extractor(provider: str):
    if provider == "claude":
        return ClaudeExtractor()
    if provider == "ollama":
        return OllamaExtractor()
    sys.exit(f"unknown provider: {provider!r} (expected claude or ollama)")


# --- normalization ----------------------------------------------------------

_DIFFICULTIES = {"beginner", "intermediate", "advanced"}
_CONFIDENCES = {"high", "medium", "low"}
_QTYPES = {"MULTIPLE_CHOICE", "FILL_BLANK"}


def _normalize(questions) -> list:
    """Coerce a model's output into valid rows; drop anything unusable.

    Local models in particular drift from the schema, so we repair what we can
    (default points/confidence/difficulty, infer question_type) and discard
    questions that can't form a valid MCQ or fill-blank.
    """
    clean = []
    for q in questions or []:
        if not isinstance(q, dict):
            continue
        prompt = str(q.get("prompt", "")).strip()
        if not prompt:
            continue

        qtype = q.get("question_type")
        if qtype not in _QTYPES:
            qtype = "MULTIPLE_CHOICE" if q.get("options") else "FILL_BLANK"

        difficulty = q.get("difficulty")
        if difficulty not in _DIFFICULTIES:
            difficulty = "intermediate"

        confidence = q.get("confidence")
        if confidence not in _CONFIDENCES:
            confidence = "low"  # unknown -> let the review gate flag it

        try:
            points = max(1, int(q.get("points") or 1))
        except (TypeError, ValueError):
            points = 1

        norm = {"prompt": prompt, "question_type": qtype,
                "difficulty": difficulty, "confidence": confidence,
                "points": points, "options": [], "answers": []}

        if qtype == "MULTIPLE_CHOICE":
            opts = []
            for o in q.get("options") or []:
                if not isinstance(o, dict):
                    continue
                text = str(o.get("text", "")).strip()
                if text:
                    opts.append({"text": text,
                                 "is_correct": bool(o.get("is_correct"))})
            if len(opts) < 2 or sum(o["is_correct"] for o in opts) != 1:
                continue  # not a usable single-answer MCQ
            norm["options"] = opts
        else:  # FILL_BLANK
            answers = [str(a).strip() for a in (q.get("answers") or [])
                       if str(a).strip()]
            if not answers:
                continue  # no answer key -> useless
            norm["answers"] = answers

        clean.append(norm)
    return clean


# --- io / orchestration -----------------------------------------------------

def _abs(p: str) -> Path:
    path = Path(p)
    return path if path.is_absolute() else REPO_ROOT / p


def _pair_hash(prb: Path, sol: Path | None) -> str:
    h = hashlib.sha1()
    for f in (prb, sol):
        if f and f.exists():
            h.update(f.read_bytes())
    return h.hexdigest()


def _placeholder(chapter_title: str) -> list:
    return [{
        "prompt": f"[PLACEHOLDER - dry run] Sample question for {chapter_title}.",
        "question_type": "FILL_BLANK", "difficulty": "beginner",
        "confidence": "low", "points": 1, "options": [], "answers": ["0"],
    }]


def build(provider: str = "claude", max_sources: int = 2, per_source: int = 4,
          dry_run: bool = False) -> dict:
    modules = load_build("modules.json")
    cache_path = BUILD_DIR / CACHE
    cache = load_json(cache_path) if cache_path.exists() else {}

    extractor = None
    if dry_run:
        engine = f"{provider}:dry-run"
    else:
        extractor = _make_extractor(provider)
        engine = f"{extractor.name}:{extractor.model}"

    out = {"chapters": []}
    for ch in modules["chapters"]:
        sources = sorted(ch["quiz_sources"],
                         key=lambda s: _source_rank(s["base"]))[:max_sources]
        questions = []
        for src in sources:
            prb = _abs(src["problem"]["local_path"])
            sol = _abs(src["solution"]["local_path"]) if src.get("solution") else None
            # Engine (provider + model) is part of the cache key so switching
            # providers never reuses another engine's extracted questions.
            key = f"{src['base']}:{engine}"
            digest = _pair_hash(prb, sol)
            cached = cache.get(key)
            if cached and cached.get("hash") == digest:
                questions.extend(cached["questions"])
                continue
            if dry_run:
                qs = _placeholder(ch["title"]) if not questions else []
            else:
                print(f"  extracting {src['base']} via {engine} ...")
                try:
                    qs = _normalize(extractor.extract(prb, sol, per_source))
                except Exception as exc:  # noqa: BLE001
                    print(f"  ! failed {src['base']}: {exc}")
                    qs = []
            cache[key] = {"hash": digest, "questions": qs, "dry_run": dry_run}
            questions.extend(qs)

        out["chapters"].append({
            "slug": ch["slug"], "id": ch["id"], "title": ch["title"],
            "questions": questions,
        })

    dump_build(CACHE, cache)
    dump_build("quizzes.json", out)
    total = sum(len(c["questions"]) for c in out["chapters"])
    low = sum(1 for c in out["chapters"] for q in c["questions"]
              if q.get("confidence") == "low")
    print(f"quiz_extract: {total} questions across {len(out['chapters'])} "
          f"chapters ({low} low-confidence) via {engine} "
          f"{'(DRY RUN)' if dry_run else ''}")
    print("REVIEW build/quizzes.json before running emit_sql.py.")
    return out


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--provider", choices=["claude", "ollama"],
                    default=os.environ.get("QUIZ_PROVIDER", "claude"),
                    help="extraction engine (default: claude, or QUIZ_PROVIDER)")
    ap.add_argument("--max-sources", type=int, default=2,
                    help="max problem/exam sources per chapter")
    ap.add_argument("--per-source", type=int, default=4,
                    help="max questions to request per source")
    ap.add_argument("--dry-run", action="store_true",
                    help="no model calls; emit placeholder questions")
    args = ap.parse_args()
    build(provider=args.provider, max_sources=args.max_sources,
          per_source=args.per_source, dry_run=args.dry_run)
