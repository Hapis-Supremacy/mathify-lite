package com.mathify.servlet.admin;

import com.mathify.dao.CourseDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

/**
 * Create / edit / delete chapters, modules and quizzes within a course, then
 * return to the content editor. Dispatched by the {@code entity} parameter
 * (chapter|module|quiz) and {@code action} (create|update|delete).
 */
@WebServlet("/admin/content-action.do")
public class AdminContentActionServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String entity = req.getParameter("entity");
        String action = req.getParameter("action");
        String courseId = req.getParameter("courseId");

        String editorUrl = (courseId != null && !courseId.isEmpty())
                ? req.getContextPath() + "/admin/editor.do?c=" + courseId
                : req.getContextPath() + "/admin/courses.do";

        if (entity == null || action == null) {
            resp.sendRedirect(editorUrl);
            return;
        }

        try {
            switch (entity) {
                case "chapter" -> handleChapter(req, action);
                case "module" -> handleModule(req, action);
                case "quiz" -> handleQuiz(req, action);
                default -> { /* unknown entity: no-op */ }
            }
        } catch (SQLIntegrityConstraintViolationException fk) {
            // Student progress / attempts reference this content (ON DELETE RESTRICT).
            resp.sendRedirect(editorUrl + "&error=in_use");
            return;
        } catch (SQLException e) {
            getServletContext().log("Error executing content action: " + entity + "/" + action, e);
            resp.sendRedirect(editorUrl + "&error=server_error");
            return;
        }

        resp.sendRedirect(editorUrl);
    }

    private void handleChapter(HttpServletRequest req, String action) throws SQLException {
        switch (action) {
            case "create" -> courseDAO.createChapter(
                    req.getParameter("courseId"),
                    trim(req.getParameter("title")),
                    trim(req.getParameter("description")),
                    parseInt(req.getParameter("xpReward"), 0),
                    parseInt(req.getParameter("orderIndex"), 0));
            case "update" -> courseDAO.updateChapter(
                    req.getParameter("chapterId"),
                    trim(req.getParameter("title")),
                    trim(req.getParameter("description")),
                    parseInt(req.getParameter("xpReward"), 0),
                    parseInt(req.getParameter("orderIndex"), 0));
            case "delete" -> courseDAO.deleteChapter(req.getParameter("chapterId"));
            default -> { }
        }
    }

    private void handleModule(HttpServletRequest req, String action) throws SQLException {
        String type = req.getParameter("moduleType");
        Integer duration = parseNullableInt(req.getParameter("durationSecs"));
        Integer slides = parseNullableInt(req.getParameter("slideCount"));
        // Enforce the schema CHECK: VIDEO needs a duration, SLIDE needs a slide count.
        if ("VIDEO".equals(type) && duration == null) duration = 0;
        if ("SLIDE".equals(type) && slides == null) slides = 1;

        switch (action) {
            case "create" -> courseDAO.createModule(
                    req.getParameter("chapterId"),
                    trim(req.getParameter("title")),
                    type,
                    trim(req.getParameter("contentUrl")),
                    duration,
                    slides,
                    parseInt(req.getParameter("orderIndex"), 0));
            case "update" -> courseDAO.updateModule(
                    req.getParameter("moduleId"),
                    trim(req.getParameter("title")),
                    type,
                    trim(req.getParameter("contentUrl")),
                    duration,
                    slides,
                    parseInt(req.getParameter("orderIndex"), 0));
            case "delete" -> courseDAO.deleteModule(req.getParameter("moduleId"));
            default -> { }
        }
    }

    private void handleQuiz(HttpServletRequest req, String action) throws SQLException {
        switch (action) {
            case "create" -> courseDAO.createQuiz(
                    req.getParameter("chapterId"),
                    trim(req.getParameter("title")),
                    parseInt(req.getParameter("passingScore"), 0));
            case "update" -> courseDAO.updateQuiz(
                    req.getParameter("quizId"),
                    trim(req.getParameter("title")),
                    parseInt(req.getParameter("passingScore"), 0));
            case "delete" -> courseDAO.deleteQuiz(req.getParameter("quizId"));
            default -> { }
        }
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static int parseInt(String value, int fallback) {
        if (value == null || value.isBlank()) return fallback;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private static Integer parseNullableInt(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
