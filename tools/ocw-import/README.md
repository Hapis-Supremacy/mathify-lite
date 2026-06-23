# OCW -> Mathify import pipeline

Turns a scraped MIT-OpenCourseWare-style content dump into a Mathify course seed
file (`database/insert_course_2.sql`), mirroring `database/insert_course_1.sql`.
Built for `single_variable_calculus/` (MIT 18.01SC, CC BY-NC-SA) but the stages
are generic.

See `.claude/skills/ocw-course-import/SKILL.md` for the conceptual mapping rules
and schema gotchas. This README is the how-to-run.

## Setup

```bash
pip install -r requirements.txt
export CLOUDINARY_URL="cloudinary://<key>:<secret>@<cloud_name>"   # stage 3
export ANTHROPIC_API_KEY="sk-ant-..."                             # stage 4 (claude provider)
```

Credentials come from the environment only - never commit them. The pipeline
also reads these from the project-root `.env` (see `.env.example`).

## Quiz extraction providers (stage 4)

Stage 4 supports two engines, chosen with `--provider` (or the `QUIZ_PROVIDER`
env var). Both send the *rendered* PDF math to the model and return the same
schema-constrained JSON - the rest of the pipeline is identical.

- `claude` (default, paid): sends native PDF document blocks to the Claude API.
  Needs `ANTHROPIC_API_KEY`. Most accurate.
- `ollama` (free, local): rasterizes the PDF pages and sends them to a local
  vision model. No key, no per-call cost. Slower and less accurate on hard
  calculus, so the review gate matters more.

### Local quiz extraction (free)

```bash
# 1. Install Ollama (https://ollama.com) and start it, then pull a vision model:
ollama pull qwen2.5vl:7b          # or qwen2.5vl:3b for low-RAM machines

# 2. Run stage 4 locally (no API key needed):
python ocw_import.py quiz --provider ollama --max-sources 1 --per-source 2
```

Override the model with `OLLAMA_MODEL` and the server with `OLLAMA_HOST`
(default `http://localhost:11434`). If `qwen2.5vl` is too weak on integrals /
limits, the higher-accuracy local route is OCR-first (Nougat -> LaTeX -> a local
text model), at the cost of a much heavier setup.

## Stages

Each stage writes a reviewable artifact under `build/`, so a slow/failed stage
(Cloudinary upload, Claude extraction) is never repeated unnecessarily.

| # | Command | Reads | Writes |
|---|---------|-------|--------|
| 1 | `python ocw_import.py structure` | `single_variable_calculus/pages/` | `build/structure.json` |
| 2 | `python ocw_import.py resources` | structure + `resources/` + `static_resources/` | `build/modules.json` |
| 3 | `python ocw_import.py cloudinary` | modules + PDFs | `build/cloudinary.json` |
| 4 | `python ocw_import.py quiz` | modules + problem/exam PDFs | `build/quizzes.json` |
| 5 | `python ocw_import.py emit` | all of the above | `database/insert_course_2.sql` |

Offline rehearsal (no network, no API spend):

```bash
python ocw_import.py all --dry-run
```

`--dry-run` makes stage 3 predict Cloudinary URLs (still counts real PDF pages)
and stage 4 emit placeholder questions, so you can exercise stage 5 end-to-end
before spending money.

## Review gate

After stage 4, **review `build/quizzes.json`** for math and answer-key accuracy
before running `emit`. The quiz questions are extracted from PDFs by an LLM;
each carries a `confidence` flag. Drop weak ones at emit time:

```bash
python ocw_import.py emit --min-confidence medium
```

To ship a course with videos + slides only (no quizzes), skip stage 4 entirely:

```bash
python ocw_import.py emit --skip-quizzes
```

## Reusing for another OCW dump

Point the pipeline at a new dump with env vars - no code edits:

```bash
export OCW_SRC="/path/to/another_course"
export OCW_COURSE_SLUG="multivariable-calculus"   # uuid5 seed + Cloudinary namespace
export OCW_CATEGORY="Calculus"
export OCW_ATTRIBUTION=" [Source: ... License: CC BY-NC-SA. https://ocw.mit.edu]"
python ocw_import.py all --dry-run
```

The reference dump (`single_variable_calculus/`) can be deleted after export;
`emit` re-runs from the cached `build/` artifacts and only the earlier stages
need the source files.

## Cost control

Stage 4 is the only billable stage, and only with `--provider claude` (the
`ollama` provider is free). It caps sources per chapter (`--max-sources`,
default 2) and questions per source (`--per-source`, default 4), and caches
results by file hash + engine in `build/quizzes.json` so re-runs are free.

## Loading the result

```bash
mysql < ../../database/mathify_schema.sql
mysql < ../../database/insert_course_1.sql
mysql < ../../database/insert_course_2.sql
```

`build/` is regenerable and git-ignored.
