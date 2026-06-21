# Project Rules and Knowledge

## Servlet Mappings and Deployment
- **Avoid Duplicate Mappings:** Do NOT map a servlet in `web.xml` if it already has a `@WebServlet` annotation. Doing so will cause Tomcat to crash during startup and result in 404s for the entire application.
- **Context Path:** The `cargo-maven3-plugin` in this project is configured to deploy at the root context (`<context>/</context>`). This means the application is accessible at `http://localhost:8080/`, not `http://localhost:8080/mathify-lite/`. Always account for this when manually pinging URLs or debugging routing.
- **Browser Caching:** When modifying static assets like `.js` files or static links, remember that browsers aggressively cache them. If an endpoint is functioning correctly but the UI is misbehaving, suspect a cached `.js` file before assuming the backend or deployment is broken.
