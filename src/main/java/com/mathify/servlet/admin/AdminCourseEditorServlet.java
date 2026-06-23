package com.mathify.servlet.admin;

import com.mathify.dao.CourseDAO;
import com.mathify.model.AdminChapterDTO;
import com.mathify.model.Course;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/** Renders the content editor for one course (chapters + modules + quizzes). */
@WebServlet("/admin/editor.do")
public class AdminCourseEditorServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String courseId = req.getParameter("c");
        if (courseId == null || courseId.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/courses.do");
            return;
        }
        try {
            Course course = courseDAO.getCourseById(courseId);
            if (course == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/courses.do?error=not_found");
                return;
            }
            List<AdminChapterDTO> chapters = courseDAO.getCourseEditorChapters(courseId);
            req.setAttribute("course", course);
            req.setAttribute("chapters", chapters);
            req.setAttribute("editorLoaded", true);
            req.getRequestDispatcher("/admin/editor.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("DB error loading course editor", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading course.");
        }
    }
}
