"""Stage 5: render database/insert_course_2.sql.

Consumes build/modules.json, build/cloudinary.json, build/quizzes.json and emits
a seed file in the SAME shape and FK-dependency order as
database/insert_course_1.sql:

  courses -> chapters -> learning_modules -> quizzes -> questions
          -> multiple_choice_options / fill_blank_questions + fill_blank_answers

All IDs are deterministic uuid5 (see common.det_uuid) so re-running yields a
stable diff. VIDEO duration_secs is a placeholder (real runtimes aren't in the
OCW metadata) - see the TODO block at the bottom of the generated file.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from common import (ATTRIBUTION, BUILD_DIR, REPO_ROOT, det_uuid, dump_build,
                    load_build, load_json, sql_str)

OUT_PATH = REPO_ROOT / "database" / "insert_course_2.sql"

VIDEO_PLACEHOLDER_SECS = 600

# difficulty -> (title suffix, passing_score), in tier order
TIERS = [
    ("beginner", "Beginner Quiz", 60),
    ("intermediate", "Intermediate Quiz", 70),
    ("advanced", "Advanced Quiz", 80),
]
_CONF_RANK = {"low": 0, "medium": 1, "high": 2}


def _row(values) -> str:
    return "(" + ", ".join(sql_str(v) for v in values) + ")"


def _section(title: str, table: str, cols: str, rows: list[str]) -> str:
    if not rows:
        return ""
    head = ("\n-- ---------------------------------------------------------------\n"
            f"-- {title}\n"
            "-- ---------------------------------------------------------------\n")
    return head + f"INSERT INTO {table} ({cols}) VALUES\n" + ",\n".join(rows) + ";\n"


def build(min_confidence: str = "low", skip_quizzes: bool = False) -> Path:
    modules = load_build("modules.json")
    cloud = load_json(BUILD_DIR / "cloudinary.json")
    # skip_quizzes lets the course ship with videos + slides only (no quiz
    # source needed), and avoids requiring build/quizzes.json to exist.
    quizzes = ({} if skip_quizzes
               else {c["slug"]: c for c in load_build("quizzes.json")["chapters"]})
    min_rank = _CONF_RANK[min_confidence]

    course = modules["course"]
    course_rows = [_row([course["id"], course["title"],
                         course["description"] + ATTRIBUTION, course["category"]])]

    chapter_rows, module_rows = [], []
    quiz_rows, question_rows = [], []
    mc_rows, fb_q_rows, fb_a_rows = [], [], []
    missing_slides = 0

    for ch in modules["chapters"]:
        chapter_rows.append(_row([
            ch["id"], course["id"], ch["title"], ch["description"],
            ch["xp_reward"], ch["order_index"]]))

        order = 0
        for m in ch["modules"]:
            if m["module_type"] == "VIDEO":
                module_rows.append(_row([
                    m["id"], ch["id"], m["title"], order, "VIDEO",
                    m["content_url"], VIDEO_PLACEHOLDER_SECS, None]))
                order += 1
            else:  # SLIDE
                entry = cloud.get(m["slug"])
                if not entry or not entry.get("secure_url"):
                    missing_slides += 1
                    continue
                module_rows.append(_row([
                    m["id"], ch["id"], m["title"], order, "SLIDE",
                    entry["secure_url"], None, entry["slide_count"]]))
                order += 1

        _emit_quizzes(ch, quizzes.get(ch["slug"]), min_rank,
                      quiz_rows, question_rows, mc_rows, fb_q_rows, fb_a_rows)

    sql = _assemble(course["title"], course_rows, chapter_rows, module_rows,
                    quiz_rows, question_rows, mc_rows, fb_q_rows, fb_a_rows)
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(sql, encoding="utf-8")

    print(f"emit_sql: wrote {OUT_PATH.relative_to(REPO_ROOT)}")
    print(f"  chapters={len(chapter_rows)} modules={len(module_rows)} "
          f"quizzes={len(quiz_rows)} questions={len(question_rows)}")
    if missing_slides:
        print(f"  ! {missing_slides} SLIDE modules skipped (no Cloudinary URL; "
              f"run cloudinary_upload.py)")
    return OUT_PATH


def _emit_quizzes(ch, qchapter, min_rank, quiz_rows, question_rows,
                  mc_rows, fb_q_rows, fb_a_rows) -> None:
    if not qchapter:
        return
    by_diff: dict[str, list] = {}
    for q in qchapter["questions"]:
        if _CONF_RANK.get(q.get("confidence", "low"), 0) < min_rank:
            continue
        by_diff.setdefault(q.get("difficulty", "beginner"), []).append(q)

    for difficulty, suffix, passing in TIERS:
        qs = by_diff.get(difficulty)
        if not qs:
            continue
        quiz_id = det_uuid("quiz", ch["slug"], difficulty)
        quiz_rows.append(_row([quiz_id, ch["id"],
                               f"{ch['title']} - {suffix}", passing]))
        for q_idx, q in enumerate(qs):
            qid = det_uuid("question", quiz_id, str(q_idx))
            qtype = q["question_type"]
            question_rows.append(_row([qid, quiz_id, q["prompt"],
                                       q.get("points", 1), qtype, q_idx]))
            if qtype == "MULTIPLE_CHOICE":
                for o_idx, opt in enumerate(q.get("options", [])):
                    mc_rows.append(_row([
                        det_uuid("option", qid, str(o_idx)), qid,
                        opt["text"], bool(opt.get("is_correct")), o_idx]))
            else:  # FILL_BLANK
                fb_q_rows.append(_row([qid, False]))
                for a_idx, ans in enumerate(q.get("answers", [])):
                    fb_a_rows.append(_row([
                        det_uuid("answer", qid, str(a_idx)), qid, ans]))


def _assemble(course_title, course_rows, chapter_rows, module_rows, quiz_rows,
              question_rows, mc_rows, fb_q_rows, fb_a_rows) -> str:
    parts = [
        "-- =====================================================================",
        f"-- Mathify data migration: {course_title}",
        "-- Generated by tools/ocw-import (do not hand-edit; re-run the pipeline).",
        "-- Targets database/mathify_schema.sql. IDs are deterministic uuid5.",
        "--",
        "-- NOTE: learning_modules.duration_secs for VIDEO rows is a PLACEHOLDER",
        f"--       ({VIDEO_PLACEHOLDER_SECS}s). OCW metadata has no reliable runtimes;",
        "--       update before relying on duration-based UI. SLIDE slide_count is",
        "--       the real PDF page count; content_url is the Cloudinary secure_url.",
        "-- =====================================================================",
        "",
        "USE mathify_db;",
        "SET FOREIGN_KEY_CHECKS = 0;",
        "",
        _section("courses", "courses",
                 "course_id, title, description, category", course_rows),
        _section("chapters", "chapters",
                 "chapter_id, course_id, title, description, xp_reward, order_index",
                 chapter_rows),
        _section("learning_modules", "learning_modules",
                 "module_id, chapter_id, title, order_index, module_type, "
                 "content_url, duration_secs, slide_count", module_rows),
        _section("quizzes", "quizzes",
                 "quiz_id, chapter_id, title, passing_score", quiz_rows),
        _section("questions", "questions",
                 "question_id, quiz_id, prompt, points, question_type, order_index",
                 question_rows),
        _section("multiple_choice_options", "multiple_choice_options",
                 "option_id, question_id, option_text, is_correct, order_index",
                 mc_rows),
        _section("fill_blank_questions", "fill_blank_questions",
                 "question_id, case_sensitive", fb_q_rows),
        _section("fill_blank_answers", "fill_blank_answers",
                 "answer_id, question_id, answer_text", fb_a_rows),
        "",
        "SET FOREIGN_KEY_CHECKS = 1;",
        "",
        "-- TODO: replace placeholder VIDEO duration_secs "
        f"({VIDEO_PLACEHOLDER_SECS}s) with real runtimes.",
        "",
    ]
    return "\n".join(p for p in parts if p is not None)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--min-confidence", choices=["low", "medium", "high"],
                    default="low",
                    help="drop questions below this extraction confidence")
    ap.add_argument("--skip-quizzes", action="store_true",
                    help="emit videos + slides only (ignore build/quizzes.json)")
    args = ap.parse_args()
    build(min_confidence=args.min_confidence, skip_quizzes=args.skip_quizzes)
