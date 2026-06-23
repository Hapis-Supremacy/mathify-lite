# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, etc.) working in this repository.
This is the canonical rules file — `CLAUDE.md` at the repo root just imports it, so
edit this file, not that one.

## General Guidelines
These are common instructions across all scenarios.
- Never use the em dash "—". Use plain dash "-" instead.
- When writing commit messages, NEVER auto-add your agent name as co-author.
- Never manually modify any files that are marked as auto-generated.
- When writing or substantially editing long Markdown files, put each full sentence on its own line. Preserve normal Markdown structure, but avoid wrapping multiple sentences onto one physical line.
- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user experiences it. This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection. If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way. Apply that same high standard to engineering excellence: lint, test failures, and test flakiness. If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Before committing, make sure `.env.example` is aligned with `.env`, since people tend to forget updating `.env.example`. Whenever you add, rename, or remove a key in `.env`, mirror the change in `.env.example` with a placeholder value (never a real secret) and a brief comment. The two files should always have the same set of keys.

## Related docs

- [README.md](../README.md) — setup & how to run the project
- [ARCHITECTURE.md](../ARCHITECTURE.md) — request flow, auth, data layer, build/deploy
- [DESIGN.md](../DESIGN.md) — index of the visual mockups and UML diagram in `design/`

## Project

**Mathify Lite** — a Java servlet web application for a gamified math learning
platform (courses, modules, quizzes, achievements, streaks, premium plans).
It is built as a WAR and runs on Tomcat 10.1 (Jakarta Servlet 6.0).

Tech stack and data-layer details live in [ARCHITECTURE.md](../ARCHITECTURE.md)
(Stack / Data layer sections) — not repeated here to avoid drift.

## Build & run

```bash
mvn package cargo:run     # build the WAR and launch embedded Tomcat 10.1
```

Then open **http://localhost:8080/** (the app is deployed at context path `/`).
Cargo downloads Tomcat automatically on first run into `target/`.

```bash
mvn compile               # compile Java only
mvn package               # build target/mathify-lite.war
```

## Layout

```
src/main/java/com/mathify/
  db/       DBUtil, DBUpdater          — JDBC connection factory + schema/data bootstrap
  dao/      UserDAO, CourseDAO, ProgressDAO — data access (PreparedStatements, returns models)
  model/    36 domain classes — User/Student/Admin, Course/Chapter/Topic,
                                quizzes & questions, progress, achievements…
  util/     AuthUtil, NavigationUtil  — session/auth helpers; NavigationUtil.redirectWithLoading()
                                        for forward navigation (see below)
  servlet/  LoginServlet (/login), RegisterServlet (/register), LogoutServlet
            servlet/student/  CourseCatalogServlet, StudentDashboardServlet, CourseDetailServlet
            servlet/admin/    AdminStudentsServlet, AdminStudentActionServlet
            servlet/filter/   StudentAuthFilter, AdminAuthFilter
src/main/webapp/
  WEB-INF/web.xml             — only LoginServlet/RegisterServlet + welcome files;
                                everything else under servlet/ uses @WebServlet/@WebFilter
  index.jsp                   — entry; redirects to student/dashboard.jsp
  login.jsp, register.jsp     — auth pages (POST to /login, /register)
  loading.jsp                 — interstitial screen used by NavigationUtil.redirectWithLoading()
  student/*.jsp               — dashboard, catalog, course, module, quiz,
                                achievements, premium
  admin/*.jsp                 — dashboard, courses, editor, quiz-editor, students
  assets/css/app.css          — shared styles
  assets/js/app.js            — injects the shared navbar/header into every page
src/main/resources/db.properties
database/mathify_schema.sql    — MySQL schema
```

## Conventions & gotchas

- **Views are JSP, not HTML.** All pages use the `.jsp` extension and start with
  `<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>`.
  When adding a page or linking between pages, always reference `.jsp`.
- The current JSPs are essentially static markup (no scriptlets/EL). If you add
  dynamic JSP, beware that literal `<%` and `${...}` in inline `<script>`/`<style>`
  are interpreted by the JSP engine — escape them (`<\%`, `\${`) or use
  `<%@ page isELIgnored="true" %>` where appropriate.
- Navigation chrome is **not** in the page markup — `assets/js/app.js` builds the
  navbar at runtime from `data-role` / `data-page` / `data-base` attributes on
  `<body>`. Update `app.js` when adding nav destinations, not each page.
