"""OCW -> Mathify course import pipeline (CLI dispatcher).

Stages run in order; each writes a reviewable artifact under build/ so an
expensive/failed stage isn't repeated:

  1 structure   pages/  -> build/structure.json   (course -> chapter -> pages)
  2 resources   resolve videos/PDFs -> build/modules.json
  3 cloudinary  upload SLIDE PDFs   -> build/cloudinary.json   (--dry-run ok)
  4 quiz        PDFs -> questions   -> build/quizzes.json       (--dry-run ok)
                >>> review build/quizzes.json before emit <<<
  5 emit        -> database/insert_course_2.sql

Examples:
  python ocw_import.py structure
  python ocw_import.py cloudinary --dry-run
  python ocw_import.py quiz --max-sources 2
  python ocw_import.py quiz --provider ollama # free, local extraction
  python ocw_import.py emit --min-confidence medium
  python ocw_import.py all --dry-run          # full offline rehearsal
"""

from __future__ import annotations

import argparse
import os

import structure
import resources
import cloudinary_upload
import quiz_extract
import emit_sql


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="stage", required=True)

    sub.add_parser("structure", help="build the chapter/page hierarchy")
    sub.add_parser("resources", help="resolve videos + PDF modules / quiz sources")

    c = sub.add_parser("cloudinary", help="upload SLIDE PDFs to Cloudinary")
    c.add_argument("--dry-run", action="store_true")

    q = sub.add_parser("quiz", help="extract quiz questions from problem/exam PDFs")
    q.add_argument("--provider", choices=["claude", "ollama"],
                   default=os.environ.get("QUIZ_PROVIDER", "claude"),
                   help="extraction engine (default: claude, or QUIZ_PROVIDER)")
    q.add_argument("--dry-run", action="store_true")
    q.add_argument("--max-sources", type=int, default=2)
    q.add_argument("--per-source", type=int, default=4)

    e = sub.add_parser("emit", help="render database/insert_course_2.sql")
    e.add_argument("--min-confidence", choices=["low", "medium", "high"],
                   default="low")
    e.add_argument("--skip-quizzes", action="store_true",
                   help="emit videos + slides only (ignore build/quizzes.json)")

    a = sub.add_parser("all", help="run every stage in order")
    a.add_argument("--provider", choices=["claude", "ollama"],
                   default=os.environ.get("QUIZ_PROVIDER", "claude"),
                   help="quiz extraction engine (default: claude, or QUIZ_PROVIDER)")
    a.add_argument("--dry-run", action="store_true",
                   help="offline rehearsal: no Cloudinary upload, no API calls")
    a.add_argument("--min-confidence", choices=["low", "medium", "high"],
                   default="low")
    a.add_argument("--skip-quizzes", action="store_true",
                   help="emit videos + slides only (ignore build/quizzes.json)")

    args = ap.parse_args()

    if args.stage == "structure":
        structure.build()
    elif args.stage == "resources":
        resources.build()
    elif args.stage == "cloudinary":
        cloudinary_upload.build(dry_run=args.dry_run)
    elif args.stage == "quiz":
        quiz_extract.build(provider=args.provider, max_sources=args.max_sources,
                           per_source=args.per_source, dry_run=args.dry_run)
    elif args.stage == "emit":
        emit_sql.build(min_confidence=args.min_confidence,
                       skip_quizzes=args.skip_quizzes)
    elif args.stage == "all":
        structure.build()
        resources.build()
        cloudinary_upload.build(dry_run=args.dry_run)
        if not args.skip_quizzes:
            quiz_extract.build(provider=args.provider, dry_run=args.dry_run)
        emit_sql.build(min_confidence=args.min_confidence,
                       skip_quizzes=args.skip_quizzes)


if __name__ == "__main__":
    main()
