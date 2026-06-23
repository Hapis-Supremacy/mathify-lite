---
name: ocw-course-import
description: Use when importing a scraped MIT-OpenCourseWare-style content dump into a Mathify course as SQL, so the mapping, schema constraints, and pipeline match how single_variable_calculus was imported.
---

# Importing an OCW content dump into a Mathify course

This repo imports scraped MIT OpenCourseWare course dumps into the Mathify schema
as a SQL seed file.
The reference run is `single_variable_calculus/` -> `database/insert_course_2.sql`,
driven by the pipeline in `tools/ocw-import/`.
Reuse that pipeline; this skill is the map of how the pieces fit so you can adapt
it to a new dump without re-deriving the layout.

## When to use

Use this when the task is "turn this OCW (or OCW-shaped) dump into course
material we can load via SQL".
Run the pipeline rather than hand-writing SQL - 800+ modules are not hand-editable.
For a brand-new course, point the pipeline at the new dump with env vars instead
of editing code (`common.py` reads them):
`OCW_SRC` (dump dir), `OCW_COURSE_SLUG` (uuid5 seed + Cloudinary namespace),
`OCW_CATEGORY`, and `OCW_ATTRIBUTION` (the license/source line).
The reference dump (`single_variable_calculus/`) may be deleted after export -
the pipeline only needs it when (re-)running `structure`/`resources`/`cloudinary`
/`quiz`; `emit` runs from the cached `build/` artifacts.

## Input dump layout (what the scrape looks like)

- `data.json` (root) - `course_title`, `course_description`.
- `pages/` - the hierarchy: unit dirs (`1.-differentiation`, `unit-2-...`) plus
  `syllabus` and `final-exam`.
  Each unit has `part-*` dirs (and `exam-*` dirs); each part has `session-*` and
  `problem-set-*` dirs.
  Every level has a `data.json` (`title`, `content`); session/problem-set/exam
  pages also have `index.html`.
- `resources/<slug>/data.json` - one per resource.
  `resource_type` is `Video` (has `youtube_key`), `Document` (PDF, with
  `learning_resource_types` like `Lecture Notes` / `Problem Sets` /
  `Problem Set Solutions` / `Exams` / `Exam Solutions`), `Image`, or `Other`
  (captions).
- `static_resources/<hex32>_<name>.<ext>` - the actual bytes.
  Map a resource's `file` field (`/courses/.../<hex32>_<name>.pdf`) to its local
  path with `static_resources/ + basename(file)`.
- A page's `index.html` links its videos and problem sets, in document order, as
  `href="../../../../resources/<slug>/index.html"`.
  That ordered link list is the source of truth for what belongs to a page -
  `content_map.json` (UUID -> path) is not needed.
- Gotcha: lecture-notes PDFs are usually NOT page-linked.
  Attach them by the session number in their filename (`...Ses<N>...`), matched
  to the chapter that owns `session-<N>`.

## Schema mapping (decisions baked into the pipeline)

- Course = the dump.
- Chapter = each Part (`part-a/b/c`), plus per-unit exam folders and the
  top-level final exam; the Unit is folded into the chapter title
  ("Unit 1A: ...").
  Sessions are ordered before problem sets; parts before exams.
- Module: `Video` + `youtube_key` -> `VIDEO`
  (`content_url = https://www.youtube.com/embed/<key>`).
  Kept PDFs -> `SLIDE` (lecture notes, plus problem sets / solutions / exams,
  hosted on Cloudinary).
- Quizzes: problem-set + exam PDFs (problem PDF + solution PDF) are sent to a
  vision model and turned into typed questions; the solution PDF supplies the
  answer key.
  Stage 4 has two interchangeable providers behind `--provider`: `claude` (paid,
  native PDF document blocks) and `ollama` (free, local - PDF pages rasterized to
  images via PyMuPDF and sent to a local vision model).
  Both share one SYSTEM prompt + `RESPONSE_SCHEMA`, and every result passes
  through `_normalize`, so the `quizzes.json` contract and review gate are
  identical regardless of provider.
  Questions are tagged a difficulty and grouped into Beginner/Intermediate/
  Advanced quizzes (passing 60/70/80), mirroring `insert_course_1.sql`.
- Skip captions (`.vtt`/`.srt`), images, and clip transcript PDFs.

## Hard schema gotchas (will break the load if violated)

Source of truth: `database/mathify_schema.sql`.
Template to match byte-for-byte in shape/order: `database/insert_course_1.sql`.

- `learning_modules` CHECK `chk_module_type_fields`: a `VIDEO` row MUST have
  `duration_secs` NOT NULL and `slide_count` NULL; a `SLIDE` row MUST have
  `slide_count` NOT NULL and `duration_secs` NULL.
  OCW has no reliable runtimes, so VIDEO `duration_secs` is a placeholder (600s)
  with a TODO at the file bottom; SLIDE `slide_count` is the real PDF page count.
- Insert in FK-dependency order: `courses` -> `chapters` -> `learning_modules`
  -> `quizzes` -> `questions` -> `multiple_choice_options` /
  `fill_blank_questions` (+ `fill_blank_answers`).
  Wrap the file in `USE mathify_db;` + `SET FOREIGN_KEY_CHECKS = 0;` ...
  `SET FOREIGN_KEY_CHECKS = 1;`.
- ENUMs are fixed: `module_type` is `VIDEO`/`SLIDE`; `question_type` is
  `MULTIPLE_CHOICE`/`FILL_BLANK`/`DRAG_AND_DROP`.
- SQL-escape every string by doubling single quotes (`common.sql_str` does this;
  it also renders `None` -> `NULL` and booleans -> `TRUE`/`FALSE`).
- There is no license column, so CC BY-NC-SA attribution is appended to the
  course `description` (same stopgap as course 1); the text is
  `common.ATTRIBUTION`, overridable via the `OCW_ATTRIBUTION` env var.
- IDs are deterministic `uuid5` via `common.det_uuid(...)` so re-running yields a
  stable diff - prefer this over random literals.

## Cloudinary

- Upload PDFs with `resource_type="raw"`, `public_id="mathify/svc/<slug>.pdf"`,
  `overwrite=False`.
- Credentials come only from the `CLOUDINARY_URL` env var - never commit them.
- The returned `secure_url` becomes the SLIDE `content_url`; page count
  (`pypdf`) becomes `slide_count`.

## Pipeline + review gate

Run from `tools/ocw-import/` (see its README for setup/flags):

```
python ocw_import.py structure
python ocw_import.py resources
python ocw_import.py cloudinary           # needs CLOUDINARY_URL (or --dry-run)
python ocw_import.py quiz                 # claude: needs ANTHROPIC_API_KEY (or --dry-run)
python ocw_import.py quiz --provider ollama  # free, local: needs Ollama + a vision model
#   >>> review build/quizzes.json for math / answer-key accuracy here <<<
python ocw_import.py emit                 # writes database/insert_course_2.sql
python ocw_import.py emit --skip-quizzes  # videos + slides only (no quiz stage)
```

`python ocw_import.py all --dry-run` rehearses the whole thing offline.
The quiz stage uses an LLM on rendered math, so its output is the one part that
needs human review before `emit` - each question carries a `confidence` flag;
use `emit --min-confidence medium` to drop weak ones.

## Verify

Load `mathify_schema.sql`, then both `insert_course_*.sql` into a scratch MySQL 8
DB - it must apply with no CHECK/FK errors.
Then `mvn package cargo:run`, open http://localhost:8080/, and confirm the new
course shows in the catalog with working video + slide modules.
