# CLAUDE.md

Guidance for Claude Code (and other agents) working in this repository.

## Project

**Mathify Lite** — a Java servlet web application for a gamified math learning
platform (courses, modules, quizzes, achievements, streaks, premium plans).
It is built as a WAR and runs on Tomcat 10.1 (Jakarta Servlet 6.0).

## Tech stack

- **Java 17**, Maven (`pom.xml`), packaged as a **WAR** (`mathify-lite`).
- **Jakarta Servlet 6.0** (`jakarta.servlet`, *not* `javax.servlet`).
- **JSP** for all views — plain JSP, no JSTL or templating framework.
- **MySQL** via `mysql-connector-j` and raw JDBC (`java.sql.*`).
- **Bootstrap 5.3** + Bootstrap Icons + Google Fonts, loaded from CDN.
- JUnit 4 for tests.

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

## Database

- Schema lives in **`mathify_schema.sql`** (repo root); database name `mathify_db`.
- Connection settings are in **`src/main/resources/db.properties`**
  (`db.url`, `db.user`, `db.password`), read once by
  `com.mathify.db.DBUtil` which exposes `DBUtil.getConnection()`.
- Default config expects a local MySQL at `localhost:3306`, user `root`, empty
  password. Do **not** commit real credentials.

## Layout

```
src/main/java/com/mathify/
  db/       DBUtil            — JDBC connection factory (reads db.properties)
  dao/      UserDAO           — data access (PreparedStatements, returns models)
  model/    35 domain classes — User/Student/Admin, Course/Chapter/Topic,
                                quizzes & questions, progress, achievements…
  servlet/  LoginServlet  (/login),  RegisterServlet (/register)
src/main/webapp/
  WEB-INF/web.xml             — servlet mappings + welcome files
  index.jsp                   — entry; redirects to student/dashboard.jsp
  login.jsp, register.jsp     — auth pages (POST to /login, /register)
  student/*.jsp               — dashboard, catalog, course, module, quiz,
                                achievements, premium
  admin/*.jsp                 — dashboard, courses, editor, quiz-editor, students
  assets/css/app.css          — shared styles
  assets/js/app.js            — injects the shared navbar/header into every page
src/main/resources/db.properties
mathify_schema.sql            — MySQL schema
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
- Servlets are registered in `web.xml` (no annotations). Add new servlets there.
- DAO methods throw `SQLException`; servlets catch it, log via
  `getServletContext().log(...)`, and redirect with an `?error=...` query param
  that the target JSP reads client-side to show an alert banner.
- `target/` is build output — never edit files there; edit `src/`.
