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

/** Create / edit / delete a course, then return to the Courses list. */
@WebServlet("/admin/course-action.do")
public class AdminCourseActionServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String coursesUrl = req.getContextPath() + "/admin/courses.do";

        if (action == null) {
            resp.sendRedirect(coursesUrl);
            return;
        }

        try {
            switch (action) {
                case "create": {
                    String title = trim(req.getParameter("title"));
                    String category = trim(req.getParameter("category"));
                    String description = trim(req.getParameter("description"));
                    if (title.isEmpty() || category.isEmpty()) {
                        resp.sendRedirect(coursesUrl + "?error=missing_fields");
                        return;
                    }
                    courseDAO.createCourse(title, category, description);
                    break;
                }
                case "update": {
                    String courseId = req.getParameter("courseId");
                    String title = trim(req.getParameter("title"));
                    String category = trim(req.getParameter("category"));
                    String description = trim(req.getParameter("description"));
                    if (courseId == null || title.isEmpty() || category.isEmpty()) {
                        resp.sendRedirect(coursesUrl + "?error=missing_fields");
                        return;
                    }
                    courseDAO.updateCourse(courseId, title, category, description);
                    break;
                }
                case "delete": {
                    String courseId = req.getParameter("courseId");
                    if (courseId != null) {
                        try {
                            courseDAO.deleteCourse(courseId);
                        } catch (SQLIntegrityConstraintViolationException fk) {
                            // Enrollments / progress reference this course (ON DELETE RESTRICT).
                            resp.sendRedirect(coursesUrl + "?error=course_in_use");
                            return;
                        }
                    }
                    break;
                }
                default:
                    break;
            }
        } catch (SQLException e) {
            getServletContext().log("Error executing course action: " + action, e);
            resp.sendRedirect(coursesUrl + "?error=server_error");
            return;
        }

        resp.sendRedirect(coursesUrl);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
