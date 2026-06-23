---
name: e2e-testing
description: Use when end-to-end testing Mathify Lite against a running server (build, bring up MySQL + Tomcat, drive real HTTP sessions with curl, assert side effects against the DB, then clean up), so you reuse the auth contracts and process gotchas that already work instead of rediscovering them.
---

# End-to-end testing Mathify Lite

The product is a servlet app, so the only honest test is over real HTTP against a
running Tomcat with the real MySQL behind it.
This skill is the playbook for that: bring the stack up, drive each flow with
`curl` and a cookie jar (a real session, exactly how a browser hits it), assert
the side effects in the database, then tear down cleanly.
`helpers.sh` (next to this file) encodes the parts that are easy to get wrong -
the auth field names, the assertion harness, and the teardown.

## When to use

Use this when verifying a feature or a merge end to end: admin course/quiz CRUD,
student catalog/course/module/quiz flow, gamification (XP/streak/energy),
achievements, premium, or a regression check after pulling someone else's branch.
Per AGENTS.md, reproduce the bug or feature as a real user experiences it (HTTP +
session + DB), not via a unit-test shortcut.
Unit tests (`mvn test`) still run, but they only cover `util/` helpers - they do
not exercise servlets, JSPs, DAOs, or the schema.

## The shape of every run

1. Build, bring up MySQL + Tomcat, wait until it answers.
2. Open a session (admin or a throwaway student) into a cookie jar.
3. Hit the endpoint, then assert the DB changed the way it should (count before
   vs after, cascade deletes, correct-flag, etc.) and/or the HTML rendered the
   expected markup.
4. Delete throwaway data, stop Tomcat, leave MySQL running.

Drive it from a Bash shell (Git Bash), not PowerShell - the harness is bash.
`source .claude/skills/e2e-testing/helpers.sh` and use its functions.

## 1. Bring up the stack

```bash
mvn -o clean package                 # 77 sources + unit tests + WAR; must be green first
# MySQL: XAMPP's mysqld on :3306 (start it from XAMPP if down). Creds: root / no password.
nohup mvn -o cargo:run > /tmp/cargo.log 2>&1 &   # see gotcha below about this "finishing"
source .claude/skills/e2e-testing/helpers.sh
wait_up                              # polls /login.jsp until 200
```

## 2. Auth contracts (these are the field names that actually work)

The login/register field names are NOT what you'd guess, and a wrong name fails
silently (you get bounced to login and the page title is `Loading - Mathify`).

- Admin login: `POST /login` with `email`, `password`.
  Seeded admin is `admin@mathify.com` / `admin123` (from
  `database/insert_admin.sql` - a documented demo default, not a secret).
- Register: `POST /register` with `fullName`, `email`, `password`, `terms=on`.
  NOT `name`, NOT `confirmPassword`. Missing `terms` -> `error=terms_required`.
- Session is a `JSESSIONID` cookie; capture it with `curl -c jar` on login and
  send it with `curl -b jar` afterwards.
- Successful login/register returns the `loading.jsp` interstitial (forward
  navigation via `NavigationUtil.redirectWithLoading`), but the session cookie is
  still set on that response - the jar is valid.
- Auth filters gate paths: `/admin/*` needs an ADMIN session, `/student/*` needs
  a STUDENT session. Hitting one with the wrong (or no) session redirects to
  login.

Use the helpers instead of hand-rolling these:

```bash
login_admin   /tmp/admin.jar
new_student   /tmp/stu.jar  "e2e_$$@test.local"  "test1234"   # registers + logs in
```

## 3. Drive and assert

Assert against the DB - that is the source of truth, not the HTTP status.
Capture a baseline count, act, re-count. Example (the quiz-CRUD check):

