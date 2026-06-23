# Architecture

How Mathify Lite is put together. For setup/run instructions see
[README.md](README.md); for repository conventions and gotchas see
[AGENTS.md](.agents/AGENTS.md) (`CLAUDE.md` just imports it for Claude Code).

## Stack

Java 17, Jakarta Servlet 6.0, plain JSP views (no JSTL/templating logic in
the views beyond static markup), MySQL via raw JDBC, packaged as a WAR and
run on Tomcat 10.1 (via the Cargo Maven plugin in dev).

## Request flow

```
Browser → Tomcat → [Filter] → Servlet (*.do) → DAO → DBUtil → MySQL
                                   ↓
                          forward/redirect → JSP (view)
```

- **Servlets** are mapped either declaratively in `web.xml` (`LoginServlet`
  at `/login`, `RegisterServlet` at `/register`) or via `@WebServlet`
  annotations (everything under `/student/*.do` and `/admin/*.do`). The two
  mechanisms are never combined for the same servlet — see the "Avoid
  Duplicate Mappings" gotcha in AGENTS.md.
- **Filters** (`@WebFilter`) gate the `/student/*` and `/admin/*` paths:
  `StudentAuthFilter` and `AdminAuthFilter` check the session first, then
  fall back to the persistent auth cookie, then redirect to login if neither
  is valid. A student hitting an admin-only path (or vice versa) is bounced
  to their own dashboard rather than rejected outright.
- **DAOs** (`com.mathify.dao`) wrap JDBC `PreparedStatement` calls and return
  populated model objects. They throw `SQLException`; servlets catch it, log
  via `getServletContext().log(...)`, and redirect with a `?error=...` query
  param that the JSP reads to render an alert banner.
- **Views** are plain JSP — `student/*.jsp` and `admin/*.jsp` — with no
  scriptlets/EL in the current pages. Shared navbar/header chrome is not in
  the markup; `assets/js/app.js` builds it at runtime from `data-role` /
  `data-page` / `data-base` attributes on `<body>`.

## Auth

- `com.mathify.util.AuthUtil` issues a long-lived cookie
  (`mathify_auth`, 30 days) containing `base64(userId:SHA256(userId+secret))`.
  This is a bearer-style "remember me" token, not session crypto — the
  session itself just stores `userId`/`userName`/`userRole` attributes.
- On each request to a guarded path, the relevant `*AuthFilter` checks the
  `HttpSession` first; if absent, it validates the cookie, re-establishes
  the session from the DB (`UserDAO.getAdminById`/`getStudentById`), and
  continues.
- `LoginServlet` sets the session + cookie on success; `LogoutServlet`
  clears both.

## Navigation / loading screens

Forward-moving transitions (successful login, opening a course, etc.) go
through `com.mathify.util.NavigationUtil.redirectWithLoading(req, resp, url,
message)`, which forwards to `/loading.jsp` with the real destination and a
status message as request attributes; the JSP then client-side-redirects.
Plain validation-error paths (bad password, missing field) use a normal
`response.sendRedirect()` back to the form instead — no loading screen. See
[DESIGN.md](DESIGN.md) for the loading-screen visual prototype this was
built from.

## Data layer

- `com.mathify.db.DBUtil` is a static connection factory: loads the MySQL
  driver once, reads `src/main/resources/db.properties`, and hands out a new
  `Connection` per call via `DriverManager`. There is no pooling.
- `com.mathify.db.DBUpdater` — standalone task for applying schema/data
  updates outside the normal app lifecycle (see its source for current
  scope).
- Schema lives in `database/mathify_schema.sql` (UUID/`CHAR(36)` primary
  keys, InnoDB, `utf8mb4`); seed data in `database/insert_admin.sql` and
  `database/insert_course_1.sql`.

## Domain model

`com.mathify.model` mirrors the database schema as plain Java objects:
`User` → `Student`/`Admin` (with `PremiumStudent` for paid plans),
`Course` → `Chapter` → `Topic`/`LearningModule` (`VideoModule`,
`SlideModule`) and `Quiz` → `Question` (`MultipleChoiceQuestion`,
`FillBlankQuestion`, `DragDropQuestion`, each with a matching `Answer`
subtype), plus progress/reporting types (`UserProgress`,
`ChapterProgress`, `QuizAttempt`, `Achievement`, `ReportMetric`,
`Notification`). The original UML class diagram this was modeled from is
[`CLASS_DIAGRAM.json`](CLASS_DIAGRAM.json) (see [DESIGN.md](DESIGN.md)).