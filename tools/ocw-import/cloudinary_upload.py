"""Stage 3: host SLIDE PDFs on Cloudinary and record their delivery URLs.

For every SLIDE module in build/modules.json we:
  - upload the local PDF as a Cloudinary ``raw`` asset under the
    ``mathify/svc/`` namespace (public_id = ``mathify/svc/<slug>.pdf``);
  - capture the returned ``secure_url`` -> becomes the module content_url;
  - read the PDF page count -> becomes slide_count (NOT NULL for SLIDE).

Results are cached in build/cloudinary.json keyed by slug + file hash, so
re-runs skip already-uploaded files and the (slow, billable) upload is never
repeated unnecessarily.

Credentials come ONLY from the CLOUDINARY_URL env var
(``cloudinary://<key>:<secret>@<cloud>``) - never committed.

Usage:
  python cloudinary_upload.py            # real upload (needs CLOUDINARY_URL)
  python cloudinary_upload.py --dry-run  # no network; page counts + predicted
                                         #   URLs so the pipeline stays testable
"""

from __future__ import annotations

import argparse
import hashlib
import os
import sys
from pathlib import Path

from common import BUILD_DIR, REPO_ROOT, dump_build, load_build, load_json

PUBLIC_PREFIX = "mathify/svc"
CACHE = "cloudinary.json"


def _file_hash(path: Path) -> str:
    h = hashlib.sha1()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def _page_count(path: Path) -> int:
    try:
        from pypdf import PdfReader
        return max(1, len(PdfReader(str(path)).pages))
    except Exception as exc:  # noqa: BLE001 - degrade gracefully
        print(f"  ! page count failed for {path.name}: {exc}; using 1")
        return 1


def _slide_modules(modules: dict):
    for ch in modules["chapters"]:
        for m in ch["modules"]:
            if m["module_type"] == "SLIDE":
                yield m


def _load_cache() -> dict:
    path = BUILD_DIR / CACHE
    return load_json(path) if path.exists() else {}


def _cloud_name() -> str:
    url = os.environ.get("CLOUDINARY_URL", "")
    # cloudinary://key:secret@cloud_name
    return url.rsplit("@", 1)[-1] if "@" in url else os.environ.get(
        "CLOUDINARY_CLOUD_NAME", "demo")


def build(dry_run: bool = False) -> dict:
    modules = load_build("modules.json")
    cache = _load_cache()

    uploader = None
    if not dry_run:
        if not os.environ.get("CLOUDINARY_URL"):
            sys.exit("CLOUDINARY_URL not set; use --dry-run to test offline.")
        import cloudinary
        import cloudinary.uploader as up
        cloudinary.config(secure=True)  # reads CLOUDINARY_URL from env
        uploader = up

    cloud = _cloud_name()
    seen, uploaded, skipped = set(), 0, 0

    for m in _slide_modules(modules):
        slug = m["slug"]
        if slug in seen:
            continue
        seen.add(slug)
        local = REPO_ROOT / m["local_path"] if not Path(
            m["local_path"]).is_absolute() else Path(m["local_path"])
        if not local.exists():
            print(f"  ! missing {local}")
            continue

        digest = _file_hash(local)
        cached = cache.get(slug)
        reusable = bool(cached and cached.get("hash") == digest
                        and cached.get("secure_url"))
        # A real run must not reuse a predicted dry-run URL (it points nowhere);
        # re-upload for real instead.
        if reusable and not dry_run and cached.get("dry_run"):
            reusable = False
        if reusable:
            skipped += 1
            continue

        public_id = f"{PUBLIC_PREFIX}/{slug}.pdf"
        slide_count = _page_count(local)

        if dry_run:
            secure_url = (f"https://res.cloudinary.com/{cloud}/raw/upload/"
                          f"{public_id}")
        else:
            res = uploader.upload(
                str(local), resource_type="raw", public_id=public_id,
                overwrite=False, unique_filename=False, use_filename=False)
            secure_url = res["secure_url"]
            uploaded += 1

        cache[slug] = {"secure_url": secure_url, "slide_count": slide_count,
                       "hash": digest, "dry_run": dry_run}

    dump_build(CACHE, cache)
    print(f"cloudinary: {uploaded} uploaded, {skipped} cached, "
          f"{len(cache)} total {'(DRY RUN)' if dry_run else ''}")
    return cache


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true",
                    help="no network; predict URLs and count pages only")
    build(**vars(ap.parse_args()))
