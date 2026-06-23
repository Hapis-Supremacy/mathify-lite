---
name: commit-style
description: Use when drafting a git commit message in this repository, so the message matches the project's existing commit history conventions.
---

# Commit message style for mathify-lite

Match the format already used in `git log` for this repo. Before drafting,
run `git log -10 --format="%s"` and `git log -3 --format="%B"` to confirm
the style hasn't drifted, then follow these rules.

## Subject line

`type(scope): summary`

- `type` is a Conventional Commits type: `feat`, `fix`, `chore`, `docs` are
  the ones seen so far in this repo. Pick whichever fits; don't invent new
  types if an existing one applies.
- `scope` is optional and lowercase, usually a layer or area name:
  `admin`, `auth`, `db`, `model`, `infra`, `ui`, `design`, or a
  slash-combo like `auth/admin` or `ui/client` when the change spans two
  areas.
- `summary` is imperative/present-tense ("add", "implement", "drop",
  "consolidate", "harden"), no trailing period, no capitalized first
  word requirement beyond normal sentence case.
- No hard length cap has been enforced in this repo (one subject line ran
  over 100 chars), but prefer to stay under ~72 chars when the change is
  simple. Only let it run long if shortening would lose real information.

## Body

- Blank line, then a body paragraph wrapped at ~72 columns (standard git
  wrap width) - regular prose, NOT one-sentence-per-line. The
  one-sentence-per-line rule in AGENTS.md applies to Markdown docs, not
  commit messages.
- Lead with *why* the change was made (the problem, gap, or motivation),
  then *what* changed at a summary level. Don't restate the diff
  line-by-line - the diff already shows that.
- Small, self-evident commits (simple file moves, single-purpose
  additions) can skip the body entirely and have just a subject line.
  Only add a body when there's non-obvious context worth recording.
- Wrap manually; don't rely on terminal wrapping.

## Hard rules (from AGENTS.md, always apply)

- Never use an em dash "—"; use a plain dash "-" instead.
- Never add an agent name as co-author (no `Co-Authored-By: Claude ...`
  or similar) unless the user explicitly asks for it.
- Use the repo's actual git user for authorship - don't override it.

## Example (real commit from this repo)

```
chore(design): drop duplicate UML export, point docs at CLASS_DIAGRAM.json

design/uploads/Mathify.json was byte-identical to the root
CLASS_DIAGRAM.json and wasn't referenced by anything. Keep the single
root copy and update DESIGN.md/ARCHITECTURE.md to point at it.
```

## Workflow

1. Run `git status` and `git diff` (or `git diff --staged`) to see what's
   actually changing.
2. Stage the relevant files explicitly (avoid `git add -A`/`.`).
3. Draft subject + body following the rules above.
4. Commit with a heredoc to preserve line breaks exactly:

```bash
git commit -m "$(cat <<'EOF'
type(scope): summary

Body paragraph wrapped at ~72 columns explaining why, then what.
EOF
)"
```

5. Only commit when the user explicitly asked for a commit.