```bash
QUIZ=...; COURSE=...
before=$(db_scalar "SELECT COUNT(*) FROM questions WHERE quiz_id='$QUIZ';")
curl -s -b /tmp/admin.jar -o /dev/null \
  --data-urlencode action=create_question --data-urlencode quizId=$QUIZ \
  --data-urlencode courseId=$COURSE --data-urlencode qType=MULTIPLE_CHOICE \
  --data-urlencode "prompt=E2E TEST: 2+2?" --data-urlencode points=5 --data-urlencode orderIndex=99 \
  --data-urlencode mcOptionText=3 --data-urlencode mcOptionText=4 --data-urlencode mcCorrectIndex=1 \
  "$BASE/admin/quiz-action.do"
chk "question created" "$(db_scalar "SELECT COUNT(*) FROM questions WHERE quiz_id='$QUIZ';")" "$((before+1))"
```

Also assert the rendered HTML when the change is user-visible (`curl -b jar -o
out.html "$BASE/..."` then `chk_grep`/`chk_missing` on `out.html`) - e.g. a slide
module must contain `<iframe` and must NOT contain `slides placeholder`.

Tag every row you create with an `E2E ` prompt/title prefix and every throwaway
student with an `e2e_` email, so `cleanup_test_data` can find and delete them.

End with `summary` (prints totals, exits non-zero if any `chk` failed).

### Endpoint quick-reference (what the servlets expect)

- `GET  /admin/courses.do` - course list.
- `GET  /admin/editor.do?c=<courseId>` - chapter/module/quiz editor for a course.
- `POST /admin/content-action.do` - `entity=chapter|module|quiz` x
  `action=create|update|delete` (redirects back to `editor.do?c=`).
- `GET  /admin/quiz-editor.do?q=<quizId>&c=<courseId>` - question editor.
- `POST /admin/quiz-action.do` - `action=create_question|delete_question`;
  create needs `quizId`, `courseId`, `qType` (`MULTIPLE_CHOICE` /
  `FILL_BLANK` / `DRAG_AND_DROP`), `prompt`, `points`, `orderIndex` plus
  per-type fields (`mcOptionText[]`+`mcCorrectIndex[]`; `fbAnswer[]`+optional
  `caseSensitive=on`; `ddDrag[]`+`ddDrop[]`). No update action - edit = delete +
  recreate.
- `GET  /student/dashboard.do`, `/student/catalog.do`, `/student/course.do?id=`,
  `/student/module.do?m=<moduleId>`.
- Quiz flow: `GET /student/quiz.do?q=<quizId>` starts it (session-held); per
  question `POST` the answer then `POST action=next`; finishing records the
  attempt and syncs XP/streak/energy.

## 4. Tear down

```bash
cleanup_test_data     # deletes e2e_ users (cascade) and 'E2E ' questions
stop_tomcat           # kills the :8080 Tomcat AND the orphaned mvn launcher
```

Leave XAMPP's `mysqld` running - the user manages it from XAMPP; do not kill it.

## Process gotchas (these wasted time before)

- `nohup mvn cargo:run &` (or `run_in_background`) reports the *launcher shell* as
  "completed" almost immediately, while Tomcat keeps running detached. Don't
  conclude it crashed - check `/login.jsp` (or `wait_up`). The cargo log ending
  in "Press Ctrl-C to stop the container..." means it is up.
- Killing the Tomcat java by port leaves the parent `mvn cargo:run` JVM
  (recognizable by `plexus-classworlds` on its command line) hung. `stop_tomcat`
  kills both; otherwise you leak a maven process every run.
- Context path is root: the app is `http://localhost:8080/`, NOT
  `/mathify-lite/`.
- A response titled `Loading - Mathify` where you expected real content means the
  request was unauthenticated and got redirected to login - your session/jar or a
  login field name is wrong (see section 2), it is not a server bug.
- mysql client output on Windows carries `\r`; `db_scalar` strips whitespace,
  `db` strips `\r` - use `db_scalar` for counts/IDs you compare with `chk`.
- Browsers cache `app.js`/`app.css` hard. If the UI looks stale but the endpoint
  works, bump the `?v=` query param rather than chasing a phantom backend bug.

## Verify (sanity for the harness itself)

A green run looks like: `mvn package` BUILD SUCCESS with unit tests passing, then
each flow's `summary` reporting `N passed, 0 failed`, then `cleanup_test_data`
reporting 0 leftover `e2e_` users on a re-check, then `stop_tomcat` reporting
`port 8080 free`.
