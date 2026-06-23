package com.mathify.servlet.student;

import com.mathify.dao.ProgressDAO;
import com.mathify.util.NavigationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Handles a student explicitly enrolling in or leaving a course. POST-only so
 * the state change follows the Post/Redirect/Get pattern: enrolling forwards
 * into the course, unenrolling returns to the catalog.
 */
@WebServlet("/student/enroll.do")
public class EnrollmentServlet extends HttpServlet {

    private final ProgressDAO progressDAO = new ProgressDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String studentId = (String) req.getSession().getAttribute("userId");
        String courseId = req.getParameter("courseId");
        String action = req.getParameter("action");

        String catalog = req.getContextPath() + "/student/catalog.do";

        if (studentId == null || courseId == null || courseId.isEmpty()) {
            resp.sendRedirect(catalog + "?error=invalid_request");
            return;
        }

        try {
            if ("unenroll".equals(action)) {
                progressDAO.unenrollCourse(studentId, courseId);
                NavigationUtil.redirectWithLoading(req, resp, catalog, "Updating your courses...");
            } else {
                progressDAO.enrollCourse(studentId, courseId);
                NavigationUtil.redirectWithLoading(req, resp,
                        req.getContextPath() + "/student/course.do?id=" + courseId, "Opening your course...");
            }
        } catch (SQLException e) {
            getServletContext().log("Error updating enrollment", e);
            resp.sendRedirect(catalog + "?error=server_error");
        }
    }
}