- Use the **Jakarta** namespace (`jakarta.servlet.*`). Never `javax.servlet.*`.
- **Avoid duplicate servlet mappings:** most servlets/filters use `@WebServlet`/
  `@WebFilter` annotations, not `web.xml`. Only `LoginServlet` and
  `RegisterServlet` are registered in `web.xml` (legacy). Do NOT add a
  `web.xml` mapping for a class that already has a `@WebServlet`/`@WebFilter`
  annotation — Tomcat will crash on startup and the whole app 404s.
- **Context path:** `cargo-maven3-plugin` deploys at the root context
  (`<context>/</context>`), so the app is at `http://localhost:8080/`, not
  `http://localhost:8080/mathify-lite/`. Account for this when pinging URLs.
- **Static asset caching:** browsers aggressively cache `.js`/`.css`. If an
  endpoint works but the UI looks stale, suspect a cached asset before
  assuming the backend is broken. Append a cache-busting query param (e.g.
  `app.js?v=2`) whenever you update a static asset.
- **Loading screens for forward navigation:** for forward-moving transitions
  (successful login, going to the dashboard, loading catalog items, etc.) use
  `com.mathify.util.NavigationUtil.redirectWithLoading(req, resp, url, message)`
  instead of `response.sendRedirect()`. Reserve plain `sendRedirect()` for
  validation errors (missing fields, wrong password) where the user expects
  an instant flash back to the form they just submitted.
- DAO methods throw `SQLException`; servlets catch it, log via
  `getServletContext().log(...)`, and redirect with an `?error=...` query param
  that the target JSP reads client-side to show an alert banner.
- `target/` is build output — never edit files there; edit `src/`.
- **DB config:** never commit real credentials to `src/main/resources/db.properties`
  — see README.md's "Configure the connection" step for local defaults.

## Database and schema gotchas

DAO queries assume columns that were not always present in `database/mathify_schema.sql`.
A missing column surfaces as a `?error=server_error` redirect on login or register: the DAO throws `SQLSyntaxErrorException` and the servlet catches it.
A known case is `users.is_disabled BOOLEAN NOT NULL DEFAULT FALSE`, used by the admin "disable student" feature.
When you add a column in a DAO, add it to `database/mathify_schema.sql` and a `database/migration_*.sql` as well.
XAMPP ships its own Tomcat on port 8080; if `cargo:run` reports "Port 8080 in use", stop XAMPP's Tomcat (only MySQL is needed from XAMPP).

## Payments (Midtrans)

The "Go Premium" upgrade uses the Midtrans Snap flow, sandbox by default.
Credentials come from a gitignored `.env` at the project root, read by `com.mathify.util.MidtransConfig` (`MIDTRANS_SERVER_KEY`, `MIDTRANS_CLIENT_KEY`, `MIDTRANS_MERCHANT_ID`, `MIDTRANS_IS_PRODUCTION`, `MIDTRANS_PRICE_MONTHLY`, `MIDTRANS_PRICE_YEARLY`); OS env vars override the file.
Never hard-code keys; see `.env.example`.
The server is the source of truth: `PremiumCheckoutServlet` (`/student/premium/checkout.do`) creates the Snap token with a server-side fixed amount, and `PremiumConfirmServlet` (`/student/premium/confirm.do`) re-verifies the transaction status with Midtrans before granting premium.
Never trust the browser's success callback or a client-supplied amount.
The HTTP calls live in `com.mathify.service.MidtransService` (Basic auth = `Base64(serverKey + ":")`).
There are two plans, selected via the `plan` request parameter: monthly (Rp 125.500, 30 days) and yearly (Rp 1.224.500, 365 days).
Plan prices are env-driven via `MIDTRANS_PRICE_MONTHLY` / `MIDTRANS_PRICE_YEARLY` (those rupiah amounts are the defaults), resolved server-side in `PremiumCheckoutServlet.resolvePlan`; the durations are fixed in code.
No webhook is needed on localhost: activation happens in `confirm.do` via a status check; for production, also configure a Midtrans notification URL.
Premium is persisted by `com.mathify.dao.SubscriptionDAO` into the `subscriptions` table; tracking columns `midtrans_order_id` and `payment_status` were added (see `database/migration_add_payment_tracking.sql`).
Admins can manually grant or revoke premium from the Students page via the `grant_premium` and `revoke_premium` actions, as an override.
The navbar premium badge, energy, and XP come from `GET /student/profile.do` (`StudentProfileServlet`), fetched by `app.js`; JSON is built and parsed with `org.json` (in `pom.xml`).
For testing, the quickest path is card `4811 1111 1111 1114`, CVV `123`, OTP `112233`.
Sandbox QRIS QR codes cannot be scanned by real apps; use the Midtrans simulator at `https://simulator.sandbox.midtrans.com/`.
